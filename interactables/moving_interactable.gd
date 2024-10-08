class_name MovingInteractable
extends Interactable

func _ready():
	super._ready()
	move_state_option = player.chase_state

func choose_target():
	player.target_node = self
