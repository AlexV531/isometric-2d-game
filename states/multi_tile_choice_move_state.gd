class_name MultiTileChoiceMoveState
extends MoveState


func _enter_state() -> void:
	var curr_tile = actor.grid_map.local_to_map(actor.global_position)
	
	var id_path = []
	var min_length = INF
	for target_tile_iter in actor.target_tiles: # For all targeted tiles, find the one that has the shortest path
		if Vector2i(curr_tile.x, curr_tile.z) == target_tile_iter:
			id_path = []
			break
		# Find path based on current position and target tile
		var curr_path = actor.grid_map.astar_grid.get_id_path(
			Vector2i(curr_tile.x, curr_tile.z),
			target_tile_iter
		).slice(1)
		print(curr_path)
		if curr_path.size() > 0 and curr_path.size() < min_length:
			min_length = curr_path.size()
			id_path = curr_path
	
	if (!id_path.is_empty()):
		path = id_path
	
	set_physics_process(true)
