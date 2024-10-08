class_name ShootAction
extends Action

func _ready():
	action_name = "Shoot"
	action_tag = Tag.SHOOT
	move_to_actor = false

func execute():
	actor.player.shooter.shoot([actor, actor])
