extends Camera3D

@export var distance: float = 20.0
@export var player: Player3D
@export var camera_speed = 8

var camera_rotation = 0.0
var tween: Tween
var rotating = false

var rotation_duration = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	var distance_xz: float = distance * sqrt(2.0/3.0)
	position.x = round((distance_xz * sin(PI/4.0)) * 1000) / 1000
	position.z = -position.x
	position.y = round((distance * (1.0/sqrt(3.0))) * 1000) / 1000
	look_at(get_parent().position)

func _physics_process(delta):
	# We create a local variable to store the input direction.
	var direction = Vector3.ZERO
	var rotation_direction = 0

	if Input.is_action_just_pressed("camera_turn_left"):
		if camera_rotation == 0:
			camera_rotation = PI/2
		elif camera_rotation == PI/2:
			camera_rotation = PI
		elif camera_rotation == PI:
			camera_rotation = 3*PI/2
		elif camera_rotation == 3*PI/2:
			get_parent().rotation.y -= 2*PI
			camera_rotation = 0
		tween = get_tree().create_tween()
		tween.tween_property(get_parent(), "rotation", Vector3(0, camera_rotation, 0), rotation_duration).set_trans(Tween.TRANS_SINE)
		
	if Input.is_action_just_pressed("camera_turn_right"):
		if camera_rotation == 0:
			get_parent().rotation.y += 2*PI
			camera_rotation = 3*PI/2
		elif camera_rotation == 3*PI/2:
			camera_rotation = PI
		elif camera_rotation == PI:
			camera_rotation = PI/2
		elif camera_rotation == PI/2:
			camera_rotation = 0
		print(camera_rotation)
		tween = get_tree().create_tween()
		tween.tween_property(get_parent(), "rotation", Vector3(0, camera_rotation, 0), rotation_duration).set_trans(Tween.TRANS_SINE)
	
	# We check for each move input and update the direction accordingly.
	if Input.is_action_pressed("walk_right"):
		direction = Vector3(-1, 0, -1).rotated(Vector3(0, 1, 0), get_parent().rotation.y)
	if Input.is_action_pressed("walk_left"):
		direction = Vector3(1, 0, 1).rotated(Vector3(0, 1, 0), get_parent().rotation.y)
	if Input.is_action_pressed("walk_down"):
		direction = Vector3(1, 0, -1).rotated(Vector3(0, 1, 0), get_parent().rotation.y)
	if Input.is_action_pressed("walk_up"):
		direction = Vector3(-1, 0, 1).rotated(Vector3(0, 1, 0), get_parent().rotation.y)
	
	get_parent().rotation.y += rotation_direction * delta
	get_parent().position += direction * camera_speed * delta
