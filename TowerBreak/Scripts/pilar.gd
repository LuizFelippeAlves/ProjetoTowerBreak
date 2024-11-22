extends Area2D

@onready var AnimationPilar: AnimationPlayer = $AnimationPilar

var player
var dano := 30

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _ready() -> void:
	# Tenta buscar o player apenas quando o projétil é inicializado
	player = get_parent().get_node_or_null("Player")
	AnimationPilar.play("Pilar")
	await wait(1.0)
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
	# Aplica dano ao jogador
		body.receber_dano(dano)
		print("Player atingido! Dano aplicado:", dano)
	
