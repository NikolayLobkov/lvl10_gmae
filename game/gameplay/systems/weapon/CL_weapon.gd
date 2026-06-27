@icon('res://assets/editor_icons/tool_3d.svg')
class_name Weapon extends Node3D


signal shoot_request
signal shoot_process(attack_data: AttackData)
signal shooted

signal message(key: StringName, content: Array)
signal configurate(key: StringName, value: Variant)


@export var config: WeaponData


var damage = 10.0
var is_shooting: bool = false

var shoot_conditions: Dictionary = {} # Cooldown, ammoes, heating

var target_mode: bool = false
var target_position := Vector3.ZERO


func _enter_tree() -> void:
	shoot_request.connect(_shoot_request)
	config.changed.connect(config_setup)

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	config_setup()

# --- SHOOTING FUNCS ---
func shoot() -> void:
	shoot_request.emit()
func _shoot_request() -> void:
	if can_shoot():
		var attack_data := AttackData.new()
		attack_data.damage = damage
		if target_mode:
			attack_data.target_position = target_position
		shoot_process.emit(attack_data)
		shooted.emit()

# --- MESSAGE FUNCS ---
func send_message(message_name: StringName, ...args: Array) -> void:
	message.emit(message_name, args)
func sendv_message(message_name: StringName, args: Array) -> void:
	message.emit(message_name, args)

# --- CONFIGURATION SETUP ---
func config_setup() -> void:
	if not config: return
	var properties: Dictionary[StringName, Variant] = config.get_properties()
	
	for key: StringName in properties.keys():
		#sendv_message(&'configurate', [key, properties[key]])
		configurate.emit(key, properties[key])
	damage = properties[&'damage']
func get_config_param(key: StringName, default: Variant = null) -> Variant:
	if config: return config.get_property(key, default)
	return default



func can_shoot() -> bool:
	return not false in shoot_conditions.values()
