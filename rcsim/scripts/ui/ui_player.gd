extends Control
class_name UIPlayerSetup

enum DeviceType {
	Invalid,
	KeyboardMouse,
	Joypad,
	TouchScreen,
}

signal player_ready

var player: int
var device_type: DeviceType
var device: int

@export var options: Array[UIPlayerRow]

@export var model_data: ModelData

var current_option: int = 0
var is_ready: bool = false



func _ready() -> void:
	set_focused_option(current_option)


func set_focused_option(in_option: int) -> void:
	var old_option := options[current_option]
	old_option.theme_type_variation = ""
	current_option = in_option
	var new_option := options[current_option]
	new_option.theme_type_variation = "PanelContainerPlayerConfigFocused"


func _input(event: InputEvent) -> void:
	if event.device != device:
		return

	if device_type == DeviceType.Joypad:
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			_handle_input(event)
	elif device_type == DeviceType.KeyboardMouse:
		if event is InputEventKey:
			_handle_input(event)


func _handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_nav_up"):
		move_cursor(-1)
	elif event.is_action_pressed("ui_nav_down"):
		move_cursor(1)
	elif event.is_action_pressed("ui_nav_left"):
		var current := options[current_option]
		current.change(-1)
	elif event.is_action_pressed("ui_nav_right"):
		var current := options[current_option]
		current.change(1)
	elif event.is_action_pressed("ui_nav_accept"):
		var current := options[current_option]
		current.select()

	get_viewport().set_input_as_handled()


func move_cursor(offset: int) -> void:
	var num_options := options.size()
	var new_option := (current_option + num_options + offset) % num_options
	set_focused_option(new_option)


func _on_option_ready_button_pressed() -> void:
	model_data = $'VBoxContainer/OptionModel'.options[$VBoxContainer/OptionModel.current_option]
	is_ready = true
	player_ready.emit()
