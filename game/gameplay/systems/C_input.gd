@icon('res://assets/editor_icons/controller.svg')
@abstract class_name CharacterInputComponent extends Node




@abstract func _get_move_direction() -> Vector2
@abstract func _get_move_amount() -> float

@abstract func _sprinting() -> bool
@abstract func _jumping() -> bool
@abstract func _attacking() -> bool
@abstract func _reload() -> bool
