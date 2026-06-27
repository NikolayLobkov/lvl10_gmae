@tool
class_name WeaponData extends Resource


@export_range(0.0, 10000.0, 0.1, 'or_greater', 'hide_control', 'suffix:hp') var damage: float = 10.0:
	set(value):
		damage = value
		emit_changed()
@export_range(0.01, 12.0, 0.01, 'or_greater', 'hide_control', 'suffix:sec') var cooldown: float = 0.2:
	set(value):
		cooldown = value
		emit_changed()
@export_range(1, 1024, 1, 'or_greater', 'suffix:ammo') var magazine_size: int = 12:
	set(value):
		magazine_size = value
		emit_changed()
@export var shoot_sound: AudioStream:
	set(value):
		shoot_sound = value
		emit_changed()
@export_range(0.01, 4.0, 0.01, 'or_greater') var shoot_sound_pitch_scale: float = 1.0:
	set(value):
		shoot_sound_pitch_scale = value
		emit_changed()


#func _get_property_list() -> Array[Dictionary]:
	#var properties: Array[Dictionary] = []
	#
	#return properties


# --- SETTERS ---
#func set_damage(value: float) -> void:
	#damage = value
	#emit_changed()
#func get_cooldown(value: float) -> void:
	#cooldown = value
	#emit_changed()
#func set_magazine_size(value: int) -> void:
	#magazine_size = value
	#emit_changed()
#func set_shoot_audio(value: AudioStream) -> void:
	#shoot_sound = value
	#emit_changed()



# --- PROPERTIES ---
func get_properties() -> Dictionary[StringName, Variant]:
	var properties: Dictionary[StringName, Variant] = {}
	var add: Callable = func(key: StringName) -> void:
		properties[key] = get(key)
	
	add.call(&'damage')
	add.call(&'cooldown')
	add.call(&'magazine_size')
	add.call(&'shoot_sound')
	add.call(&'shoot_sound_pitch_scale')
	
	return properties

func get_property(key: StringName, default: Variant) -> Variant:
	var p: Variant = get(key)
	if p: return p
	return default
