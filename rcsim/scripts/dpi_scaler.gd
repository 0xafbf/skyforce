extends Node


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		var window := get_window()
		if window.mode == Window.MODE_WINDOWED:
			window.mode = Window.MODE_FULLSCREEN
		else:
			window.mode = Window.MODE_WINDOWED


func _ready() -> void:
	
	var scale_factor: float = DisplayServer.screen_get_scale()
	if OS.get_name() == "Windows":
		scale_factor = DisplayServer.screen_get_dpi() / 96.0
	
	var window := get_window()
	window.content_scale_factor = scale_factor
	window.position = window.position - Vector2i(0.5 * window.size * (scale_factor - 1.0))
	window.size = window.size * scale_factor
