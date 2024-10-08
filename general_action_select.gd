extends VBoxContainer

@export var player: Player3D

@onready var move_button: Button = $MoveButton
@onready var shoot_button: Button = $ShootButton

func _ready():
	move_button.pressed.connect(player.change_action.bind(Action.Tag.MOVE_TO))
	shoot_button.pressed.connect(player.change_action.bind(Action.Tag.SHOOT))
