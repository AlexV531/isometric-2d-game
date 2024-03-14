extends TileMap

var astar_grid: AStarGrid2D

var three_twenty: bool = false

func _ready():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = get_used_rect()
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar_grid.update()
	
	for x in get_used_rect().size.x:
		for y in get_used_rect().size.y:
			var tile_pos = Vector2i(x + get_used_rect().position.x, y + get_used_rect().position.y)
			var tile_data = get_cell_tile_data(0, tile_pos)
			
			if tile_data == null || tile_data.get_custom_data("walkable") == false:
				astar_grid.set_point_solid(tile_pos, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	"""
	if (Input.is_action_just_pressed("leftClick")):
		#print(get_global_mouse_position())
		var mouseTile = local_to_map(get_global_mouse_position())
		print("Mouse located at:", mouseTile)
		#print(Vector2(414, 57.5))
		#print(local_to_map(Vector2(414, 57.5)))
		#print(find_path(Vector2(414, 57.5), mouseTile))
		
		
	if (Input.is_action_just_pressed("rightClick")):
		var mouseTile = local_to_map(get_global_mouse_position())
		var minHeap = PriorityQueue.new()
		minHeap.insert(mouseTile, 1)
		#print(minHeap._data)
		print(get_weighted_distance(Vector2i(9, 15), Vector2i(9, 17)))
		print(get_weighted_distance(Vector2i(9, 19), Vector2i(10, 18)))
		print(get_weighted_distance(Vector2i(9, 19), Vector2i(10, 16)))
		print(get_weighted_distance(Vector2i(10, 23), Vector2i(11, 25)))
		print(get_neighbors(Vector2i(49, 49)))

func find_path(start_pos, target_pos):
	
	#if (abs(start_pos.x) > 50 || abs(start_pos.y) > 50):
	#	return null
	
	var open = PriorityQueue.new()
	var closed = {}
	var g_cost = {}
	var parent = {}
	
	g_cost[start_pos] = 0
	parent[start_pos] = null
	
	# If the start pos is not on a grid space
	if(start_pos is Vector2):
		var neighbors = get_neighbors_float(start_pos)
		#print("Vector2 check passed, neighbors are:", neighbors)
		for i in range(0, neighbors.size()):
			
			var current_g_cost = get_weighted_distance_start_pos(start_pos, neighbors[i])
			g_cost[neighbors[i]] = current_g_cost
			var h_cost = get_weighted_distance(neighbors[i], target_pos)/2
			var f_cost = current_g_cost + h_cost
			open.insert(neighbors[i], f_cost)
			parent[neighbors[i]] = start_pos
	else:
		#print("Vector2 check failed")
		open.insert(start_pos, 0)
	
	while open.size() > 0:
		var current_node = open.extract()
		var current_tile = Vector2i(int(current_node.x), int(current_node.y))
		
		#closed[current_tile] = true

		if (current_tile == target_pos):
			return retrace_path(start_pos, target_pos, parent)
		
		var neighbors = get_neighbors(current_tile)
		
		for i in range(0, neighbors.size()):
			# Checks if the neighbor is in the closed list
			#if(closed.has(neighbors[i])):
			#	continue
			
			var new_movement_cost_to_neighbor = g_cost[current_tile] + get_weighted_distance(current_tile, neighbors[i])
			
			if (!g_cost.has(neighbors[i])):
				if(!g_cost.has(neighbors) || new_movement_cost_to_neighbor < g_cost[neighbors[i]]):
					g_cost[neighbors[i]] = new_movement_cost_to_neighbor
					var h_cost = get_weighted_distance(neighbors[i], target_pos)/2
					var f_cost = new_movement_cost_to_neighbor + h_cost
					open.insert(neighbors[i], f_cost)
					parent[neighbors[i]] = current_tile
	
	return []

func retrace_path(start_pos, target_pos, parent):
	var path = []
	var current_tile = target_pos
	while (parent[current_tile] != null):
		path.push_front(current_tile)
		current_tile = parent[current_tile]
	return path

# Get neighbors surrounding a tile on an isometric tilemap
func get_neighbors(tile_pos: Vector2i):
	var neighbors = []
	# Obstruction variables for diagonal tiles
	var tL = true
	var tR = true
	var bL = true
	var bR = true
	# First check diagonals, if they aren't obstructed, check verticals and horizontals
	# Due to the isometric nature, we need to check if the y is even or odd.
	if(tile_pos.y % 2 == 0):
		if(!check_obstacle(Vector2i(tile_pos.x - 1, tile_pos.y - 1))):
			neighbors.append(Vector2i(tile_pos.x - 1, tile_pos.y - 1))
			tL = false
		if(!check_obstacle(Vector2i(tile_pos.x, tile_pos.y - 1))):
			neighbors.append(Vector2i(tile_pos.x, tile_pos.y - 1))
			tR = false
		if(!check_obstacle(Vector2i(tile_pos.x - 1, tile_pos.y + 1))):
			neighbors.append(Vector2i(tile_pos.x - 1, tile_pos.y + 1))
			bL = false
		if(!check_obstacle(Vector2i(tile_pos.x, tile_pos.y + 1))):
			neighbors.append(Vector2i(tile_pos.x, tile_pos.y + 1))
			bR = false
	else:
		if(!check_obstacle(Vector2i(tile_pos.x, tile_pos.y - 1))):
			neighbors.append(Vector2i(tile_pos.x, tile_pos.y - 1))
			tL = false
		if(!check_obstacle(Vector2i(tile_pos.x + 1, tile_pos.y - 1))):
			neighbors.append(Vector2i(tile_pos.x + 1, tile_pos.y - 1))
			tR = false
		if(!check_obstacle(Vector2i(tile_pos.x, tile_pos.y + 1))):
			neighbors.append(Vector2i(tile_pos.x, tile_pos.y + 1))
			bL = false
		if(!check_obstacle(Vector2i(tile_pos.x + 1, tile_pos.y + 1))):
			neighbors.append(Vector2i(tile_pos.x + 1, tile_pos.y + 1))
			bR = false
	# Vertical and horizontal tiles need to check to make sure adjacent diagonal tiles arent obstructed
	# Vertical tiles
	if(!(tL || tR) && !check_obstacle(Vector2i(tile_pos.x, tile_pos.y - 2))):
		neighbors.append(Vector2i(tile_pos.x, tile_pos.y - 2))
	if(!(bL || bR) && !check_obstacle(Vector2i(tile_pos.x, tile_pos.y + 2))):
		neighbors.append(Vector2i(tile_pos.x, tile_pos.y + 2))
	# Horizontal tiles
	if(!(tL || bL) && !check_obstacle(Vector2i(tile_pos.x - 1, tile_pos.y))):
		neighbors.append(Vector2i(tile_pos.x - 1, tile_pos.y))
	if(!(tR || bR) && !check_obstacle(Vector2i(tile_pos.x + 1, tile_pos.y))):
		neighbors.append(Vector2i(tile_pos.x + 1, tile_pos.y))
	
	return neighbors;

# Get neighbors method if the position is not an integer
# Used for when the starting position is not perfectly aligned with a tile
func get_neighbors_float(pos: Vector2):
	var neighbors = []
	
	var pos_lower_bound = Vector2(pos.x, pos.y + (tile_set.tile_size.y/2))
	var tile_pos = local_to_map(pos_lower_bound)
	
	if(!check_obstacle(tile_pos)):
		neighbors.append(tile_pos)
	if(!check_obstacle(Vector2i(tile_pos.x, tile_pos.y - 2))):
		neighbors.append(Vector2i(tile_pos.x, tile_pos.y - 2))
	if(!check_obstacle(Vector2i(tile_pos.x, tile_pos.y - 1))):
		neighbors.append(Vector2i(tile_pos.x, tile_pos.y - 1))
	if(tile_pos.y % 2 == 0):
		if(!check_obstacle(Vector2i(tile_pos.x - 1, tile_pos.y - 1))):
			neighbors.append(Vector2i(tile_pos.x - 1, tile_pos.y - 1))
	else:
		if(!check_obstacle(Vector2i(tile_pos.x + 1, tile_pos.y - 1))):
			neighbors.append(Vector2i(tile_pos.x + 1, tile_pos.y - 1))
	
	return neighbors

func check_obstacle(tile_pos: Vector2i):
	# If the texture of the tile is the orange on layer 1, it is an obstacle and return true
	# Or if the tile includes a value in its coordinates that is beyond the bounds
	return ((get_cell_atlas_coords(1, tile_pos, false) == Vector2i(1, 6))) || ((abs(tile_pos.x) > 50 || abs(tile_pos.y) > 50))
	

func get_weighted_distance(tile_a: Vector2i, tile_b: Vector2i):
	# Converts the coordates to pixels instead of tilemap coords for easier calculations
	var tile_a_real = map_to_local(tile_a)
	var tile_b_real = map_to_local(tile_b)
	# Finds the differences between the xs and ys
	var diff_x = abs(tile_a_real.x - tile_b_real.x)
	var diff_y = abs(tile_a_real.y - tile_b_real.y)*2
	
	# Finds the distance between the two points and returns it
	var distance
	if (diff_x > diff_y):
		distance = sqrt(2)*diff_y + (diff_x - diff_y)
	else:
		distance = sqrt(2)*diff_x + (diff_y - diff_x)
	return distance

# Used only to find the distance between a local position and a map position
# Used in the case that the start position isn't exactly on a grid space, such as if they get a new 
# movement target while they are already moving between two points
func get_weighted_distance_start_pos(start_pos: Vector2, tile_b: Vector2i):
	var tile_a_real = start_pos
	var tile_b_real = map_to_local(tile_b)
	
	var diff_x = abs(tile_a_real.x - tile_b_real.x)
	var diff_y = abs(tile_a_real.y - tile_b_real.y)*2
	
	var distance
	
	if (diff_x > diff_y):
		distance = sqrt(2)*diff_y + (diff_x - diff_y)
	else:
		distance = sqrt(2)*diff_x + (diff_y - diff_x)
	
	return distance
"""
