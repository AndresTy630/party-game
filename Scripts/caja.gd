extends RigidBody2D

var health = 1

func _ready():
	pass

func take_hit():
	health -= 1
	if health <= 0:
		queue_free()
