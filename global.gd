extends Node

var items

const ITEM_SLOT_SIZE = Vector2(36, 36)
const ITEM_ICON_SIZE = Vector2(32, 32)

const FLOOR_HEIGHT = 0.5

func _ready():
	items = read_from_JSON("res://assets/json/items.json")
	for key in items.keys():
		items[key]["key"] = key
	#print(get_item_by_key("sword"))

func read_from_JSON(path):
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		if error == OK:
			return json.data
		else:
			printerr("JSON Parse Error: ", json.get_error_message(), " in ", file.get_as_text(), " at line ", json.get_error_line())
	else:
		printerr("Invalid path given")

func get_item_by_key(key):
	if items and items.has(key):
		return items[key].duplicate(true)
