class_name HealthComponent extends Node


signal health_changed(value: float)
signal max_health_changed(value: float)
signal damage_taked(data: AttackData)



var health: float = 100.0: set = change_health
@export_range(1.0, 1000.0, 1.0, 'or_greater') var max_health: float = 100.0: set = change_max_health



func change_health(value: float) -> void:
	health = clampf(value, 0.0, max_health)
	health_changed.emit(value)
func change_max_health(value: float) -> void:
	max_health = maxf(max_health, 1.0)
	max_health_changed.emit(value)
func damage(data: AttackData) -> void:
	if data:
		health -= data.damage
		damage_taked.emit(data)
