extends Control

@onready var panel: Control = $Panel
@onready var portrait_rect: TextureRect = %Portrait
@onready var name_label: Label = %NameLabel
@onready var text_label: RichTextLabel = %TextLabel

func _ready() -> void:
	panel.modulate.a = 0.0
	DialogueManager.sequence_started.connect(_on_sequence_started)
	DialogueManager.line_started.connect(_on_line_started)
	DialogueManager.sequence_finished.connect(_on_sequence_finished)

func _on_sequence_started(seq: DialogueSequence) -> void:
	if seq.open_sfx:
		SfxPlayer.play(seq.open_sfx)
	create_tween().tween_property(panel, "modulate:a", 1.0, 0.15)

func _on_line_started(line: DialogueLine, index: int, total: int) -> void:
	portrait_rect.texture = line.portrait
	name_label.text = line.speaker_name
	name_label.modulate = line.tint
	_typewriter(line.text)
	if line.voice_clip:
		SfxPlayer.play(line.voice_clip)

func _on_sequence_finished(seq: DialogueSequence) -> void:
	if seq.close_sfx:
		SfxPlayer.play(seq.close_sfx)
	create_tween().tween_property(panel, "modulate:a", 0.0, 0.2)

func _typewriter(text: String) -> void:
	text_label.text = text
	text_label.visible_ratio = 0.0
	var tw := create_tween()
	tw.tween_property(text_label, "visible_ratio", 1.0, text.length() * 0.02)
