extends State

@export var player: Player

func _enter_state() -> void:
	super._enter_state()
	player.interacting = true
