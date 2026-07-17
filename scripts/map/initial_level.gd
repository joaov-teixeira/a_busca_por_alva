extends Node2D


@onready var player: CharacterBody2D = $Player
@onready var hud = $HUD
@onready var dialogue_box = $DialogueBox
@onready var battle_screen = $BattleScreen


var dialogue_active: bool = false
var battle_active: bool = false

var player_max_health: int = 10
var player_current_health: int = 5


var current_enemy: BattleEnemy = null
@export_category("Degenerated Area")

@export var courage_decay_per_second: float = 1
@export var courage_after_collapse: float = 40.0

var player_max_courage: float = 100.0
var player_current_courage: float = 100.0

var active_degenerated_areas: Array[DegeneratedArea] = []

var defeat_in_progress: bool = false

func _ready() -> void:
	connect_battle_screen_signals()
	connect_dialogue_box_signals()

	hud.update_health(player_current_health)
	hud.update_courage(player_current_courage)
	# Aguarda NPCs e inimigos entrarem em seus grupos.
	await get_tree().process_frame

	connect_dialogue_triggers()
	connect_battle_enemies()
	connect_degenerated_areas()
	connect_level_exits()
# =========================================================
# CONEXÃO DOS SINAIS PRINCIPAIS
# =========================================================
func connect_level_exits() -> void:
	var exits: Array[Node] = get_tree().get_nodes_in_group(
		"level_exits"
	)

	print("Saídas encontradas: ", exits.size())

	for node: Node in exits:
		if not node is LevelExit:
			continue

		var level_exit: LevelExit = node

		if not level_exit.level_exit_requested.is_connected(
			_on_level_exit_requested
		):
			level_exit.level_exit_requested.connect(
				_on_level_exit_requested
			)
			
func _on_level_exit_requested() -> void:
	if defeat_in_progress:
		return

	if battle_active:
		return

	if dialogue_active:
		return

	player.set_can_move(false)
	hud.visible = false

	SceneTransition.change_scene(
		"res://scenes/ui/level_complete.tscn"
	)
	
func connect_degenerated_areas() -> void:
	var areas: Array[Node] = get_tree().get_nodes_in_group(
		"degenerated_areas"
	)

	print("Áreas degeneradas encontradas: ", areas.size())

	for node: Node in areas:
		if not node is DegeneratedArea:
			continue

		var area: DegeneratedArea = node

		if not area.player_entered.is_connected(
			_on_degenerated_area_entered
		):
			area.player_entered.connect(
				_on_degenerated_area_entered
			)

		if not area.player_exited.is_connected(
			_on_degenerated_area_exited
		):
			area.player_exited.connect(
				_on_degenerated_area_exited
			)


func _on_degenerated_area_entered(
	area: DegeneratedArea
) -> void:
	if active_degenerated_areas.has(area):
		return

	active_degenerated_areas.append(area)

	hud.show_message(
		"Você entrou em uma Área Degenerada.",
		2.0
	)


func _on_degenerated_area_exited(
	area: DegeneratedArea
) -> void:
	active_degenerated_areas.erase(area)

	if active_degenerated_areas.is_empty():
		hud.show_message(
			"Você deixou a Área Degenerada.",
			2.0
		)

func connect_dialogue_box_signals() -> void:
	if not dialogue_box.dialogue_finished.is_connected(
		_on_dialogue_finished
	):
		dialogue_box.dialogue_finished.connect(
			_on_dialogue_finished
		)


func connect_battle_screen_signals() -> void:
	if not battle_screen.battle_won.is_connected(
		_on_battle_won
	):
		battle_screen.battle_won.connect(
			_on_battle_won
		)

	if not battle_screen.battle_fled.is_connected(
		_on_battle_fled
	):
		battle_screen.battle_fled.connect(
			_on_battle_fled
		)

	if not battle_screen.player_damaged.is_connected(
		_on_player_damaged
	):
		battle_screen.player_damaged.connect(
			_on_player_damaged
		)

	if not battle_screen.player_defeated.is_connected(
		_on_player_defeated
	):
		battle_screen.player_defeated.connect(
			_on_player_defeated
		)

