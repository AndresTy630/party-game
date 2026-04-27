extends Area2D

var direction = Vector2.UP
var shooter_index = 0
var speed = 600.0
var lifetime = 3.0
var timer = 0.0

func _ready():
	body_entered.connect(_on_body_entered)
	add_to_group("bullets")

func _process(delta):
	global_position += direction * speed * delta
	timer += delta
	if timer >= lifetime:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("tanks"):
		if body.player_index != shooter_index:
			body.take_hit()
			queue_free()
	elif body is StaticBody2D:
		queue_free()
	elif body is RigidBody2D:
		body.take_hit()
		queue_free()
