extends Object
class_name Action

enum ActionNames{ BUILD_NEXUS, BUILD_LOCUS, BUILD_HIEROPHANT }

var action_name: String
var shortcut: StringName
var effect: Callable
var hover: Callable

var highlight_footprint: Vector2i
var highlight_tiles: Array = []

# Public
static func build(action: ActionNames) -> Action:
	var temp = Action.new()
	match action:
		ActionNames.BUILD_NEXUS:
			temp.action_name = "Build Nexus"
			temp.shortcut = "BuildNexus"
			temp.effect = temp.build_nexus
			temp.highlight_footprint = load("res://units/Buildings/nexus.tscn").instantiate().footprint
		ActionNames.BUILD_LOCUS:
			temp.action_name = "Build Locus"
			temp.shortcut = "BuildLocus"
			temp.effect = temp.build_locus
			temp.highlight_footprint = load("res://units/Buildings/locus.tscn").instantiate().footprint
		ActionNames.BUILD_HIEROPHANT:
			temp.action_name = "Build Hierophant"
			temp.shortcut = "BuildHierophant"
			temp.effect = temp.build_hierophant
			temp.highlight_footprint = load("res://units/Buildings/hierophant.tscn").instantiate().footprint
		_:
			temp.effect = temp._null_effect
	temp.hover = temp.hover_building
	return temp


# Private
func _null_effect(args: Array):
	print("NO EFFECT SET")

## Args[ target_position, manager_node ]
func _build(action: ActionNames, args: Array) -> bool:
	var building
	
	match action:
		ActionNames.BUILD_NEXUS:
			building = load("res://units/Buildings/nexus.tscn").instantiate()
		ActionNames.BUILD_LOCUS:
			building = load("res://units/Buildings/locus.tscn").instantiate()
		ActionNames.BUILD_HIEROPHANT:
			building = load("res://units/Buildings/hierophant.tscn").instantiate()
		_:
			_null_effect([])
			return false
	
	building.position = args[0]
	args[1].add_child(building)
	
	return true


# Effects
func build_nexus(args: Array) -> bool:
	return _build(ActionNames.BUILD_NEXUS, args)
	clear_highlights()

func build_locus(args: Array) -> bool:
	return _build(ActionNames.BUILD_LOCUS, args)
	clear_highlights()

func build_hierophant(args: Array) -> bool:
	return _build(ActionNames.BUILD_HIEROPHANT, args)
	clear_highlights()

func hover_building(target_position: Vector2) -> void:
	clear_highlights()
	var grid_start = GameInfo.map.local_to_map(target_position)
	var tile = preload("res://ui/highlight_tile.tscn")
	for i in highlight_footprint.x:
		for j in highlight_footprint.y:
			var temp = tile.instantiate()
			temp.position = GameInfo.map.map_to_local(grid_start + Vector2i(i, -j))
			temp.input_event.connect(_highlight_clicked)
			highlight_tiles.push_back(temp)
			GameInfo.map.add_child(temp)

func clear_highlights():
	for tile in highlight_tiles:
		tile.queue_free()
	highlight_tiles.clear()


func _highlight_clicked(viewport: Node, event: InputEvent, shape_idx: int):
	if event.is_action_pressed("click"):
		effect.call([GameInfo.camera_offset(event.position), GameInfo.map.get_tree().current_scene])
