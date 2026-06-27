extends Node


var mouse_visibility_conditions: Dictionary[StringName, bool] = {}


func _enter_tree() -> void:
	name = 'MouseManager'


func set_visibility_condition(cond: StringName, value: bool) -> void:
	mouse_visibility_conditions[cond] = value
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if true in mouse_visibility_conditions.values() else Input.MOUSE_MODE_CAPTURED
