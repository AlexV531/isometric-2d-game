class_name SlowMetaState
extends State

# See InteractingMetaState.gd for info on this
var jankDelay: bool = true

@export var p: Player

func _enter_state() -> void:
	super._enter_state()
	Engine.time_scale = 0.1

func _exit_state() -> void:
	super._exit_state()
	Engine.time_scale = 1
	jankDelay = true

"""
func _input(event):
	if p.fmsm.state == self:
		if jankDelay:
			jankDelay = false
			return
		# Code here
		if event.is_action_pressed("slowTime"):
			print("here")
			Engine.time_scale = 1
			p.fmsm.change_state(p.default_meta_state)
"""
