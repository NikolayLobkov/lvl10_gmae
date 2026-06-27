class_name Player extends CharacterBody3D


@onready var input_component: CharacterInputComponent = $InputComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var look_component: LookComponent = $LookComponent
@onready var weapon_manager: WeaponManager = %WeaponManager


func _physics_process(delta: float) -> void:
	movement_component.move_direction = input_component._get_move_direction()
	movement_component.move_amount = input_component._get_move_amount()
	movement_component.sprinting = input_component._sprinting()
	movement_component.jumping = input_component._jumping()
	movement_component.basis = basis
	movement_component.on_floor = is_on_floor()
	
	movement_component._tick(delta)
	move_and_slide()
	
	if input_component._attacking():
		weapon_manager.weapon_attack()

func _unhandled_input(event: InputEvent) -> void:
	look_component._input_tick(event)
	
	#if event.is_action_pressed(&'jump'):
		#movement_component.jumping = true
