class_name PooledObjectComponent extends ObjectPoolManagementNode


## @experimental


@warning_ignore_start('unused_signal')
signal create_commanded(args: Array)
signal remove_commanded

@export var auto_set_active: bool = true

var object_pool: ObjectPool:
	get = get_object_pool

var is_active: bool = false


func _ready() -> void:
	create_commanded.connect(_on_create_commanded)
	remove_commanded.connect(_on_remove_commanded)
	
	remove_commanded.emit()

func remove() -> void:
	assert(object_pool)
	object_pool.remove_object(get_parent())


func _on_create_commanded(_args: Array) -> void:
	if auto_set_active:
		is_active = true
func _on_remove_commanded() -> void:
	if auto_set_active:
		is_active = false


func get_object_pool() -> ObjectPool:
	var _parent: Node = get_parent()
	if _parent:
		return _parent.get_parent() as ObjectPool
	return null
