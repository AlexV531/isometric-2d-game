class_name Player3D
extends CharacterBody3D

# For moving around the tilemap:
@export var grid_map: GridMap
var target_tile: Vector2i
var target_node: Node3D
var target_tiles: Array[Vector2i] = [Vector2i(5, 6), Vector2i(4, -3)] # For multi tile moving, move_state chooses the closest and moves to that

# Movement
@export var free_movement: bool = false
@export var speed: float = 5000
var move_input_down: bool = false

# For interacting with interactable objects:
var interacting_delay: bool = false
var interactables_on_mouse: Array[Interactable] = []
var selected_interactable: Interactable = null
var hovered = null

# For targeting targetable objects in slow mode:
var targeted_nodes: Array[Interactable] = [] # There can be duplicates in the targeted_nodes list
var highlight_lines: Array[HighlightLine] = []
var max_targeted_nodes = 3
var default_player_action: Action.Tag = Action.Tag.DEFAULT
var current_player_action: Action.Tag = Action.Tag.MOVE_TO # Current action, when in default meta state the current action will play out
# Player actions are things that the player can do to interactables like shoot, punch, etc.

@onready var fsm = $FiniteStateMachine as FiniteStateMachine
@onready var move_state = $FiniteStateMachine/MoveState as MoveState
@onready var move_one_away_state = $FiniteStateMachine/MoveOneAwayState as MoveOneAwayState
@onready var chase_state = $FiniteStateMachine/ChaseState as ChaseState
@onready var idle_state = $FiniteStateMachine/IdleState as IdleState
@onready var multi_tile_choice_move_state = $FiniteStateMachine/MultiTileChoiceMoveState as MultiTileChoiceMoveState

@onready var fmsm = $FiniteMetaStateMachine as FiniteStateMachine
@onready var default_meta_state = $FiniteMetaStateMachine/DefaultMetaState as DefaultMetaState
@onready var interacting_meta_state = $FiniteMetaStateMachine/InteractingMetaState as InteractingMetaState
@onready var slow_meta_state = $FiniteMetaStateMachine/SlowMetaState as SlowMetaState
@onready var talking_meta_state = $FiniteMetaStateMachine/TalkingMetaState as TalkingMetaState
@onready var paused_meta_state = $FiniteMetaStateMachine/PausedMetaState as PausedMetaState

#@onready var ground_position = Vector3(10, 10, 10)

@onready var inventory = $Inventory
@onready var inventory_menu = $UI/InventoryMenu
@export var ui_controller: UIController

@onready var shooter: Shooter = $Shooter

@export var aim_highlight: HighlightLine
@export var grid_space_select: MeshInstance3D

@export var action_label: Label

@onready var camera = $Camera3D

@onready var animation = $AnimationPlayer

var highlight_line_scene = preload("res://highlight_line.tscn")

# TEMPORARY STATS, MOVE LATER
var how_many_shots_in_slow = 3
var rate_of_fire = 0.5 # Bullets per second
var slow_time_limit = 10
var selected_action: Action.Tag = Action.Tag.SHOOT # REDUNDANT, REMOVE LATER

# Developer option to test different control schemes
enum MouseControls {ORIGINAL, FALLOUT}
var mouse_control: MouseControls = MouseControls.FALLOUT

func _ready():
	move_state.state_finished.connect(fsm.change_state.bind(idle_state))
	motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	# Linking inventory item slots
	for item_slot in get_tree().get_nodes_in_group("item_slot"):
		var index = item_slot.get_index()
		item_slot.gui_input.connect(ui_controller._on_ItemSlot_gui_input.bind(index, inventory))
		item_slot.mouse_entered.connect(ui_controller.show_tooltip.bind(index, inventory))
		item_slot.mouse_exited.connect(ui_controller.hide_tooltip)
	# Link dialogic timelines end to unfreeze players
	DialogueManager.dialogue_ended.connect(dialogue_ended)
	
	# Populate highlight_lines array
	for i in range(10):
		var highlight_line = highlight_line_scene.instantiate()
		highlight_line.set_red(true)
		shooter.add_child(highlight_line)
		highlight_lines.append(highlight_line)

