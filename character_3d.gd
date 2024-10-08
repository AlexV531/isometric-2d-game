class_name Character3D
extends MovingInteractable

var target_tile: Vector2i

@onready var talk_action = $TalkAction as TalkAction
@onready var shoot_action = $ShootAction as ShootAction

@onready var fsm = $FiniteStateMachine as FiniteStateMachine
@onready var move_state = $FiniteStateMachine/MoveState as MoveState
@onready var idle_state = $FiniteStateMachine/IdleState as IdleState
@onready var listen_state = $FiniteStateMachine/ListenState as ListenState

#@onready var mesh = $MeshInstance3D

#const outline = preload("res://outline.tscn")

func _ready():
	actions.append(talk_action)
	actions.append(shoot_action)
	super._ready()

#func _unhandled_input(event):
	#if event.is_action_pressed("rightClick"):
	#	mesh.add_child(outline.instantiate())
	#if event.is_action_pressed("leftClick"):
	#	print(mesh.get_child(0).get_child(0))
#	if event.is_action_pressed("rightClick"):
#		var mouse_map_pos = grid_map.get_cursor_map_position()
#		if mouse_map_pos == null:
#			return
#		target_tile = mouse_map_pos
#		print(target_tile)
#		fsm.change_state(move_state)
