extends Building
class_name Nexus

var unlocked_elements: Dictionary = {}

# Engine
func _ready() -> void:
	super()
	get_tree().current_scene.get_node("Units").child_entered_tree.connect(_update_elements_add)


# Private
func _update_elements_add(node: Node):
	if node is Unit and node.unit_name == "Temple" and node.player_id == player_id:
		node.remove_element.connect(lock_element)
		unlock_element(node.element)


# Public
func unlock_element(ele: Element):
	unlocked_elements[ele] = true
	var unlocked_count = 0
	for unlocked in unlocked_elements.values():
		if unlocked == true:
			unlocked_count += 1
	
	if unlocked_count >= 4:
		print("%'s timer started, 4 min to win")
		$WinTimer.start()

func lock_element(ele: Element):
	unlocked_elements[ele] = false
	$WinTimer.stop()


# Signals
func _on_win_timer_timeout() -> void:
	print("%s WINS" % GameInfo.active_player)
