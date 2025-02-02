extends Node2D

@onready var map = $World/Ground

# Unit Selection
var selected: Array[Unit] = [  ]
var selection_start: Vector2 = Vector2.ZERO


# Engine
func _process(_delta: float) -> void:
	if selection_start != Vector2.ZERO:
		queue_redraw()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("alt_click"):
		if map.get_cell_tile_data(map.local_to_map(GameInfo.camera_offset(event.position))) == null:
			return
		var formation: Array[Vector2] = _get_formation(event.position)
		for i in range(selected.size() - 1, -1, -1):
			if selected[i] == null:
				selected.remove_at(i)
			else:
				selected[i].route(Vector2(formation[i]))
	
	if event.is_action_pressed("click"):
		selection_start = GameInfo.camera_offset(event.position)
	
	if event.is_action_released("click"):
		var box: Rect2 = Rect2(selection_start, GameInfo.camera_offset(event.position) - selection_start).abs()
		selection_start = Vector2.ZERO
		var all_units = find_children("*", "Unit")
		if box.get_area() > 32 * 16:
			for unit in selected:
				if unit != null and !unit.dying:
					unit.select(false)
			selected.clear()
			for unit in all_units:
				if box.has_point(unit.position) and !unit.dying and unit.team == GameInfo.active_player:
					selected.push_back(unit)
					unit.select()
			for i in range(selected.size() - 1, 0, -1):
				if selected.size() > 1 and selected[i] is Building:
					selected[i].select(false)
					selected.remove_at(i)
				else:
					selected[i].select()
		else:
			for unit in all_units:
				if GameInfo.camera_offset(event.position).distance_to(unit.position) < 24:
					for sel in selected:
						sel.select(false)
					selected.clear()
					selected.push_back(unit)
					unit.select()
					break
		
		queue_redraw()

func _draw() -> void:
	if selection_start != Vector2.ZERO:
		var target = GameInfo.camera_offset(get_viewport().get_mouse_position())
		draw_rect(Rect2(selection_start, target - selection_start), Color.DARK_GRAY, false, 3)
		draw_rect(Rect2(selection_start, target - selection_start), Color(0.663, 0.663, 0.663, 0.475))


# Private
func _get_formation(target: Vector2, spacing: int = 128) -> Array[Vector2]:
	@warning_ignore("narrowing_conversion")
	spacing *= GameInfo.camera.zoom.x
	var formation: Array[Vector2] = [  ]
	var columns = int(ceil(sqrt(float(selected.size()))))
	@warning_ignore("integer_division")
	var offset = Vector2((spacing * (columns - 1)) / 2, ((spacing / 2) * (columns - 1)) / 2)
	for i in columns:
		for j in columns:
			@warning_ignore("integer_division")
			formation.push_back(GameInfo.camera_offset(target + Vector2(j * spacing, i * spacing / 2) - offset))
	return formation
