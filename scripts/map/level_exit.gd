class_name LevelExit
extends Area2D


signal level_exit_requested


@export var enabled: bool = true

var already_triggered: bool = false


func _ready() -> void:
	add_to_group("level_exits")

	monitoring = enabled
	monitorable = true

	if not body_entered.is_connected(
		_on_body_entered
	):
		body_entered.connect(
			_on_body_entered
		)


func _on_body_entered(body: Node2D) -> void:
	if not enabled:
		return

	if already_triggered:
		return

	if not body.is_in_group("player"):
		return

	already_triggered = true
	monitoring = false

	level_exit_requested.emit()


func set_exit_enabled(value: bool) -> void:
	enabled = value
	already_triggered = false

	set_deferred(
		"monitoring",
		value
	)
