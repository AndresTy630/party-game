extends Node2D

var tanks = []
var alive_count = 0
var hud_labels = []

var airplane_scene = preload("res://Scenes/Minigames/Airplane.tscn")
var airplane_timer = 10.0
var airplane_cooldown = 10.0
var max_supply_boxes = 6
var from_right = false

var spawn_positions = [
	Vector2(200, 200),
	Vector2(1000, 200),
	Vector2(200, 500),
	Vector2(1000, 500)
]

var keys_press = [KEY_Q, KEY_P, KEY_Z, KEY_M]

func _ready():
	tanks = [$Tank, $Tank2, $Tank3, $Tank4]
	hud_labels = [$HUD/P1Label, $HUD/P2Label, $HUD/P3Label, $HUD/P4Label]
	
	var tank_textures = [
	load("res://Assets/TanqueVerde.png"),
	load("res://Assets/TanqueAzul.png"),
	load("res://Assets/TanqueRojo.png"),
	load("res://Assets/TanqueAmarillo.png")
	]
	
	for i in range(tanks.size()):
		tanks[i].player_index = i
		tanks[i].get_node("Sprite").texture = tank_textures[i]
	
	alive_count = tanks.size()
	update_all_huds()

func _input(event):
	if event is InputEventKey:
		for i in range(tanks.size()):
			if event.keycode == keys_press[i]:
				if event.pressed and not event.echo:
					tanks[i].on_key_pressed()
					update_hud(i)
				elif not event.pressed:
					tanks[i].on_key_released()

func update_hud(i):
	var tank = tanks[i]
	var lives_text = "❤".repeat(tank.lives)
	var bullets_text = "●".repeat(tank.current_bullets)
	if tank.is_reloading:
		bullets_text = "recargando..."
	hud_labels[i].text = lives_text + "  " + bullets_text

func update_all_huds():
	for i in range(tanks.size()):
		update_hud(i)

func on_player_died(player_index):
	hud_labels[player_index].text = "💀"
	alive_count -= 1
	if alive_count <= 1:
		for tank in tanks:
			if tank.is_alive:
				var win_screen = load("res://Scenes/WinScreen.tscn").instantiate()
				win_screen.winner = tank.player_index + 1
				get_tree().root.add_child(win_screen)
				break
	
func _process(delta):
	airplane_timer -= delta
	if airplane_timer <= 0:
		var current_boxes = get_tree().get_nodes_in_group("supply_boxes").size()
		if current_boxes < max_supply_boxes:
			spawn_airplane()
			airplane_timer = airplane_cooldown
		else:
			airplane_timer = 1.0
	
func spawn_airplane():
	var current_boxes = get_tree().get_nodes_in_group("supply_boxes").size()
	if current_boxes >= max_supply_boxes:
		return
	var airplane = airplane_scene.instantiate()
	add_child(airplane)
	airplane.start()
