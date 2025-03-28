extends Node
class_name Player
# Container class for player stats

const START_AETHER: int = 150
const START_EMPYRIUM: int = 100

@onready var sync = $Synchronizer

var aether: int = START_AETHER
var empyrium: int = START_EMPYRIUM
var player_id: int = 1

var producers: Array[Producer] = [  ]

# Signals
func _on_production_timer_timeout() -> void:
	for producer in producers:
		aether += producer.aether_production
		empyrium += producer.empyrium_production


func spawn_unit(unit: Unit):
	if multiplayer.is_server():
		_spawn_unit(unit.scene_file_path, unit.position, unit.player_id, unit.element)
	else:
		_spawn_unit.rpc(unit.scene_file_path, unit.position, unit.player_id, unit.element)
	

@rpc("call_local", "reliable")
func _spawn_unit(filepath: String, position: Vector2, id: int, element: Unit.Element):
	if multiplayer.is_server():
		var node = load(filepath).instantiate()
		node.position = position
		node.player_id = id
		node.element = element
		get_tree().current_scene.get_node("Units").add_child(node, true)
