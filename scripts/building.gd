class_name Building extends Unit


@export var footprint: Vector2i = Vector2i(3, 3)
var grid_start: Vector2i

# Engine
func _ready() -> void:
	flags["multi_select"] = false
	while (GameInfo.map == null):
		await get_tree().create_timer(0.1).timeout
	
	if multiplayer.is_server():
		position = GameInfo.map.map_to_local(GameInfo.map.local_to_map(position) - (Vector2i(1, -1) * floor(footprint / 2)))
	
		for i in range(1, footprint.x):
			position -= Vector2(GameInfo.GRID) / 4
		for j in range(1, footprint.y):
			@warning_ignore("integer_division")
			position.x += GameInfo.GRID.x / 4
			@warning_ignore("integer_division")
			position.y -= GameInfo.GRID.y / 4
	clear_tiles(get_tiles_in_footprint())
	super()


# Public
func clear_tiles(tiles: Array[Vector2i]):
	for tile in tiles:
		GameInfo.map.set_cell_all_maps(tile)
		
func get_tiles_in_footprint() -> Array[Vector2i]:
	var ret: Array[Vector2i] = []
	
	grid_start = GameInfo.map.local_to_map(position)
	var x_offset = 0
	if footprint.x % 2 == 1:	# ODD
		@warning_ignore("integer_division")
		x_offset = (footprint.x - 1) / 2
	else:	# EVEN
		@warning_ignore("integer_division")
		x_offset = (footprint.x / 2) - 1
	var y_offset = 0
	if footprint.y % 2 == 1:	# ODD
		@warning_ignore("integer_division")
		y_offset = (footprint.y - 1) / 2
	else:	# EVEN
		@warning_ignore("integer_division")
		y_offset = (footprint.y / 2) - 1
	
	for x in footprint.x:
		for y in footprint.y:
			ret.push_back(grid_start + Vector2i(x - x_offset, y - y_offset))
	
	return ret

func movement(_delta: float) -> void:
	pass

func die():
	super()
	
	var points: Array[Vector2i] = get_tiles_in_footprint()
	GameInfo.map.set_cells_terrain_connect(points, 0, 0)
