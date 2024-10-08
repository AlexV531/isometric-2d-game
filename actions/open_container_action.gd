class_name OpenContainerAction
extends Action

func _ready():
	action_name = "Open Container"

func execute():
	#print("Open container action executed on ", actor.name)
	actor.player.ui_controller.open_inventory(actor.player.inventory_menu)
	actor.player.fmsm.change_state(actor.player.paused_meta_state)
	actor.inventory_menu.show()
	actor.player.ui_controller.container_inventory_menu = actor.inventory_menu
	action_finished.emit()
