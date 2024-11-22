extends CharacterBody2D

@onready var sprite: Sprite2D = $SpriteCristalLife2  # Certifique-se de que este seja um AnimatedSprite2D

func _ready():
	# Conecte-se ao sinal do Boss
	var boss = get_node_or_null("../Golem")  # Ajuste o caminho do nó do boss
	if boss and boss.has_signal("AtualizarVida"):
		boss.connect("AtualizarVida", Callable(self, "_on_boss_health_updated"))
	else:
		print("Erro: Não foi possível encontrar o Boss ou o sinal 'AtualizarVida'.")

func _on_boss_health_updated(vida_atual: int):
	# Altere o frame baseado na vida atual do Boss
	match vida_atual:
		200:
			sprite.frame = 0  # Substitua "Frame0" pelo nome da animação correspondente
		150:
			sprite.frame = 1
		100:
			sprite.frame = 2
		_:
			print("Vida do Boss fora dos valores esperados:", vida_atual)
