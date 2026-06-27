extends WeaponComponent



@export_range(0.01, 12.0, 0.01, 'or_greater', 'hide_control', 'suffix:sec') var cooldown_time: float = 0.2:
	set = set_cooldown_time


var timer := Timer.new()


func _ready() -> void:
	add_child(timer)
	timer.one_shot = true
	
	timer.timeout.connect(_on_timer_timeout)
	
	#set_cooldown_time(cooldown_time)


# --- COMPONENT OVERRIDE ---
func _shoot_request() -> void: pass
func _shoot_process(_attack_data: AttackData) -> void:
	weapon.shoot_conditions['cooldown'] = false
	timer.wait_time = cooldown_time
	timer.start()
func _message(_message_name: StringName, _args: Array) -> void:
	pass
func _configurate(key: StringName, value: Variant) -> void:
	match key:
		&'cooldown':
			cooldown_time = value

# --- SETTERS ---
func set_cooldown_time(value: float) -> void:
	cooldown_time = value
	if timer:
		timer.wait_time = value

# --- CONNECTIONS ---
func _on_timer_timeout() -> void:
	weapon.shoot_conditions['cooldown'] = true
