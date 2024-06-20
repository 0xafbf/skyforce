extends RigidBody3D
class_name Model

@export var cam_target_firstperson: Node3D
@export var cam_target_thirdperson: Node3D

func get_cam_tx() -> Transform3D:
	return cam_target_firstperson.global_transform
