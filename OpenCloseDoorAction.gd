class_name OpenCloseDoorAction
extends Action

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
