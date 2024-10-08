class_name HighlightLine
extends MeshInstance3D

var target_position: Vector3
var active: bool = false

func _ready():
	var immediate_mesh := ImmediateMesh.new()
	var material := StandardMaterial3D.new()
	
	mesh = immediate_mesh
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	transparency = 0.3
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(position)
	immediate_mesh.surface_add_vertex(Vector3(0.0, 0.0, -1.0))
	immediate_mesh.surface_end()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.WHITE_SMOKE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		visible = true
		look_at(target_position)
		scale.z = target_position.distance_to(to_global(position))
	else:
		visible = false

func set_red(red: bool):
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.RED
	material_override = material
	pass
