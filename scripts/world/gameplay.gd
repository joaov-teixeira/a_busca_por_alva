extends Node2D

@onready var hud = $HUD
@onready var player: CharacterBody2D = $Player
@onready var gray_area: Area2D = $PrototypeMap/GrayArea
@onready var alva_clue = get_node_or_null("PrototypeMap/Interactables/AlvaClue")

@export var courage_decay_per_second: float = 8.0
@export var courage_reset_after_damage: float = 40.0

var player_inside_gray_area: bool = false
var world_purified: bool = false
var has_alva_clue: bool = false


func _ready() -> void:
	gray_area.body_entered.connect(_on_gray_area_body_entered)
	gray_area.body_exited.connect(_on_gray_area_body_exited)

	if alva_clue != null:
		alva_clue.collected.connect(_on_alva_clue_collected)


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
