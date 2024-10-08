class_name ItemContainerMenu
extends SlotContainer

@export var inventory: Inventory

func _ready():
	open_container_menu()
	hide()

func open_container_menu():
	display_item_slots(inventory.cols, inventory.rows, inventory)
	await get_tree().process_frame
	position.x = (get_viewport_rect().size.x + get_viewport_rect().size.x/8) / 2
	position.y = (get_viewport_rect().size.y - size.y*scale.y) / 2
