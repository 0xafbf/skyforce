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

var config_steps := [
	{
		"bind_type": "button",
		"bind_id": "ui_back",
		"bind_name": "BACK",
	},
	{
		"bind_type": "button",
		"bind_id": "ui_accept",
		"bind_name": "OK",
	},
	{
		"bind_type": "axis",
		"bind_id": "left_x",
		"bind_stick": "Left",
		"bind_direction": "Right"
	},
	{
		"bind_type": "axis",
		"bind_id": "left_y",
		"bind_stick": "Left",
		"bind_direction": "Up"
	},
	{
		"bind_type": "axis",
		"bind_id": "right_x",
		"bind_stick": "Right",
		"bind_direction": "Right"
	},
	{
		"bind_type": "axis",
		"bind_id": "right_y",
		"bind_stick": "Right",
		"bind_direction": "Up"
	},
]


func _ready() -> void:
	set_process(false)


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

	process_step()

var current_step: int


func process_step():
	return
	
	

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


func handle_released(is_axis: bool, index: int):
	if is_axis:
		axes_state[index] = 0
		axes_time_pressed[index] = 0
	else:
		btns_time_pressed[index] = 0
