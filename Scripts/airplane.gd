extends Node2D

var speed = 300.0
var drop_positions = []
var boxes_dropped = 0
var max_drops = 3
var going_right = true

var supply_box_scene = preload("res://Scenes/supply_box.tscn")

func start():
	global_position = Vector2(1380, randf_range(100, 500))
	scale.x = 1
	going_right = false

func _process(delta):
	if going_right:
		global_position.x += speed * delta
		if global_position.x > 1380:
			queue_free()
	else:
		global_position.x -= speed * delta
		if global_position.x < -100:
			queue_free()

	# Tira cajas en posiciones distribuidas del recorrido
	var progress = remap(global_position.x, -100, 1380, 0.0, 1.0)
	if not going_right:
		progress = 1.0 - progress

	for i in range(max_drops):
		var drop_at = (i + 1.0) / (max_drops + 1.0)
		if progress >= drop_at and i >= boxes_dropped:
			drop_box()
			boxes_dropped += 1

func drop_box():
	var current_boxes = get_tree().get_nodes_in_group("supply_boxes").size()
	if current_boxes >= 6:
		return

	# Intentar posición válida (no encima de rocas)
	var attempts = 10
	var drop_pos = global_position
	
	for i in range(attempts):
		var test_pos = Vector2(
			randf_range(100, 1180),
			randf_range(100, 620)
		)
		# Verificar que no haya colisión
		var space = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = test_pos
		query.collision_mask = 1
		var result = space.intersect_point(query)
		if result.is_empty():
			drop_pos = test_pos
			break
	
	var box = supply_box_scene.instantiate()
	box.global_position = drop_pos
	get_parent().add_child(box)
