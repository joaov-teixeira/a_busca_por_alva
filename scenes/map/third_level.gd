extends Node2D


@export_file("*.tscn")
var game_over_scene_path: String = (
	"res://scenes/ui/game_over.tscn"
)


var player: CharacterBody2D = null
var hud: Node = null
var dialogue_box: Node = null
var battle_screen: Node = null

var dialogue_active: bool = false
var battle_active: bool = false
var changing_scene: bool = false

var player_max_health: int = 3
var player_current_health: int = 3

var current_enemy: BattleEnemy = null


func _ready() -> void:
	find_required_nodes()

	connect_dialogue_box_signal()
	connect_battle_screen_signals()

	if hud != null and hud.has_method("update_health"):
		hud.call(
			"update_health",
			player_current_health
		)

	# Aguarda os triggers e inimigos entrarem nos grupos.
	await get_tree().process_frame

	connect_dialogue_triggers()
	connect_battle_enemies()


# =========================================================
# LOCALIZAÇÃO DOS NÓS
# =========================================================

func find_required_nodes() -> void:
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

	battle_screen = find_child(
		"BattleScreen",
		true,
		false
	)

	if player == null:
		push_error(
			"Player não foi encontrado no terceiro mapa."
		)
	else:
		print(
			"Player encontrado: ",
			player.get_path()
		)

	if dialogue_box == null:
		push_error(
			"DialogueBox não foi encontrada no terceiro mapa."
		)
	else:
		print(
			"DialogueBox encontrada: ",
			dialogue_box.get_path()
		)

	if battle_screen == null:
		push_error(
			"BattleScreen não foi encontrada no terceiro mapa. "
			+ "Copie a BattleScreen do primeiro mapa."
		)
	else:
		print(
			"BattleScreen encontrada: ",
			battle_screen.get_path()
		)

	if hud == null:
		push_warning(
			"HUD não foi encontrada. "
			+ "A batalha ainda pode funcionar sem ela."
		)


# =========================================================
# FUNÇÃO AUXILIAR PARA CONECTAR SINAIS
# =========================================================

func connect_node_signal(
	source: Node,
	signal_name: StringName,
	callback: Callable
) -> void:
	if source == null:
		return

	if not source.has_signal(signal_name):
		push_error(
			"O nó "
			+ source.name
			+ " não possui o sinal "
			+ str(signal_name)
			+ "."
		)
		return

	if not source.is_connected(
		signal_name,
		callback
	):
		source.connect(
			signal_name,
			callback
		)


# =========================================================
# DIALOGUE BOX
# =========================================================

