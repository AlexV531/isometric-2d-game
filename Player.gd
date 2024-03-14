class_name Player
extends Node2D

@export var tile_map: TileMap
var target_tile: Vector2i
var target_node: Node2D
#var interacting: bool = false
var interacting_delay: bool = false
var interactables_on_mouse: Array[Interactable] = []
var selected_interactable: Interactable = null

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

func _ready():
	move_state.state_finished.connect(fsm.change_state.bind(idle_state))
	# Link dialogic timelines end to unfreeze player
	Dialogic.timeline_ended.connect(dialogue_ended)

func _input(event):
	# Default
	if fmsm.state == default_meta_state:
		# Interact with the outlined interactable
		if event.is_action_pressed("rightClick"):
			if selected_interactable != null:
				selected_interactable.open_menu()
				fmsm.change_state(interacting_meta_state)
		# Move to a map space
		if event.is_action_pressed("leftClick"):
			target_tile = tile_map.local_to_map(get_global_mouse_position())
			fsm.change_state(move_state)
		# Enter slow meta state (for attacking probably)
		if event.is_action_pressed("slowTime"):
			fmsm.change_state(slow_meta_state)
		return
	# Interacting
	if fmsm.state == interacting_meta_state:
		# Put inputs that happen when interacting here           Here's the rightclick we could remove to fix the issue
		if event.is_action_pressed("leftClick") || event.is_action_pressed("rightClick"):
			if selected_interactable != null:
				# Check if the mouse is clicking on an action button, if not close the interact menu 
				if !Rect2(selected_interactable.box_container.global_position, selected_interactable.box_container.get_rect().size).has_point(get_global_mouse_position()):
					selected_interactable.close_menu()
		return
	# Slow
	if fmsm.state == slow_meta_state:
		# Exit slow mode
		if event.is_action_pressed("slowTime"):
			fmsm.change_state(default_meta_state)
		return
	# Talking
	if fmsm.state == talking_meta_state:
		return

func dialogue_ended():
	#print("dialogue ended")
	fmsm.change_state(default_meta_state)

# Return values let the interactable know if it is selected or not.
func set_interactable_on_mouse(interactable: Interactable):
	# PLAN: INSERT IN SORTED ORDER BASED ON Y VALUE
	interactables_on_mouse.append(interactable)

func unset_interactable_on_mouse(interactable: Interactable):
	interactables_on_mouse.erase(interactable)

func is_interacting():
	return fmsm.state is InteractingMetaState
