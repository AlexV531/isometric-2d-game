class_name Door
extends Interactable

@onready var open_close_door_action = $OpenCloseDoorAction as OpenCloseDoorAction
@onready var unlock_action = $UnlockAction as UnlockAction

@onready var animation_player = $AnimationPlayer

@export var closed: bool
var hold_open: bool = false
var locked: bool = false

var actors_on_door: int = 0

func _ready():
	actions.append(open_close_door_action)
	actions.append(unlock_action)
	super._ready()

func open():
	animation_player.play("open")
	closed = false

func close():
	animation_player.play("close")
	closed = true

# If the door tile is entered
func _on_tile_area_body_entered(body):
	if actors_on_door == 0:
		open()
	actors_on_door += 1

# If the door tile is exited
func _on_tile_area_body_exited(body):
	actors_on_door -= 1
	if actors_on_door == 0 && !hold_open:
		close()
