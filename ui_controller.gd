class_name UIController
extends Node

@export var drag_preview: DragPreview
@export var tooltip: Tooltip
var container_inventory_menu: ItemContainerMenu
var inventory_open: bool = false

func open_inventory(inventory_menu):
	inventory_menu.show()
	inventory_open = true

func close_inventory(inventory_menu):
	if inventory_menu.visible and drag_preview.dragged_item: return
	inventory_menu.hide()
	hide_tooltip()
	if container_inventory_menu != null:
		container_inventory_menu.hide()
		container_inventory_menu = null
	inventory_open = false

# These two methods (this and drag_item) are used for ALL ITEM INVENTORIES LINK EVERYTHING TO HERE
func _on_ItemSlot_gui_input(event, index, inventory):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if inventory_open:
				drag_item(index, inventory)
				hide_tooltip()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if inventory_open:
				split_item(index, inventory)
				hide_tooltip()

func drag_item(index: int, inventory: Inventory):
	var inventory_item = inventory.items[index]
	var dragged_item = drag_preview.dragged_item
	# pick item
	if inventory_item and !dragged_item:
		drag_preview.dragged_item = inventory.remove_item(index)
		drag_preview.show()
	# drop item
	elif !inventory_item and dragged_item:
		drag_preview.dragged_item = inventory.set_item(index, dragged_item)
		drag_preview.hide()
	# swap items
	elif inventory_item and dragged_item:
		# stack item
		if inventory_item.key == dragged_item.key and inventory_item.stackable:
			inventory.set_item_quantity(index, dragged_item.quantity)
			drag_preview.dragged_item = {}
		# swap items
		else:
			drag_preview.dragged_item = inventory.set_item(index, dragged_item)

func split_item(index: int, inventory: Inventory):
		var inventory_item = inventory.items[index]
		var dragged_item = drag_preview.dragged_item
		if !inventory_item or !inventory_item.stackable: return
		var split_amount = ceil(inventory_item.quantity / 2.0)
		if dragged_item and inventory_item.key == dragged_item.key:
			drag_preview.dragged_item.quantity += split_amount
			inventory.set_item_quantity(index, -split_amount)
		if !dragged_item:
			var item = inventory_item.duplicate()
			item.quantity = split_amount
			drag_preview.dragged_item = item
			inventory.set_item_quantity(index, -split_amount)

func show_tooltip(index, inventory):
	var inventory_item = inventory.items[index]
	if inventory_item and !drag_preview.dragged_item:
		tooltip.display_info(inventory_item)
		tooltip.show()
	else:
		tooltip.hide()

func hide_tooltip():
	tooltip.hide()
