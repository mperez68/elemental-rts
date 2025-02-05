extends Area2D

var valid: bool = true

@onready var sprite = $Sprite2D
@export var valid_color: Color
@export var invalid_color: Color


func _ready() -> void:
	var tile = GameInfo.map.get_cell_tile_data(GameInfo.map.local_to_map(position))
	if tile == null:
		valid = false
	else:
		valid = true
	if valid:
		sprite.self_modulate = valid_color
	else:
		sprite.self_modulate = invalid_color
