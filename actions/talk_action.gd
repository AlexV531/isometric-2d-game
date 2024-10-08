class_name TalkAction
extends Action

#@export var dialogic_timeline: String = 'timeline'
@export var dialogue_resource: DialogueResource

var interupted_state: State

func _ready():
	action_name = "Talk"

func execute():
	#print("Talk Action")
	interupted_state = actor.fsm.state
	actor.fsm.change_state(actor.listen_state)
	actor.player.fmsm.change_state(actor.player.talking_meta_state)
	DialogueManager.dialogue_ended.connect(dialogue_ended)
	DialogueManager.show_dialogue_balloon(dialogue_resource, "start")
	action_finished.emit()

func dialogue_ended(dialogue_resource: DialogueResource):
	#print("also dialogue ended here")
	actor.fsm.change_state(interupted_state)
	DialogueManager.dialogue_ended.disconnect(dialogue_ended)
