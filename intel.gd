class_name Intel
extends Panel

var active_description: Control
var descriptions: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in $Descriptions.get_children():
		descriptions[str(child.name).to_lower()] = child


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _show_description(intel_key: String):
	if active_description:
		active_description.hide()
	active_description = descriptions[intel_key]
	active_description.show()


func _on_button_pressed(intel_key: String):
	intel_key = intel_key.to_lower()
	_show_description(intel_key)
