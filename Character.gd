class_name Character
extends MovingInteractable

@onready var test_action = $TestAction as TestAction
@onready var talk_action = $TalkAction as TalkAction

@onready var move_state = $FiniteStateMachine/MoveState as MoveState
@onready var idle_state = $FiniteStateMachine/IdleState as IdleState
@onready var wander_state = $FiniteStateMachine/WanderState as WanderState
@onready var listen_state = $FiniteStateMachine/ListenState as ListenState

var target_tile: Vector2i

func _ready():
	actions.append(talk_action)
	super._ready()
