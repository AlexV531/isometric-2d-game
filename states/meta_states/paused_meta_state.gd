class_name PausedMetaState
extends State

func _enter_state() -> void:
	super._enter_state()
	Engine.time_scale = 0

func _exit_state() -> void:
	super._exit_state()
	Engine.time_scale = 1
