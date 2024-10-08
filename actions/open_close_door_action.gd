class_name OpenCloseDoorAction
extends Action

# To use this action, an Interactable must have an open and close method and a hold open boolean.
# Maybe make this use the animation player instead

func execute():
	if actor.closed:
		# Open the door
		actor.open()
		actor.hold_open = true
	else:
		# Close the door
		actor.close()
		actor.hold_open = false
	
	action_finished.emit()

func get_action_name():
	if actor.closed:
		return "Open"
	else:
		return "Close"
