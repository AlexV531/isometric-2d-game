class_name Inventory
extends Node

signal items_changed(indexes)

var cols = 3
var rows = 6
var slots = cols * rows
var items = []

func _ready():
	for i in range(slots):
		items.append({})
	items[0] = Global.get_item_by_key("sword")
	items[1] = Global.get_item_by_key("armor")
	items[2] = Global.get_item_by_key("apple")
	items[3] = Global.get_item_by_key("apple")
	items[4] = Global.get_item_by_key("potion")

func set_item(index, item):
	var previous_item = items[index]
	items[index] = item
	emit_signal("items_changed", [index])
	return previous_item

func remove_item(index):
	var previous_item = items[index].duplicate()
	items[index].clear()
	emit_signal("items_changed", [index])
	return previous_item

func set_item_quantity(index, amount):
	items[index].quantity += amount
	if items[index].quantity <= 0:
		remove_item(index)
	else:
		emit_signal("items_changed", [index])
