extends Control

func activate():
	visible = true
	InputManager.push_input_handler(self)


func handle_input(event: InputEvent):
	print(event)
