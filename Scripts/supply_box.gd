extends Area2D

enum Type { HEALTH, SHIELD, DOUBLE_SHOT, TRIPLE_SHOT }

var box_type = Type.HEALTH

# Colores según tipo
var type_colors = {
	Type.HEALTH: Color.RED,        # ❤ Vida = ROJO
	Type.SHIELD: Color.CYAN,       # 🛡 Escudo = CELESTE
	Type.DOUBLE_SHOT: Color.YELLOW, # 2x Disparo = AMARILLO
	Type.TRIPLE_SHOT: Color.ORANGE  # 3x Disparo = NARANJA
}

func _ready():
	# 60% chance caja de vida, 40% armamento
	var rand = randf()
	if rand < 0.6:
		box_type = Type.HEALTH
	elif rand < 0.75:
		box_type = Type.SHIELD
	elif rand < 0.87:
		box_type = Type.DOUBLE_SHOT
	else:
		box_type = Type.TRIPLE_SHOT

	# Color según tipo
	var sprite = get_node_or_null("Sprite")
	if sprite:
		sprite.modulate = type_colors[box_type]

	body_entered.connect(_on_body_entered)
	
	add_to_group("supply_boxes")
	
	var label = Label.new()
	label.position = Vector2(-15, -40)
	match box_type:
		Type.HEALTH:      label.text = "❤"
		Type.SHIELD:      label.text = "🛡"
		Type.DOUBLE_SHOT: label.text = "2x"
		Type.TRIPLE_SHOT: label.text = "3x"
	add_child(label)

func _on_body_entered(body):
	if body.is_in_group("tanks"):
		apply_effect(body)
		queue_free()

func apply_effect(tank):
	match box_type:
		Type.HEALTH:
			tank.lives = min(tank.lives + 1, 3)
			get_parent().update_hud(tank.player_index)
		Type.SHIELD:
			tank.activate_shield()
		Type.DOUBLE_SHOT:
			tank.activate_double_shot()
		Type.TRIPLE_SHOT:
			tank.activate_triple_shot()
