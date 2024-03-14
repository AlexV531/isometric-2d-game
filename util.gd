class_name util
extends Node

static func tilemap_distance_to(tile_map: TileMap, pos1: Vector2, pos2: Vector2):
	var tile_pos1 = tile_map.local_to_map(pos1)
	var tile_pos2 = tile_map.local_to_map(pos2)
	
	var tile_distance = sqrt((tile_pos1.x-tile_pos2.x)**2 + (tile_pos1.y-tile_pos2.y)**2)
	return tile_distance
