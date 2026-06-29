extends AudioStreamPlayer

@export_range(0, 5, 1) var type_sound = 0

var is_fall:=false

func _process(delta: float) -> void:
	if type_sound == 0:
		if !playing:
			if $"../MovementComponent".velocity.length() > 0.1:
				play()
	if type_sound == 1:
		if !playing:
			if $"../MovementComponent".on_floor:
				if is_fall == true:
					play()
					is_fall = false
			else:
				is_fall = true
	if type_sound == 2:
		if !playing:
			if $"../MovementComponent".jumping:
				play()
