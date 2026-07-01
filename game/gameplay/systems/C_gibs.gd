extends Node



@export var skeleton: Skeleton3D
@export var hitbox: Hitbox


func _ready() -> void:
	if hitbox:
		hitbox.damage_taked.connect(_on_damage_taked)
	else: print_rich('[color=red]Hitbox не указан![/color]')

func _on_damage_taked(data: AttackData) -> void:
	pass
