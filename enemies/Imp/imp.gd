extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var sprite: Sprite3D = $Sprite3D
@export var anim_col: int = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera: Camera3D = %Player/Camera3D

@onready var states_map: Dictionary = {
	"idle": $States/Idle
}

var states_stack: Array[State] = []
var current_state: State = null

func _process(_delta) -> void:
	# directional_sprite_calculation()
	pass

func _physics_process(delta) -> void:
	directional_sprite_calculation()

func directional_sprite_calculation() -> void:
	if camera == null:
		return
 
	var player_foward: Vector3 = -camera.global_transform.basis.z
	var forward: Vector3 = global_transform.basis.z
	var left: Vector3 = global_transform.basis.x
 
	var left_dot_product: float = left.dot(player_foward)
	var forward_dot_product: float = forward.dot(player_foward)
	var row: int = 0
	sprite.flip_h = false
	if forward_dot_product < -0.85:
		row = 0 # front sprite
	elif forward_dot_product > 0.85:
		row = 4 # back sprite
	else:
		sprite.flip_h = left_dot_product > 0
		if abs(forward_dot_product) < 0.3:
			row = 2 # left sprite
		elif forward_dot_product < 0:
			row = 1 # forward left sprite
		else:
			row = 3 # back left sprite
	sprite.frame = anim_col + row * 4

func _on_health_component_health_depleted():
	queue_free()