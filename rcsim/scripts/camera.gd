extends Camera3D

@export var target_path: NodePath
@onready var target = get_node(target_path)

@export var distance: float = 5
var pitch: float = 15
@export var pitch_speed_deg_s: float = 90
@export var yaw_speed_deg_s: float = 90
var yaw: float = -90

# mouse speeds are given in degrees per pixel
@export var pitch_speed_deg_px: float = 1
@export var yaw_speed_deg_px: float = 1

var last_valid_yaw: float = 0

func _input(event):
	if event is InputEventMouseMotion:
		var motion_event: InputEventMouseMotion = event
		var delta = motion_event.relative
		# pitch += delta.y * pitch_speed_deg_px
		# yaw += -delta.x * yaw_speed_deg_px
		get_viewport().set_input_as_handled()
		

func _process(delta):
	
	var plane_tx = target.global_transform.basis
	var plane_direction = plane_tx * Vector3.FORWARD
	var plane_up = plane_tx * Vector3.UP
	var upright = plane_up.dot(Vector3.UP)
	var blend_amount: float = inverse_lerp(-0.1, 0.4, upright)
	blend_amount = clamp(blend_amount, 0, 1)
	
	var desired_yaw = atan2(-plane_direction.z, plane_direction.x)
	if (desired_yaw - last_valid_yaw) > PI:
		last_valid_yaw += TAU
	elif (desired_yaw - last_valid_yaw) < -PI:
		last_valid_yaw -= TAU
	
	last_valid_yaw = lerp(last_valid_yaw, desired_yaw, blend_amount * delta * 4)
	
	
	var dx: float = (
		Input.get_action_strength("aim_right")
		- Input.get_action_strength("aim_left")
	)
	var dy: float = (
		Input.get_action_strength("aim_up")
		- Input.get_action_strength("aim_down")
	)
	
	pitch += dy * pitch_speed_deg_s * delta
	yaw -= dx * yaw_speed_deg_s * delta

	var pos_y = sin(deg_to_rad(pitch))
	var base_hx = cos(deg_to_rad(pitch))
	
	var final_yaw = deg_to_rad(yaw) + last_valid_yaw
	var pos_x = sin(final_yaw) * base_hx
	var pos_z = cos(final_yaw) * base_hx
	position = target.position + Vector3(pos_x, pos_y, pos_z) * distance
	#look_at(get_parent().translation, parent.transform.basis * Vector3.UP)
	look_at(target.position, Vector3.UP)
	

