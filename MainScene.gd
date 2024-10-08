# MainScene.gd
class_name MainScene
extends Node2D

@onready var game_camera: Camera3D = $World3D/Player3D/Camera3D
#@onready var game_scene: Node3D = $World3D
@onready var stencil_viewport: SubViewport = $StencilViewport
@onready var stencil_camera: Camera3D = $StencilViewport/Camera3D

func _process(delta):
	#game_scene.main_scene = self

	var viewport := get_viewport()

	if stencil_viewport.size != viewport.size:
		stencil_viewport.size = viewport.size

	stencil_camera.global_transform = game_camera.global_transform
	stencil_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	stencil_camera.size = game_camera.size
	stencil_camera.near = game_camera.near
	stencil_camera.far = game_camera.far
