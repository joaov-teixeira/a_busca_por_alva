extends CharacterBody2D

@export var tile_size: int = 16
@export var move_time: float = 0.12

var is_moving: bool = false
var facing_direction: Vector2 = Vector2.DOWN


func _ready() -> void:
	position = position.snapped(Vector2(tile_size, tile_size))


func _physics_process(_delta: float) -> void:
	if is_moving:
		return

	var direction := get_input_direction()

	if direction != Vector2.ZERO:
		facing_direction = direction
		try_move(direction)


func get_input_direction() -> Vector2:
	if Input.is_action_pressed("move_up"):
		return Vector2.UP

	if Input.is_action_pressed("move_down"):
		return Vector2.DOWN

	if Input.is_action_pressed("move_left"):
		return Vector2.LEFT

	if Input.is_action_pressed("move_right"):
		return Vector2.RIGHT

	return Vector2.ZERO


func try_move(direction: Vector2) -> void:
	var motion := direction * tile_size

	if test_move(global_transform, motion):
		return

	is_moving = true

	var target_position := global_position + motion
	var tween := create_tween()

	tween.tween_property(self, "global_position", target_position, move_time)
	tween.finished.connect(_on_move_finished)


func _on_move_finished() -> void:
	is_moving = false
