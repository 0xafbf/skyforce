class_name SFInput
extends Node

var throttle: float = 0
var pitch: float = 0
var yaw: float = 0
var roll: float = 0

func _process(delta: float) -> void:
	
	roll = Input.get_joy_axis(0, 0)
	pitch = Input.get_joy_axis(0, 1)
	throttle = Input.get_joy_axis(0, 2)
	yaw = Input.get_joy_axis(0, 3)
