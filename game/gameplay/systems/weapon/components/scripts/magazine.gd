extends WeaponComponent


@export var bullet_type: StringName = &'pistol'

@export var magazine_size: int = 12
var ammo: int = 12: set = set_ammo


# --- WEAPON ---
func _shoot_request() -> void: pass
func _shoot_process(_attack_data: AttackData) -> void:
	ammo -= 1
func _message(message_name: StringName, args: Array) -> void:
	match message_name:
		&'set_bullets':
			var amount: int = args.get(0)
			set_ammo(amount)
		#&'request_magazine_data':
			#pass
func _configurate(key: StringName, value: Variant) -> void:
	match key:
		&'magazine_size':
			magazine_size = value
			ammo = value


# --- FUNCTIONS ---
func reload_request() -> void:
	if is_full(): return
	weapon.send_message(&'reload_request', bullet_type)

# --- CONDITIONS ---
func have_ammo() -> bool:
	return ammo > 0
func is_full() -> bool:
	return ammo == magazine_size


# --- SETTERS ---
func set_ammo(value: int) -> void:
	ammo = min(value, magazine_size)
	if weapon:
		weapon.shoot_conditions['have_ammo'] = have_ammo()
