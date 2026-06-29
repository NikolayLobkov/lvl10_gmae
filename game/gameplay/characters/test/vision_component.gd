class_name VisionComponent
extends Node

signal target_spotted(target: Node3D)
signal target_lost(target: Node3D)

@export_group("Components")
@export var actor: CharacterBody3D
@export var eyes: Node3D
@export var ray: RayCast3D

@export_group("Vision")
@export_range(0.0, 1000.0, 0.1)
var vision_range := 35.0

@export_range(0.0, 360.0, 1.0)
var vision_angle := 120.0

var current_target: Node3D
var last_seen_position := Vector3.ZERO


func tick(_delta: float) -> void:
	if current_target == null:
		return

	if can_see(current_target):
		last_seen_position = current_target.global_position
	else:
		target_lost.emit(current_target)
		current_target = null


func set_target(target: Node3D) -> void:
	current_target = target


func clear_target() -> void:
	current_target = null


func has_target() -> bool:
	return current_target != null


func can_see(target: Node3D) -> bool:
	if target == null:
		return false

	if actor == null or eyes == null or ray == null:
		return false

	var to_target := target.global_position - eyes.global_position

	if to_target.length() > vision_range:
		return false

	var forward := -eyes.global_basis.z
	forward.y = 0.0

	var flat := to_target
	flat.y = 0.0

	if flat.length_squared() > 0.00001:
		var angle := rad_to_deg(forward.angle_to(flat.normalized()))

		if angle > vision_angle * 0.5:
			return false

	ray.target_position = ray.to_local(target.global_position + Vector3.UP)

	ray.force_raycast_update()

	if !ray.is_colliding():
		return false

	var collider := ray.get_collider()

	if collider.get_owner() == target:
		last_seen_position = target.global_position

		if current_target != target:
			current_target = target
			target_spotted.emit(target)

		return true

	if collider is Node:
		if collider.is_in_group("player") and target.is_in_group("player"):
			last_seen_position = target.global_position

			if current_target != target:
				current_target = target
				target_spotted.emit(target)

			return true

	return false


func find_target(group: String) -> Node3D:
	for node in get_tree().get_nodes_in_group(group):
		if node is Node3D and can_see(node):
			return node

	return null
