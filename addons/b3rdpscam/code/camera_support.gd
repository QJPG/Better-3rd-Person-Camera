extends Camera3D

@export var target : Node3D
@export var zoom : float = 5.0
@export var exclude : Array[PhysicsBody3D]
@export var input_active : bool
@export var input_rotation_factor : float = 0.005
@export var input_rotation_limit : float = 80.0
@export var input_zoom_active : bool
@export var input_zoom_limit_min : float = 1.0
@export var input_zoom_limit_max : float = 10.0

var xray := PhysicsRayQueryParameters3D.new()
var xrot := Vector3.ZERO

func _input(event: InputEvent) -> void:
	if not input_active:
		return
		
	if event is InputEventMouseMotion:
		var rel = event.relative
		
		xrot.x += rel.y * -input_rotation_factor
		xrot.y += rel.x * -input_rotation_factor
	
		rotation.x = deg_to_rad(
			clamp(rad_to_deg(rotation.x),
				-input_rotation_limit, input_rotation_limit))
	
	if not input_zoom_active:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom -= 1.0
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom += 1.0
		
		zoom = clamp(zoom, input_zoom_limit_min, input_zoom_limit_max)

func _physics_process(delta: float) -> void:
	if not target:
		return
	
	var world := get_world_3d()
	
	#rotation
	
	var from : Vector3 = target.global_transform.origin + Vector3(0.0, 0.0, zoom)
	var to : Vector3 = target.global_transform.origin
	
	var rotation_basis_up := Basis().rotated(Vector3.UP, xrot.y)
	var rotation_basis_right := Basis().rotated(Vector3.RIGHT, xrot.x)
	var rotated_from : Vector3 = (rotation_basis_up * rotation_basis_right) * (from - target.global_transform.origin) + target.global_transform.origin
	
	#raycast
	
	
	xray.from = target.global_transform.origin
	xray.to = rotated_from
	xray.hit_back_faces = true
	xray.hit_from_inside = true
	
	var as_array_rid : Array[RID]
	
	for phys_obj in exclude:
		as_array_rid.append(phys_obj.get_rid())
	
	xray.exclude = as_array_rid
	
	var res := world.direct_space_state.intersect_ray(xray)
	
	if res:
		rotated_from = res.position + res.normal * 0.5
	
	#transformation
	
	var xtrans := global_transform #SINGLETON.viewpcam.global_transform
	
	xtrans.origin = rotated_from
	xtrans = xtrans.looking_at(to)
	
	global_transform = transform.interpolate_with(
		Transform3D(xtrans), delta * 12.0)
	
	#SINGLETON.viewpcam.global_transform = SINGLETON.viewpcam.global_transform.interpolate_with(
	#	Transform3D(
	#		xtrans), delta * 12.0)
