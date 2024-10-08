class_name SlotContainer
extends GridContainer

@export var ItemSlot: PackedScene

var slots

func display_item_slots(cols: int, rows: int, inventory: Inventory):
	columns = cols
	slots = cols * rows
	for index in range(slots):
		var item_slot = ItemSlot.instantiate()
		add_child(item_slot)
		item_slot.display_item(inventory.items[index])
	inventory.items_changed.connect(_on_Inventory_items_changed.bind(inventory))

func _on_Inventory_items_changed(indexes, inventory: Inventory):
	for index in indexes:
		if index < slots:
			var item_slot = get_child(index)
			item_slot.display_item(inventory.items[index])
