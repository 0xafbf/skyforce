extends Control

@export var player_setup_template: PackedScene
@export var player_setup_container: Control

@export var level: Level

var player_setup_views: Array[Control]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		add_player(event.device, UIPlayerSetup.DeviceType.Joypad)
		return

	if event is InputEventKey:
		add_player(event.device, UIPlayerSetup.DeviceType.KeyboardMouse)
		return

func add_player(device: int, device_type: UIPlayerSetup.DeviceType):
	var ui_player_setup := player_setup_template.instantiate() as UIPlayerSetup
	ui_player_setup.player = player_setup_views.size()
	ui_player_setup.device = device
	ui_player_setup.device_type = device_type
	ui_player_setup.player_ready.connect(on_player_ready)
	player_setup_container.add_child(ui_player_setup)
	player_setup_views.append(ui_player_setup)
	relayout_views(player_setup_views)

func relayout_views(views: Array[Control]):
	var num_views = views.size()
	if num_views == 1:
		var view_full := views[0]
		view_full.set_anchors_preset(Control.PRESET_FULL_RECT)
	elif num_views == 2:
		var view_1 := views[0]
		var view_2 := views[1]

		view_1.set_anchors_preset(Control.PRESET_FULL_RECT)
		view_1.anchor_right = 0.5

		view_2.set_anchors_preset(Control.PRESET_FULL_RECT)
		view_2.anchor_left = 0.5
	else:
		var view_1 := views[0]
		var view_2 := views[1]
		var view_3 := views[2]

		view_1.set_anchors_preset(Control.PRESET_FULL_RECT)
		view_1.anchor_right = 0.5
		view_1.anchor_bottom = 0.5
		view_1.offset_right = 0
		view_1.offset_bottom = 0

		view_2.set_anchors_preset(Control.PRESET_FULL_RECT)
		view_2.anchor_left = 0.5
		view_2.anchor_bottom = 0.5
		view_2.offset_left = 0
		view_2.offset_bottom = 0

		view_3.set_anchors_preset(Control.PRESET_FULL_RECT)
		view_3.anchor_right = 0.5
		view_3.anchor_top = 0.5
		view_2.offset_right = 0
		view_2.offset_top = 0

		if num_views == 4:
			var view_4 := views[3]
			view_4.set_anchors_preset(Control.PRESET_FULL_RECT)
			view_4.anchor_left = 0.5
			view_4.anchor_top = 0.5

@export var game_client: Control
@export var player_client_template: PackedScene

func on_player_ready() -> void:
	for player in player_setup_views:
		if not player.is_ready:
			return

	print("ready!")

	var model_container := level.get_parent()

	var player_clients: Array[Control] = []
	for player: UIPlayerSetup in player_setup_views:
		var player_idx := player.player
		var spawn_point := level.spawn_points[player_idx]
		var model_data := player.model_data
		var model_template := load(model_data.asset_path) as PackedScene
		var model := model_template.instantiate() as Model
		model.transform = spawn_point.global_transform
		model_container.add_child(model)

		var client := player_client_template.instantiate() as PlayerClient
		client.device = player.device
		client.target = model
		game_client.add_child(client)
		player_clients.append(client)

	relayout_views(player_clients)
