@tool
extends AnimationTree



@export var move_amount: float = 0.0
@export var shooting: bool = false


func _physics_process(delta: float) -> void:
	lerp_param(&'parameters/MoveAmount/blend_position', move_amount, delta * 5.0)
	set(&'parameters/Shooting/blend_amount', float(shooting))

func lerp_param(property: StringName, value: Variant, delta: float) -> void:
	set(property, lerp(get(property), value, delta))
