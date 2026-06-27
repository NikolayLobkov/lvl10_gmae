class_name Hitbox extends Area3D


signal damage_taked(data: AttackData)

@export var health_comp: HealthComponent


func _enter_tree() -> void:
	# Выставляем значение слоя на всякий случай.
	collision_layer = 1 << 3

func damage(data: AttackData) -> void:
	damage_taked.emit(data)
	if health_comp:
		health_comp.damage(data)
		return
	print_rich('[color=red]Компонент здоровья не указан![/color]')
