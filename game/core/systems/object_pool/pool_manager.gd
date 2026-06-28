@icon('res://assets/editor_icons/ref.svg')
class_name ObjectPoolManager extends ObjectPoolManagementNode

## @experimental

@export var pool_name: StringName = &''

var object_pool: ObjectPool:
	get = get_object_pool


func pool_create_object(...args: Array) -> Node:
	return pool_create_objectv(args)
func pool_create_objectv(args: Array) -> Node:
	if object_pool:
		return object_pool.create_objectv(args)
	return null
func pool_remove_object(obj: Node) -> void:
	if object_pool:
		object_pool.remove_object(obj)


func get_object_pool() -> ObjectPool:
	if pool_name:
		var node = get_tree().get_first_node_in_group(ObjectPool.POOL_NAME_PREFIX + pool_name) as ObjectPool
		return node
	return null
