extends Area2D

signal dialogue_requested(lines)

@export var npc_name: String = "NPC"
@export var npc_portrait: Texture2D

@export var dialogue_texts: Array[String] = [
	"Olá, viajante.",
	"A floresta está diferente desde que a escuridão chegou.",
	"Tenha cuidado ao seguir adiante."
]

@export var repeatable: bool = false

var already_used: bool = false
var player_inside: bool = false


func _ready() -> void:
	add_to_group("dialogue_triggers")

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return

	if already_used and not repeatable:
		return

	if player_inside:
		return

	player_inside = true
	request_dialogue()


func _on_body_exited(body: Node2D) -> void:
	if body.name != "Player":
		return

	player_inside = false


func request_dialogue() -> void:
	var lines: Array[Dictionary] = []

	for text in dialogue_texts:
		if text.strip_edges().is_empty():
			continue

		lines.append({
			"speaker": npc_name,
			"text": text,
			"internal": false,
			"portrait": npc_portrait
		})

	if lines.is_empty():
		return

	already_used = true
	dialogue_requested.emit(lines)
