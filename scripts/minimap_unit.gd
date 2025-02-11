extends Sprite2D
class_name MinimapUnit

@export var friendly_color: Color
@export var unfriendly_color: Color

@onready var aura: ShapeCast2D = $ShapeCast2D

var player_id: int

var unit: Unit:
	set(u):
		unit = u
		player_id = u.player_id
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
			var ret: bool = false
			for node in aura.collision_result:
				if node.collider is MinimapUnitCollider and node.collider.id != player_id:
					ret = true
			visible = ret
		position = GameInfo.map.local_to_map(unit.position)
	
