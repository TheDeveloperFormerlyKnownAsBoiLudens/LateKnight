extends Area3D
class_name HitBoxComponent

@export var attack:Attack
@export var per_physics_frame: bool = false

func _on_area_entered(area:Area3D):
	if per_physics_frame:
		return
	hurt_box_check(area)

func _physics_process(_delta):
	if !per_physics_frame:
		return
	var areas: Array[Area3D] = get_overlapping_areas()
	if areas.size() == 0:
		return 
	for area in areas:
		hurt_box_check(area)
		area_entered.emit(area)
	

func hurt_box_check(area: Area3D):
	if not (area is HurtBoxComponent):
		return
	var hit_box: HurtBoxComponent = area
	hit_box.damage(attack)