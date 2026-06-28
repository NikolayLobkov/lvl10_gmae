@icon('res://assets/editor_icons/mouse_motion.svg')
class_name LookComponent extends Node


const MIN_ANGLE: float = -PI / 3.0
const MAX_ANGLE: float = PI / 2.0


@export var actor: Node3D
@export var pivot: Node3D


func _ready() -> void:
	UIManager.MouseManager.set_visibility_condition(&'mouse_look', false)

func _input_tick(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		actor.rotation.y -= event.relative.x * 0.005
		pivot.rotation.x = clampf(pivot.rotation.x - event.relative.y * 0.005, MIN_ANGLE, MAX_ANGLE)
