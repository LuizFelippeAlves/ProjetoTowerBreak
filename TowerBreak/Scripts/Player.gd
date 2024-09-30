extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var is_jumping := false
var current_state := "Idle"

@onready var animation_player := $AnimationPlayer

func _ready():
	if animation_player == null:
		print("Erro: Nó de AnimationPlayer não encontrado!")

func _physics_process(delta: float) -> void:
	# Adiciona gravidade
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	else:
		velocity.y = 0

	# Lidar com o pulo
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		change_state("Jump")
	elif is_on_floor():
		is_jumping = false

	# Movimentação lateral
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * SPEED
		if !is_jumping:
			change_state("Running")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if !is_jumping:
			change_state("Idle")

	# Mover o personagem
	move_and_slide()

# Função para trocar estados e animações
func change_state(new_state: String) -> void:
	if current_state != new_state:
		current_state = new_state
		match current_state:
			"Idle":
				animation_player.play("Idle")
			"Running":
				animation_player.play("Running")
			"Jump":
				animation_player.play("jump")
			"Attack":
				animation_player.play("attack")
			"Damage":
				animation_player.play("Damage")
