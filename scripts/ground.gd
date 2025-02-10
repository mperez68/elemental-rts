extends TileMapLayer

@onready var resource_layer: TileMapLayer = %ResourceVeins
@onready var bg_layer: TileMapLayer = %GroundCover

@export var start_locations: Array[Vector2i] = []

# Engine
func _ready() -> void:
	GameInfo.map = self
	start_locations.shuffle()


# Public
func get_resource(grid_position: Vector2i) -> int:
	var ret: int
	var resource_tile = resource_layer.get_cell_tile_data(grid_position)
	if resource_tile:
		ret = resource_tile.get_custom_data("Resource")
	return ret

func set_cell_all_maps(tile_position: Vector2i):
	set_cell(tile_position)
	bg_layer.set_cell(tile_position, 0, Vector2i(1, 1))
