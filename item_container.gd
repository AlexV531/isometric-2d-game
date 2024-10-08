class_name ItemContainer
extends Interactable

@onready var open_container_action = $OpenContainerAction
@onready var inventory = $Inventory
@onready var inventory_menu = $UI/ItemContainerMenu

func _ready():
	actions.append(open_container_action)
	for item_slot in get_tree().get_nodes_in_group("item_slot"):
		var index = item_slot.get_index()
		item_slot.gui_input.connect(player.ui_controller._on_ItemSlot_gui_input.bind(index, inventory))
		item_slot.mouse_entered.connect(player.ui_controller.show_tooltip.bind(index, inventory))
		item_slot.mouse_exited.connect(player.ui_controller.hide_tooltip)
	super._ready()
