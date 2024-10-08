class_name CoverInteractable
extends Interactable

@onready var cover_action = $TakeCoverAction

func _ready():
	actions.append(cover_action)
	super._ready()
	move_state_option = player.move_state
