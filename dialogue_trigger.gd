# dialogue_trigger.gd  (на Area3D где-нибудь в уровне)
extends Area3D

@export var sequence: DialogueSequence

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		DialogueManager.play(sequence)
