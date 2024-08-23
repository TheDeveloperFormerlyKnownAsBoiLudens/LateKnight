extends Area2D

func cause_trauma(trauma_increase: float):
	var trauma_areas := get_overlapping_areas()
	for area in trauma_areas:
		if area.has_method("add_trauma"):
			area.add_trauma(trauma_increase)
