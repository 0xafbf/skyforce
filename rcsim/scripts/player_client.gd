extends Node

@export var target: Model

enum InputMode {
	Mode1,
	Mode2,
}

@export var input_mode: InputMode = InputMode.Mode2
@export var device: int = -1

@export var camera: Camera3D


# var input_thrust: float
@onready var input: SFInput = $Input

func _ready() -> void:
	input.set_device(device)

func _process(_delta: float) -> void:
	if not target:
		return

	if Input.is_action_just_pressed("change_input_mode"):
		if input_mode == InputMode.Mode1:
			input_mode = InputMode.Mode2
		else:
			input_mode = InputMode.Mode1


	if input_mode == InputMode.Mode1:
		target.in_yaw =    input.left_x
		target.in_pitch =  input.left_y
		target.in_roll =   input.right_x
		target.in_thrust = input.right_y
	elif input_mode == InputMode.Mode2:
		target.in_yaw =    input.left_x
		target.in_thrust = input.left_y
		target.in_roll =   input.right_x
		target.in_pitch =  input.right_y

	var target_cam_tx := target.get_cam_tx()
	camera.global_transform = target_cam_tx
