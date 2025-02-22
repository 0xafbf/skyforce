extends Node

var player_for_device: Dictionary

func _ready() -> void:
	InputManager.push_input_handler(self)


func handle_input(event: InputEvent) -> void:
	var player: Node = player_for_device.get(event.device)
	if player:
		player.handle_input(event)


func login_player(device: int) -> void:
	print("logged in player with device", device)
