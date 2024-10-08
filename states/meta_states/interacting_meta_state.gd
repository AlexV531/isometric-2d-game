class_name InteractingMetaState
extends State

@export var p: Player3D

# This is an example of how to fix the input bleed but I don't like it hence the name
# Could also just make it that no inputs from interacting are the same as default but that
# is also bad (ie taking away the rightclick to close the interaction menu shown below)
# This is only a problem if an input is used to change a meta state and also used to do
# something in the next state
#var jankDelay: bool = true

func _enter_state() -> void:
	super._enter_state()
	Engine.time_scale = 0

func _exit_state() -> void:
	super._exit_state()
	Engine.time_scale = 1

"""
func _input(event):
	if p.fmsm.state == self:
		# Put inputs that happen when interacting here           Here's the rightclick we could remove to fix the issue
		if event.is_action_pressed("leftClick") || event.is_action_pressed("rightClick"):
			if p.selected_interactable != null:
				# Check if the mouse is clicking on an action button, if not close the interact menu 
				if !Rect2(p.selected_interactable.box_container.global_position, p.selected_interactable.box_container.get_rect().size).has_point(p.get_global_mouse_position()):
					print("hello")
					p.selected_interactable.close_menu()
"""
