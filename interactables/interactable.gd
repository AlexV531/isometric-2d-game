class_name Interactable
extends CollisionObject3D

@export var grid_map: GridMap
@export var player: Player3D
@export var action_select: VBoxContainer
@export var default_action: Action = null

# Can be set in inheiriting class, have default values set in _ready()
var move_state_option: MoveState

# Set the actions you want in the inheiriting class, for example the door might have the open/close action
var actions: Array[Action]
var buttons: Array[Button]
var selected_action: Action

var interact_tiles: Array[Vector2i] = [] # Set these in _ready if necessary

@onready var mesh_instance = $MeshInstance3D as MeshInstance3D

func _ready():
	# Add the action buttons
	for action in actions:
		var button = Button.new()
		button.pressed.connect(execute_action.bind(action))
		button.text = action.get_action_name()
		#button.custom_minimum_size = Vector2i(85, 16)
		buttons.append(button)
	# Add the Cancel button
	var button = Button.new()
	button.pressed.connect(execute_action.bind(null))
	button.text = "Cancel"
	#button.custom_minimum_size = Vector2i(85, 16)
	buttons.append(button)
	# Meant to be changable in subclass
	move_state_option = player.move_one_away_state
	#player.slow_meta_state.slow_state_entered.connect(_enter_slow_mode)
	#player.slow_meta_state.slow_state_exited.connect(_exit_slow_mode)
	if default_action == null:
		default_action = actions[0]

func _check_and_move():
	
	# If the player is further than 1 tile way from the interactable object, move 1 tile away from the interactable object then interact
	if util.grid_map_distance_to(grid_map, global_position, player.global_position) < 1.5 || !selected_action.move_to_actor:
		interact()
	else:
		# Move the player to one tile away from the interactable object
		# once the move state finishes it will immediately interact
		var tile_pos = grid_map.local_to_map(global_position)
		var obstructed = grid_map.astar_grid.is_point_solid(Vector2i(tile_pos.x, tile_pos.z))
		#print(move_state_option)
		move_state_option.state_finished.connect(interact, CONNECT_ONE_SHOT)
		if move_state_option is MultiTileChoiceMoveState:
			set_player_targets() # Sets the player's target tiles for the move state, for when there are multiple possible tiles the player can use as interactoin points
		elif move_state_option is ChaseState:
			player.target_node = self
		else:
			set_player_target() # Sets the player's target tile for the move state
		# Set the tile the interactable object is located on to be unobstructed just for the pathfinding section.
		if obstructed:
			grid_map.astar_grid.set_point_solid(tile_pos, false)
		player.fsm.change_state(move_state_option)
		if obstructed:
			grid_map.astar_grid.set_point_solid(tile_pos, true)

func interact():
	# Stop the player from moving
	player.fsm.change_state(player.idle_state) # Can change this state to a state related to the action.
	selected_action.execute()

func execute_action(action: Action):
	# Hide the outline
	#set_outline_visible(false)
	# Player is done with the menu, so close menu
	close_menu()
	# The cancel button sets the action to null
	if action == null:
		return
	selected_action = action
	# Move to to action
	_check_and_move()

func execute_default_action():
	selected_action = default_action
	# Move to the action
	_check_and_move()

func open_menu():
	# Update the names of all the buttons in case the action names have changed
	for i in range(0, actions.size()):
		buttons[i].text = actions[i].get_action_name()
	# Open the interaction menu
	action_select.global_position = Vector2(action_select.get_global_mouse_position().x, action_select.get_global_mouse_position().y)
	for button in buttons:
		action_select.add_child(button)
	action_select.visible = true

func close_menu():
	if !player.is_interacting():
		return
	# Would rather this is done in the player class but not sure how, so it stays in here for now.
	player.fmsm.change_state(player.default_meta_state)
	action_select.visible = false
	for button in buttons:
		action_select.remove_child(button)

func set_player_target():
	var target_pos = grid_map.local_to_map(global_position)
	player.target_tile = Vector2i(target_pos.x, target_pos.z)

func set_player_targets():
	player.target_tiles = interact_tiles

func has_action_tag(tag: Action.Tag):
	for action in actions:
		if action.action_tag == tag:
			return true
	return false

func set_outline(outlined: bool):
	mesh_instance.set_instance_shader_parameter("outlined", outlined)

func set_outline_red(red: bool):
	mesh_instance.set_instance_shader_parameter("red", red)

## Sets the interactable outline to red to mark it's 
#func _enter_slow_mode():
	#print("slow mode entered")
	#mesh_instance.set_instance_shader_parameter("red", true)
#
#func _exit_slow_mode():
	#print("slow mode exited")
	#mesh_instance.set_instance_shader_parameter("red", false)
