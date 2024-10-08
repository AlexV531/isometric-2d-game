class_name Target
extends Node2D

func _ready():
	#super._ready()
	# If the parent node is an interactable, get the player from here
	if get_parent().player != null:
		get_parent().player.slow_meta_state.slow_state_entered.connect(_enter_target_mode)
		get_parent().player.slow_meta_state.slow_state_exited.connect(_exit_target_mode)

func _enter_target_mode():
	visible = true
	material.set_shader_parameter("red", 1)

func _exit_target_mode():
	visible = false
	material.set_shader_parameter("red", 0)

#func _process(delta):
	#if get_parent().player.fmsm.state is SlowMetaState and:
		
