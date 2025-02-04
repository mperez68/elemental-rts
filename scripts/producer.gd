class_name Producer extends Building


@export var aether_production: int = 10
@export var empyrium_production: int = 0

func _ready() -> void:
	super()
	GameInfo.players[team].producers.push_back(self)
