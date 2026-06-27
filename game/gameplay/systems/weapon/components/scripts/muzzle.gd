extends WeaponComponent3D


@onready var bullet_emmiter: Node3D = $BulletEmmiter


func _shoot_request() -> void: pass
func _shoot_process(attack_data: AttackData) -> void:
	bullet_emmiter.shoot(attack_data)
	print('SHOOT')
func _message(_message_name: StringName, _args: Array) -> void:
	pass
func _configurate(key: StringName, value: Variant) -> void:
	match key:
		&'shoot_sound':
			bullet_emmiter.shoot_audio_stream = value
			#print('CONFIGURATED')
		&'shoot_sound_pitch_scale':
			bullet_emmiter.shoot_audio_pitch_scale = value
