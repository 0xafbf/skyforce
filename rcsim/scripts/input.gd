class_name SFInput
extends Node

var left_y: float = 0
var right_y: float = 0
var left_x: float = 0
var right_x: float = 0

@export var touch_left: TouchArea
@export var touch_right: TouchArea


enum ControlType {
	XINPUT,
	TX12,
}

var control_type: ControlType
var device: int

func set_device(in_device: int):
	device = in_device
	if device == -1:
		print("setting touch device")
	else:
		var control_name = Input.get_joy_name(device)
		if control_name == "Radiomaster TX12 Joystick":
			control_type = ControlType.TX12
		else:
			control_type = ControlType.XINPUT


@warning_ignore("int_as_enum_without_cast")
func _process(_delta: float) -> void:
	if device == -1:
		if touch_left:
			left_x = touch_left.analog_value.x
			left_y = touch_left.analog_value.y
		if touch_right:
			right_x = touch_right.analog_value.x
			right_y = touch_right.analog_value.y

		return

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
