extends RigidBody3D
class_name Drone

@export var propeller_fl: Node3D
@export var propeller_fr: Node3D
@export var propeller_rl: Node3D
@export var propeller_rr: Node3D

## force applied at full thrust
@export var thrust_power: float = 30

## Rotation rate at full input
@export var pitch_speed: float = 800
## Rotation rate at full input
@export var yaw_speed: float = 800
## Rotation rate at full input
@export var roll_speed: float = 800

## how fast do engines reach their target?
@export var power_pitch: float = 1
## how fast do engines reach their target?
@export var power_yaw: float = 1
## how fast do engines reach their target?
@export var power_roll: float = 1

var in_yaw: float = 0
var in_roll: float = 0
var in_pitch: float = 0
var in_thrust: float = 0

@export_range(0, 100, 0.1, "or_greater", "radians_as_degrees") var propeller_angularspeed_max: float = 40*TAU

enum FlightMode {
	ACRO,
	THREE_D,
	HORIZON,
	LEVEL,
}

@export var flight_mode: FlightMode = FlightMode.ACRO

func _process(delta: float) -> void:
	var propeller_base := propeller_angularspeed_max * in_thrust
	var propeller_delta := propeller_angularspeed_max * delta
	propeller_fl.rotate(Vector3.UP, propeller_speed[0] * propeller_delta)
	propeller_fr.rotate(Vector3.UP, propeller_speed[1] * propeller_delta)
	propeller_rl.rotate(Vector3.UP, propeller_speed[2] * propeller_delta)
	propeller_rr.rotate(Vector3.UP, propeller_speed[3] * propeller_delta)

func get_relative_pos(target: Node3D) -> Vector3:
	return target.global_transform.origin - global_transform.origin


var propeller_speed: PackedFloat32Array = PackedFloat32Array()

func _physics_process(delta):

	var input_thrust := in_thrust
	if flight_mode == FlightMode.ACRO:
		input_thrust = input_thrust * 0.5 + 0.5

	var target_pitch_rate := in_pitch * pitch_speed
	var target_yaw_rate := in_yaw * yaw_speed
	var target_roll_rate := in_roll * roll_speed
	var target_rate	:= Vector3(target_pitch_rate, target_yaw_rate, target_roll_rate) / 360 * TAU
	
	var delta_rate := target_rate - angular_velocity
	print("target rate: ", target_rate)
	print("delta rate:  ", delta_rate )


	var base_thrust := input_thrust * thrust_power
	var base_roll := delta_rate.z * power_roll
	var base_pitch := delta_rate.x * power_pitch
	var base_yaw := delta_rate.y * power_yaw

	var input_fl := base_thrust - base_pitch + base_roll
	var input_fr := base_thrust - base_pitch - base_roll
	var input_rl := base_thrust + base_pitch + base_roll
	var input_rr := base_thrust + base_pitch - base_roll
	
	propeller_speed.resize(4)
	propeller_speed[0] = input_fl
	propeller_speed[1] = input_fr
	propeller_speed[2] = input_rl
	propeller_speed[3] = input_rr
	print(propeller_speed)
	
	var thrust_dir := global_transform.basis.y
	apply_force(thrust_dir * input_fl, get_relative_pos(propeller_fl))
	apply_force(thrust_dir * input_fr, get_relative_pos(propeller_fr))
	apply_force(thrust_dir * input_rl, get_relative_pos(propeller_rl))
	apply_force(thrust_dir * input_rr, get_relative_pos(propeller_rr))
	

	var torque2: Vector3 = -global_transform.basis.y * base_yaw
	apply_torque(torque2)

