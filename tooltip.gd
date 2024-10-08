class_name Tooltip
extends ColorRect

@onready var margin_container = $MarginContainer
@onready var item_name = $MarginContainer/ItemName

func _input(event):
	if event is InputEventMouseMotion:
		position = event.position
		position.y -= size.y*scale.y

func display_info(item):
	item_name.text = item.name
	await get_tree().process_frame
	margin_container.size = Vector2()
	size = margin_container.size
