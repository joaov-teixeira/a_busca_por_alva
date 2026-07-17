extends CanvasLayer

signal battle_won
signal battle_fled
signal player_damaged(amount: int)
signal player_defeated

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

var current_enemy: BattleEnemy = null

var enemy_hp: int = 0
var enemy_max_hp: int = 0

var player_hp: int = 3
var player_max_hp: int = 3

var defending: bool = false
var battle_active: bool = false
var action_locked: bool = false


func _ready() -> void:
	root.visible = false

	attack_button.pressed.connect(_on_attack_pressed)
	defend_button.pressed.connect(_on_defend_pressed)
	flee_button.pressed.connect(_on_flee_pressed)


func start_battle(
	enemy: BattleEnemy,
	current_player_hp: int,
	max_player_hp: int
) -> void:
	if battle_active:
		return

	current_enemy = enemy

	enemy_max_hp = enemy.max_hp
	enemy_hp = enemy_max_hp

	player_hp = current_player_hp
	player_max_hp = max_player_hp

	defending = false
	action_locked = false
	battle_active = true

	root.visible = true

	title_label.text = "BATALHA — " + enemy.enemy_name
	battle_log_label.text = (
		enemy.enemy_name + " bloqueia seu caminho!"
	)

	update_interface()
	set_buttons_enabled(true)

	attack_button.grab_focus()


func _on_attack_pressed() -> void:
	if not can_choose_action():
		return

	action_locked = true
	set_buttons_enabled(false)

	var damage: int = randi_range(1, 2)

	enemy_hp = max(0, enemy_hp - damage)

	battle_log_label.text = (
		"Você atacou e causou %d de dano." % damage
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

	var escaped: bool = randf() < 0.50

	if escaped:
		battle_log_label.text = "Você conseguiu fugir."

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

	if current_enemy == null:
		return

	var defense_reduction: int = 0

	if defending:
		defense_reduction = 1

	var damage: int = max(
		0,
		current_enemy.attack_damage - defense_reduction
	)

	defending = false

	if damage > 0:
		player_hp = max(0, player_hp - damage)

		battle_log_label.text = (
			"%s atacou e causou %d de dano."
			% [current_enemy.enemy_name, damage]
		)

		player_damaged.emit(damage)
	else:
		battle_log_label.text = (
			"Você bloqueou completamente o ataque!"
		)

	update_interface()

	if player_hp <= 0:
		await get_tree().create_timer(0.7).timeout

		close_battle()
		player_defeated.emit()
		return

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
	battle_log_label.text = (
		current_enemy.enemy_name + " foi derrotado!"
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
