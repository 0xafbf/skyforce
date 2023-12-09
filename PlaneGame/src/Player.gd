extends Node

enum InputMode {
	Mode1,
	Mode2,
}

@export var plane_path: NodePath
@onready var plane: Node3D = get_parent()
@export var input_mode: InputMode = InputMode.Mode1

# var input_thrust: float
@onready var input: SFInput = $"../../Input"

func _process(delta):
	
	if Input.is_action_just_pressed("face_top"):
		if input_mode == InputMode.Mode1:
			input_mode = InputMode.Mode2
		else:
			input_mode = InputMode.Mode1

	if Input.is_action_just_pressed("face_left"):
		plane.rotation_degrees.x = 0
		plane.rotation_degrees.z = 0
		
	
	var lx := Input.get_axis("L_Left", "L_Right")
	var ly := Input.get_axis("L_Down", "L_Up")
	var rx := Input.get_axis("R_Left", "R_Right")
	var ry := Input.get_axis("R_Down", "R_Up")
	
	if input_mode == InputMode.Mode1:
		plane.in_rudder = lx
		plane.in_elevator = ly
		plane.in_ailerons = rx
		plane.in_thrust = ry
	elif input_mode == InputMode.Mode2:	
		plane.in_rudder = lx
		plane.in_thrust = ly
		plane.in_ailerons = rx
		plane.in_elevator = ry
	
	plane.in_rudder = input.yaw
	plane.in_thrust = input.throttle * 0.5 + 0.5
	plane.in_ailerons = input.roll
	plane.in_elevator = input.pitch
