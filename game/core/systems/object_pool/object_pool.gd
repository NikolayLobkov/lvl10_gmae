@tool
@icon('res://editor_icons/pool_3d.svg')
class_name ObjectPool extends Node3D

## @experimental

## Префикс названия пула.
const POOL_NAME_PREFIX: StringName = &'object_pool_with_name_'

## Размер пула.
@export_range(1, 2048, 1) var pool_size: int = 10
@export var scene: PackedScene:
	set = _set_scene
## Название пула.
@export var pool_name: StringName = &''

@export var extendable: bool = false

## Используемые объекты.
var active_objects: Array[Node] = []
## Доступные объекты.
var available_objects: Array[Node] = []


func _ready() -> void:
	if not Engine.is_editor_hint():
		if pool_name: add_to_group(POOL_NAME_PREFIX + pool_name)
		
		if not scene: return
		
		var _object
		for i in pool_size:
			_object = scene.instantiate()
			add_child(_object)
			available_objects.append(_object)


func create_object(...args: Array) -> Node:
	return create_objectv(args)
func create_objectv(args: Array) -> Node:
	if not scene: return
	
	if is_overflow():
		if not extendable:
			remove_object(active_objects[0])
		else:
			extend(pool_size * 2)
	
	if available_objects:
		var obj: Node = available_objects[0]
		var comp: PooledObjectComponent = object_get_component(obj)
		
		available_objects.erase(obj)
		active_objects.append(obj)
		
		if comp:
			comp.create_commanded.emit(args)
		
		return obj
	
	return null

func remove_object(obj: Node) -> void:
	if active_objects:
		var comp: PooledObjectComponent = object_get_component(obj)
		
		active_objects.erase(obj)
		available_objects.append(obj)
		
		if comp:
			comp.remove_commanded.emit()


func object_get_component(obj: Node) -> PooledObjectComponent:
	var a: Array = obj.get_children().filter(func(x: Node) -> bool: return x is PooledObjectComponent)
	
	if a:
		return a[-1]
	return null


func get_pool() -> Array[Node]:
	return get_children()


func is_overflow() -> bool:
	return active_objects.size() == pool_size


func extend(new_size: int) -> void:
	if new_size <= pool_size:
		return
	
	var _object
	for i in new_size - pool_size:
		_object = scene.instantiate()
		add_child(_object)
		available_objects.append(_object)
	pool_size = new_size



func _set_scene(value: PackedScene) -> void:
	scene = value
	
	update_configuration_warnings()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_CHILD_ORDER_CHANGED: update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if not scene:
		warnings.append('Параметр scene пуст. Как, по вашему мнению, ObjectPool должен работать?!')
	if get_child_count() > 0:
		warnings.append('ObjectPool не должен содержать каких-либо узлов в редакторе.')
	
	return warnings
