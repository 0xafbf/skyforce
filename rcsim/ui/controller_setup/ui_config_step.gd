@tool
extends PanelContainer

enum {
	STATUS_INACTIVE,
	STATUS_CURRENT,
	STATUS_FINISHED,
}

@export var step_name: String:
	set(in_step_name):
		step_name = in_step_name
		label_step_name.text = step_name

@export_group("Internal")
@export var label_step_name: Label
@export var label_step_status: Label

var binding_name: String
var mapping_name: String

func set_binding_name(in_name: String):
	binding_name = in_name
	label_step_name.text = "Configure %s" % binding_name

func set_status(status: int) -> void:
	match status:
		STATUS_INACTIVE:
			label_step_status.text = ""
		STATUS_CURRENT:
			label_step_status.text = "Configuring..."
		STATUS_FINISHED:
			label_step_status.text = "Configured to %s" % mapping_name
		
