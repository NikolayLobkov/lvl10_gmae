extends RayCast3D



func hit(data: AttackData) -> void:
	var collider := get_collider()
	if collider is Hitbox:
		collider.damage(data)
