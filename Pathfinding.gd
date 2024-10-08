extends GridMap

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
