extends CharacterBody2D

@onready var AnimationColetor: AnimationPlayer = $AnimationColetor
@onready var AtaqueCorpo: Timer = $AtaqueCorpo
@onready var AtaqueCorpoRec: Timer = $AtaqueCorpoRec
@onready var AtaqueMangual: Timer = $AtaqueMangual
@onready var AtaqueMangualRec: Timer = $AtaqueMangualRec

var movimento = Vector2()
var player_in_area = false
var player_in_ataque = false
var is_attacking = false  # Controle de estado para saber se o inimigo está atacando

func _ready() -> void:
	add_to_group("Boss")
	AtaqueCorpoRec.one_shot = true
	AtaqueMangualRec.one_shot = true
	AtaqueCorpoRec.connect("timeout", Callable(self, "_on_ataque_corpo_cooldown_timeout"))
	AtaqueMangualRec.connect("timeout", Callable(self, "_on_ataque_mangual_cooldown_timeout"))

func _process(delta: float) -> void:
	if not is_attacking:
		if player_in_area:
			seguir_jogador(delta)
		else:
			parar_movimento()

func _on_area_detec_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true
		print("Muve")
		AnimationColetor.play("Andar")

func _on_area_detec_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		print("Pause")
		AnimationColetor.play("idle")

func seguir_jogador(delta: float) -> void:
	var player = get_parent().get_node_or_null("Player")
	if player:
		# Movimenta-se apenas no eixo X (direita/esquerda)
		var direction_x = player.position.x - position.x
		position.x += sign(direction_x) * delta * 50  # Controla a velocidade de movimento
		
		# Flip horizontal da sprite ao mudar de direção
		if direction_x > 0:
			scale.x = 1  # Virado para a direita
		elif direction_x < 0:
			scale.x = -1  # Virado para a esquerda

func _on_area_hit_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not is_attacking:
		player_in_ataque = true
		iniciar_ataque()

func _on_area_hit_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_ataque = false

func iniciar_ataque() -> void:
	is_attacking = true
	if AtaqueCorpoRec.is_stopped():
		AnimationColetor.play("AtaqueCorpo")
		AtaqueCorpoRec.start(6.0)  # Cooldown de 2 segundos para ataque corpo
	else:
		AnimationColetor.play("AtaqueMangual")
		AtaqueMangualRec.start(2.0)  # Cooldown de 3 segundos para ataque mangual

func _on_ataque_corpo_cooldown_timeout() -> void:
	is_attacking = false

func _on_ataque_mangual_cooldown_timeout() -> void:
	is_attacking = false

func parar_movimento() -> void:
	AnimationColetor.stop()
