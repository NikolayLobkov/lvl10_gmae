class_name NavigationComponent
extends Node

@export var actor: CharacterBody3D
@export var movement: MovementComponent
@export var agent: NavigationAgent3D

@export_range(0.01, 1.0, 0.01)
var update_interval := 0.15

var _target_node: Node3D
var _target_position := Vector3.ZERO

var _active := false
var _update_timer := 0.0


func tick(delta: float) -> void:
	if not _active:
		_stop()
		return

	_update_timer += delta

	if _update_timer >= update_interval:
		_update_timer = 0.0

		if _target_node:
			agent.target_position = _target_node.global_position
		else:
			agent.target_position = _target_position

	_update_direction()


func move_to_node(node: Node3D) -> void:
	if node == null:
		return

	_target_node = node
	_active = true


func move_to_position(position: Vector3) -> void:
	_target_node = null
	_target_position = position
	_active = true


func stop() -> void:
	_active = false
	_stop()


func reached_target() -> bool:
	if not _active:
		return true

	return agent.is_navigation_finished()


func is_moving() -> bool:
	return _active and not agent.is_navigation_finished()


func _update_direction() -> void:
	if movement == null or actor == null:
		return

	if agent.is_navigation_finished():
		_stop()
		return

	var next_position := agent.get_next_path_position()

	var direction := next_position - actor.global_position
	direction.y = 0.0
	
	actor.look_at(actor.global_position + Vector3(direction.x, 0, direction.z), Vector3.UP)

	if direction.length_squared() < 0.00001:
		_stop()
		return

	direction = direction.normalized()

	var local_direction := actor.global_basis.inverse() * direction

	movement.move_direction = Vector2(
		local_direction.x,
		local_direction.z
	)

	movement.move_amount = 1.0


func _stop() -> void:
	if movement == null:
		return

	movement.move_direction = Vector2.ZERO
	movement.move_amount = 0.0
