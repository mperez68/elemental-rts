extends HBoxContainer

const rps_postfix: String = "/s"

@onready var aether_text = $Aether/Value
@onready var aether_rps_text = $Aether/RPS
@onready var empyrium_text = $Empyrium/Value
@onready var empyrium_rps_text = $Empyrium/RPS

func _process(_delta: float) -> void:
	aether_text.text = str(GameInfo.players[GameInfo.active_player].aether)
	empyrium_text.text = str(GameInfo.players[GameInfo.active_player].empyrium)
	var aether_rps: float = 0
	var empyrium_rps: float = 0
	for producer in GameInfo.players[GameInfo.active_player].producers:
		aether_rps += producer.aether_production
		empyrium_rps += producer.empyrium_production
	
	aether_rps_text.text = str(aether_rps) + rps_postfix
	empyrium_rps_text.text = str(empyrium_rps) + rps_postfix
