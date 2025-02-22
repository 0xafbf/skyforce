extends Node

var _input_handler_stack: Array[Node]

func _input(event: InputEvent) -> void:
	
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		var handler_idx := len(_input_handler_stack)
		while handler_idx > 0:
			handler_idx -= 1
			var handler := _input_handler_stack[handler_idx]
			handler.handle_input(event)
			if get_viewport().is_input_handled():
				break
	get_viewport().set_input_as_handled()


func push_input_handler(target: Node) -> void:
	_input_handler_stack.append(target)

func pop_input_handler(target: Node) -> void:
	var last_handler: Node = _input_handler_stack.pop_back()
	assert(last_handler == target)
