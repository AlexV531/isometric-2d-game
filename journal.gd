class_name Journal
extends TabContainer

@export var custom_balloon: CanvasLayer
@export var dialogue_resource: DialogueResource

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func selected_title(title):
	print(title)
	if title in custom_balloon.resource.titles:
		custom_balloon.next(title)
	else:
		print("NPC doesn't know about " + title)
