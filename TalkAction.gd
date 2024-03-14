class_name TalkAction
extends Action

@export var dialogic_timeline: String = 'timeline'

var interupted_state: State

func _ready():
	action_name = "Talk"

func execute():
	print("Talk Action")
	interupted_state = actor.fsm.state
	actor.fsm.change_state(actor.listen_state)
	actor.player.fmsm.change_state(actor.player.talking_meta_state)
	Dialogic.start(dialogic_timeline)
	Dialogic.timeline_ended.connect(dialogue_ended)
	action_finished.emit()

func dialogue_ended():
	print("also dialogue ended here")
	actor.fsm.change_state(interupted_state)
	Dialogic.timeline_ended.disconnect(dialogue_ended)
