class_name SFInput
extends Node

var left_y: float = 0
var right_y: float = 0
var left_x: float = 0
var right_x: float = 0


enum ControlType {
	XINPUT,
	TX12,
}

@export var control_type: ControlType
@export var device: int = 0

func _process(delta: float) -> void:
	if control_type == ControlType.TX12:
		right_x = Input.get_joy_axis(device, 0)
		right_y = Input.get_joy_axis(device, 1)
		left_y = Input.get_joy_axis(device, 2)
		left_x = Input.get_joy_axis(device, 3)
	else:
		left_x = Input.get_joy_axis(device, JOY_AXIS_LEFT_X)
		left_y = Input.get_joy_axis(device, JOY_AXIS_LEFT_Y)
		right_x = Input.get_joy_axis(device, JOY_AXIS_RIGHT_X)
		right_y = Input.get_joy_axis(device, JOY_AXIS_RIGHT_Y)
