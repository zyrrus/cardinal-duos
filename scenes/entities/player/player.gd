extends CharacterBody3D

signal health_changed(health_value)

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

# Movement bobbing
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var bob_time = 0.0

# Field of view
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var health = 3

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var gun = $Head/Camera3D/GunTransform/AutomaticRifle
@onready var raycast = $Head/Camera3D/RayCast3D


func _enter_tree():
	set_multiplayer_authority(str(name).to_int())


func _ready():
	if not is_multiplayer_authority(): return
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = true


func _unhandled_input(event):
	if not is_multiplayer_authority(): return

	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	if Input.is_action_just_pressed("fire"):
		gun.play_shoot_effects.rpc()
		gun.fire(raycast)
		


func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
		# Handle Jump.
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			gun.play_anim("move")
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 10.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 10.0)
			gun.play_anim("idle")
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Head bobbing
	bob_time += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _head_bob(bob_time)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2.0)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()

func _head_bob(time) -> Vector3:
	var pos = Vector3.ZERO
	
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	
	return pos


@rpc("any_peer")
func receive_damage(): 
	health -= 1
	if health <= 0: 
		health = 3
		position = Vector3.ZERO
	health_changed.emit(health)
