class_name State
extends Node

signal state_finished

func _ready():
	set_process(false)

func _enter_state() -> void:
	set_process(true)

func _exit_state() -> void:
	set_process(false)
