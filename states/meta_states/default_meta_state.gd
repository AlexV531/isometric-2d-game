class_name DefaultMetaState
extends State

@export var p: Player3D

func _exit_state() -> void:
	super._exit_state()

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
		# Interact with the outlined interactable
		if event.is_action_pressed("rightClick"):
			if p.selected_interactable != null:
				print(p.selected_interactable)
				p.selected_interactable.open_menu()
				p.fmsm.change_state(p.interacting_meta_state)
		# Move to a map space
		if event.is_action_pressed("leftClick"):
			p.target_tile = p.tile_map.local_to_map(p.get_global_mouse_position())
			p.fsm.change_state(p.move_state)
		# Enter slow meta state (for attacking probably)
		if event.is_action_released("slowTime"):
			p.fmsm.change_state(p.slow_meta_state)
"""
