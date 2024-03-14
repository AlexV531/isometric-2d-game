class_name Interactable
extends Area2D

@export var tile_map: TileMap
@export var player: Player
@export var theme: Theme
@export var outline: Sprite2D

# Can be set in inheiriting class, have default values set in _ready()
var move_state_option: MoveState

# Set the actions you want in the inheiriting class, for example the door might have the open/close action
var actions: Array[Action]
var buttons: Array[Button]
var box_container: VBoxContainer
var selected_action: Action

func _ready():
	box_container = VBoxContainer.new()
	# Add the action buttons
	for action in actions:
		var button = Button.new()
		button.pressed.connect(set_action.bind(action))
		button.text = action.get_action_name()
		button.custom_minimum_size = Vector2i(85, 16)
		buttons.append(button)
		box_container.add_child(button)
	# Add the Cancel button
	var button = Button.new()
	button.pressed.connect(set_action.bind(null))
	button.text = "Cancel"
	button.custom_minimum_size = Vector2i(85, 16)
	buttons.append(button)
	box_container.add_child(button)
	add_child(box_container)
	box_container.visible = false
	box_container.theme = theme
	box_container.z_index = 10
	
	# Meant to be changable in subclass
	move_state_option = player.move_one_away_state

func check_and_move():
	
	# If the player is further than 1 tile way from the interactable object, move 1 tile away from the interactable object then interact
	if util.tilemap_distance_to(tile_map, global_position, player.global_position) < 1.5:
		interact()
	else:
		# Move the player to one tile away from the interactable object
		# once the move state finishes it will immediately interact
		var tile_pos = tile_map.local_to_map(global_position)
		var obstructed = tile_map.astar_grid.is_point_solid(tile_pos)
		#print(move_state_option)
		move_state_option.state_finished.connect(interact, CONNECT_ONE_SHOT)
		choose_target()
		# Set the tile the interactable object is located on to be unobstructed just for the pathfinding section.
		if obstructed:
			tile_map.astar_grid.set_point_solid(tile_pos, false)
		player.fsm.change_state(move_state_option)
		if obstructed:
			tile_map.astar_grid.set_point_solid(tile_pos, true)

func interact():
	# Stop the player from moving
	player.fsm.change_state(player.idle_state) # Can change this state to a state related to the action.
	selected_action.execute()

func set_action(action: Action):
	# Hide the outline
	set_outline_visible(false)
	# Player is done with the menu, so close menu
	close_menu()
	# The cancel button sets the action to null
	if action == null:
		return
	selected_action = action
	# Move to to action
	check_and_move()

func open_menu():
	# Update the names of all the buttons in case the action names have changed
	for i in range(0, actions.size()):
		buttons[i].text = actions[i].get_action_name()
	# Open the interaction menu
	box_container.global_position = Vector2(global_position.x, global_position.y)
	box_container.visible = true
	Engine.time_scale = 0

"""
func close_menu():
	if !player.interacting:
		return
	# Would rather this is done in the player class but not sure how, so it stays in here for now.
	player.interacting = false
	box_container.visible = false
"""
func close_menu():
	if !player.is_interacting():
		return
	# Would rather this is done in the player class but not sure how, so it stays in here for now.
	player.fmsm.change_state(player.default_meta_state)
	box_container.visible = false
	Engine.time_scale = 1

func check_close_menu():
	if Rect2(box_container.global_position, box_container.get_rect().size).has_point(get_global_mouse_position()):
		print("hello")
		close_menu()

func choose_target():
	player.target_tile = tile_map.local_to_map(global_position)

func set_outline_visible(outline_visible):
	if outline != null:
		outline.visible = outline_visible

func _on_mouse_entered():
	player.set_interactable_on_mouse(self)

func _on_mouse_exited():
	player.unset_interactable_on_mouse(self)
