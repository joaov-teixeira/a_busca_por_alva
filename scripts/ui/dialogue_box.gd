extends CanvasLayer

signal dialogue_finished

@onready var root: Control = $Root

@onready var portrait_texture: TextureRect = (
	$Root/DialoguePanel/MarginContainer/ContentContainer/PortraitTexture
)

@onready var speaker_label: Label = (
	$Root/DialoguePanel/MarginContainer/ContentContainer/TextContainer/SpeakerLabel
)

@onready var dialogue_label: Label = (
	$Root/DialoguePanel/MarginContainer/ContentContainer/TextContainer/DialogueLabel
)

@onready var continue_label: Label = (
	$Root/DialoguePanel/MarginContainer/ContentContainer/TextContainer/ContinueLabel
)

var lines: Array[Dictionary] = []
var current_index: int = 0
var is_active: bool = false
var can_advance: bool = false


func _ready() -> void:
	root.visible = false
	portrait_texture.visible = false


func start_dialogue(new_lines: Array[Dictionary]) -> void:
	if is_active:
		return

	if new_lines.is_empty():
		return

	lines = new_lines
	current_index = 0
	is_active = true
	can_advance = false

	root.visible = true
	show_current_line()

	# Evita que a mesma tecla/entrada que abriu o diálogo avance a fala.
	await get_tree().create_timer(0.15).timeout
	can_advance = true


func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return

	if not can_advance:
		return

	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		next_line()


func show_current_line() -> void:
	var line: Dictionary = lines[current_index]

	var speaker: String = str(line.get("speaker", ""))
	var text: String = str(line.get("text", ""))
	var internal: bool = bool(line.get("internal", false))
	var portrait: Texture2D = line.get("portrait", null)

	if internal:
		speaker_label.visible = false
		dialogue_label.text = "“" + text + "”"
		dialogue_label.modulate = Color(
			0.80,
			0.88,
			1.00,
			1.00
		)
	else:
		speaker_label.visible = true
		speaker_label.text = speaker
		dialogue_label.text = text
		dialogue_label.modulate = Color.WHITE

	# O retrato pode aparecer tanto em falas normais
	# quanto em pensamentos internos.
	if portrait != null:
		portrait_texture.texture = portrait
		portrait_texture.visible = true
	else:
		portrait_texture.texture = null
		portrait_texture.visible = false

	continue_label.text = "E / Enter — continuar"

func next_line() -> void:
	current_index += 1

	if current_index >= lines.size():
		finish_dialogue()
		return

	show_current_line()


func finish_dialogue() -> void:
	root.visible = false
	is_active = false
	can_advance = false
	lines.clear()

	dialogue_finished.emit()


func is_dialogue_open() -> bool:
	return is_active
