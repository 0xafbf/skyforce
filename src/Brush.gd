extends Node3D

class_name Brush



var current_mode = BrushMode.BRUSH_OFF

@export var build_mat: Material
@export var destroy_mat: Material
@export var edit_mat: Material
@export var editing_mat: Material
@export var paint_mat: Material

var spawn_rotation = 0.0
var snap_size = 0.5

var target: Brick
@onready var brush_mesh = $BrushMesh


func set_target(in_target):
	target = in_target
	if (target):
		size = target.size
	else:
		# extents = Vector3(1,1,1)
		$ResizeHandle.visible = false
	set_extents(size)

func set_extents(in_extents: Vector3):
	size = in_extents.abs()
	brush_mesh.scale = size + Vector3(0.02, 0.02, 0.02)

func _ready():
	set_target(null)
	set_mode(BrushMode.BRUSH_OFF)

func set_mode(new_mode):
	current_mode = new_mode

	$ResizeHandle.visible = false
	visible = (current_mode != BrushMode.BRUSH_OFF)

	$BrushUI.set_brush_mode(current_mode)

	if current_mode == BrushMode.BRUSH_BUILD:
		$BrushMesh.material_override = build_mat
	elif current_mode == BrushMode.BRUSH_DESTROY:
		$BrushMesh.material_override = destroy_mat
	elif current_mode == BrushMode.BRUSH_EDIT:
		$BrushMesh.material_override = edit_mat
	elif current_mode == BrushMode.BRUSH_EDITING:
		$BrushMesh.material_override = editing_mat
	elif current_mode == BrushMode.BRUSH_PAINT:
		$BrushMesh.material_override = paint_mat
		$BrushUI.set_paint_id(active_skin)


var size = Vector3(1,1,1)
func snap_to_position_and_direction(in_position: Vector3, in_direction: Vector3):
	var local_direction = (in_direction) * transform.basis
	var local_offset = local_direction * size
	var world_offset = transform.basis * (local_offset)
	position = in_position + world_offset

var last_hit_position
func aim_brush(from_position: Vector3, direction: Vector3):

	if current_mode == BrushMode.BRUSH_OFF:
		return

	if current_mode == BrushMode.BRUSH_EDITING:
		var resize_current_point = resize_plane.intersects_ray(from_position, direction)

		if resize_current_point == null:
			return
		var resize_delta = resize_current_point - last_hit_position
		var local_resize_delta = (resize_delta) * transform.basis
		local_resize_delta *= resize_axis
		#local_resize_delta /= snap_size
		var resize_coords = Vector3()
		resize_coords.x = int(local_resize_delta.x)
		resize_coords.y = int(local_resize_delta.y)
		resize_coords.z = int(local_resize_delta.z)
		resize_coords *= snap_size

		var final_extents = resize_previous_extents + resize_coords
		set_extents(final_extents)
		position = resize_starting_point + transform.basis * (resize_coords * resize_axis)

		var arrow_position = (resize_current_point) * transform
		arrow_position -= arrow_position.project(resize_axis)
		arrow_position += resize_axis * size
		$ResizeHandle.position = arrow_position

		return

	var to = from_position + (direction * 100)
	var space_state = get_world_3d().direct_space_state
	var hit_result = space_state.intersect_ray(from_position, to)


	if !hit_result:
		return

	visible = true
	var collider = hit_result.collider
	var brick: Brick = collider.owner as Brick
	# if colliding with an already existing brick
	if brick:
		last_hit_position = hit_result.position

		if current_mode == BrushMode.BRUSH_BUILD:
			rotation = brick.rotation

			var hit_position = hit_result.position
			var next_brick_direction = brick.get_suggested_build_direction(hit_position)
			var next_brick_position = brick.get_snapping_position(hit_position)

			snap_to_position_and_direction(next_brick_position, next_brick_direction)

		elif current_mode == BrushMode.BRUSH_DESTROY:
			rotation = brick.rotation
			position = brick.position
			set_target(brick)
		elif current_mode == BrushMode.BRUSH_EDIT:
			rotation = brick.rotation
			position = brick.position
			set_target(brick)
			setup_resize(hit_result)
		elif current_mode == BrushMode.BRUSH_PAINT:
			rotation = brick.rotation
			position = brick.position
			set_target(brick)

	else:
		set_target(null)
		rotation.y = spawn_rotation
		position = hit_result.position

var resize_margin = 0.4
var resize_normal_axis: Vector3
var resize_axis: Vector3
var resize_grab_point = Vector3()
var resize_previous_extents: Vector3
var resize_starting_point: Vector3

