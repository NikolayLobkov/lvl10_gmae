@icon('res://assets/editor_icons/component_3d.svg')
@abstract class_name WeaponComponent3D extends Node3D


#@export var use_external_weapon: bool = false
@export var external_weapon: Weapon
@export var enabled: bool = true

var weapon: Weapon


func _enter_tree() -> void:
	if not external_weapon:
		weapon = get_parent() as Weapon
	#assert(weapon, 'Оружие не найдено!')
	if not weapon: return
	
	# --- CONNECTING TO WEAPON SIGNALS ---
	weapon.shoot_request.connect(func():
		if enabled: _shoot_request()
	)
	weapon.shoot_process.connect(func(attack_data: AttackData):
		if enabled: _shoot_process(attack_data)
	)
	weapon.message.connect(func(message_name: StringName, args: Array):
		if enabled: _message(message_name, args)
	)
	weapon.configurate.connect(func(key: StringName, value: Variant):
		_configurate(key, value)
	)


# --- OVERRIDE ---
@abstract func _shoot_request() -> void
@abstract func _shoot_process(attack_data: AttackData) -> void
@abstract func _message(message_name: StringName, args: Array) -> void
@abstract func _configurate(key: StringName, value: Variant) -> void
