@tool
extends PanelContainer

@export var step_name: String:
	set(in_step_name):
		step_name = in_step_name
		label_step_name.text = step_name

@export_group("Internal")
@export var label_step_name: Label
@export var label_step_status: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
