extends Node
class_name GrabbableComponent

signal is_grabbed

@export var weight: int = 1
@export var is_grabbable: bool = false

func grabbed() -> void:
	is_grabbed.emit()