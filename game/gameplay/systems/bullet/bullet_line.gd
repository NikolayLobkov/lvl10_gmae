@tool
class_name Line3D extends Node3D



@export var target_position: Vector3 = Vector3(0.0, 0.0, -1.0)


@onready var pooled_object_component: PooledObjectComponent = $PooledObjectComponent
@onready var mesh: MeshInstance3D = $Mesh
@onready var free_timer: Timer = $FreeTimer

var material: ShaderMaterial
var progress: float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint(): return
	material = mesh.get_active_material(0)
	progress = 0.0
	
	hide()


func _physics_process(delta: float) -> void:
	update()
	if not Engine.is_editor_hint():
		if pooled_object_component.is_active:
			progress += delta * 0.5 / mesh.scale.y * 100.0
			material['shader_parameter/progress'] = progress
			
			if progress >= 1.0:
				pooled_object_component.remove()
	

func update() -> void:
	#look_at(global_position + target_position)
	if target_position.length_squared() > 0.0:
		global_transform.basis = Basis(Quaternion(Vector3.FORWARD, target_position.normalized()))
	mesh.scale.y = target_position.length()
	mesh.position.z = -mesh.scale.y / 2.0


func _on_free_timer_timeout() -> void:
	pooled_object_component.remove()


func _on_pooled_object_component_create_commanded(args: Array) -> void:
	progress = 0.0
	
	global_position = args[0]
	target_position = args[1]
	
	free_timer.start()
	
	update()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	show()
func _on_pooled_object_component_remove_commanded() -> void:
	if not is_node_ready(): await ready
	progress = 0.0
	free_timer.stop()
	hide()
