# === UI MANAGER ===

extends Node



var MouseManager := preload('res://game/ui/globals/MOD_mouse_manager.gd').new()



func _enter_tree() -> void:
	add_child(MouseManager, true)
