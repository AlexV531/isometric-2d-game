extends GridMap

var astar_grid: AStarGrid2D
var walkable_cell_indexes = [1, 2]

@onready var camera: Camera3D = get_viewport().get_camera_3d()

var cover_dict: Dictionary = {}

# For instantiating cover arrows
@export var cover_arrow: CoverInteractable

func _ready():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = _get_used_rect()
	#print(astar_grid.region)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar_grid.update()
	
	for x in range(astar_grid.region.position.x, astar_grid.region.position.x + astar_grid.region.size.x):
		for z in range(astar_grid.region.position.y, astar_grid.region.position.y + astar_grid.region.size.y):
			var tile_pos = Vector2i(x, z)
			var tile_data = get_cell_item(Vector3i(x, 0, z))
			# Checks the tile data, and if its not in the walkable index list, it will obstruct the tile.
			if tile_data not in walkable_cell_indexes:
				astar_grid.set_point_solid(tile_pos, true)
			# Adding Cover
			# Cover tiles are those where the player can peek and shoot from without using
			# the move action. If the target is on the other side of the cover, the shooter
			# decides which side of the cover to move to to shoot, then checks if the shot
			# can be made. If so, the shot takes place.
	for x in range(astar_grid.region.position.x, astar_grid.region.position.x + astar_grid.region.size.x):	
		for z in range(astar_grid.region.position.y, astar_grid.region.position.y + astar_grid.region.size.y):
			var tile_data = get_cell_item(Vector3i(x, 0, z))
			var orientation = get_cell_item_orientation(Vector3i(x, 0, z))
			# Corner piece, index 0
			if tile_data == 0:
				if orientation == 0: # Pointing up
					_add_cover(Vector3i(x, 0, z + 1), PI/2)
					_add_cover(Vector3i(x - 1, 0, z), 0.0)
				elif orientation == 10: # Pointing down
					_add_cover(Vector3i(x, 0, z - 1), -PI/2)
					_add_cover(Vector3i(x + 1, 0, z), PI)
				elif orientation == 16: # Pointint left
					_add_cover(Vector3i(x, 0, z + 1), PI/2)
					_add_cover(Vector3i(x + 1, 0, z), PI)
				elif orientation == 22: # Pointing right
					_add_cover(Vector3i(x, 0, z - 1), -PI/2)
					_add_cover(Vector3i(x - 1, 0, z), 0.0)
				#print(orientation, " ", (Vector3i(x, 0, z)))
			# Doorway piece, index 1
			if tile_data == 1:
				#_add_cover(Vector3i(x + 1, 0, z + 1), 0.0)
				#_add_cover(Vector3i(x - 1, 0, z + 1), 0.0)
				#_add_cover(Vector3i(x - 1, 0, z - 1), 0.0)
				#_add_cover(Vector3i(x + 1, 0, z - 1), 0.0)
				pass
	
	# Set up gound collision for detecting which grid space the mouse is clicking
	var ground_area = $Ground
	var map_centre = map_to_local(Vector3i(astar_grid.region.position.x + astar_grid.region.size.x / 2, 0, astar_grid.region.position.y + astar_grid.region.size.y / 2))
	ground_area.position = Vector3(map_centre.x, 0, map_centre.z)
	var ground_shape = $Ground/CollisionShape3D
	ground_shape.shape.size = Vector3(astar_grid.region.size.x + 1, 1, astar_grid.region.size.y + 1)

func _add_cover(map_pos: Vector3i, rotation_y: float):
	if map_pos in cover_dict:
		return # Update the cover highlight
	var new_cover = cover_arrow.duplicate()
	new_cover.position = map_to_local(map_pos)
	new_cover.position.y += 0.02
	new_cover.rotation.y = rotation_y
	add_child(new_cover)
	cover_dict[map_pos] = new_cover

func check_walkable(map_pos: Vector3i):
	if get_cell_item(map_pos) in walkable_cell_indexes:
		return true
	return false

func check_cover(map_pos: Vector3i):
	if map_pos in cover_dict:
		return cover_dict[map_pos]
	return false

func _get_used_rect() -> Rect2i:
	var used_cells = get_used_cells()
	if used_cells.is_empty():
		return Rect2i()
	var first_cell: Vector3i = used_cells.pop_front()
	var maxx = first_cell.x
	var minx = first_cell.x
	var maxz = first_cell.z
	var minz = first_cell.z
	for cell: Vector3i in used_cells:
		if cell.x > maxx:
			maxx = cell.x
		elif cell.x < minx:
			minx = cell.x
		if cell.z > maxz:
			maxz = cell.z
		elif cell.z < minz:
			minz = cell.z
	return Rect2i(minx, minz, maxx - minx + 1, maxz - minz + 1)

func get_cursor_collider_world():
	const RAY_DISTANCE = 64.0
	
	if not is_instance_valid(camera): return null
	var mouse_pos = get_viewport().get_mouse_position()
	
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + camera.project_ray_normal(mouse_pos) * RAY_DISTANCE
	
	var ray_params := PhysicsRayQueryParameters3D.create(from, to, 0b100)
	ray_params.collide_with_areas = true
	var ray_result: Dictionary = get_world_3d().direct_space_state.intersect_ray(ray_params)
	if round(ray_result.get("position", to).y * 1000) == 500:
		var mouse_world_pos = ray_result.get("position", to)
		return Vector3(mouse_world_pos.x, 0.5, mouse_world_pos.z)
	return ray_result.get("collider", null) # return Vector3.ZERO if needed

#func get_cursor_collider_ground():
	#const RAY_DISTANCE = 64.0
	#
	#if not is_instance_valid(camera): return null
	#var mouse_pos = get_viewport().get_mouse_position()
	#
	#var from: Vector3 = camera.project_ray_origin(mouse_pos)
	#var to: Vector3 = from + camera.project_ray_normal(mouse_pos) * RAY_DISTANCE
	#
	#var ray_params := PhysicsRayQueryParameters3D.create(from, to, 0b100)
	#ray_params.collide_with_areas = true
	#var ray_result: Dictionary = get_world_3d().direct_space_state.intersect_ray(ray_params)
	#if round(ray_result.get("position", to).y * 1000) == 500:
		#var mouse_world_pos = ray_result.get("position", to)
		#return Vector3(mouse_world_pos.x, 0.5, mouse_world_pos.z)
	#return ray_result.get("collider", null) # return Vector3.ZERO if needed

func get_cursor_ground_position() -> Vector3:
	const RAY_DISTANCE = 64.0
	
	if not is_instance_valid(camera): return Vector3.ZERO
	var mouse_pos = get_viewport().get_mouse_position()
	
	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + camera.project_ray_normal(mouse_pos) * RAY_DISTANCE
	
	var ray_params := PhysicsRayQueryParameters3D.create(from, to, 0b1000)
	ray_params.collide_with_areas = true
	var ray_result: Dictionary = get_world_3d().direct_space_state.intersect_ray(ray_params)
	
	return ray_result.get("position", to) # return Vector3.ZERO if needed

func get_cursor_map_position():
	var mouse_pos = get_cursor_ground_position()
	#print(mouse_pos)
	if round(mouse_pos.y * 1000) != 500:
		return null
	var mouse_map_pos = local_to_map(mouse_pos)
	return Vector2i(mouse_map_pos.x, mouse_map_pos.z)
