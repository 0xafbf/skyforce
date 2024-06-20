extends Control
class_name TouchArea

## If true, Y value is not reset when released, and when pressed the offset is
## applied from previos position
@export var free_y: bool = false
@export var pull_center: bool = false

@export var range_ui: Control
@export var stick_ui: Control

var start_pos: Vector2
var current_pos: Vector2

var pressed: bool = false

var rect_half_size: Vector2 = Vector2(50, 50)
var analog_value: Vector2

var current_relative

func _ready() -> void:
	set_pressed(false)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		set_pressed(event.pressed)
		set_start_pos(event.position)
		set_current_pos(event.position)

	elif event is InputEventMouseMotion:
		set_current_pos(event.position)

func set_pressed(in_pressed: bool):
	pressed = in_pressed
	range_ui.visible = pressed
	stick_ui.visible = pressed
	if not pressed:
		analog_value = Vector2.ZERO

func set_start_pos(in_pos: Vector2):
	start_pos = in_pos
	range_ui.position = start_pos - rect_half_size
	range_ui.size = rect_half_size * 2

func set_current_pos(in_pos: Vector2):
	if pressed:
		current_pos = in_pos
		var relative := current_pos - start_pos
		relative = relative.clamp(CLAMP_LOW * rect_half_size, CLAMP_HIGH * rect_half_size)
		current_pos = start_pos + relative
		stick_ui.position = current_pos

		analog_value = relative / rect_half_size
		analog_value.y *= -1


const CLAMP_LOW := Vector2.ONE * -1
const CLAMP_HIGH := Vector2.ONE


