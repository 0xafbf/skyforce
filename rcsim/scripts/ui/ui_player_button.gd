extends UIPlayerRow

signal button_pressed

# interface for children to override
func select() -> void:
	button_pressed.emit()
