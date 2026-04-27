extends Control

var winner = 1

func _ready():
	$WinLabel.text = "¡Jugador " + str(winner) + " GANA!"
	$RestartButton.pressed.connect(_on_restart_pressed)

func _on_restart_pressed():
	queue_free()
	get_tree().change_scene_to_file("res://Scenes/Minigames/battle_arena.tscn")
