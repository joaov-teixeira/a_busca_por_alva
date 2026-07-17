class_name DialogueTrigger
extends Area2D


signal dialogue_requested(lines: Array)


@export_category("Dialogue")

@export var speaker_name: String = "HERÓI"

@export var portrait: Texture2D

@export var internal_dialogue: bool = true

@export var one_shot: bool = true

@export var dialogue_texts: Array[String] = [
	"Este lugar parece diferente...",
	"A influência do Rei Demônio está mais forte aqui."
]


var already_used: bool = false


func _ready() -> void:
	add_to_group("dialogue_triggers")

	monitoring = true
	monitorable = true

	if not body_entered.is_connected(
		_on_body_entered
	):
		body_entered.connect(
			_on_body_entered
		)

	print(
		"DialogueTrigger carregado: ",
		get_path()
	)


func _on_body_entered(body: Node2D) -> void:
	print(
		"Corpo entrou no DialogueTrigger: ",
		body.name
	)

	if not body.is_in_group("player"):
		print(
			"O corpo não está no grupo player."
		)
		return

	if one_shot and already_used:
		print("Esse diálogo já foi executado.")
		return

	var lines: Array[Dictionary] = []

	for dialogue_text: String in dialogue_texts:
		if dialogue_text.strip_edges().is_empty():
			continue

		lines.append(
			{
				"speaker": speaker_name,
				"text": dialogue_text,
				"internal": internal_dialogue,
				"portrait": portrait
			}
		)

	if lines.is_empty():
		push_warning(
			"DialogueTrigger não possui textos."
		)
		return

	already_used = true

	print(
		"Emitindo diálogo com ",
		lines.size(),
		" falas."
	)

	dialogue_requested.emit(lines)

	if one_shot:
		set_deferred(
			"monitoring",
			false
		)
