class_name Character
extends MovingInteractable

@onready var test_action = $TestAction as TestAction
@onready var talk_action = $TalkAction as TalkAction
@onready var shoot_action = $ShootAction as ShootAction

@onready var fsm = $FiniteStateMachine as FiniteStateMachine
@onready var move_state = $FiniteStateMachine/MoveState as MoveState
@onready var idle_state = $FiniteStateMachine/IdleState as IdleState
@onready var wander_state = $FiniteStateMachine/WanderState as WanderState
@onready var listen_state = $FiniteStateMachine/ListenState as ListenState

@onready var animation_player = $AnimationPlayer as AnimationPlayer

@export var test_move: bool = true

var target_tile: Vector2i

func _ready():
	actions.append(talk_action)
	actions.append(shoot_action)
	animation_player.play("idle")
	if !test_move:
		fsm.change_state(idle_state)
	super._ready()

func gets_shot():
	fsm.change_state(idle_state)
	animation_player.play("dead")
