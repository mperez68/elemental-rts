extends SubViewport

var u = preload("res://ui/minimap_unit.tscn")

func _ready() -> void:
	get_tree().current_scene.get_node("Units").child_entered_tree.connect(add_minimap_unit)

func add_minimap_unit(node: Node):
	if node is not Unit:
		return
	
	var unit = u.instantiate()
	unit.unit = node
	$Units.add_child(unit)
	
