extends CharacterBody2D

var shoot_cooldown = 0.3
var shoot_timer = 0.0

var move_speed = 150.0
var rotate_speed = 3.0
var max_bullets = 4
var reload_time = 1.5
var player_index = 0
var lives = 3

var current_bullets = 0
var is_reloading = false
var reload_timer = 0.0
var is_moving = false
var is_alive = true

var bullet_scene = preload("res://Scenes/Minigames/bullet.tscn")

func _ready():
	current_bullets = max_bullets
	add_to_group("tanks")

func _process(delta):
	if not is_alive:
		return

	# Rotación automática
	if not is_moving:
		rotation += rotate_speed * delta

	# Cooldown disparo
	if shoot_timer > 0:
		shoot_timer -= delta

	# Movimiento
	if is_moving:
		velocity = Vector2.UP.rotated(rotation) * move_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# Recarga
	if is_reloading:
		reload_timer -= delta
		if reload_timer <= 0:
			current_bullets = max_bullets
			is_reloading = false
			get_parent().update_hud(player_index)

func on_key_pressed():
	if not is_alive:
		return
	
	rotate_speed = -rotate_speed
	is_moving = true
	shoot()  # 👈 dispara UNA vez por toque

func on_key_released():
	is_moving = false

func shoot():
	if is_reloading or current_bullets <= 0 or shoot_timer > 0:
		return
	
	shoot_timer = shoot_cooldown
	$ShootSound.play()
	current_bullets -= 1
	get_parent().update_hud(player_index)
	var bullet = bullet_scene.instantiate()
	bullet.direction = Vector2.UP.rotated(rotation)
	bullet.global_position = global_position + bullet.direction * 30.0
	bullet.shooter_index = player_index
	get_parent().add_child(bullet)
	if current_bullets <= 0:
		is_reloading = true
		reload_timer = reload_time
		get_parent().update_hud(player_index)

func take_hit():
	if not is_alive:
		return
	lives -= 1
	get_parent().update_hud(player_index)
	if lives <= 0:
		die()

func die():
	is_alive = false
	visible = false
	set_process(false)
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	get_parent().update_hud(player_index)
	get_parent().on_player_died(player_index)
