extends CharacterBody3D

@export_range(1, 35, 1) var speed: float = 10 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

@export_range(1, 1000) var projectile_speed:float = 1

@onready var can_stand_raycast: RayCast3D = $CanStandRayCast
@onready var camera: Camera3D = $Camera3D
@onready var camera_raycast: RayCast3D = $Camera3D/CameraRayCast

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var sprites_node: Node3D = $Sprites
@onready var boobs_sprite: Sprite3D = $Sprites/BoobsSprite3D
@onready var lower_animated_sprite: AnimatedSprite3D = $Sprites/LowerSprite3D

@onready var weapon_node: Node3D = $Camera3D/Weapon
@export var bullet_scene: PackedScene

var active_weapon: Node3D
var bullet_spawn: Node3D

var mouse_captured: bool = false
var jumping: bool = false
var is_standing: bool = false
var is_crouched_pressed: bool = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var look_dir: Vector2 # Input direction for look/aim
var move_dir: Vector2

var walk_vel: Vector3
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity

var sprites_node_offset: float
var weapon_node_offset: float

func _ready() -> void:
	# TODO: we can probably access the camera with %
	get_tree().call_group("enemies", "set_camera", camera)
	sprites_node_offset =  camera.position.y - sprites_node.position.y
	# weapon_node_offset =  camera.position.y - weapon_node.position.y
	capture_mouse()
	# FIX THIS TO NOT CALL CHILD LIKE A CHAIN, MAYBE FACTOR THIS OUT MORE PROPERLY
	active_weapon = weapon_node.get_child(0)
	bullet_spawn = active_weapon.get_node('BulletSpawn')

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	if Input.is_action_just_pressed("jump"): jumping = true
	if Input.is_action_just_pressed("exit"): get_tree().quit()
	if Input.is_action_just_pressed("fire"):
		fire()
	# TODO: add a toggle for crouch
	if Input.is_action_just_pressed("crouch") and !is_crouched_pressed:		
		is_crouched_pressed = true
		is_standing = false
		animation_player.play("crouch")
	if Input.is_action_just_released("crouch"):
		is_crouched_pressed = false
		if !can_stand_raycast.is_colliding():
			is_standing = true
			animation_player.play("stand")

	
func _process(_delta) -> void:
	sprites_node.rotation.y = camera.rotation.y
	sprites_node.position.y = camera.position.y - sprites_node_offset
	# weapon_node.rotation = camera.rotation
	# weapon_node.position.y = camera.position.y - weapon_node_offset
	# TODO: weapon model is backwards, figure out some good export settings
	if camera_raycast.is_colliding():
		pass
		# active_weapon.look_at(camera_raycast.get_collision_point())
	

func _physics_process(delta) -> void:
	if mouse_captured: _handle_joypad_camera_rotation(delta)
	move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	lower_body_animation(move_dir)
	velocity = _walk(move_dir, delta) + _gravity(delta) + _jump(delta)
	stand_check()
	move_and_slide()

func stand_check():
	# TODO: toggle crouch would also apply here
	if is_crouched_pressed:
		return
	if is_standing:
		return
	if !can_stand_raycast.is_colliding():
		animation_player.play("stand")
		is_standing = true

func lower_body_animation(move_dir: Vector2) -> void:
	var move_dir_length: float = move_dir.length()
	if is_standing:
		if move_dir_length < 0.1:
			lower_animated_sprite.play("default")
		else:
			lower_animated_sprite.play("stand_walk")
	else:
		if move_dir_length < 0.1:
			lower_animated_sprite.play("crouch")
		else:
			lower_animated_sprite.play("crouch_walk")
	

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(sens_mod: float = 1.0) -> void:
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir: Vector2 = Input.get_vector("look_left","look_right","look_up","look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		_rotate_camera(sens_mod)
		look_dir = Vector2.ZERO

func _walk(move_dir:Vector2, delta:float) -> Vector3:
	# move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir = Vector3(forward.x, 0, forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

func fire():
	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	bullet.global_position = bullet_spawn.global_position
	bullet.rotation = bullet_spawn.rotation
	var direction = bullet_spawn.global_transform.basis.z  # Get the direction the projectile should travel

	bullet.velocity = direction * projectile_speed  # Set the velocity of the projectile
	bullet.top_level = true
	# lazer_fire_audio.play()
