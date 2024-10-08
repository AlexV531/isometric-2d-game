class_name Journal_Text
extends RichTextLabel

# Kind of a bad way of doing it
@onready var journal = find_parent("Journal")

# Called when the node enters the scene tree for the first time.
func _ready():
	meta_clicked.connect(_on_meta_clicked)

func _on_meta_clicked(meta):
	# Here the meta could be decoded, for example if I just wanted "lost watch"
	# to link to code "lostgoldenwatch" I could fix that here.
	var title = str(meta).to_lower().replace(" ", "")
	journal.selected_title(title)
