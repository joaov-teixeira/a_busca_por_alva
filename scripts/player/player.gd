extends CharacterBody2D

@export var velocidade: float = 140.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Controla se o jogador pode se mover ou não.
var can_move: bool = true

# Direção usada quando o jogador para.
# O personagem começa olhando para baixo.
var ultima_direcao: Vector2 = Vector2.DOWN


func _ready() -> void:
	sprite.play("idle_down")


func _physics_process(_delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		reproduzir_animacao("idle", ultima_direcao)
		return

	var direcao: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	if direcao != Vector2.ZERO:
		ultima_direcao = direcao
		velocity = direcao * velocidade
		reproduzir_animacao("walk", direcao)
	else:
		velocity = Vector2.ZERO
		reproduzir_animacao("idle", ultima_direcao)

	move_and_slide()


func reproduzir_animacao(
	tipo: String,
	direcao: Vector2
) -> void:
	var nome_direcao: String

	# Determina se o movimento predominante é horizontal ou vertical.
	if abs(direcao.x) > abs(direcao.y):
		if direcao.x > 0.0:
			nome_direcao = "right"
		else:
			nome_direcao = "left"
	else:
		if direcao.y > 0.0:
			nome_direcao = "down"
		else:
			nome_direcao = "up"

	var nome_animacao: StringName = StringName(
		tipo + "_" + nome_direcao
	)

	# Evita reiniciar a animação a cada frame.
	if sprite.animation != nome_animacao:
		sprite.play(nome_animacao)


func set_can_move(value: bool) -> void:
	can_move = value

	if not can_move:
		velocity = Vector2.ZERO
		reproduzir_animacao("idle", ultima_direcao)
