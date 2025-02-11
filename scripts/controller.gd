extends MultiplayerSynchronizer


@onready var unit = get_parent()
@onready var target: Vector2 = get_parent().position
var clear_chase: bool = false


# Engine
func _ready() -> void:
	if !multiplayer.is_server():
		set_process(false)

func _process(_delta: float) -> void:
	if unit.nav.target_position != target:
		_route.rpc()


# public
func route(new_target: Vector2, new_clear_chase: bool = false):
	target = new_target
	clear_chase = new_clear_chase


# Private
@rpc("call_local")
func _route():
	if multiplayer.is_server():
		if clear_chase:
			unit.last_targets.clear()
		unit.nav.target_position = target
