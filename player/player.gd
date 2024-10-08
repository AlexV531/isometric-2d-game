class_name Player
extends CharacterBody2D

# For moving around the tilemap:
@export var tile_map: TileMap
var target_tile: Vector2i
var target_node: Node2D

# Movement
@export var free_movement: bool = true
@export var speed: float = 5000
var move_input_down: bool = false

# For interacting with interactable objects:
#var interacting: bool = false
var interacting_delay: bool = false
var interactables_on_mouse: Array[Interactable] = []
var selected_interactable: Interactable = null

# For targeting targetable objects in slow mode:
var targeted_nodes: Array[Interactable] = [] # There can be duplicates in the targeted_nodes list
var max_targeted_nodes = 3
var current_player_action = null # Current action, when in default meta state the current action will play out
# Player actions are things that the player can do to interactables like shoot, punch, etc.

@onready var fsm = $FiniteStateMachine as FiniteStateMachine
@onready var move_state = $FiniteStateMachine/MoveState as MoveState
@onready var move_one_away_state = $FiniteStateMachine/MoveOneAwayState as MoveOneAwayState
@onready var chase_state = $FiniteStateMachine/ChaseState as ChaseState
@onready var idle_state = $FiniteStateMachine/IdleState as IdleState

@onready var fmsm = $FiniteMetaStateMachine as FiniteStateMachine
@onready var default_meta_state = $FiniteMetaStateMachine/DefaultMetaState as DefaultMetaState
@onready var interacting_meta_state = $FiniteMetaStateMachine/InteractingMetaState as InteractingMetaState
@onready var slow_meta_state = $FiniteMetaStateMachine/SlowMetaState as SlowMetaState
@onready var talking_meta_state = $FiniteMetaStateMachine/TalkingMetaState as TalkingMetaState
@onready var paused_meta_state = $FiniteMetaStateMachine/PausedMetaState as PausedMetaState

@onready var inventory = $Inventory
@onready var inventory_menu = $UI/InventoryMenu
@export var ui_controller: UIController

@onready var shooter = $Shooter
#@onready var raycast = shooter.raycast
#@onready var bullet_trail = $BulletTrail

var test_collision_point: Vector2

# TEMPORARY STATS, MOVE LATER
var how_many_shots_in_slow = 3
var rate_of_fire = 0.5 # Bullets per second
var slow_time_limit = 10
var selected_action: Action.Tag = Action.Tag.SHOOT

func _ready():
	move_state.state_finished.connect(fsm.change_state.bind(idle_state))
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	# Linking inventory item slots
	for item_slot in get_tree().get_nodes_in_group("item_slot"):
		var index = item_slot.get_index()
		item_slot.gui_input.connect(ui_controller._on_ItemSlot_gui_input.bind(index, inventory))
		item_slot.mouse_entered.connect(ui_controller.show_tooltip.bind(index, inventory))
		item_slot.mouse_exited.connect(ui_controller.hide_tooltip)
	# Link dialogic timelines end to unfreeze players
	DialogueManager.dialogue_ended.connect(dialogue_ended)

func _process(delta):
	#queue_redraw()
	
	# Move in mouse direction
	if free_movement and move_input_down:
		var move_dir: Vector2 = get_global_mouse_position() - position
		velocity = move_dir.normalized() * speed * delta
		move_and_slide()
	
	# Raycast Testing
	#raycast.target_position = get_local_mouse_position()

func _unhandled_input(event):
	# Default
	if fmsm.state == default_meta_state:
		# Interact with the outlined interactable
		if event.is_action_pressed("rightClick"):
			if selected_interactable != null:
				selected_interactable.open_menu()
				fmsm.change_state(interacting_meta_state)
		# Move to a map space
		if event.is_action_pressed("leftClick"):
			if free_movement:
				move_input_down = true
			else:
				target_tile = tile_map.local_to_map(get_global_mouse_position())
				fsm.change_state(move_state)
		if event.is_action_released("leftClick"):
			if free_movement:
				move_input_down = false
		# Enter slow meta state (for attacking probably)
		if event.is_action_pressed("slowTime"):
			fmsm.change_state(slow_meta_state)
		if event.is_action_pressed("ui_menu"):
			ui_controller.open_inventory(inventory_menu)
			fmsm.change_state(paused_meta_state)
		if event.is_action_pressed("move_mode_toggle"):
			free_movement = !free_movement
			move_input_down = false
		# 
	# Interacting
	elif fmsm.state == interacting_meta_state:
		# Put inputs that happen when interacting here           Here's the rightclick we could remove to fix the issue
		if event.is_action_pressed("leftClick") || event.is_action_pressed("rightClick"):
			if selected_interactable != null:
				# Check if the mouse is clicking on an action button, if not close the interact menu 
				if !Rect2(selected_interactable.box_container.global_position, selected_interactable.box_container.get_rect().size).has_point(get_global_mouse_position()):
					selected_interactable.close_menu()
	# Slow
	elif fmsm.state == slow_meta_state:
		# All the targetable objects will highlight in red. The player can choose one to activate (right now just shoot)
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
				target_tile = tile_map.local_to_map(get_global_mouse_position())
				fsm.change_state(move_state)
	# Talking
	elif fmsm.state == talking_meta_state:
		pass
	elif fmsm.state == paused_meta_state:
		if event.is_action_pressed("ui_menu"):
			ui_controller.close_inventory(inventory_menu)
			fmsm.change_state(default_meta_state)

#func _draw():
	#for targeted_node in targeted_nodes:
#		draw_line(Vector2.ZERO, targeted_node.position - position, Color.RED, -1.0, false)
	#var color = Color.WHITE
	#if raycast.is_colliding():
	#	color = Color.RED
	#	draw_circle(to_local(raycast.get_collision_point()) + shot_height, 3, Color.RED)
	#if test_collision_point:
	#	draw_circle(to_local(test_collision_point), 3, Color.RED)
	#draw_line(raycast.position + shot_height, raycast.target_position + shot_height, color, -1.0, false)
	

func dialogue_ended(dialogue_resource: DialogueResource):
	print("dialogue ended")
	fmsm.change_state(default_meta_state)

# Return values let the interactable know if it is selected or not.
func set_interactable_on_mouse(interactable: Interactable):
	# PLAN: INSERT IN SORTED ORDER BASED ON Y VALUE
	interactables_on_mouse.append(interactable)

func unset_interactable_on_mouse(interactable: Interactable):
	interactables_on_mouse.erase(interactable)

func is_interacting():
	return fmsm.state is InteractingMetaState
