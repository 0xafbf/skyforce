class_name SFInput
extends Node

@export var left_y: float = 0
@export var right_y: float = 0
@export var left_x: float = 0
@export var right_x: float = 0


enum ControlType {
	XINPUT,
	TX12,
}

@export var control_type: ControlType
@export var device: int = 0

@warning_ignore("int_as_enum_without_cast")
func _process(_delta: float) -> void:
	var control_name = Input.get_joy_name(device)
	if control_name == "Radiomaster TX12 Joystick":
		control_type = ControlType.TX12
	else:
		control_type = ControlType.XINPUT

	if control_type == ControlType.TX12:
		left_x = Input.get_joy_axis(device, 3)
		left_y = Input.get_joy_axis(device, 2)
		right_x = Input.get_joy_axis(device, 0)
		right_y = Input.get_joy_axis(device, 1)
	else:
		left_x = Input.get_joy_axis(device, JOY_AXIS_LEFT_X)
		left_y = -Input.get_joy_axis(device, JOY_AXIS_LEFT_Y)
		right_x = Input.get_joy_axis(device, JOY_AXIS_RIGHT_X)
		right_y = -Input.get_joy_axis(device, JOY_AXIS_RIGHT_Y)

