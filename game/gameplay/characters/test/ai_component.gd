class_name AIComponent
extends Node

@export_group("Components")
@export var actor: CharacterBody3D
@export var state: StateComponent
@export var health: HealthComponent
@export var navigation: NavigationComponent
@export var vision: VisionComponent

@export_group("Patrol")
@export var patrol_points: Array[Node3D]
@export var search_duration := 3.0

@export_group("Rotation")
@export_range(0.0, 20.0, 0.1)
var rotation_speed := 8.0

var patrol_index := 0
var search_timer := 0.0


func _ready() -> void:
	health.death.connect(_on_death)

	if patrol_points.is_empty():
		state.set_state(StateComponent.State.IDLE)
	else:
		state.set_state(StateComponent.State.PATROL)


func tick(delta: float) -> void:
	match state.current:
		StateComponent.State.IDLE:
			_idle()

		StateComponent.State.PATROL:
			_patrol()

		StateComponent.State.CHASE:
			_chase(delta)

		StateComponent.State.SEARCH:
			_search(delta)

		StateComponent.State.DEAD:
			pass


func _idle() -> void:
	var player := vision.find_target("player")

	if player:
		vision.set_target(player)
		state.set_state(StateComponent.State.CHASE)


func _patrol() -> void:
	var player := vision.find_target("player")

	if player:
		vision.set_target(player)
		state.set_state(StateComponent.State.CHASE)
		return

	if patrol_points.is_empty():
		return

	navigation.move_to_node(patrol_points[patrol_index])

	if navigation.reached_target():
		patrol_index += 1
		patrol_index %= patrol_points.size()


func _chase(delta: float) -> void:
	if !vision.has_target():
		state.set_state(StateComponent.State.SEARCH)
		search_timer = 0.0
		return

	var target := vision.current_target

	if !vision.can_see(target):
		state.set_state(StateComponent.State.SEARCH)
		search_timer = 0.0
		return

	navigation.move_to_node(target)
	_rotate_towards(target.global_position, delta)


func _search(delta: float) -> void:
	var player := vision.find_target("player")

	if player:
		vision.set_target(player)
		state.set_state(StateComponent.State.CHASE)
		return

	navigation.move_to_position(vision.last_seen_position)

	if navigation.reached_target():
		search_timer += delta

		if search_timer >= search_duration:
			search_timer = 0.0

			if patrol_points.is_empty():
				state.set_state(StateComponent.State.IDLE)
			else:
				state.set_state(StateComponent.State.PATROL)


func _rotate_towards(position: Vector3, delta: float) -> void:
	var direction := position - actor.global_position
	direction.y = 0.0

	if direction.length_squared() < 0.0001:
		return

	var target_basis := Basis.looking_at(direction.normalized())

	actor.global_basis = actor.global_basis.slerp(
		target_basis,
		delta * rotation_speed
	)


func _on_death() -> void:
	navigation.stop()
	state.set_state(StateComponent.State.DEAD)
