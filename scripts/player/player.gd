extends CharacterBody2D

@export var move_speed: float = 55.0

var can_move: bool = true
var facing_direction: Vector2 = Vector2.DOWN


func _physics_process(_delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction := get_input_direction()

	if direction != Vector2.ZERO:
		facing_direction = direction
		velocity = direction * move_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func get_input_direction() -> Vector2:
	var direction := Vector2.ZERO

	if Input.is_action_pressed("move_up"):
		direction.y -= 1

	if Input.is_action_pressed("move_down"):
		direction.y += 1

	if Input.is_action_pressed("move_left"):
		direction.x -= 1

	if Input.is_action_pressed("move_right"):
		direction.x += 1

	return direction.normalized()


func set_can_move(value: bool) -> void:
	can_move = value

	if not can_move:
		velocity = Vector2.ZERO
