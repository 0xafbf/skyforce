extends UIPlayerRow

@export var option_name: String
@export var options: Array[Resource]

@export_category("Internal References")
@export var option_label: Label

var current_option: int = 0


func _ready() -> void:
	set_option(current_option)


func set_option(in_option: int) -> void:
	current_option = in_option
	var option = options[current_option]
	option_label.text = option.name


func change(delta: int) -> void:
	var new_option := (current_option + options.size() + delta) % options.size()
	set_option(new_option)
