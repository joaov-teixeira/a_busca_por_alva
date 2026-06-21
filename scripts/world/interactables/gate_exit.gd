extends Area2D

signal gate_entered

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var is_active: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	set_active(false)


func set_active(value: bool) -> void:
	is_active = value
	visible = value
	monitoring = value
	monitorable = value

	if collision_shape != null:
		collision_shape.set_deferred("disabled", not value)


func _on_body_entered(body: Node2D) -> void:
	if not is_active:
		return

	if body.name != "Player":
		return

	print("Player atravessou o portão.")
	gate_entered.emit()
