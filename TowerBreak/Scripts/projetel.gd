extends Area2D

const speed := 100

var velocity := Vector2.ZERO
var direction := 1
var player
var dano := 10

func _ready() -> void:
	# Tenta buscar o player apenas quando o projétil é inicializado
	player = get_parent().get_node_or_null("Player")

func set_direction(dir: int) -> void:
	direction = dir
	if direction == 1:
		$Projetil.flip_h = false
	else:
		$Projetil.flip_h = true

func _physics_process(delta: float) -> void:
	# Atualiza a posição do projétil com base na velocidade
	velocity.x = speed * direction
	translate(velocity * delta)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		# Aplica dano ao jogador
		body.receber_dano(dano)
		print("Player atingido! Dano aplicado:", dano)
	elif body.is_in_group("Wall"):
		# Remove o projétil ao colidir com uma parede
		print("Projétil colidiu com a parede e foi destruído.")
		queue_free()

	# Remove o projétil após qualquer colisão
	queue_free()
