extends Spatial

class_name Brush

enum {BRUSH_OFF, BRUSH_BUILD, BRUSH_DESTROY, BRUSH_EDIT, BRUSH_EDITING}

var current_mode = BRUSH_OFF

export var build_mat: Material
export var destroy_mat: Material
export var edit_mat: Material
export var editing_mat: Material

var spawn_rotation = 0.0
var snap_size = 0.5

var target: Brick
onready var brush_mesh = $BrushMesh

func set_target(in_target: Brick):
	target = in_target
	if (target):
		extents = target.extents
	else:
		extents = Vector3(1,1,1)
		$ResizeHandle.visible = false
	set_extents(extents)

func set_extents(in_extents: Vector3):
	extents = in_extents
	brush_mesh.scale = extents + Vector3(0.02, 0.02, 0.02)

func _ready():
	set_target(null)

func set_mode(new_mode):
	current_mode = new_mode

	$ResizeHandle.visible = false

	visible = (current_mode != BRUSH_OFF)
	brush_mesh = $BrushMesh
	if current_mode == BRUSH_BUILD:
		brush_mesh.material_override = build_mat
	elif current_mode == BRUSH_DESTROY:
		brush_mesh.material_override = destroy_mat
	elif current_mode == BRUSH_EDIT:
		brush_mesh.material_override = edit_mat
	elif current_mode == BRUSH_EDITING:
		brush_mesh.material_override = editing_mat


var extents = Vector3(1,1,1)
func snap_to_position_and_direction(in_position: Vector3, in_direction: Vector3):
	var local_direction = transform.basis.xform_inv(in_direction)
	var local_offset = local_direction * extents
	var world_offset = transform.basis.xform(local_offset)
	translation = in_position + world_offset

var last_hit_position
func aim_brush(from_position: Vector3, direction: Vector3):

	if current_mode == BRUSH_OFF:
		return

	if current_mode == BRUSH_EDITING:
		var resize_current_point = resize_plane.intersects_ray(from_position, direction)
		if resize_current_point == null:
			return
		var resize_delta = resize_current_point - last_hit_position
		var local_resize_delta = transform.basis.xform_inv(resize_delta)
		print(resize_axis)
		local_resize_delta *= resize_axis
		#local_resize_delta /= snap_size
		var resize_coords = Vector3()
		resize_coords.x = int(local_resize_delta.x)
		resize_coords.y = int(local_resize_delta.y)
		resize_coords.z = int(local_resize_delta.z)
		resize_coords *= snap_size

		var final_extents = resize_previous_extents + resize_coords
		print(final_extents)
		set_extents(final_extents)
		translation = resize_starting_point + transform.basis.xform(resize_coords * resize_axis)

		return

	var to = from_position + (direction * 100)
	var space_state = get_world().direct_space_state
	var hit_result = space_state.intersect_ray(from_position, to)


	if !hit_result:
		return

	visible = true
	var collider = hit_result.collider
	var brick = collider.owner as Brick
	# if colliding with an already existing brick
	if brick:
		last_hit_position = hit_result.position

		if current_mode == BRUSH_BUILD:
			rotation = brick.rotation

			var hit_position = hit_result.position
			var next_brick_direction = brick.get_suggested_build_direction(hit_position)
			var next_brick_position = brick.get_snapping_position(hit_position)
			snap_to_position_and_direction(next_brick_position, next_brick_direction)

		elif current_mode == BRUSH_DESTROY:
			rotation = brick.rotation
			translation = brick.translation
			set_target(brick)
		elif current_mode == BRUSH_EDIT:
			rotation = brick.rotation
			translation = brick.translation
			set_target(brick)
			setup_resize(hit_result)

	else:
		set_target(null)
		rotation.y = spawn_rotation
		translation = hit_result.position

var resize_margin = 0.4
var resize_normal_axis
var resize_axis: Vector3
var resize_grab_point = Vector3()
var resize_origin = Vector3()
var resize_previous_extents: Vector3
var resize_starting_point: Vector3

func setup_resize(hit_result):
	var world_position = hit_result.position
	var local_coordinates = to_local(world_position)
	var cube_coordinates = local_coordinates / extents
	var abs_cube_coordinates = Vector3(abs(cube_coordinates.x), abs(cube_coordinates.y), abs(cube_coordinates.z))

	var major_axis = abs_cube_coordinates.max_axis()
	var minor_axis = abs_cube_coordinates.min_axis()
	var second_axis = 3 - major_axis - minor_axis

	var suggested_direction = Vector3()

	var handle = $ResizeHandle

	var distance_from_margin = extents[second_axis] - abs(local_coordinates[second_axis])
	if distance_from_margin < resize_margin:
		# near to the edge, suggest resize
		handle.visible = true
		resize_axis = Vector3()
		resize_axis[second_axis] = sign(local_coordinates[second_axis])

		resize_normal_axis = major_axis
		resize_grab_point[major_axis] = sign(local_coordinates[major_axis]) * extents[major_axis]
		resize_grab_point[second_axis] = sign(local_coordinates[second_axis]) * extents[second_axis]
		resize_grab_point[minor_axis] = local_coordinates[minor_axis]

		handle.translation = resize_grab_point

	else:
		# not near to edge, hide handle
		handle.visible = false

	return transform.basis.xform(suggested_direction)

var resize_plane: Plane

func start_resize():
	if target == null:
		return
	resize_origin = -resize_axis * extents
	current_mode = BRUSH_EDITING

	var plane_normal = Vector3()
	# local space
	# TODO: resize_normal_axis can be null
	plane_normal[resize_normal_axis] = 1
	# world space
	plane_normal = transform.basis.xform(plane_normal)
	var plane_distance = last_hit_position.project(plane_normal)

	resize_plane = Plane(plane_normal, plane_distance.length())
	resize_previous_extents = extents
	resize_starting_point = translation


func stop_resize():
	target.set_extents(extents)
	target.translation = translation
	set_mode(BRUSH_EDIT)

onready var brick_template = preload("res://Aether/Construction/Brick.tscn")

func fire():

	if current_mode == BRUSH_OFF:
		return

	if current_mode == BRUSH_BUILD:
		var new_brick = brick_template.instance()
		new_brick.translation = translation
		new_brick.rotation = rotation
		new_brick.set_extents(extents)
		get_tree().get_root().add_child(new_brick)
	elif current_mode == BRUSH_DESTROY:
		target.get_parent().remove_child(target)
		target = null
	elif current_mode == BRUSH_EDIT:
		start_resize()
	elif current_mode == BRUSH_EDITING:
		stop_resize()


