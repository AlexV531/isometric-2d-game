class_name Action
extends Node

@export var actor: Interactable

var action_name: String
signal action_finished

func execute():
	pass

func get_action_name():
	return action_name
