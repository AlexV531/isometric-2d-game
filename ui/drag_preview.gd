class_name DragPreview
extends Control

var dragged_item = {} : set = set_dragged_item

@onready var item_icon = $ItemIcon
@onready var item_quantity = $ItemQuantity

func _ready():
	custom_minimum_size = Global.ITEM_SLOT_SIZE
	size = Global.ITEM_SLOT_SIZE

func _input(event):
	if event is InputEventMouseMotion:
		position = event.position - item_icon.size*scale

func set_dragged_item(item):
	dragged_item = item
	if dragged_item:
		item_icon.texture = load("res://assets/images/%s" % dragged_item.icon)
		item_quantity.text = str(dragged_item.quantity) if dragged_item.stackable else ""
	else:
		item_icon.texture = null
		item_quantity.text = ""
