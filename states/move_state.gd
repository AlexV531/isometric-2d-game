class_name MoveState
extends State

@export var actor: Node3D # Put any nessesary data like tilemap and target position here
@export var speed: int = 4

var floor_height = 0.5

var timer: Timer
var delaying: bool = false
var obstructed_tile: Vector2i
var path = []

func _ready():
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	set_physics_process(false)

func _enter_state() -> void:
	var curr_tile = actor.grid_map.local_to_map(actor.global_position)
	# Find path based on current position and target tile
	var id_path = actor.grid_map.astar_grid.get_id_path(
		Vector2i(curr_tile.x, curr_tile.z),
		actor.target_tile
	).slice(1)
	
	if (!id_path.is_empty()):
		path = id_path
	
	set_physics_process(true)

func _exit_state() -> void:
	set_physics_process(false)

func _physics_process(delta):
	# Check delay timer
	if delaying:
		#print("delaying")
		if timer.is_stopped():
			# Make new path, if null, reset timer
			var curr_tile_2 = actor.grid_map.local_to_map(actor.global_position)
			path = actor.grid_map.astar_grid.get_id_path(
				Vector2i(curr_tile_2.x, curr_tile_2.z),
				actor.target_tile
			).slice(1)
		
			if !path.is_empty():
				delaying = false
			# If path is null, delay for a second and try again
			else:
				delaying = true
				timer.start()
				return
		else:
			return
	
	if path.is_empty():
		#print("finished")
		state_finished.emit()
		return
	
	var next_pos = actor.grid_map.map_to_local(Vector3i(path.front().x, 0, path.front().y)) + Vector3(0, actor.global_position.y - floor_height, 0)
	
	actor.global_position = actor.global_position.move_toward(next_pos, delta * speed)
	
	if (actor.global_position == next_pos):
		var curr_tile = path.pop_front()
		
		# Check if next tile is obstructed.
		# If so, find new path
		if (!path.is_empty() && actor.grid_map.astar_grid.is_point_solid(path.front())):
			print("path blocked")
			
			var curr_tile_2 = actor.grid_map.local_to_map(actor.global_position)
			path = actor.grid_map.astar_grid.get_id_path(
				Vector2i(curr_tile_2.x, curr_tile_2.z),
				actor.target_tile
			).slice(1)
			print(path)
			
			# An alternate path is found:
			if !path.is_empty():
				delaying = false
			# Otherwise, wait 1 second and try again
			else:
				delaying = true
				timer.start()
