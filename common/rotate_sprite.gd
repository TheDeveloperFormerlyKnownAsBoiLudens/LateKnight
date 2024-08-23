extends Sprite3D

@export var anim_col: int = 0
 
var camera: Camera3D = null

func set_camera(camera: Camera3D) -> void:
	self.camera = camera
 
func _process(_delta) -> void:
	if camera == null:
		return
 
	var player_foward: Vector3 = -camera.global_transform.basis.z
	var forward: Vector3 = global_transform.basis.z
	var left: Vector3 = global_transform.basis.x
 
	var left_dot_product: float = left.dot(player_foward)
	var forward_dot_product: float = forward.dot(player_foward)
	var row: int = 0
	self.flip_h = false
	if forward_dot_product < -0.85:
		row = 0 # front sprite
	elif forward_dot_product > 0.85:
		row = 4 # back sprite
	else:
		self.flip_h = left_dot_product > 0
		if abs(forward_dot_product) < 0.3:
			row = 2 # left sprite
		elif forward_dot_product < 0:
			row = 1 # forward left sprite
		else:
			row = 3 # back left sprite
	self.frame = anim_col + row * 4