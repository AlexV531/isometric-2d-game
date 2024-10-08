class_name UnlockAction
extends Action

func _ready():
	action_name = "Unlock"
	action_tag = Tag.LOCKPICK

func execute():
	if actor.closed:
		if actor.locked:
			actor.locked = false
			print("Unlocked")
		else:
			print("Already unlocked")
	
	action_finished.emit()
