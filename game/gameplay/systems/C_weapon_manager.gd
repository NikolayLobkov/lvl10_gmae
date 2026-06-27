@tool
@icon('res://assets/editor_icons/group.svg')
class_name WeaponManager extends Node3D


signal weapon_shooted(weapon: Weapon)
#signal weapon_overheated(weapon: Weapon, overheating_meter: OverheatingMeter)
signal weapon_changed(to: Weapon, idx: int)

signal weapon_message(key: StringName, content: Array)


@export var cur_weapon: int = 0:
	set = change_weapon_idx
@export var enabled: bool = true: set = set_enabled
@export var enable_targeting: bool = false

var shoot_target := Vector3.ZERO

func _ready() -> void:
	set_enabled(enabled)
	change_weapon_idx(cur_weapon)
	
	if Engine.is_editor_hint(): return
	
	for w: Weapon in get_children():
		w.shooted.connect(weapon_shooted.emit.bind(w))
		w.message.connect(_on_weapon_message)
		w.target_mode = enable_targeting
		#if w.has_meta('overheating_meter'):
			#var ov_meter: OverheatingMeter = w.get_meta('overheating_meter')
			#if ov_meter:
				#ov_meter.overheated.connect(weapon_overheated.emit.bind(w, ov_meter))

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if enable_targeting:
		get_cur_weapon().target_position = shoot_target
	#get_cur_weapon().message.emit(&'request_magazine_data', [])

func weapon_attack() -> void:
	get_cur_weapon().shoot()
func weapon_reload() -> void:
	#get_cur_weapon().message.emit(&'request_magazine_data', [])
	get_cur_weapon().message.emit(&'set_bullets', [999])

func continue_reloading(content: Array) -> void:
	var weapon: Weapon = get_cur_weapon()
	var ammoes: int = content[0]
	var max_ammoes: int = content[1]
	
	if ammoes == max_ammoes: return
	
	var result: int = max_ammoes - ammoes
	
	weapon.message.emit(&'reloaded', [result])
	
	print('Reloaded: %d' % [ammoes + result])

func change_weapon_idx(value: int) -> void:
	cur_weapon = value
	if is_node_ready():
		value = clampi(value, 0, get_child_count() - 1)
		cur_weapon = value
		
		for w: Node in get_children():
			if w is Weapon:
				w.hide()
		get_cur_weapon().show()
		
		weapon_changed.emit(get_cur_weapon(), value)


func _on_weapon_message(key: StringName, content: Array) -> void:
	weapon_message.emit(key, content)
	
	match key:
		&'no_ammoes':
			weapon_reload()
		&'send_magazine_data':
			continue_reloading(content)

func get_cur_weapon() -> Weapon:
	return get_child(cur_weapon)

func set_enabled(value: bool) -> void:
	enabled = value
	visible = value

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	var w: bool = false
	for c: Node in get_children():
		if c is Weapon: w = true
	
	if not w: warnings.append("The weapon manager hasn't any weapon!")
	
	return warnings

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_CHILD_ORDER_CHANGED:
			update_configuration_warnings()
