extends Area2D

signal collected

var already_collected: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if already_collected:
		return

	if body.name != "Player":
		return

	already_collected = true
	collected.emit()

	print("Pista de Alva coletada")

	call_deferred("queue_free")
