extends Sprite2D

@export var friendly_color: Color
@export var unfriendly_color: Color

var unit: Unit:
	set(u):
		unit = u
		if u is Building:
			scale += Vector2(0.005, 0.005)

# Engine
func _process(_delta: float) -> void:
	# Do nothing if unit is not set
	if unit and (!is_instance_valid(unit) or unit.flags["dying"]):
		queue_free()
	else:
		if unit.player_id == GameInfo.active_player:
			modulate = friendly_color
		else:
			modulate = unfriendly_color
		position = GameInfo.map.local_to_map(unit.position)
	
