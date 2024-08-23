extends Area3D
class_name HurtBoxComponent

@export var health_component: HealthComponent : set = _set_health_component

func _ready():
	if not health_component:
		push_error("HurtBoxComponent: health_component is not set!")

func damage(attack: Attack):
	if health_component:
		health_component.damage(attack)

func _set_health_component(new_health_component: HealthComponent):
	health_component = new_health_component
