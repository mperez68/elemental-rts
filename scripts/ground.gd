extends TileMapLayer

@onready var resource_layer: TileMapLayer = $"../ResourceVeins"


# Engine
func _ready() -> void:
	GameInfo.map = self

func get_resource(grid_position: Vector2i) -> int:
	var ret: int
	var resource_tile = resource_layer.get_cell_tile_data(grid_position)
	if resource_tile:
		ret = resource_tile.get_custom_data("Resource")
	return ret
