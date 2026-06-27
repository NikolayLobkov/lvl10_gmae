class_name LookComponent extends Node


@export var actor: Node3D
@export var pivot: Node3D


func _ready() -> void:
	UIManager.MouseManager.set_visibility_condition(&'mouse_look', false)

func _input_tick(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		actor.rotation.y -= event.relative.x * 0.005
		pivot.rotation.x = clampf(pivot.rotation.x - event.relative.y * 0.005, -PI / 2.0, PI / 2.0)
