# Outline.gd
extends Node3D

@export var width: float = 5.0
@export var color: Color = Color.RED

const shader = preload("res://outline.gdshader")

func _enter_tree():
	await get_tree().root.ready
	var mesh: MeshInstance3D = get_parent()
	mesh.set_layer_mask_value(2, true)

	var surf = SurfaceTool.new()
	surf.begin(Mesh.PRIMITIVE_TRIANGLES)
	var seen = {}
	var i = 0
	for face in mesh.mesh.get_faces():
		if !seen.has(face):
			var index = i
			i += 1
			seen[face] = index
			surf.add_vertex(face)
			surf.add_index(index)
		else:
			surf.add_index(seen[face])

	surf.generate_normals()
	var material = ShaderMaterial.new()
	material.shader = shader
	print(get_tree().current_scene.stencil_viewport.get_texture())
	material.set_shader_parameter("stencil", get_tree().current_scene.stencil_viewport.get_texture())
	material.set_shader_parameter("width", width)
	material.set_shader_parameter("color", color)

	var outline := MeshInstance3D.new()
	outline.mesh = surf.commit()
	outline.material_override = material
	add_child(outline)

func _exit_tree():
	var mesh: MeshInstance3D = get_parent()
	mesh.set_layer_mask_value(2, false)
