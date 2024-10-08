class_name TestAction
extends Action

func _ready():
	action_name = "Testing Action"

func execute():
	print("Test action executed on ", actor.name)
	action_finished.emit()
