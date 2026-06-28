@icon('res://assets/editor_icons/heart.svg')
class_name HealthComponent extends Node


signal health_changed(value: float)
signal max_health_changed(value: float)
signal damage_taked(data: AttackData)
signal death

@export_range(1.0, 1000.0, 1.0, 'or_greater') var max_health: float = 100.0: set = change_max_health

var health: float = 100.0: set = change_health
var dead: bool = false


func change_health(value: float) -> void:
	value = clampf(value, 0.0, max_health)
	health = value
	health_changed.emit(value)
	
	if value <= 0.0 and not dead:
		dead = true
		death.emit()
	else:
		dead = false
func change_max_health(value: float) -> void:
	value = maxf(value, 1.0)
	max_health = value
	max_health_changed.emit(value)
func damage(data: AttackData) -> void:
	if data:
		health -= data.damage
		damage_taked.emit(data)
