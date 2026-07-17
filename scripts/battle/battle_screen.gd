extends CanvasLayer

signal battle_won
signal battle_fled
signal player_damaged(amount: int)
signal player_defeated


@export_category("Player Combat")

@export_range(1, 20, 1)
var player_min_damage: int = 1

@export_range(1, 20, 1)
var player_max_damage: int = 2

@export_range(0.0, 1.0, 0.05)
var player_hit_chance: float = 0.90

@export_range(0.0, 1.0, 0.05)
var player_critical_chance: float = 0.15

@export_range(1, 5, 1)
var critical_multiplier: int = 2

@export_range(0, 20, 1)
var defense_reduction: int = 1

@export_range(0.0, 1.0, 0.05)
var flee_chance: float = 0.50


@onready var root: Control = $Root

@onready var title_label: Label = (
	$Root/Panel/MarginContainer/VBoxContainer/TitleLabel
)

@onready var enemy_hp_bar: ProgressBar = (
	$Root/Panel/MarginContainer/VBoxContainer/EnemyHPBar
)

@onready var enemy_hp_label: Label = (
	$Root/Panel/MarginContainer/VBoxContainer/EnemyHPLabel
)

@onready var player_hp_label: Label = (
	$Root/Panel/MarginContainer/VBoxContainer/PlayerHPLabel
)

@onready var battle_log_label: Label = (
	$Root/Panel/MarginContainer/VBoxContainer/BattleLogLabel
)

@onready var attack_button: Button = (
	$Root/Panel/MarginContainer/VBoxContainer/
	ActionsContainer/AttackButton
)

@onready var defend_button: Button = (
	$Root/Panel/MarginContainer/VBoxContainer/
	ActionsContainer/DefendButton
)

@onready var flee_button: Button = (
	$Root/Panel/MarginContainer/VBoxContainer/
	ActionsContainer/FleeButton
)


var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var current_enemy: BattleEnemy = null

var enemy_hp: int = 0
var enemy_max_hp: int = 0

var player_hp: int = 3
var player_max_hp: int = 3

var defending: bool = false
var battle_active: bool = false
var action_locked: bool = false


func _ready() -> void:
	rng.randomize()

	root.visible = false

	attack_button.pressed.connect(
		_on_attack_pressed
	)

	defend_button.pressed.connect(
		_on_defend_pressed
	)

	flee_button.pressed.connect(
		_on_flee_pressed
	)


func start_battle(
	enemy: BattleEnemy,
	current_player_hp: int,
	max_player_hp: int
) -> void:
	if battle_active:
		return

	current_enemy = enemy

	# A vida do inimigo varia a cada batalha.
	var hp_offset: int = rng.randi_range(
		-enemy.hp_variation,
		enemy.hp_variation
	)

	enemy_max_hp = max(
		1,
		enemy.max_hp + hp_offset
	)

	enemy_hp = enemy_max_hp

	player_hp = current_player_hp
	player_max_hp = max_player_hp

	defending = false
	action_locked = false
	battle_active = true

	root.visible = true

	title_label.text = (
		"BATALHA — " + enemy.enemy_name
	)

	battle_log_label.text = (
		enemy.enemy_name
		+ " bloqueia seu caminho!"
	)

	update_interface()
	set_buttons_enabled(true)

	attack_button.grab_focus()


func _on_attack_pressed() -> void:
	if not can_choose_action():
		return

	action_locked = true
	set_buttons_enabled(false)

	# Teste de acerto.
	if rng.randf() > player_hit_chance:
		battle_log_label.text = (
			"Você atacou, mas errou o golpe!"
		)

		await enemy_turn()
		return

	var damage: int = rng.randi_range(
		player_min_damage,
		player_max_damage
	)

	var critical: bool = (
		rng.randf() < player_critical_chance
	)

	if critical:
		damage *= critical_multiplier

	enemy_hp = max(
		0,
		enemy_hp - damage
	)

	if critical:
		battle_log_label.text = (
			"Golpe crítico! Você causou %d de dano."
			% damage
		)
	else:
		battle_log_label.text = (
			"Você causou %d de dano."
			% damage
		)

	update_interface()

	if enemy_hp <= 0:
		await get_tree().create_timer(0.7).timeout

		finish_with_victory()
		return

	await enemy_turn()


func _on_defend_pressed() -> void:
	if not can_choose_action():
		return

	action_locked = true
	set_buttons_enabled(false)

	defending = true

	battle_log_label.text = (
		"Você assume uma postura defensiva."
	)

	await enemy_turn()


