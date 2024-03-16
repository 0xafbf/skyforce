extends Control

@export var cont_left: Control
@export var cont_right: Control
@export var thumb_left: Control
@export var thumb_right: Control

@export var input: SFInput

func _process(_delta: float) -> void:
	var left_x := input.left_x
	var left_y := input.left_y
	var right_x := input.right_x
	var right_y := input.right_y

	thumb_left.position = (cont_left.size - thumb_left.size) * Vector2(
		inverse_lerp(-1, 1, left_x),
		inverse_lerp(1, -1, left_y),
	)

	thumb_right.position = (cont_right.size - thumb_right.size) * Vector2(
		inverse_lerp(-1, 1, right_x),
		inverse_lerp(1, -1, right_y),
	)

