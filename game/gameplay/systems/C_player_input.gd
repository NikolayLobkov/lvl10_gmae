class_name PlayerInputComponent extends CharacterInputComponent




func _get_move_direction() -> Vector2:
	return Input.get_vector(&'move_left', &'move_right', &'move_forward', &'move_backward').normalized()
func _get_move_amount() -> float:
	return Input.get_vector(&'move_left', &'move_right', &'move_forward', &'move_backward').length()

func _sprinting() -> bool:
	return Input.is_action_pressed(&'sprint')
func _jumping() -> bool:
	return Input.is_action_just_pressed(&'jump')
func _attacking() -> bool:
	return Input.is_action_pressed(&'attack')
