extends Control

const INT_MAX := 0x7FFF_FFFF

## After holding this time, we will show "keep pressing BTN to quit"
@export var time_to_quit_warning: float = 1
## After holding this time, we will quit the controller configuration
@export var time_to_quit_commit: float = 4

@export_group("Internal")
@export var label_hold_to_exit: Label

var device: int

var axes_state: Dictionary
var axes_time_pressed: Dictionary
var btns_time_pressed: Dictionary

var config_steps: Array[ConfigStepBase]

func _ready() -> void:
	set_process(false)
	var config_steps_node := $ConfigSteps
	for idx in config_steps_node.get_child_count():
		config_steps.append(config_steps_node.get_child(idx))


func start_controller_setup(in_device: int) -> void:
	device = in_device
	InputManager.push_input_handler(self)
	visible = true
	set_process(true)
	axes_state = {}
	axes_time_pressed = {}
	btns_time_pressed = {}
	for axis in JOY_AXIS_MAX:
		var axis_value := Input.get_joy_axis(device, axis)
		if abs(axis_value) > 0.5:
			axes_state[axis] = sign(axis_value)


func exit_config():
	InputManager.pop_input_handler(self)
	visible = false
	set_process(false)


func _process(_delta: float) -> void:
	var oldest_input_time_ms: int = INT_MAX
	var oldest_input_isaxis: bool
	var oldest_input_index: int
	
	for idx in axes_time_pressed:
		var time: int = axes_time_pressed[idx]
		if time == 0:
			continue
		if time < oldest_input_time_ms:
			oldest_input_time_ms = time
			oldest_input_isaxis = true
			oldest_input_index = idx
	
	for idx in btns_time_pressed:
		var time: int = btns_time_pressed[idx]
		if time == 0:
			continue
		if time < oldest_input_time_ms:
			oldest_input_time_ms = time
			oldest_input_isaxis = false
			oldest_input_index = idx
	
	var show_hold_msg := false
	var passed_exit_time := false
	if oldest_input_time_ms != INT_MAX:
		var current_time_ms := Time.get_ticks_msec()
		var time_holding_btn_sec := (current_time_ms - oldest_input_time_ms) / 1000.0
		if time_holding_btn_sec > time_to_quit_commit:
			passed_exit_time = true
		elif time_holding_btn_sec > time_to_quit_warning:
			show_hold_msg = true
	
	if passed_exit_time:
		exit_config()
		return
	elif show_hold_msg:
		var input_name: String
		if oldest_input_isaxis:
			var idx := oldest_input_index
			input_name = "Axis %d%s" % [idx, "+" if axes_state[idx] > 0 else "-"]
		else:
			input_name = "Button %d" % oldest_input_index
		label_hold_to_exit.text = "Keep holding %s to quit configuration." % input_name
	else:
		label_hold_to_exit.text = "Hold any button or axis to quit configuration."

var current_step: int = 0
var last_binding: InputEvent

var binding_back: InputEvent
var binding_ok: InputEvent
var binding_left_x: InputEventJoypadMotion
var binding_left_y: InputEventJoypadMotion
var binding_right_x: InputEventJoypadMotion
var binding_right_y: InputEventJoypadMotion

var bindings := [
	{"name": "back", "field": "binding_back", "is_axis": false},
	{"name": "ok", "field": "binding_ok", "is_axis": false},
	{"name": "left_x", "field": "binding_left_x", "is_axis": true},
	{"name": "left_y", "field": "binding_left_y", "is_axis": true},
	{"name": "right_x", "field": "binding_right_x", "is_axis": true},
	{"name": "right_y", "field": "binding_right_y", "is_axis": true},
]


func step_handle_event_pressed(is_axis: bool, index: int, value: int = 0):
	var new_binding: InputEvent


	if is_axis:
		new_binding = InputEventJoypadMotion.new()
		new_binding.axis = index
		new_binding.axis_value = value
	else:
		new_binding = InputEventJoypadButton.new()
		new_binding.button_index = index
	
	
	if new_binding.is_match(binding_back):
		current_step -= 1
		last_binding = null
		if current_step == 0:
			binding_back = null
		return
	
	var step_binding_isaxis: bool = bindings[current_step].is_axis
	
	if step_binding_isaxis:
		if new_binding is InputEventJoypadButton:
			# for axis inputs we want joypad motion events
			return
	
	var step_binding_name: String = bindings[current_step].name
	if new_binding.is_match(last_binding):
		print("confirmed %s as %s binding" % [last_binding, step_binding_name])
		var step_binding_field: String = bindings[current_step].field
		self[step_binding_field] = new_binding
		current_step += 1
		last_binding = null
	else:
		last_binding = new_binding
		print("press again %s to bind as %s" % [new_binding, step_binding_name])


func handle_input(event: InputEvent) -> void:
	# consume all events always, while this UI is visible
	get_viewport().set_input_as_handled()
	
	# ignore any event that doesn't come from the device being configured
	if event.device != device:
		return
	if event is InputEventJoypadButton:
		if event.pressed:
			handle_pressed(false, event.button_index)
		else:
			handle_released(false, event.button_index)
	else:
		var motion_event := event as InputEventJoypadMotion
		assert(motion_event != null)
		var axis := motion_event.axis
		if abs(motion_event.axis_value) > 0.5:
			if axes_state.get(axis, 0) == 0:
				var value := signf(motion_event.axis_value)
				handle_pressed(true, axis, value)
		else:
			if axes_state.get(axis, 0) != 0:
				handle_released(true, axis)


func handle_pressed(is_axis: bool, index: int, value: int = 0):
	if is_axis:
		axes_state[index] = value
		axes_time_pressed[index] = Time.get_ticks_msec()
	else:
		btns_time_pressed[index] = Time.get_ticks_msec()
	step_handle_event_pressed(is_axis, index, value)


func handle_released(is_axis: bool, index: int):
	if is_axis:
		axes_state[index] = 0
		axes_time_pressed[index] = 0
	else:
		btns_time_pressed[index] = 0
