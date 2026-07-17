class_name DegeneratedArea
extends Area2D

signal player_entered(area: DegeneratedArea)
signal player_exited(area: DegeneratedArea)


@export var area_name: String = "Área Degenerada"


func _ready() -> void:
	add_to_group("degenerated_areas")

	monitoring = true
	monitorable = true

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player_entered.emit(self)


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player_exited.emit(self)
