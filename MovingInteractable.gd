class_name MovingInteractable
extends Interactable

@export var fsm: FiniteStateMachine
@export var this: MovingInteractable

func _ready():
	super._ready()
	move_state_option = player.chase_state

func choose_target():
	player.target_node = this
