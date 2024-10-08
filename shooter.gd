class_name Shooter # Class for any node that shoots guns
extends Node3D

var range = 50
var time_between_shots = 0.2
var shot_height = Vector2(0, -10)
var raycast = RayCast3D.new()
var shot_timer = Timer.new()
var shooting: bool = false

var target_queue = Queue.new(10) # Queue up shots at the target (Good for burst fire/automatic spray)

func _ready():
	raycast.set_collision_mask_value(1, false)
	raycast.set_collision_mask_value(5, true)
	raycast.collide_with_areas = true
	add_child(raycast) # Forgetting this line caused me 15 minutes of pain
	shot_timer.one_shot = true
	add_child(shot_timer)

func _process(delta):
	pass

# Checks if the player shot would hit, basically casts a ray. Meant for checking if a shot will hit
# before actually shooting, for example enemy AI or player highlighting.
# Will either return a (shootable) interactable or the position the shot would land, if nothing
# hits return null.
func check_shot(target_position: Vector3):
	raycast.target_position = target_position
	raycast.force_raycast_update()
	if raycast.is_colliding():
		if raycast.get_collider() is Interactable:
			return raycast.get_collider().position
		else:
			return raycast.get_collision_point()
	return null

# When shots are added to the queue, it shoots the first one immediately and sets a timer until
# the next shot. The timeout signal on the timer shoots the next shot in the queue, and this repeats
# until the queue is empty.
func shoot(target_nodes: Array):
	for target_node in target_nodes:
		target_queue.enqueue(target_node)
	# Check if the player is in cover, if so, add a peek from cover method, which then is connected
	# to the shoot method when the animation is completed
	var grid_position = get_parent().grid_map.local_to_map(get_parent().position)
	var cover = get_parent().grid_map.check_cover(Vector3i(grid_position.x, 0, grid_position.z))
	if cover:
		print("in cover")
	_shoot(target_queue.dequeue())

func _shoot(target_node):
	# Turn off highlight during shooting
	shooting = true
	var target_position = target_node.position
	raycast.target_position = to_local(target_position)
	raycast.force_raycast_update()
	var missed = true
	if raycast.get_collider() == target_node:
		missed = false
	if !missed:
		_bullet_line(to_local(target_position))
		print("Shot hit!")
		# Take health, make the enemy react
	elif missed:
		var collision_point = raycast.get_collision_point()
		print("Shot missed, hit " + str(collision_point))
		_bullet_line(to_local(collision_point))
	print(raycast.get_collider())
	# Set up next shot in queue if there is one
	if !target_queue.is_empty():
		var next_target = target_queue.dequeue()
		shot_timer.timeout.disconnect(_shoot)
		shot_timer.timeout.connect(_shoot.bind(next_target))
		shot_timer.start(time_between_shots)
	else:
		shooting = false
	#print("Did shot miss? ", missed)
	return !missed

func _bullet_line(target: Vector3, color = Color.WHITE_SMOKE, duration = 0.1):
	var mesh_instance := MeshInstance3D.new()
	add_child(mesh_instance)
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3.ZERO)
	immediate_mesh.surface_add_vertex(target)
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	var tween = mesh_instance.create_tween()
	tween.tween_property(mesh_instance, "transparency", 1, duration).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(mesh_instance.queue_free)
