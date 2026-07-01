class_name Char extends CharacterBody3D


@export var movement: MovementComponent
@export var health: HealthComponent

@export var navigation: NavigationComponent
@export var vision: VisionComponent
@export var ai: AIComponent
@export var state: StateComponent


func _ready():

	if navigation:
		navigation.actor = self
		navigation.movement = movement
		navigation.agent = $NavigationAgent3D

	if vision:
		vision.actor = self
		vision.eyes = $Eyes
		vision.ray = $Eyes/VisionRay

	if ai:
		ai.actor = self


func _physics_process(delta: float) -> void:
	if health and health.dead:
		return

	if vision:
		vision.tick(delta)

	if ai:
		ai.tick(delta)

	if navigation:
		navigation.tick(delta)

	if movement:
		movement.on_floor = is_on_floor()
		movement.basis = global_basis
		movement._tick(delta)

	if vision and navigation:
		if vision.current_target:
			navigation.move_to_node(vision.current_target)
		elif vision.last_seen_position != Vector3.ZERO:
			navigation.move_to_position(vision.last_seen_position)

	move_and_slide()
