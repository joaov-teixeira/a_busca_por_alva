extends Node2D

@onready var hud = $HUD
@onready var player: CharacterBody2D = $Player
@onready var gray_area: Area2D = $PrototypeMap/GrayArea
@onready var alva_clue = get_node_or_null("PrototypeMap/Interactables/AlvaClue")

@onready var false_altar = get_node_or_null("PrototypeMap/Interactables/FalseAltar")
@onready var true_altar = get_node_or_null("PrototypeMap/Interactables/TrueAltar")
@onready var object_layer: TileMapLayer = $PrototypeMap/ObjectLayer

@export var courage_decay_per_second: float = 8.0
@export var courage_reset_after_damage: float = 40.0

var player_inside_gray_area: bool = false
var world_purified: bool = false
var has_alva_clue: bool = false
var gate_open: bool = false

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
		print("Game Over")


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

func _ready() -> void:
	gray_area.body_entered.connect(_on_gray_area_body_entered)
	gray_area.body_exited.connect(_on_gray_area_body_exited)

	if alva_clue != null:
		alva_clue.collected.connect(_on_alva_clue_collected)

	if false_altar != null:
		false_altar.activated.connect(_on_altar_activated)

	if true_altar != null:
		true_altar.activated.connect(_on_altar_activated)


func _process(delta: float) -> void:
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
		print("Game Over")


func _on_alva_clue_collected() -> void:
	has_alva_clue = true
	hud.increase_courage(15)

	print("Estado atualizado: has_alva_clue = true")
