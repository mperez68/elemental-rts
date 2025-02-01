extends Node2D

var selected: Array[Unit] = [  ]

var selection_start: Vector2 = Vector2.ZERO


# Engine
func _process(_delta: float) -> void:
	if selection_start != Vector2.ZERO:
		queue_redraw()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("alt_click"):
		var formation: Array[Vector2] = _get_formation(event.position)
		for i in selected.size():
			selected[i].route(formation[i])
	
	if event.is_action_pressed("click"):
		selection_start = GameInfo.camera_offset(event.position)
	
	if event.is_action_released("click"):
		var box: Rect2 = Rect2(selection_start, GameInfo.camera_offset(event.position) - selection_start).abs()
		selection_start = Vector2.ZERO
		if box.get_area() > 32 * 16:
			for unit in selected:
				unit.highlight(false)
			selected.clear()
			for unit in find_children("*", "Unit"):
				if box.has_point(unit.position):
					selected.push_back(unit)
					unit.highlight()
		else:
			for unit in find_children("*", "Unit"):
				if GameInfo.camera_offset(event.position).distance_to(unit.position) < 24:
					for sel in selected:
						sel.highlight(false)
					selected.clear()
					selected.push_back(unit)
					unit.highlight()
					break
					
		queue_redraw()

func _draw() -> void:
	if selection_start != Vector2.ZERO:
		var target = GameInfo.camera_offset(get_viewport().get_mouse_position())
		draw_rect(Rect2(selection_start, target - selection_start), Color.DARK_GRAY, false, 3)
		draw_rect(Rect2(selection_start, target - selection_start), Color(0.663, 0.663, 0.663, 0.475))


# Private
func _get_formation(target: Vector2, spacing: int = 128) -> Array[Vector2]:
	var formation: Array[Vector2] = [  ]
	var columns = int(ceil(sqrt(float(selected.size()))))
	var offset = Vector2((spacing * (columns - 1)) / 2, ((spacing / 2) * (columns - 1)) / 2)
	for i in columns:
		for j in columns:
			formation.push_back(target + Vector2(j * spacing, i * spacing / 2) - offset)
	return formation
