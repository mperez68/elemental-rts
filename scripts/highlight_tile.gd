extends Area2D
class_name BlueprintTile

enum ResourceRequirement{ RESOURCE_NONE, RESOURCE_AETHER, RESOURCE_EMPYRIUM }

var valid: bool = true

@onready var sprite = $Sprite2D
@export var valid_color: Color
@export var invalid_color: Color

var resource_req: ResourceRequirement = ResourceRequirement.RESOURCE_NONE


func _ready() -> void:
	var tile = GameInfo.map.get_cell_tile_data(GameInfo.map.local_to_map(position))
	var resource: int = GameInfo.map.get_resource(GameInfo.map.local_to_map(position))
	if tile == null or resource != resource_req:
		valid = false
	
	if valid:
		sprite.self_modulate = valid_color
	else:
		sprite.self_modulate = invalid_color
