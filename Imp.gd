extends Sprite3D

@export var anim_col: int = 0
 
var camera: Camera3D = null

func set_camera(c) -> void:
	camera = c
 
func _process(delta) -> void:
	if camera == null:
		return
 
	var p_fwd: Vector3 = -camera.global_transform.basis.z
	var fwd: Vector3 = global_transform.basis.z
	var left: Vector3 = global_transform.basis.x
 
	var l_dot: float = left.dot(p_fwd)
	var f_dot: float = fwd.dot(p_fwd)
	var row: int = 0
	self.flip_h = false
	if f_dot < -0.85:
		row = 0 # front sprite
	elif f_dot > 0.85:
		row = 4 # back sprite
	else:
		self.flip_h = l_dot > 0
		if abs(f_dot) < 0.3:
			row = 2 # left sprite
		elif f_dot < 0:
			row = 1 # forward left sprite
		else:
			row = 3 # back left sprite
	self.frame = anim_col + row * 4