class_name MovementComponent extends Node


const GRAVITY := Vector3(0.0, -9.8, 0.0)

@export var actor: CharacterBody3D
@export var params: MovementParams

# --- INPUT ---
var move_direction: Vector2
var move_amount: float
var sprinting: bool
var jumping: bool
var on_floor: bool
var basis: Basis

var velocity: Vector3
var direction: Vector3

var speed: float


func _tick(delta: float) -> void:
	velocity = actor.velocity
	
	speed = params.default_speed
	if sprinting: speed *= params.sprint_mult
	
	direction = basis * Vector3(move_direction.x, 0.0, move_direction.y) * move_amount
	
	velocity.x = lerpf(velocity.x, direction.x * speed, delta * params.acell)
	velocity.z = lerpf(velocity.z, direction.z * speed, delta * params.acell)
	
	if not on_floor:
		velocity += GRAVITY * delta
		if jumping: jumping = false
	elif jumping:
		velocity.y += params.jump_force
	
	
	actor.velocity = velocity
	
