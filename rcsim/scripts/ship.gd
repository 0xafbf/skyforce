extends Model
class_name Airplane

@export var thrust_scale: float = 10

@export var lift_scale: float = 0.1
@export var drag_scale: float = 0.1

@export var gl_path: NodePath
@onready var gl: Node # ImmediateMesh = get_node(gl_path)

@onready var aileron_l = $AileronLPivot
@onready var aileron_r = $AileronRPivot
@onready var pivot_rudder = $RudderPivot
@onready var pivot_elevator = $ElevatorPivot
@onready var thruster_visual = $ThrusterPivot/Helice

@onready var stabilizer_vert = $StabilizerVertical
@onready var stabilizer_horz = $StabilizerHorizontal
@export var stabilizer_horz_influence: float = 1
@export var stabilizer_vert_influence: float = 1
@onready var wings = $Wings

@export var aileron_rate: float = 20
@export var rudder_rate: float = 20
@export var elevator_rate: float = 20

@export var roll_torque: float = 1
@export var pitch_torque: float = 1
@export var yaw_torque: float = 1

@export var thruster_angular_speed: float = 1000

var in_yaw: float = 0
var in_roll: float = 0
var in_pitch: float = 0
var in_thrust: float = 0

var thrust_cumulative: float = 0


func _process(delta):

	aileron_l.rotation_degrees.x = in_roll * aileron_rate
	aileron_r.rotation_degrees.x = -in_roll * aileron_rate

	pivot_rudder.rotation_degrees.y = in_yaw * rudder_rate
	pivot_elevator.rotation_degrees.x = in_pitch * elevator_rate

	thrust_cumulative += in_thrust * delta
	thruster_visual.rotation_degrees.z = thrust_cumulative * thruster_angular_speed


var thrust_vector: Vector3
var lift_vector: Vector3


func get_relative_pos(target: Node3D) -> Vector3:
	return target.global_transform.origin - global_transform.origin

func _physics_process(_delta):
	var tx_basis := transform.basis
	var forward: Vector3 = tx_basis * Vector3.FORWARD
	var up: Vector3      = tx_basis * Vector3.UP
	var right: Vector3   = tx_basis * Vector3.RIGHT

	var thrust_mag = in_thrust * thrust_scale
	thrust_vector = thrust_mag * forward
	#print("adding force:%s" % thrust_vector)
	apply_force(thrust_vector, get_relative_pos(thruster_visual))

	var velocity = linear_velocity
	var velocity_forward = velocity.dot(forward)


	var drag = velocity * drag_scale * -1
	apply_force(drag)

	var remaining_velocity = (1.0 - drag_scale) * velocity_forward

	var wing_up = wings.global_transform.basis * Vector3.UP
	var wing_influence = wing_up.dot(-velocity)
	lift_vector = lift_scale * wing_up * wing_influence * remaining_velocity

	apply_force(lift_vector)

	var torque_amount = velocity_forward * in_roll * roll_torque
	var torque: Vector3 = torque_amount * forward
	apply_torque(torque)

	torque_amount = velocity_forward * in_pitch * pitch_torque
	torque = -torque_amount * right
	apply_torque(torque)

	torque_amount = velocity_forward * in_yaw * yaw_torque
	torque = -torque_amount * up
	apply_torque(torque)

	var stabilizer_horz_mag = stabilizer_horz_influence * velocity.dot(right)
	var stabilizer_vert_mag = stabilizer_vert_influence * velocity.dot(up)

	apply_force(-stabilizer_horz_mag * right, get_relative_pos(stabilizer_horz))
	apply_force(-stabilizer_vert_mag * up, get_relative_pos(stabilizer_vert))