func _process(delta):
	#print(position)
	# All States
	# Highlight lines connecting to targeted nodes
	for highlight_line in highlight_lines: # Initially set all to inactive
		highlight_line.active = false
	var counter: int = 0
	for targeted_node in targeted_nodes: # Activate and set target positions
		highlight_lines[counter].target_position = targeted_node.position
		highlight_lines[counter].active = true
		counter += 1
	# Default
	if fmsm.state == default_meta_state:
		# During default state, interactables can always be right clicked, but left click action
		# depends on current_player_action
		var curr_hovered = grid_map.get_cursor_collider_world()
		if curr_hovered is Interactable:
			if hovered is Interactable:
				hovered.set_outline(false)
			curr_hovered.set_outline(true)
		elif hovered is Interactable:
			hovered.set_outline(false)
		hovered = curr_hovered
		# This part decides based on current player action
		match mouse_control:
			MouseControls.ORIGINAL:
				if current_player_action == Action.Tag.MOVE_TO:
					var curr_ground = grid_map.get_cursor_ground_position()
					move_action_passive(curr_ground)
				if current_player_action == Action.Tag.SHOOT:
					shoot_action_passive(curr_hovered)
			MouseControls.FALLOUT:
				if current_player_action == Action.Tag.MOVE_TO:
					var curr_ground = grid_map.get_cursor_ground_position()
					move_action_passive(curr_ground)
				if current_player_action == Action.Tag.SHOOT:
					shoot_action_passive(curr_hovered)
				if current_player_action == Action.Tag.DEFAULT:
					default_action_passive(curr_hovered)

func _unhandled_input(event):
	# Default
	if fmsm.state == default_meta_state:
		match mouse_control:
			MouseControls.ORIGINAL:
				if event.is_action_pressed("rightClick"):
					if hovered is Interactable:
						hovered.open_menu()
						fmsm.change_state(interacting_meta_state)
				# Move to a map space
				if event.is_action_pressed("leftClick"):
					if current_player_action == Action.Tag.MOVE_TO:
						move_action()
					if current_player_action == Action.Tag.SHOOT:
						if hovered is Interactable:
							targeted_nodes.append(hovered)
						print(targeted_nodes)
				if event.is_action_released("leftClick"):
					if current_player_action == Action.Tag.MOVE_TO:
						if free_movement:
							move_input_down = false
			MouseControls.FALLOUT:
				if event.is_action_pressed("rightClick"):
					if hovered is Interactable:
						hovered.open_menu()
						fmsm.change_state(interacting_meta_state)
					else:
						if current_player_action != Action.Tag.MOVE_TO:
							change_action(Action.Tag.MOVE_TO)
						elif current_player_action != default_player_action:
							change_action(default_player_action)
				if event.is_action_pressed("leftClick"):
					if current_player_action == Action.Tag.MOVE_TO:
						move_action()
					if current_player_action == Action.Tag.SHOOT:
						shoot_action()
					if current_player_action == Action.Tag.DEFAULT:
						if hovered is Interactable:
							hovered.execute_default_action()
				# Lean controls for when in cover
		# Enter slow meta state (for attacking probably)
		if event.is_action_pressed("slowTime"):
			#fmsm.change_state(slow_meta_state)
			#animation.play("peek_right")
			#fsm.change_state(multi_tile_choice_move_state)
			pass
		if event.is_action_pressed("inventory"):
			ui_controller.open_inventory(inventory_menu)
			fmsm.change_state(paused_meta_state)
		if event.is_action_pressed("execute_action"):
			if not targeted_nodes.is_empty():
				shooter.shoot(targeted_nodes)
				clear_targets()
	# Interacting
	elif fmsm.state == interacting_meta_state:
		# Put inputs that happen when interacting here           Here's the rightclick we could remove to fix the issue
		if event.is_action_pressed("leftClick") || event.is_action_pressed("rightClick"):
			if selected_interactable != null:
				# Check if the mouse is clicking on an action button, if not close the interact menu 
				#if !Rect2(selected_interactable.box_container.global_position, selected_interactable.box_container.get_rect().size).has_point(get_global_mouse_position()):
				#	selected_interactable.close_menu()
				pass
	# Slow
	elif fmsm.state == slow_meta_state:
		# All the targetable objects will highlight in red. The player can choose one to activate (right now just shoot)
		if event is InputEventMouseMotion:
			var curr_hovered = grid_map.get_cursor_collider_grid()
			if curr_hovered is Interactable and hovered is Interactable:
				if hovered:
					hovered.set_outline(false)
				curr_hovered.set_outline(true)
			else:
				if hovered:
					hovered.set_outline(false)
			hovered = curr_hovered
		# Exit slow mode
		if event.is_action_pressed("slowTime"):
			fmsm.change_state(default_meta_state)
			# All targeted objects will have the action happen to them.
			for targeted_node in targeted_nodes:
				targeted_node.gets_shot()
			targeted_nodes = []
		if event.is_action_pressed("rightClick"):
			if selected_interactable != null:
				pass
				# Add the object to a targeted objects list
		if event.is_action_pressed("leftClick"):
			if selected_interactable != null:
				if !(len(targeted_nodes) >= max_targeted_nodes) and selected_interactable.has_action_tag(selected_action):
					print(selected_action)
					targeted_nodes.append(selected_interactable)
			else:
				target_tile = grid_map.get_cursor_map_position()
				if target_tile != null:
					fsm.change_state(move_state)
	# Talking
	elif fmsm.state == talking_meta_state:
		print("help")
		pass
	# Paused
	elif fmsm.state == paused_meta_state:
		if event.is_action_pressed("inventory"):
			ui_controller.close_inventory(inventory_menu)
			fmsm.change_state(default_meta_state)

