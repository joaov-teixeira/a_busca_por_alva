extends Area2D

signal activated(altar_id: String, is_correct: bool)

@export var altar_id: String = "S1"
@export var is_correct: bool = false

var player_in_range: bool = false
var already_activated: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if already_activated:
		return

	if not player_in_range:
		return

	if event.is_action_pressed("interact"):
		activate_altar()


func activate_altar() -> void:
	already_activated = true
	activated.emit(altar_id, is_correct)

	print("Altar ativado: " + altar_id)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true
		print("Pressione E para interagir com o altar " + altar_id)


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