func setup_resize(hit_result):
	var world_position = hit_result.position
	var local_coordinates = to_local(world_position)
	var cube_coordinates = local_coordinates / size
	var abs_cube_coordinates = Vector3(abs(cube_coordinates.x), abs(cube_coordinates.y), abs(cube_coordinates.z))

	var major_axis = abs_cube_coordinates.max_axis()
	var minor_axis = abs_cube_coordinates.min_axis()
	var second_axis = 3 - major_axis - minor_axis

	var suggested_direction = Vector3()

	var handle = $ResizeHandle

	var distance_from_margin = size[second_axis] - abs(local_coordinates[second_axis])
	if distance_from_margin < resize_margin:
		# near to the edge, suggest resize in WS edge direction
		handle.visible = true
		resize_axis = Vector3()
		resize_axis[second_axis] = sign(local_coordinates[second_axis])

		resize_normal_axis = Vector3()
		resize_normal_axis[major_axis] = sign(local_coordinates[major_axis])
		resize_grab_point[major_axis] = sign(local_coordinates[major_axis]) * size[major_axis]
		resize_grab_point[second_axis] = sign(local_coordinates[second_axis]) * size[second_axis]
		resize_grab_point[minor_axis] = local_coordinates[minor_axis]

		handle.position = resize_grab_point
		var resize_right = resize_axis.cross(resize_normal_axis)
		handle.transform.basis = Basis(resize_right, resize_normal_axis, resize_axis)

	else:
		# not near to edge, resize in normal direction
		handle.visible = true
		resize_axis = Vector3()
		resize_axis[major_axis] = sign(local_coordinates[major_axis])
		resize_normal_axis = Vector3()
		resize_normal_axis[second_axis] = sign(local_coordinates[second_axis])

		handle.position = local_coordinates
		var resize_right = resize_axis.cross(resize_normal_axis)
		handle.transform.basis = Basis(resize_right, resize_normal_axis, resize_axis)


	return transform.basis * (suggested_direction)

var resize_plane: Plane

func start_resize():
	if target == null:
		return


	current_mode = BrushMode.BRUSH_EDITING

	var plane_normal = transform.basis * (resize_normal_axis)
	var plane_distance = last_hit_position.dot(plane_normal)

	resize_plane = Plane(plane_normal, plane_distance )#.length())
	resize_previous_extents = size
	resize_starting_point = position



func stop_resize():
	target.set_extents(size)
	target.position = position
	set_mode(BrushMode.BRUSH_EDIT)

var brick_template = preload("res://assets/bricks/Brick.tscn")

func fire():

	if current_mode == BrushMode.BRUSH_OFF:
		return

	if current_mode == BrushMode.BRUSH_BUILD:
		var new_brick = brick_template.instantiate()
		new_brick.position = position
		new_brick.rotation = rotation
		new_brick.set_extents(size)
		get_tree().get_root().add_child(new_brick)
	elif current_mode == BrushMode.BRUSH_DESTROY:
		if target:
			target.get_parent().remove_child(target)
		target = null
	elif current_mode == BrushMode.BRUSH_EDIT:
		start_resize()
	elif current_mode == BrushMode.BRUSH_EDITING:
		stop_resize()
	elif current_mode == BrushMode.BRUSH_PAINT:
		paint_target()

enum BrushSkin {
	CLEAR,
	WOOD,
}
var active_skin = 0 # this could work like a block type

func set_active_skin(skin_id):
	active_skin = clamp(skin_id, 0, 2)
	$BrushUI.set_paint_id(active_skin)

func paint_target():
	if target:
		print("painting %d" % active_skin)
		target.set_skin(active_skin)


var rotation_snaps = 48
func _input(event):
	if event.is_action_pressed("slot_1"):
		set_mode(BrushMode.BRUSH_OFF)
	elif event.is_action_pressed("slot_2"):
		set_mode(BrushMode.BRUSH_BUILD)
	elif event.is_action_pressed("slot_3"):
		set_mode(BrushMode.BRUSH_DESTROY)
	elif event.is_action_pressed("slot_4"):
		set_mode(BrushMode.BRUSH_EDIT)
	elif event.is_action_pressed("slot_5"):
		set_mode(BrushMode.BRUSH_PAINT)
	elif event.is_action_pressed("preset_1"):
		set_preset(0)
	elif event.is_action_pressed("preset_2"):
		set_preset(1)
	elif event.is_action_pressed("preset_3"):
		set_preset(2)
	elif event.is_action_pressed("preset_4"):
		set_preset(3)

	if current_mode == BrushMode.BRUSH_PAINT:
		if event.is_action_pressed("variant_next"):
			set_active_skin(active_skin+1)
		elif event.is_action_pressed("variant_previous"):
			set_active_skin(active_skin-1)
	else:
		if event.is_action_pressed("variant_next"):
			spawn_rotation += (TAU/rotation_snaps)
		elif event.is_action_pressed("variant_previous"):
			spawn_rotation -= (TAU/rotation_snaps)


@export var presets # (Array, Vector3)
func set_preset(preset_idx):
	var preset = presets[preset_idx]
	set_extents(preset)
