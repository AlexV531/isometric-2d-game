class_name Building
extends Node2D

@export var tile_map: TileMap
@export var player: Player
@export var layer: int
@export var bounds: Array[Rect2i]

var inside: bool

func _process(delta):
	var x = tile_map.local_to_map(player.global_position).x
	var y = tile_map.local_to_map(player.global_position).y
	for bound in bounds:
		if((x >= bound.position.x && x <= bound.end.x) && (y >= bound.position.y && y <= bound.end.y)):
			if !inside:
				tile_map.set_layer_enabled(layer, false)
			inside = true
			return
	if inside:
		tile_map.set_layer_enabled(layer, true)
	inside = false

