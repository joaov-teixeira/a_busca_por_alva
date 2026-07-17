extends Node2D


@export_file("*.tscn")
var next_scene_path: String = (
	"res://scenes/map/third_level.tscn"
)


var player: CharacterBody2D = null
var hud: Node = null
var dialogue_box: Node = null

var dialogue_active: bool = false
var changing_scene: bool = false


func _ready() -> void:
	find_map_nodes()
	connect_dialogue_box_signal()

	# Aguarda os gatilhos entrarem em seus grupos.
	await get_tree().process_frame

	connect_dialogue_triggers()
	connect_level_exits()


# =========================================================
# LOCALIZAÇÃO DOS NÓS
# =========================================================

func find_map_nodes() -> void:
	player = find_child(
		"Player",
		true,
		false
	) as CharacterBody2D

	hud = find_child(
		"HUD",
		true,
		false
	)

	dialogue_box = find_child(
		"DialogueBox",
		true,
		false
	)

	if player == null:
		push_error(
			"Player não encontrado no segundo mapa."
		)
	else:
		print(
			"Player encontrado: ",
			player.get_path()
		)

	if hud == null:
		push_warning(
			"HUD não encontrada no segundo mapa."
		)
	else:
		print(
			"HUD encontrada: ",
			hud.get_path()
		)

	if dialogue_box == null:
		push_error(
			"DialogueBox não encontrada no segundo mapa."
		)
	else:
		print(
			"DialogueBox encontrada: ",
			dialogue_box.get_path()
		)


# =========================================================
# DIALOGUE BOX
# =========================================================

func connect_dialogue_box_signal() -> void:
	if dialogue_box == null:
		return

	if not dialogue_box.has_signal(
		"dialogue_finished"
	):
		push_error(
			"DialogueBox não possui o sinal dialogue_finished."
		)
		return

	var callback: Callable = Callable(
		self,
		"_on_dialogue_finished"
	)

	if not dialogue_box.is_connected(
		"dialogue_finished",
		callback
	):
		dialogue_box.connect(
			"dialogue_finished",
			callback
		)


# =========================================================
# GATILHOS DE DIÁLOGO
# =========================================================

func connect_dialogue_triggers() -> void:
	var triggers: Array[Node] = (
		get_tree().get_nodes_in_group(
			"dialogue_triggers"
		)
	)

	print(
		"Triggers de diálogo encontrados: ",
		triggers.size()
	)

	var callback: Callable = Callable(
		self,
		"_on_dialogue_requested"
	)

	for trigger: Node in triggers:
		if not trigger.has_signal(
			"dialogue_requested"
		):
			push_warning(
				"O nó "
				+ trigger.name
				+ " não possui dialogue_requested."
			)
			continue

		if not trigger.is_connected(
			"dialogue_requested",
			callback
		):
			trigger.connect(
				"dialogue_requested",
				callback
			)

		print(
			"Trigger conectado: ",
			trigger.get_path()
		)


func _on_dialogue_requested(
	lines: Array
) -> void:
	print(
		"Diálogo recebido com ",
		lines.size(),
		" falas."
	)

	if changing_scene:
		return

	if dialogue_active:
		return

	if player == null:
		push_error(
			"Não foi possível iniciar o diálogo: Player null."
		)
		return

	if dialogue_box == null:
		push_error(
			"Não foi possível iniciar o diálogo: "
			+ "DialogueBox null."
		)
		return

	if lines.is_empty():
		push_warning(
			"O diálogo recebido está vazio."
		)
		return

	if not dialogue_box.has_method(
		"start_dialogue"
	):
		push_error(
			"DialogueBox não possui start_dialogue()."
		)
		return

	dialogue_active = true
	player.set_can_move(false)

	dialogue_box.call(
		"start_dialogue",
		lines
	)


func _on_dialogue_finished() -> void:
	dialogue_active = false

	if changing_scene:
		return

	if player != null:
		player.set_can_move(true)


# =========================================================
# SAÍDA DO MAPA
# =========================================================

func connect_level_exits() -> void:
	var exits: Array[Node] = (
		get_tree().get_nodes_in_group(
			"level_exits"
		)
	)

	print(
		"Saídas encontradas no mapa 2: ",
		exits.size()
	)

	var callback: Callable = Callable(
		self,
		"_on_level_exit_requested"
	)

	for level_exit: Node in exits:
		if not level_exit.has_signal(
			"level_exit_requested"
		):
			push_warning(
				"O nó "
				+ level_exit.name
				+ " não possui level_exit_requested."
			)
			continue

		if not level_exit.is_connected(
			"level_exit_requested",
			callback
		):
			level_exit.connect(
				"level_exit_requested",
				callback
			)

		print(
			"Saída conectada: ",
			level_exit.get_path()
		)


func _on_level_exit_requested() -> void:
	if changing_scene:
		return

	if next_scene_path.is_empty():
		push_error(
			"O caminho da próxima cena está vazio."
		)
		return

	if not ResourceLoader.exists(
		next_scene_path
	):
		push_error(
			"A próxima cena não existe: "
			+ next_scene_path
		)
		return

	changing_scene = true

	if player != null:
		player.set_can_move(false)

	if hud != null:
		hud.visible = false

	SceneTransition.change_scene(
		next_scene_path
	)
