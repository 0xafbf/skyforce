extends Control

@export var target: Model

enum InputMode {
	Mode1,
	Mode2,
}

enum CameraMode {
	Native,
	NTSC,
	PAL,
}

@export var input_mode: InputMode = InputMode.Mode2
@export var device: int = -1

@export var camera: Camera3D
@export var camera_mode: CameraMode = CameraMode.Native
#@export var aspect_container: AspectRatioContainer
@export var subviewport_container: SubViewportContainer
@export var subviewport: SubViewport

# var input_thrust: float
@onready var input: SFInput = $Input

@export var models: Array[Model]
@export var current_model: int = 0

func _ready() -> void:
	input.set_device(device)
	set_current_model(current_model)
	set_camera_mode(camera_mode)

func set_current_model(in_model: int):
	if models.size() == 0:
		push_error("no models available")
		return
	var desired := (in_model + models.size()) % models.size()
	current_model = desired
	target = models[current_model]


func set_camera_mode(in_camera_mode: CameraMode) -> void:
	camera_mode = in_camera_mode
	#var target_size := aspect_container.size
	#if camera_mode == CameraMode.NTSC:
		#target_size = Vector2i(320, 240)
	#var aspect := target_size.x / target_size.y
	##aspect_container.ratio = aspect
	#subviewport.size = target_size * get_window().content_scale_factor
	#subviewport_container.scale = Vector2.ONE * (1.0 / get_window().content_scale_factor)
	var dpi_scale := get_window().content_scale_factor
	var container_size := self.size
	subviewport_container.size = container_size * dpi_scale
	subviewport_container.scale = Vector2.ONE / dpi_scale
	subviewport_container.position = Vector2.ZERO


func _process(_delta: float) -> void:
	if not target:
		return

	#if Input.is_action_just_pressed("change_input_mode"):
		#if input_mode == InputMode.Mode1:
			#input_mode = InputMode.Mode2
		#else:
			#input_mode = InputMode.Mode1

	if input_mode == InputMode.Mode1:
		target.in_yaw =    input.left_x
		target.in_pitch =  input.left_y
		target.in_roll =   input.right_x
		target.in_thrust = input.right_y
	elif input_mode == InputMode.Mode2:
		target.in_yaw =    input.left_x
		target.in_thrust = input.left_y
		target.in_roll =   input.right_x
		target.in_pitch =  input.right_y

	var target_cam_tx := target.get_cam_tx()
	camera.global_transform = target_cam_tx


func _on_btn_reset_pressed() -> void:
	target.reset_position()


func _on_btn_viewport_mode_pressed() -> void:
	if camera_mode == CameraMode.Native:
		set_camera_mode(CameraMode.NTSC)
	else:
		set_camera_mode(CameraMode.Native)


func _on_btn_switch_pressed() -> void:
	set_current_model(current_model + 1)
