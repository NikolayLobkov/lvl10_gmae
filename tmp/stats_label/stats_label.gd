extends Label3D


@export var health_comp: HealthComponent



func _ready() -> void:
	health_comp.health_changed.connect(func(health: float) -> void:
		text = str(health)
	)
	
	text = str(health_comp.health)
