extends RigidBody3D
class_name Drone

@export var propeller_fl: Node3D
@export var propeller_fr: Node3D
@export var propeller_rl: Node3D
@export var propeller_rr: Node3D

@export var thrust_scale: float = 3

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

var in_yaw: float = 0
var in_roll: float = 0
var in_pitch: float = 0
var in_thrust: float = 0

var thrust_cumulative: float = 0

var thrust_vector: Vector3
var lift_vector: Vector3

@export_range(0, 100, 0.1, "or_greater", "radians_as_degrees") var propeller_angularspeed_max: float = 40*TAU

enum FlightMode {
	ACRO,
	THREE_D,
	HORIZON,
	LEVEL,
}

@export var flight_mode: FlightMode = FlightMode.ACRO

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

	var input_thrust := in_thrust
	if flight_mode == FlightMode.ACRO:
		input_thrust = input_thrust * 0.5 + 0.5

	var input_pitch := in_pitch * scale_pitch
	var input_roll := in_roll * scale_roll

	var input_fl := input_thrust - input_pitch + input_roll
	var input_fr := input_thrust - input_pitch - input_roll
	var input_rl := input_thrust + input_pitch + input_roll
	var input_rr := input_thrust + input_pitch - input_roll
	
	var thrust_dir := global_transform.basis.y * thrust_scale
	apply_force(thrust_dir * input_fl, get_relative_pos(propeller_fl))
	apply_force(thrust_dir * input_fr, get_relative_pos(propeller_fr))
	apply_force(thrust_dir * input_rl, get_relative_pos(propeller_rl))
	apply_force(thrust_dir * input_rr, get_relative_pos(propeller_rr))
	
	var input_yaw = in_yaw * scale_yaw
	var torque2: Vector3 = -global_transform.basis.y * input_yaw
	apply_torque(torque2)

