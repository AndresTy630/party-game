extends CharacterBody2D

var has_shield = false
var shield_timer = 0.0
var double_shot = false
var double_shot_timer = 0.0
var triple_shot = false
var triple_shot_timer = 0.0
var power_duration = 7.0

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
		
	# Timers de poderes
	if has_shield:
		shield_timer -= delta
		if shield_timer <= 0:
			has_shield = false
			$ShieldEffect.visible = false

	if double_shot:
		double_shot_timer -= delta
		if double_shot_timer <= 0:
			double_shot = false

	if triple_shot:
		triple_shot_timer -= delta
		if triple_shot_timer <= 0:
			triple_shot = false

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
	current_bullets -= 1
	get_parent().update_hud(player_index)
	$ShootSound.play()

	# Bala normal
	spawn_bullet(rotation)

	# Doble disparo
	if double_shot:
		spawn_bullet(rotation + deg_to_rad(15))

	# Triple disparo
	if triple_shot:
		spawn_bullet(rotation + deg_to_rad(20))
		spawn_bullet(rotation - deg_to_rad(20))

	if current_bullets <= 0:
		is_reloading = true
		reload_timer = reload_time
		get_parent().update_hud(player_index)

func spawn_bullet(angle):
	var bullet = bullet_scene.instantiate()
	bullet.direction = Vector2.UP.rotated(angle)
	bullet.global_position = global_position + bullet.direction * 30.0
	bullet.shooter_index = player_index
	get_parent().add_child(bullet)

func take_hit():
	if not is_alive:
		return
	if has_shield:
		return  # escudo bloquea el daño
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
	
func activate_shield():
	has_shield = true
	shield_timer = power_duration
	$ShieldEffect.visible = true

func activate_double_shot():
	double_shot = true
	double_shot_timer = power_duration

func activate_triple_shot():
	triple_shot = true
	triple_shot_timer = power_duration
