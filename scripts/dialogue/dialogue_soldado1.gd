extends Area2D

signal dialogue_requested(lines)

@export var npc_name: String = "Soldado"

@export var dialogue_texts: Array[String] = [
	"Olá, Himmel, há quanto tempo...",
	"Nosso alvo está pela frente, a floresta está estranha, tome cuidado.",
]

@export var repeatable: bool = true

@onready var prompt_label: Label = $PromptLabel

var player_nearby: bool = false
var dialogue_used: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	prompt_label.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not player_nearby:
		return

	if dialogue_used and not repeatable:
		return

	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		request_dialogue()


func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return

	player_nearby = true

	if dialogue_used and not repeatable:
		return

	prompt_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.name != "Player":
		return

	player_nearby = false
	prompt_label.visible = false


func request_dialogue() -> void:
	var lines: Array[Dictionary] = []

	for text in dialogue_texts:
		if text.strip_edges().is_empty():
			continue

		lines.append({
			"speaker": npc_name,
			"text": text,
			"internal": false
		})

	if lines.is_empty():
		return

	dialogue_used = true
	prompt_label.visible = false

	dialogue_requested.emit(lines)
