extends Node

enum InputMode {
	Mode1,
	Mode2,
}

const Ship = preload("res://PlaneGame/src/Ship.gd")
export var plane_path: NodePath
onready var plane: Ship = get_node(plane_path)
export(InputMode) var input_mode = InputMode.Mode1

# var input_thrust: float

func _process(delta):
	
	if Input.is_action_just_pressed("face_top"):
		if input_mode == InputMode.Mode1:
			input_mode = InputMode.Mode2
		else:
			input_mode = InputMode.Mode1

	if Input.is_action_just_pressed("face_left"):
		plane.rotation_degrees.x = 0
		plane.rotation_degrees.z = 0
		
	
	
	if input_mode == InputMode.Mode1:
		# LX: Rudder, LY: Elevator
		plane.in_rudder = Input.get_action_strength("L_Right") - Input.get_action_strength("L_Left")
		plane.in_elevator = Input.get_action_strength("L_Up") - Input.get_action_strength("L_Down")
		# RX: Ailerons, RY: Thrust
		plane.in_ailerons = Input.get_action_strength("R_Right") - Input.get_action_strength("R_Left")
		plane.in_thrust = Input.get_action_strength("R_Up") - Input.get_action_strength("R_Down")
	elif input_mode == InputMode.Mode2:	
		# LX: Rudder, LY: Elevator
		plane.in_rudder = Input.get_action_strength("L_Right") - Input.get_action_strength("L_Left")
		plane.in_thrust = Input.get_action_strength("L_Up") - Input.get_action_strength("L_Down")
		# RX: Ailerons, RY: Thrust
		plane.in_ailerons = Input.get_action_strength("R_Right") - Input.get_action_strength("R_Left")
		plane.in_elevator = Input.get_action_strength("R_Up") - Input.get_action_strength("R_Down")
	
