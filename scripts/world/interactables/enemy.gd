extends CharacterBody2D

signal battle_requested(enemy_node: Node)

@export var enemy_name: String = "Sombra Corrompida"
@export var enemy_max_hp: int = 3

@onready var battle_detection: Area2D = $BattleDetection

var battle_enabled: bool = true


func _ready() -> void:
	battle_detection.body_entered.connect(_on_battle_detection_body_entered)
	battle_detection.body_exited.connect(_on_battle_detection_body_exited)


func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()


func _on_battle_detection_body_entered(body: Node2D) -> void:
	if not battle_enabled:
		return

	if body.name != "Player":
		return

	battle_enabled = false

	print("Inimigo encontrado: " + enemy_name)

	battle_requested.emit(self)


func _on_battle_detection_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		battle_enabled = true
