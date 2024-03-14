class_name Door
extends Interactable

@onready var open_close_door_action = $OpenCloseDoorAction as OpenCloseDoorAction
@onready var unlock_action = $UnlockAction as UnlockAction

@onready var open_door: Sprite2D = $OpenDoor
@onready var closed_door: Sprite2D = $ClosedDoor
@onready var collision_open: CollisionPolygon2D = $CollisionOpen
@onready var collision_closed: CollisionPolygon2D = $CollisionClosed
@onready var tile_area: Area2D = $TileArea
@onready var open_door_outline: Sprite2D = $OpenDoorOutline
@onready var closed_door_outline: Sprite2D = $ClosedDoorOutline

var closed: bool
var hold_open: bool = false
var locked: bool = false

var actors_on_door: int = 0

func _ready():
	actions.append(open_close_door_action)
	actions.append(unlock_action)
	super._ready()
	
	if closed_door.visible:
		closed = true
		outline = closed_door_outline
	else:
		closed = false
		outline = open_door_outline
	
# If the door tile is entered
func _on_tile_area_area_entered(area):
	if actors_on_door == 0:
		open()
	actors_on_door += 1

# If the door tile is exited
func _on_tile_area_area_exited(area):
	actors_on_door -= 1
	if actors_on_door == 0 && !hold_open:
		close()

func open():
	closed_door.visible = false
	open_door.visible = true
	collision_closed.disabled = true
	collision_open.disabled = false
	closed_door_outline.visible = false
	outline = open_door_outline
	closed = false

func close():
	open_door.visible = false
	closed_door.visible = true
	collision_open.disabled = true
	collision_closed.disabled = false
	open_door_outline.visible = false
	outline = closed_door_outline
	closed = true
