class_name SlowMetaState
extends State

@export var p: Player3D

signal slow_state_entered
signal slow_state_exited

func _enter_state() -> void:
	super._enter_state()
	slow_state_entered.emit()
	Engine.time_scale = 0.1

func _exit_state() -> void:
	super._exit_state()
	slow_state_exited.emit()
	Engine.time_scale = 1

func _process(delta):
	# If there are interactables on the mouse and no interactable has been selected, select one
	if !p.interactables_on_mouse.is_empty():
		# Always make sure the selected interactable is the one at the front of the list
		if p.selected_interactable != null:
			p.selected_interactable.set_outline_visible(false)
		p.selected_interactable = p.interactables_on_mouse.front()
		p.selected_interactable.set_outline_visible(true)
	else:
		# Unselect the current selected interactable
		if p.selected_interactable != null:
			p.selected_interactable.set_outline_visible(false)
		p.selected_interactable = null

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