func _on_flee_pressed() -> void:
	if not can_choose_action():
		return

	action_locked = true
	set_buttons_enabled(false)

	var current_flee_chance: float = flee_chance

	# Quando estiver com apenas um coração,
	# a chance de fuga aumenta.
	if player_hp <= 1:
		current_flee_chance += 0.15

	current_flee_chance = clampf(
		current_flee_chance,
		0.0,
		0.90
	)

	var escaped: bool = (
		rng.randf() < current_flee_chance
	)

	if escaped:
		battle_log_label.text = (
			"Você conseguiu fugir."
		)

		await get_tree().create_timer(0.7).timeout

		close_battle()
		battle_fled.emit()
		return

	battle_log_label.text = (
		"Você tentou fugir, mas o inimigo bloqueou o caminho!"
	)

	await enemy_turn()


func enemy_turn() -> void:
	await get_tree().create_timer(0.8).timeout

	if not is_instance_valid(current_enemy):
		return

	var heavy_attack: bool = (
		rng.randf()
		< current_enemy.heavy_attack_chance
	)

	var current_hit_chance: float = (
		current_enemy.hit_chance
	)

	if heavy_attack:
		current_hit_chance -= (
			current_enemy.heavy_accuracy_penalty
		)

	current_hit_chance = clampf(
		current_hit_chance,
		0.05,
		1.0
	)

	# O inimigo pode errar.
	if rng.randf() > current_hit_chance:
		if heavy_attack:
			battle_log_label.text = (
				current_enemy.enemy_name
				+ " tentou um ataque pesado, mas errou!"
			)
		else:
			battle_log_label.text = (
				current_enemy.enemy_name
				+ " atacou, mas errou!"
			)

		defending = false
		unlock_player_actions()
		return

	var damage: int = rng.randi_range(
		current_enemy.min_attack_damage,
		current_enemy.max_attack_damage
	)

	if heavy_attack:
		damage += current_enemy.heavy_bonus_damage

	var critical: bool = (
		rng.randf()
		< current_enemy.critical_chance
	)

	if critical:
		damage *= critical_multiplier

	if defending:
		damage = max(
			0,
			damage - defense_reduction
		)

	defending = false

	if damage <= 0:
		battle_log_label.text = (
			"Você bloqueou completamente o ataque!"
		)

		unlock_player_actions()
		return

	player_hp = max(
		0,
		player_hp - damage
	)

	if heavy_attack and critical:
		battle_log_label.text = (
			"Ataque pesado crítico! %s causou %d de dano."
			% [current_enemy.enemy_name, damage]
		)
	elif heavy_attack:
		battle_log_label.text = (
			"%s usou um ataque pesado e causou %d de dano."
			% [current_enemy.enemy_name, damage]
		)
	elif critical:
		battle_log_label.text = (
			"Golpe crítico inimigo! %s causou %d de dano."
			% [current_enemy.enemy_name, damage]
		)
	else:
		battle_log_label.text = (
			"%s causou %d de dano."
			% [current_enemy.enemy_name, damage]
		)

	player_damaged.emit(damage)

	update_interface()

	if player_hp <= 0:
		await get_tree().create_timer(0.7).timeout

		close_battle()
		player_defeated.emit()
		return

	unlock_player_actions()


func unlock_player_actions() -> void:
	action_locked = false
	set_buttons_enabled(true)
	attack_button.grab_focus()


func update_interface() -> void:
	enemy_hp_bar.max_value = enemy_max_hp
	enemy_hp_bar.value = enemy_hp

	enemy_hp_label.text = (
		"Vida do inimigo: %d/%d"
		% [enemy_hp, enemy_max_hp]
	)

	player_hp_label.text = (
		"Sua vida: %d/%d"
		% [player_hp, player_max_hp]
	)


func can_choose_action() -> bool:
	return battle_active and not action_locked


func set_buttons_enabled(enabled: bool) -> void:
	attack_button.disabled = not enabled
	defend_button.disabled = not enabled
	flee_button.disabled = not enabled


func finish_with_victory() -> void:
	if not is_instance_valid(current_enemy):
		return

	battle_log_label.text = (
		current_enemy.enemy_name
		+ " foi derrotado!"
	)

	await get_tree().create_timer(0.7).timeout

	close_battle()
	battle_won.emit()


func close_battle() -> void:
	root.visible = false

	battle_active = false
	action_locked = false
	defending = false

	set_buttons_enabled(false)
