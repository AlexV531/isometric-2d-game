class_name InventoryMenu
extends SlotContainer

@export var inventory: Inventory

func _ready():
	display_item_slots(inventory.cols, inventory.rows, inventory)
	await get_tree().process_frame
	position.x = (get_viewport_rect().size.x - get_viewport_rect().size.x/8 - size.x*scale.x*2) / 2
	position.y = (get_viewport_rect().size.y - size.y*scale.y) / 2
	hide()
