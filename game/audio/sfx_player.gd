extends Node

var _player: AudioStreamPlayer

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.bus = "SFX"  # или "Radio", если завели отдельный bus в Audio Bus Layout
	add_child(_player)

func play(stream: AudioStream) -> void:
	if stream == null:
		return
	_player.stream = stream
	_player.play()
