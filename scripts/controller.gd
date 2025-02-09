extends MultiplayerSynchronizer


@onready var unit = get_parent()
@onready var target: Vector2 = get_parent().position
var clear_chase: bool = false


func _ready() -> void:
	if !multiplayer.is_server():
		set_process(false)
		


func route(new_target: Vector2, new_clear_chase: bool = false):
	target = new_target
	clear_chase = new_clear_chase

func _process(_delta: float) -> void:
	if unit.nav.target_position != target:
		_route.rpc()

@rpc("call_local")
func _route():
	#if multiplayer.get_unique_id() == sync.get_multiplayer_authority():
	if multiplayer.is_server():
		if clear_chase:
			unit.last_targets.clear()
	unit.nav.target_position = target
