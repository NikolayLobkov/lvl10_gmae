class_name Player extends CharacterBody3D


@onready var movement_component: MovementComponent = $MovementComponent
@onready var look_component: LookComponent = $LookComponent


func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector(&'move_left', &'move_right', &'move_forward', &'move_backward')
	
	movement_component.move_direction = input_vector.normalized()
	movement_component.move_amount = input_vector.length()
	movement_component.sprinting = Input.is_action_pressed(&'sprint')
	movement_component.basis = basis
	movement_component.on_floor = is_on_floor()
	
	movement_component._tick(delta)
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	look_component._input_tick(event)
	
	if event.is_action_pressed(&'jump'):
		movement_component.jumping = true
