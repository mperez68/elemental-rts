extends Timer

var units: Array[Unit] = []

func _ready() -> void:
	for unit in get_parent().find_children("*", "Unit"):
		units.push_back(unit)



func _on_timeout() -> void:
	for unit in units:
		unit.damage(1)
