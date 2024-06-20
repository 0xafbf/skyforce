extends Control

@export var plane_path: NodePath
@onready var plane: Airplane = get_node(plane_path)

@export var player_path: NodePath
@onready var player: Player = get_node(player_path)


@onready var thrust_fill = $Thrust/Fill
@onready var elevator_fill = $Elevator/Fill
@onready var ailerons_fill = $Ailerons/Fill
@onready var rudder_fill = $Rudder/Fill
@onready var thrust_text = $Thrust/Text
@onready var elevator_text = $Elevator/Text
@onready var ailerons_text = $Ailerons/Text
@onready var rudder_text = $Rudder/Text
@onready var label_mode = $LabelMode

func _unhandled_input(event):
	if event is InputEventKey:
		var key_event: InputEventKey = event
		if key_event.keycode == KEY_ESCAPE:
			get_tree().quit()
			get_viewport().set_input_as_handled()

func _process(delta):

	thrust_fill.anchor_top = 1 - remap_to_01(plane.in_thrust)
	elevator_fill.anchor_top = 1 - remap_to_01(plane.in_elevator)
	rudder_fill.anchor_right = remap_to_01(plane.in_rudder)
	ailerons_fill.anchor_right = remap_to_01(plane.in_ailerons)

	elevator_text.text = "%.02f" % plane.in_elevator
	ailerons_text.text = "%.02f" % plane.in_ailerons
	thrust_text.text   = "%.02f" % plane.in_thrust
	rudder_text.text   = "%.02f" % plane.in_rudder

	if player.input_mode == Player.InputMode.Mode1:
		label_mode.text = "Mode: 1"
	elif player.input_mode == Player.InputMode.Mode2:
		label_mode.text = "Mode: 2"
	else:
		label_mode.text = "Invalid Mode"

# func _draw():

func remap_to_01(value):
	return value * 0.5 + 0.5
