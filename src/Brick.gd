@tool
extends Node3D

class_name Brick

@export var margin = 0.2
@export var size: Vector3: set = set_extents
var snap_size = 0.5


var owned_material_id = -1
@onready var owned_material:Material = null
func get_owned_material(desired_id):

	if desired_id == owned_material_id:
		if owned_material:
			return owned_material
	owned_material_id = desired_id

	if owned_material_id < skin_materials.size():
		var new_material = skin_materials[owned_material_id]
		owned_material = new_material.duplicate()
		$BrickCollision/MeshInstance3D.material_override = owned_material
	else:
		owned_material = null
	return owned_material

func set_extents(in_extents):
	in_extents = in_extents / snap_size
	size.x = max(int(in_extents.x), 1)
	size.y = max(int(in_extents.y), 1)
	size.z = max(int(in_extents.z), 1)

	size = size * snap_size
	if brick_mesh:
		brick_mesh.scale = size


	var mat = get_owned_material(skin)
	if mat:
		mat.set_shader_parameter("box_size", size)

	update_collision()

var shape_owner = -1

@onready var brick_collision: StaticBody3D = $BrickCollision
@onready var brick_mesh = $BrickCollision/MeshInstance3D

func update_collision():
	var shape = BoxShape3D.new()
	shape.size = size
	if brick_collision:
		if shape_owner == -1:
			shape_owner = brick_collision.create_shape_owner(self)

		brick_collision.shape_owner_clear_shapes(shape_owner)
		brick_collision.shape_owner_add_shape(shape_owner, shape)
		# $BrickCollision/CollisionShape. = shape


func _ready():
	set_extents(size)

func get_suggested_build_direction(world_position):
	var local_coordinates = to_local(world_position)
	var cube_coordinates = local_coordinates / size
	var abs_cube_coordinates = Vector3(abs(cube_coordinates.x), abs(cube_coordinates.y), abs(cube_coordinates.z))

	var major_axis = abs_cube_coordinates.max_axis()
	var minor_axis = abs_cube_coordinates.min_axis()
	var second_axis = 3 - major_axis - minor_axis

	var suggested_direction = Vector3()

	var test = abs(local_coordinates[second_axis]) + margin
	if test > size[second_axis]:
		# near to the edge, build sideways
		suggested_direction[second_axis] = sign(local_coordinates[second_axis])
	else:
		# build in face direction
		suggested_direction[major_axis] = sign(local_coordinates[major_axis])


	return transform.basis * (suggested_direction)

func get_snapping_position(world_position):
	var local_coordinates = to_local(world_position)

	var cube_coordinates = local_coordinates / size
	var abs_cube_coordinates = Vector3(abs(cube_coordinates.x), abs(cube_coordinates.y), abs(cube_coordinates.z))

	var major_axis = abs_cube_coordinates.max_axis()
	var minor_axis = abs_cube_coordinates.min_axis()
	var second_axis = 3 - major_axis - minor_axis

	var pos = Vector3()

	var test = abs(local_coordinates[second_axis]) + margin
	if test > size[second_axis]:
		# aiming border: project onto side...
		pos[second_axis] = size[second_axis] * sign(local_coordinates[second_axis])
	else:
		pos[major_axis] = size[major_axis] * sign(local_coordinates[major_axis])
		pos[second_axis] = int(local_coordinates[second_axis]/snap_size) * snap_size
		pos[minor_axis] = int(local_coordinates[minor_axis]/snap_size) * snap_size

	return transform * (pos)


@export var skin = 0: set = set_skin
enum { SKIN_0, SKIN_WOOD, SKIN_METAL }
@export var skin_materials # (Array, Material)
func set_skin(skin_id):
	skin_id = clamp(skin_id, 0, skin_materials.size()-1)
	if skin_id != skin:
		skin = skin_id
		if skin != -1:
			get_owned_material(skin)
			set_extents(size)
			#$BrickCollision/MeshInstance.material_override = skin_materials[skin]

func serialized():
	var r = Dictionary()
	r["location"] = var_to_str(position)
	r["rotation"] = var_to_str(rotation)
	r["size"] = var_to_str(size)
	r["brick_type"] = skin
	return r

func deserialize(input: Dictionary):
	position = str_to_var(input["location"])
	rotation = str_to_var(input["rotation"])
	var new_extents = str_to_var(input["size"])
	set_extents(new_extents)
	set_skin(input["brick_type"])
