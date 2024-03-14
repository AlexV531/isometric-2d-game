extends Sprite2D

@onready var label = $Label as Label

func _ready():
	label.position.x = self.position.x + self.texture.get_width()/2 
	label.position.y = self.position.y - self.texture.get_height() - label.size.y/2
