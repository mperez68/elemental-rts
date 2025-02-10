extends Node2D

signal update_hud(selection: Array[Unit])

@onready var map = $World/Ground

# Unit Selection
var selected: Array[Unit] = [  ]
var selection_start: Vector2 = Vector2.ZERO
var clicked_unit: Unit = null


# Engine
func _ready() -> void:
	multiplayer.peer_connected.connect(clear_sel)

func _process(_delta: float) -> void:
	# Draw Selection Box
	if selection_start != Vector2.ZERO:
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if !GameInfo.map.get_children().is_empty():
		return
	
	if event.is_action_pressed("alt_click"):
		if map.get_cell_tile_data(map.local_to_map(GameInfo.camera_offset(event.position))) == null:
			return
		var formation: Array[Vector2] = _get_formation(event.position)
		for i in range(selected.size() - 1, -1, -1):
			if selected[i] == null:
				selected.remove_at(i)
			else:
				selected[i].route(Vector2(formation[i]), true)
	
	if event.is_action_pressed("click"):
		selection_start = GameInfo.camera_offset(event.position)
	
	if event.is_action_released("click") and selection_start != Vector2.ZERO:
		var box: Rect2 = Rect2(selection_start, GameInfo.camera_offset(event.position) - selection_start).abs()
		var box_size: Vector2 = box.size
		var all_units = find_children("*", "Unit", true, false)
		# Box past size threshold
		if box_size.x + box_size.y > GameInfo.GRID.x + GameInfo.GRID.y:
			new_sel(all_units, box)
		else:
			clear_sel()
			if clicked_unit != null and clicked_unit.player_id == GameInfo.active_player:
				selected.push_back(clicked_unit)
				clicked_unit.select()
			clicked_unit = null
			update_hud.emit(selected)
		
		selection_start = Vector2.ZERO
		queue_redraw()

func log_click_unit(unit: Unit):
	clicked_unit = unit


func new_sel(units: Array[Node], rect: Rect2):
	clear_sel()
	for unit in units:
		if rect.has_point(unit.position + unit.collider_target) and !unit.flags["dying"] and unit.player_id == GameInfo.active_player:
			selected.push_back(unit)
			unit.select()
	if selected.size() > 1:
		for i in range(selected.size() - 1, -1, -1):
			if !selected[i].flags["multi_select"]:
				selected[i].select(false)
				selected.remove_at(i)
	update_hud.emit(selected)

func clear_sel(_non = null):
	for unit in selected:
		if unit != null and !unit.flags["dying"]:
			unit.select(false)
	selected.clear()

func _draw() -> void:
	if selection_start != Vector2.ZERO:
		var target = GameInfo.camera_offset(get_viewport().get_mouse_position())
		draw_rect(Rect2(selection_start, target - selection_start), Color.DARK_GRAY, false, 3)
		draw_rect(Rect2(selection_start, target - selection_start), Color(0.663, 0.663, 0.663, 0.475))


# Private
func _get_formation(target: Vector2, spacing: int = 96) -> Array[Vector2]:
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

@rpc("call_local", "reliable")
func _handoff(node_name: String) -> void:
	if !multiplayer.is_server():
		return
	var node
	var count = 0
	@warning_ignore("unassigned_variable")
	while node == null and count < 100:
		if $Units.has_node(node_name):
			node = $Units.get_node(node_name)
		if count > 10:
			print("COULD NOT FIND NODE")
			return
		if count > 0:
			await get_tree().create_timer(0.1).timeout
		count += 1
	node.set_multiplayer_authority(node.player_id)




# Signals
func _on_child_entered_tree(node: Node) -> void:
	if node is Unit:
		node.select_event.connect(log_click_unit)
		_handoff.rpc(node.name)


func _on_multiplayer_spawner_spawned(node: Node) -> void:
	if node is Unit:
		_handoff.rpc(node.name)


func _on_multiplayer_spawner_despawned(node: Node) -> void:
	if node is Building:
		var points: Array[Vector2i] = node.get_tiles_in_footprint()
		
		GameInfo.map.set_cells_terrain_connect(points, 0, 0)
