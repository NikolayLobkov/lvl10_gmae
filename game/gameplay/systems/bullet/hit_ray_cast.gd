extends RayCast3D

const TEST_EXPLOSION = preload("uid://cpccnrjbsma8b")

func hit(data: AttackData) -> void:
	var collider := get_collider()
	var explosion:=TEST_EXPLOSION.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = get_collision_point()
	if collider is Hitbox:
		collider.damage(data)
