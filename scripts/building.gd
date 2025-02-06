class_name Building extends Unit


@export var footprint: Vector2i = Vector2i(3, 3)
var grid_start: Vector2i

# Engine
func _ready() -> void:
	flags["multi_select"] = false
	while (GameInfo.map == null):
		await get_tree().create_timer(0.1).timeout
	
	position = GameInfo.map.map_to_local(GameInfo.map.local_to_map(position))
	grid_start = GameInfo.map.local_to_map(position)
	for i in range(1, footprint.x):
		position -= Vector2(GameInfo.GRID) / 4
	for j in range(1, footprint.y):
		@warning_ignore("integer_division")
		position.x += GameInfo.GRID.x / 4
		@warning_ignore("integer_division")
		position.y -= GameInfo.GRID.y / 4
	
	for a in footprint.x:
		for b in footprint.y:
			GameInfo.map.set_cell(grid_start + Vector2i(a, -b))
	
	super()


# Public
func movement(_delta: float) -> void:
	pass
	
func die():
	super()
	
	var points: Array[Vector2i] = []
	for a in footprint.x:
		for b in footprint.y:
			points.push_back(grid_start + Vector2i(a, -b))
	
	GameInfo.map.set_cells_terrain_connect(points, 0, 0)
