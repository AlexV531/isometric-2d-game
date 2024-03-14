class_name MoveOneAwayState
extends MoveState

func _enter_state() -> void:
	super._enter_state()
	
	if !path.is_empty():
		path.pop_back()
		actor.target_tile = path.back()
