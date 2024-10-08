class_name Action
extends Node

enum Tag {NONE, DEFAULT, MOVE_TO, SHOOT, LOCKPICK, STEAL}

@export var actor: Interactable

var action_name: String # This is what will show up on the button in the interaction menu
var action_tag: Tag = Tag.NONE # Action tags are for common actions the player can do on more than one object like shoot and lockpick
var move_to_actor: bool = true # This determines if the player must move to the object before performing the action or not

signal action_finished

func execute():
	pass

func get_action_name():
	return action_name