func _process(delta: float) -> void:
	if defeat_in_progress:
		return

	if dialogue_active:
		return

	if battle_active:
		return

	if active_degenerated_areas.is_empty():
		return

	player_current_courage = maxf(
		0.0,
		player_current_courage
		- courage_decay_per_second * delta
	)

	hud.update_courage(player_current_courage)

	if player_current_courage <= 0.0:
		handle_courage_exhausted()
# =========================================================
# SISTEMA DE DIÁLOGO
# =========================================================

func handle_courage_exhausted() -> void:
	player_current_health = max(
		0,
		player_current_health - 1
	)

	hud.update_health(player_current_health)

	if player_current_health <= 0:
		_on_player_defeated()
		return

	player_current_courage = courage_after_collapse

	hud.update_courage(player_current_courage)

	hud.show_message(
		"A escuridão consumiu 1 coração!",
		2.5
	)

func connect_dialogue_triggers() -> void:
	var triggers: Array[Node] = get_tree().get_nodes_in_group(
		"dialogue_triggers"
	)

	var callback := Callable(
		self,
		"_on_dialogue_requested"
	)

	print("Triggers de diálogo encontrados: ", triggers.size())

	for trigger: Node in triggers:
		if not trigger.has_signal("dialogue_requested"):
			continue

		if not trigger.is_connected(
			"dialogue_requested",
			callback
		):
			trigger.connect(
				"dialogue_requested",
				callback
			)


func _on_dialogue_requested(lines: Array) -> void:
	if dialogue_active:
		return

	if battle_active:
		return

	dialogue_active = true
	player.set_can_move(false)

	dialogue_box.start_dialogue(lines)


func _on_dialogue_finished() -> void:
	dialogue_active = false

	# Evita liberar o movimento caso uma batalha esteja ativa.
	if not battle_active:
		player.set_can_move(true)


# =========================================================
# CONEXÃO DOS INIMIGOS
# =========================================================

func connect_battle_enemies() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group(
		"battle_enemies"
	)

	print("Inimigos encontrados: ", enemies.size())

	for enemy: Node in enemies:
		if not enemy is BattleEnemy:
			continue

		var battle_enemy: BattleEnemy = enemy

		if not battle_enemy.battle_requested.is_connected(
			_on_enemy_battle_requested
		):
			battle_enemy.battle_requested.connect(
				_on_enemy_battle_requested
			)
			print(
				"Inimigo conectado: ",
				battle_enemy.name
			)

func _on_enemy_battle_requested(
	enemy: BattleEnemy
) -> void:
	print(
		"Pedido de batalha recebido de: ",
		enemy.enemy_name
	)

	if battle_active:
		print("Já existe uma batalha ativa.")
		enemy.unlock_after_flee()
		return

	if dialogue_active:
		print("Existe um diálogo ativo.")
		enemy.unlock_after_flee()
		return

	battle_active = true
	current_enemy = enemy

	player.set_can_move(false)
	hud.visible = false

	print("Abrindo BattleScreen.")

	battle_screen.start_battle(
		enemy,
		player_current_health,
		player_max_health
	)

# =========================================================
# AÇÕES E RESULTADOS DA BATALHA
# =========================================================

func _on_player_damaged(amount: int) -> void:
	player_current_health = max(
		0,
		player_current_health - amount
	)

	hud.update_health(player_current_health)


func _on_battle_won() -> void:
	var reward: int = 0
	var defeated_enemy_name: String = "Inimigo"

	if is_instance_valid(current_enemy):
		reward = current_enemy.courage_reward
		defeated_enemy_name = current_enemy.enemy_name

		current_enemy.defeat()

	current_enemy = null
	battle_active = false

	hud.visible = true
	player.set_can_move(true)

	if reward > 0:
		hud.increase_courage(reward)

	hud.show_message(
		"%s derrotado! +%d de Coragem."
		% [defeated_enemy_name, reward],
		3.0
	)


func _on_battle_fled() -> void:
	if is_instance_valid(current_enemy):
		current_enemy.unlock_after_flee()

	current_enemy = null
	battle_active = false

	hud.visible = true
	player.set_can_move(true)

	hud.show_message(
		"Você fugiu da batalha.",
		2.0
	)

func _on_player_defeated() -> void:
	if defeat_in_progress:
		return

	defeat_in_progress = true
	battle_active = false
	dialogue_active = false
	current_enemy = null

	player.set_can_move(false)
	hud.visible = false

	SceneTransition.change_scene(
		"res://scenes/ui/game_over.tscn"
	)