func connect_dialogue_box_signal() -> void:
	if dialogue_box == null:
		return

	connect_node_signal(
		dialogue_box,
		&"dialogue_finished",
		Callable(
			self,
			"_on_dialogue_finished"
		)
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
		"Triggers encontrados no mapa 3: ",
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
	if changing_scene:
		return

	if dialogue_active:
		return

	if battle_active:
		return

	if lines.is_empty():
		return

	if player == null:
		push_error(
			"Player está null ao iniciar o diálogo."
		)
		return

	if dialogue_box == null:
		push_error(
			"DialogueBox está null ao iniciar o diálogo."
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

	if not battle_active and not changing_scene:
		if player != null:
			player.set_can_move(true)


# =========================================================
# BATTLE SCREEN
# =========================================================

func connect_battle_screen_signals() -> void:
	if battle_screen == null:
		return

	connect_node_signal(
		battle_screen,
		&"battle_won",
		Callable(
			self,
			"_on_battle_won"
		)
	)

	connect_node_signal(
		battle_screen,
		&"battle_fled",
		Callable(
			self,
			"_on_battle_fled"
		)
	)

	connect_node_signal(
		battle_screen,
		&"player_damaged",
		Callable(
			self,
			"_on_player_damaged"
		)
	)

	connect_node_signal(
		battle_screen,
		&"player_defeated",
		Callable(
			self,
			"_on_player_defeated"
		)
	)


# =========================================================
# CONEXÃO DOS INIMIGOS
# =========================================================

func connect_battle_enemies() -> void:
	var enemies: Array[Node] = (
		get_tree().get_nodes_in_group(
			"battle_enemies"
		)
	)

	print(
		"Inimigos encontrados no mapa 3: ",
		enemies.size()
	)

	for node: Node in enemies:
		if not node is BattleEnemy:
			push_warning(
				"O nó "
				+ node.name
				+ " está no grupo battle_enemies, "
				+ "mas não possui a classe BattleEnemy."
			)
			continue

		var enemy: BattleEnemy = node

		if not enemy.battle_requested.is_connected(
			_on_enemy_battle_requested
		):
			enemy.battle_requested.connect(
				_on_enemy_battle_requested
			)

		print(
			"Inimigo conectado: ",
			enemy.get_path()
		)


# =========================================================
# INÍCIO DA BATALHA
# =========================================================

func _on_enemy_battle_requested(
	enemy: BattleEnemy
) -> void:
	print(
		"Pedido de batalha recebido de: ",
		enemy.enemy_name
	)

	if changing_scene:
		enemy.unlock_after_flee()
		return

	if battle_active:
		enemy.unlock_after_flee()
		return

	if dialogue_active:
		enemy.unlock_after_flee()
		return

	if player == null:
		push_error(
			"Não foi possível iniciar a batalha: Player null."
		)
		enemy.unlock_after_flee()
		return

	if battle_screen == null:
		push_error(
			"Não foi possível iniciar a batalha: "
			+ "BattleScreen null."
		)
		enemy.unlock_after_flee()
		return

	if not battle_screen.has_method("start_battle"):
		push_error(
			"A BattleScreen não possui start_battle()."
		)
		enemy.unlock_after_flee()
		return

	battle_active = true
	current_enemy = enemy

	player.set_can_move(false)

	if hud != null:
		hud.visible = false

	battle_screen.call(
		"start_battle",
		enemy,
		player_current_health,
		player_max_health
	)


# =========================================================
# DANO RECEBIDO
# =========================================================

func _on_player_damaged(
	amount: int
) -> void:
	player_current_health = maxi(
		0,
		player_current_health - amount
	)

	if hud != null and hud.has_method(
		"update_health"
	):
		hud.call(
			"update_health",
			player_current_health
		)


# =========================================================
# VITÓRIA
# =========================================================

func _on_battle_won() -> void:
	var reward: int = 0
	var defeated_enemy_name: String = "Inimigo"

	if is_instance_valid(current_enemy):
		reward = current_enemy.courage_reward
		defeated_enemy_name = current_enemy.enemy_name

		current_enemy.defeat()

	current_enemy = null
	battle_active = false

	if hud != null:
		hud.visible = true

		if reward > 0 and hud.has_method(
			"increase_courage"
		):
			hud.call(
				"increase_courage",
				reward
			)

		if hud.has_method("show_message"):
			hud.call(
				"show_message",
				(
					"%s derrotado! +%d de Coragem."
					% [
						defeated_enemy_name,
						reward
					]
				),
				3.0
			)

	if player != null:
		player.set_can_move(true)


# =========================================================
# FUGA
# =========================================================

func _on_battle_fled() -> void:
	if is_instance_valid(current_enemy):
		current_enemy.unlock_after_flee()

	current_enemy = null
	battle_active = false

	if hud != null:
		hud.visible = true

		if hud.has_method("show_message"):
			hud.call(
				"show_message",
				"Você fugiu da batalha.",
				2.0
			)

	if player != null:
		player.set_can_move(true)


# =========================================================
# DERROTA
# =========================================================

func _on_player_defeated() -> void:
	if changing_scene:
		return

	changing_scene = true
	battle_active = false
	dialogue_active = false
	current_enemy = null

	if player != null:
		player.set_can_move(false)

	if hud != null:
		hud.visible = false

	if not ResourceLoader.exists(
		game_over_scene_path
	):
		push_error(
			"A cena de Game Over não existe: "
			+ game_over_scene_path
		)
		return

	SceneTransition.change_scene(
		game_over_scene_path
	)
