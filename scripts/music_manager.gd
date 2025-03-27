extends Node

enum { THEME, NONE }

@onready var layers: Array[Node] = get_children()

func play(element: Unit.Element):
	layers[element].volume_db = 0

func stop(element: Unit.Element):
	layers[element].volume_db = -80
