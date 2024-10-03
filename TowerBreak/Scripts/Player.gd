extends CharacterBody2D

# Variáveis de movimento
var velocidade = Vector2.ZERO
var velocidade_max = 200
var pulo_forca = -500
var gravidade = 1000

# Nós do jogador
@onready var animacao = $animacao
@onready var hitbox = $Hitbox
@onready var hitbox_collision = $Hitbox/CollisionShape2D

func _process(delta):
	var direcao_x = Input.get_axis("move_left", "move_right")
	
	# Movimento horizontal
	velocidade.x = direcao_x * velocidade_max
	
	# Gravidade
	if not is_on_floor():
		velocidade.y += gravidade * delta
	
	# Pulo
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocidade.y = pulo_forca

	# Atualiza as animações e direção
	update_direction_and_animations(direcao_x)
	
	# Move o personagem
	move_and_slide()

func update_direction_and_animations(direcao_x):
	if direcao_x != 0:
		# Espelha o sprite e a hitbox
		animacao.flip_h = direcao_x < 0

		# Ajusta a posição da hitbox ao espelhar
		if direcao_x > 0:
			hitbox.position.x = 10  # Posição à direita do jogador
		else:
			hitbox.position.x = -10  # Posição à esquerda do jogador

	# Troca as animações com base no estado
	if is_on_floor():
		if direcao_x == 0:
			animacao.play("Idle")
		else:
			animacao.play("Running")
	else:
		animacao.play("Jump")
