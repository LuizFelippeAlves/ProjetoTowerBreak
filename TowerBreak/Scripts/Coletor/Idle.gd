extends State

@onready var collision = %Area

var player_entered: bool = false:
	set(value):
		player_entered = value
		collision.set_deferred("disabled", value)


func _on_player_entered(_body):
	player_entered = true

func transition():
	if player_entered:
		get_parent().change_state("Andar")
