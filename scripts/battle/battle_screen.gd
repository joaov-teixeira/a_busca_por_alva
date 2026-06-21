extends CanvasLayer

signal battle_won
signal battle_fled
signal player_damaged(amount: int)

@onready var root: Control = $Root
@onready var title_label: Label = $Root/Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var enemy_hp_label: Label = $Root/Panel/MarginContainer/VBoxContainer/EnemyHPLabel
@onready var battle_log_label: Label = $Root/Panel/MarginContainer/VBoxContainer/BattleLogLabel

@onready var attack_button: Button = $Root/Panel/MarginContainer/VBoxContainer/ActionsContainer/AttackButton
@onready var defend_button: Button = $Root/Panel/MarginContainer/VBoxContainer/ActionsContainer/DefendButton
@onready var flee_button: Button = $Root/Panel/MarginContainer/VBoxContainer/ActionsContainer/FleeButton

var enemy_name: String = "Sombra Corrompida"
var enemy_max_hp: int = 3
var enemy_hp: int = 3

var defending: bool = false
var battle_active: bool = false


func _ready() -> void:
	root.visible = false

	attack_button.pressed.connect(_on_attack_button_pressed)
	defend_button.pressed.connect(_on_defend_button_pressed)
	flee_button.pressed.connect(_on_flee_button_pressed)


func start_battle(new_enemy_name: String, new_enemy_max_hp: int) -> void:
	enemy_name = new_enemy_name
	enemy_max_hp = new_enemy_max_hp
	enemy_hp = enemy_max_hp
	defending = false
	battle_active = true

	root.visible = true
	set_action_buttons_enabled(true)

	update_ui("Uma sombra bloqueia seu caminho.")
	attack_button.grab_focus()


func force_end_battle() -> void:
	battle_active = false
	root.visible = false
	set_action_buttons_enabled(false)


func update_ui(message: String) -> void:
	title_label.text = "Batalha"
	enemy_hp_label.text = "%s HP: %d/%d" % [enemy_name, enemy_hp, enemy_max_hp]
	battle_log_label.text = message


func set_action_buttons_enabled(enabled: bool) -> void:
	attack_button.disabled = not enabled
	defend_button.disabled = not enabled
	flee_button.disabled = not enabled


func _on_attack_button_pressed() -> void:
	if not battle_active:
		return

	set_action_buttons_enabled(false)

	enemy_hp -= 1
	update_ui("Você atacou a sombra.")

	if enemy_hp <= 0:
		update_ui("A sombra se dissipou.")
		await get_tree().create_timer(0.6).timeout

		if not battle_active:
			return

		force_end_battle()
		battle_won.emit()
		return

	await enemy_turn()


func _on_defend_button_pressed() -> void:
	if not battle_active:
		return

	set_action_buttons_enabled(false)

	defending = true
	update_ui("Você se preparou para defender.")

	await enemy_turn()


func _on_flee_button_pressed() -> void:
	if not battle_active:
		return

	set_action_buttons_enabled(false)
	update_ui("Você recuou da batalha.")

	await get_tree().create_timer(0.6).timeout

	if not battle_active:
		return

	force_end_battle()
	battle_fled.emit()


func enemy_turn() -> void:
	await get_tree().create_timer(0.6).timeout

	if not battle_active:
		return

	if defending:
		defending = false
		update_ui("A sombra atacou, mas você defendeu.")
	else:
		player_damaged.emit(1)
		update_ui("A sombra atacou. Você perdeu 1 coração.")

	await get_tree().create_timer(0.6).timeout

	if not battle_active:
		return

	set_action_buttons_enabled(true)
