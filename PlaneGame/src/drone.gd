extends RigidBody3D

@export var propeller_fl: Node3D
@export var propeller_fr: Node3D
@export var propeller_rl: Node3D
@export var propeller_rr: Node3D

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

var in_rudder: float = 0
var in_ailerons: float = 0
var in_elevator: float = 0
var in_thrust: float = 0

var thrust_cumulative: float = 0

var thrust_vector: Vector3
var lift_vector: Vector3

@export_range(0, 100, 0.1, "or_greater", "radians_as_degrees") var propeller_angularspeed_max: float = 40*TAU


func _process(delta: float) -> void:
	var propeller_speed := propeller_angularspeed_max * in_thrust
	var propeller_delta := propeller_speed * delta
	propeller_fl.rotate(Vector3.UP, propeller_delta)
	propeller_fr.rotate(Vector3.UP, -propeller_delta)
	propeller_rl.rotate(Vector3.UP, -propeller_delta)
	propeller_rr.rotate(Vector3.UP, propeller_delta)

func get_relative_pos(target: Node3D) -> Vector3:
	return target.global_transform.origin - global_transform.origin

var scale_pitch: float = 0.2
var scale_roll: float = 0.2
var scale_yaw: float = 1

func _physics_process(delta):

	var input_pitch := in_elevator * scale_pitch
	var input_roll := in_ailerons * scale_roll

	var input_fl := in_thrust - input_pitch + input_roll
	var input_fr := in_thrust - input_pitch - input_roll
	var input_rl := in_thrust + input_pitch + input_roll
	var input_rr := in_thrust + input_pitch - input_roll
	
	var thrust_dir := global_transform.basis.y * thrust_scale
	apply_force(thrust_dir * input_fl, get_relative_pos(propeller_fl))
	apply_force(thrust_dir * input_fr, get_relative_pos(propeller_fr))
	apply_force(thrust_dir * input_rl, get_relative_pos(propeller_rl))
	apply_force(thrust_dir * input_rr, get_relative_pos(propeller_rr))
	
	var input_yaw = in_rudder * scale_yaw
	var torque2: Vector3 = -global_transform.basis.y * input_yaw
	apply_torque(torque2)
	
	
	return
	var basis = transform.basis
	var forward: Vector3 = basis * Vector3.FORWARD
	var up: Vector3      = basis * Vector3.UP
	var right: Vector3   = basis * Vector3.RIGHT
	
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
	
	var torque_amount = velocity_forward * in_ailerons * roll_torque
	var torque: Vector3 = torque_amount * forward
	apply_torque(torque)

	torque_amount = velocity_forward * in_elevator * pitch_torque
	torque = -torque_amount * right
	apply_torque(torque)
	
	torque_amount = velocity_forward * in_rudder * yaw_torque
	torque = -torque_amount * up
	apply_torque(torque)

	var stabilizer_horz_mag = stabilizer_horz_influence * velocity.dot(right)
	var stabilizer_vert_mag = stabilizer_vert_influence * velocity.dot(up)
	
	apply_force(-stabilizer_horz_mag * right, get_relative_pos(stabilizer_horz))
	apply_force(-stabilizer_vert_mag * up, get_relative_pos(stabilizer_vert))
	
	
