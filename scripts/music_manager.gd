extends Node

const VOLUME_MAX = 0
const VOLUME_MIN = -80
enum { THEME, NONE }

@onready var layers: Array[Node] = get_children()
var rising_layers: Array[Unit.Element] = [  ]
var lowering_layers: Array[Unit.Element] = [  ]

func _process(delta: float) -> void:
	for i in range(rising_layers.size() - 1, -1, -1):
		layers[rising_layers[i]].volume_db += 1
		if layers[rising_layers[i]].volume_db >= VOLUME_MAX:
			rising_layers.remove_at(i)
	
	for i in range(lowering_layers.size() - 1, -1, -1):
		layers[lowering_layers[i]].volume_db -= 1
		if layers[lowering_layers[i]].volume_db <= VOLUME_MIN:
			lowering_layers.remove_at(i)
		

func play(element: Unit.Element):
	rising_layers.push_front(element)

func stop(element: Unit.Element):
	lowering_layers.push_front(element)
