extends Area2D

signal dialogue_requested(lines)

@export_category("Internal Dialogue")

@export_multiline var thoughts: Array[String] = [
	"Essa floresta está silenciosa demais.",
	"Não consigo sentir a presença de Alva por aqui.",
	"Preciso continuar."
]

@export var thought_portrait: Texture2D
@export var one_shot: bool = true

var already_used: bool = false


func _ready() -> void:
	add_to_group("dialogue_triggers")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return

	if one_shot and already_used:
		return

	var lines: Array[Dictionary] = []

	for thought: String in thoughts:
		if thought.strip_edges().is_empty():
			continue

		lines.append({
			"speaker": "",
			"text": thought,
			"internal": true,
			"portrait": thought_portrait
		})

	if lines.is_empty():
		return

	already_used = true
	dialogue_requested.emit(lines)

	if one_shot:
		set_deferred("monitoring", false)
