extends Node
class_name Player
# Container class for player stats

var aether: int = 100
var empyrium: int = 0
var player_id: int = 1

var producers: Array[Producer] = [  ]

# Signals
func _on_production_timer_timeout() -> void:
	for producer in producers:
		aether += producer.aether_production
		empyrium += producer.empyrium_production
