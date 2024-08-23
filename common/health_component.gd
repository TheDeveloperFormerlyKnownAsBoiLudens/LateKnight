extends Node
class_name HealthComponent

signal health_adjust(health_value: float)
signal health_depleted
signal health_ready(health_value: float)

@export var max_health: float = 20.0
@export var invincible: bool = false: set = _set_invincible
@export var heal_charge: int = 5

@onready var health: float = max_health : set = _set_health, get = _get_health

var can_heal: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_ready.emit(health)

func damage(attack: Attack) -> void:
	if invincible:
		return
	can_heal = false
	
	var take_damage:float = health - attack.attack_damage
	_set_health(take_damage)

func _on_heal_recharge_timer_timeout() -> void:
	can_heal = true

func _set_health(value) -> void:
	health = value
	if health > max_health:
		health = max_health
	if health <= 0:
		health = 0
		health_depleted.emit()
	health_adjust.emit(health)

func _get_health() -> float:
	return health

func _set_invincible(is_invincible: bool) -> void:
	invincible = is_invincible
