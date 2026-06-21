extends Node2D

@onready var hud = $HUD
@onready var player: CharacterBody2D = $Player
@onready var gray_area: Area2D = $PrototypeMap/GrayArea
@onready var object_layer: TileMapLayer = $PrototypeMap/ObjectLayer
@onready var battle_screen = $BattleScreen

@onready var alva_clue = get_node_or_null("PrototypeMap/Interactables/AlvaClue")
@onready var false_altar = get_node_or_null("PrototypeMap/Interactables/FalseAltar")
@onready var true_altar = get_node_or_null("PrototypeMap/Interactables/TrueAltar")
@onready var enemy = get_node_or_null("PrototypeMap/Interactables/Enemy")

@export var courage_decay_per_second: float = 2.0
@export var courage_reset_after_damage: float = 60


var player_inside_gray_area: bool = false
var world_purified: bool = false
var has_alva_clue: bool = false
var gate_open: bool = false

var is_in_battle: bool = false
var current_enemy: Node = null


func _ready() -> void:
	gray_area.body_entered.connect(_on_gray_area_body_entered)
	gray_area.body_exited.connect(_on_gray_area_body_exited)

	if alva_clue != null:
		alva_clue.collected.connect(_on_alva_clue_collected)

	if false_altar != null:
		false_altar.activated.connect(_on_altar_activated)

	if true_altar != null:
		true_altar.activated.connect(_on_altar_activated)

	if enemy != null:
		enemy.battle_requested.connect(_on_enemy_battle_requested)

	battle_screen.battle_won.connect(_on_battle_won)
	battle_screen.battle_fled.connect(_on_battle_fled)
	battle_screen.player_damaged.connect(_on_battle_player_damaged)


func _process(delta: float) -> void:
	if is_in_battle:
		return

	if player_inside_gray_area and not world_purified:
		hud.decrease_courage(courage_decay_per_second * delta)

		if hud.courage <= 0:
			_on_courage_depleted()


func _on_gray_area_body_entered(body: Node2D) -> void:
	if body == player:
		player_inside_gray_area = true
		print("Player entrou na Área Cinza")


func _on_gray_area_body_exited(body: Node2D) -> void:
	if body == player:
		player_inside_gray_area = false
		print("Player saiu da Área Cinza")


func _on_courage_depleted() -> void:
	hud.damage_player(1)
	hud.update_courage(courage_reset_after_damage)

	print("Coragem esgotada: Player perdeu 1 coração")

	if hud.health <= 0:
		_handle_game_over()


func _on_alva_clue_collected() -> void:
	has_alva_clue = true
	hud.increase_courage(15)

	print("Estado atualizado: has_alva_clue = true")


func _on_altar_activated(altar_id: String, is_correct: bool) -> void:
	if is_correct:
		_handle_correct_altar(altar_id)
	else:
		_handle_false_altar(altar_id)


func _handle_false_altar(altar_id: String) -> void:
	hud.damage_player(1)

	print("Altar falso ativado: " + altar_id)
	print("Player perdeu 1 coração")

	if hud.health <= 0:
		_handle_game_over()


func _handle_correct_altar(altar_id: String) -> void:
	print("Altar verdadeiro ativado: " + altar_id)

	if not has_alva_clue:
		print("A magia do altar não responde. Talvez falte uma pista de Alva.")
		return

	open_gate()


func open_gate() -> void:
	if gate_open:
		return

	gate_open = true

	object_layer.erase_cell(Vector2i(7, 9))
	object_layer.erase_cell(Vector2i(7, 10))

	print("Portão aberto")


func _on_enemy_battle_requested(enemy_node: Node) -> void:
	if is_in_battle:
		return

	is_in_battle = true
	current_enemy = enemy_node
	hud.visible = false
	
	player.set_can_move(false)

	var enemy_name: String = enemy_node.enemy_name
	var enemy_hp: int = enemy_node.enemy_max_hp

	print("Batalha iniciada contra: " + enemy_name)

	battle_screen.start_battle(enemy_name, enemy_hp)


func _on_battle_player_damaged(amount: int) -> void:
	hud.damage_player(amount)

	print("Player recebeu dano na batalha: %d" % amount)

	if hud.health <= 0:
		_handle_game_over()


func _on_battle_won() -> void:
	print("Batalha vencida")

	if current_enemy != null:
		current_enemy.queue_free()

	current_enemy = null
	is_in_battle = false
	hud.visible = true
	
	player.set_can_move(true)


func _on_battle_fled() -> void:
	print("Player fugiu da batalha")

	current_enemy = null
	is_in_battle = false
	hud.visible = true
	
	player.set_can_move(true)


func _handle_game_over() -> void:
	print("Game Over")

	is_in_battle = false
	player.set_can_move(false)
	hud.visible = false

	if battle_screen != null:
		battle_screen.force_end_battle()
