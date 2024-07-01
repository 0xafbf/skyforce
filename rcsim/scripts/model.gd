extends RigidBody3D
class_name Model

@export var cam_target_firstperson: Node3D
@export var cam_target_thirdperson: Node3D

var start_pos: Transform3D

func _ready():
	start_pos = global_transform


func get_cam_tx() -> Transform3D:
	return cam_target_firstperson.global_transform

func reset_position() -> void:
	await get_tree().physics_frame
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_transform = start_pos
	global_position = start_pos.origin
