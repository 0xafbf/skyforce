extends Node
class_name Player

enum InputMode {
	Mode1,
	Mode2,
}

@onready var plane: Node3D = get_parent()
@export var input_mode: InputMode = InputMode.Mode2

# var input_thrust: float
@export var input: SFInput

func _process(_delta: float) -> void:

	#if Input.is_action_just_pressed("change_input_mode"):
		#if input_mode == InputMode.Mode1:
			#input_mode = InputMode.Mode2
		#else:
			#input_mode = InputMode.Mode1

	if Input.is_action_just_pressed("face_left"):
		plane.rotation_degrees.x = 0
		plane.rotation_degrees.z = 0

	if input_mode == InputMode.Mode1:
		plane.in_yaw =    input.left_x
		plane.in_pitch =  input.left_y
		plane.in_roll =   input.right_x
		plane.in_thrust = input.right_y
	elif input_mode == InputMode.Mode2:
		plane.in_yaw =    input.left_x
		plane.in_thrust = input.left_y
		plane.in_roll =   input.right_x
		plane.in_pitch =  input.right_y

