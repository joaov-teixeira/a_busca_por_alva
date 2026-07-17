class_name BattleEnemy
extends CharacterBody2D

signal battle_requested(enemy: BattleEnemy)


@export_category("Enemy Data")

@export var enemy_name: String = "Criatura Sombria"

@export_range(1, 99, 1)
var max_hp: int = 5

@export_range(0, 20, 1)
var attack_damage: int = 1

@export_range(0, 100, 1)
var courage_reward: int = 10


@export_category("Animation")

@export var idle_animation: StringName = &"idle"

@export_range(1.0, 30.0, 0.5)
var idle_fps: float = 6.0


@onready var animated_sprite: AnimatedSprite2D = (
	get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
)

@onready var battle_trigger: Area2D = (
	get_node_or_null("BattleTrigger") as Area2D
)


var defeated: bool = false
var trigger_locked: bool = false


func _ready() -> void:
	add_to_group("battle_enemies")

	print("Inimigo carregado: ", name)
	print("BattleTrigger encontrado: ", battle_trigger)

	configure_animation()
	configure_battle_trigger()


func configure_animation() -> void:
	if animated_sprite == null:
		push_error(
			"AnimatedSprite2D não encontrado no inimigo."
		)
		return

	if animated_sprite.sprite_frames == null:
		push_error(
			"O inimigo não possui SpriteFrames."
		)
		return

	if not animated_sprite.sprite_frames.has_animation(
		idle_animation
	):
		push_error(
			"Animação não encontrada: "
			+ str(idle_animation)
		)
		return

	animated_sprite.sprite_frames.set_animation_speed(
		idle_animation,
		idle_fps
	)

	animated_sprite.sprite_frames.set_animation_loop(
		idle_animation,
		true
	)

	animated_sprite.play(idle_animation)


func configure_battle_trigger() -> void:
	if battle_trigger == null:
		push_error(
			"BattleTrigger não encontrado em "
			+ str(get_path())
		)
		return

	battle_trigger.monitoring = true
	battle_trigger.monitorable = true

	if not battle_trigger.body_entered.is_connected(
		_on_battle_trigger_body_entered
	):
		battle_trigger.body_entered.connect(
			_on_battle_trigger_body_entered
		)

	print("BattleTrigger configurado com sucesso.")


func _on_battle_trigger_body_entered(
	body: Node2D
) -> void:
	print(
		"Corpo entrou no BattleTrigger: ",
		body.name
	)

	if defeated:
		print("Inimigo já derrotado.")
		return

	if trigger_locked:
		print("Trigger está bloqueado.")
		return

	if not body.is_in_group("player"):
		print(
			"O corpo detectado não pertence ao grupo player."
		)
		return

	print("Player detectado. Solicitando batalha.")

	trigger_locked = true

	battle_trigger.set_deferred(
		"monitoring",
		false
	)

	battle_requested.emit(self)


func unlock_after_flee() -> void:
	if defeated:
		return

	trigger_locked = false

	if battle_trigger != null:
		battle_trigger.set_deferred(
			"monitoring",
			true
		)


func defeat() -> void:
	defeated = true
	trigger_locked = true

	if battle_trigger != null:
		battle_trigger.set_deferred(
			"monitoring",
			false
		)

	queue_free()