func move_action_passive(curr_hovered):
	if curr_hovered is Vector3:
		curr_hovered = grid_map.local_to_map(curr_hovered)
		var map_pos = to_local(grid_map.map_to_local(curr_hovered))
		if map_pos.x != to_local(grid_space_select.position).x or map_pos.z != to_local(grid_space_select.position).z:
			# Checks if the grid space is walkable, if not don't show grid space select
			grid_space_select.position.x = to_global(map_pos).x
			grid_space_select.position.y = 0.5
			grid_space_select.position.z = to_global(map_pos).z
			if grid_map.check_walkable(curr_hovered):
				grid_space_select.visible = true
			else:
				grid_space_select.visible = false
			# Path preview
			var curr_tile = grid_map.local_to_map(global_position)
			var path_preview = grid_map.astar_grid.get_id_path(
				Vector2i(curr_tile.x, curr_tile.z),
				Vector2i(map_pos.x, map_pos.z)
			).slice(1)
	else:
		grid_space_select.visible = false

func shoot_action_passive(curr_hovered):
	if curr_hovered is Interactable:
		curr_hovered = curr_hovered.position
		#print(curr_hovered)
	if not curr_hovered is Vector3:
		aim_highlight.active = false
		return
	aim_highlight.active = true
	# Adjust the target to have a range and not point at the ground
	var target_pos_adjusted = shooter.to_local(curr_hovered)
	target_pos_adjusted.y = 0.0
	target_pos_adjusted = target_pos_adjusted.normalized() * shooter.range
	var hit_position = shooter.check_shot(target_pos_adjusted)
	if hit_position != null:
		aim_highlight.target_position = hit_position
	else:
		aim_highlight.target_position = to_global(target_pos_adjusted)

func default_action_passive(curr_hovered):
	if curr_hovered is Interactable:
		action_label.position = get_viewport().get_mouse_position()
		action_label.position.y -= action_label.size.y
		action_label.text = curr_hovered.default_action.get_action_name()
		action_label.visible = true
	else:
		action_label.visible = false

func move_action():
	if free_movement:
		move_input_down = true
	else:
		var mouse_map_pos = grid_map.get_cursor_map_position() # Change this to ignore interactables
		if mouse_map_pos != null:
			target_tile = mouse_map_pos
			fsm.change_state(move_state)

func shoot_action():
	if hovered is Interactable:
		add_target(hovered)
	print(targeted_nodes)

func change_action(action: Action.Tag):
	current_player_action = action
	grid_space_select.visible = false
	grid_space_select.position = Vector3.ZERO
	aim_highlight.active = false

func add_target(target: Interactable):
	targeted_nodes.append(target)
	target.set_outline_red(true)

func clear_targets():
	for targeted_node in targeted_nodes:
		targeted_node.set_outline_red(false)
	targeted_nodes.clear()

func dialogue_ended(dialogue_resource: DialogueResource):
	print("dialogue ended")
	fmsm.change_state(default_meta_state)

func is_interacting():
	return fmsm.state is InteractingMetaState
