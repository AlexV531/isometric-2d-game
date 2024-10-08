class_name Outline
extends Sprite2D

@onready var label = $Label as Label
var sprite2d: Sprite2D
var animation_player: AnimationPlayer

func _ready():
	sprite2d = get_node("../Sprite2D")
	animation_player = get_node("../AnimationPlayer")
	texture = sprite2d.texture
	offset = sprite2d.offset
	hframes = sprite2d.hframes
	vframes = sprite2d.vframes
	frame = sprite2d.frame
	position = sprite2d.position
	if label != null:
		label.position.x = self.position.x + self.texture.get_width()/2
		label.position.y = self.position.y - self.texture.get_height() - label.size.y/2

func _process(delta):
	if animation_player != null:
		frame = sprite2d.frame
		position = sprite2d.position
