extends Node3D
class_name Level


var spawn_points: Array[SpawnMarker] = []

func _ready() -> void:
	for child in get_children():
		if child is SpawnMarker:
			spawn_points.append(child)
