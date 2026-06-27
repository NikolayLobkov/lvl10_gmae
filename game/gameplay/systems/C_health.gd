class_name HealthComponent extends Node


signal health_changed(value: float)
signal max_health_changed(value: float)
signal damage_taked



var health: float = 100.0: set = change_health
var max_health: float = 100.0: set = change_max_health



func change_health(value: float) -> void:
	health = value
func change_max_health(value: float) -> void:
	max_health = value
func damage() -> void:
	pass
