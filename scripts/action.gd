extends Object
class_name Action

signal clear_hover

enum ActionNames{ BUILD_NEXUS, BUILD_LOCUS, BUILD_HIEROPHANT, BUILD_VANGUARD }

var action_name: String
var shortcut: StringName
var effect: Callable
var hover: Callable

var highlight_footprint: Vector2i
var highlight_tiles: Array = []

# Public
static func build(action: ActionNames) -> Action:
	var temp = Action.new()
	if range(ActionNames.BUILD_NEXUS, ActionNames.BUILD_VANGUARD + 1).has(action):
		temp.hover = temp.hover_building
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
			temp.hover = temp.hover_locus
		ActionNames.BUILD_HIEROPHANT:
			temp.action_name = "Build Hierophant"
			temp.shortcut = "BuildHierophant"
			temp.effect = temp.build_hierophant
			temp.highlight_footprint = load("res://units/Buildings/hierophant.tscn").instantiate().footprint
			temp.hover = temp.hover_hierophant
		ActionNames.BUILD_VANGUARD:
			temp.action_name = "Build Vanguard"
			temp.shortcut = "BuildVanguard"
			temp.effect = temp.build_vanguard
			temp.highlight_footprint = load("res://units/Buildings/defense_tower.tscn").instantiate().footprint
		_:
			temp.effect = temp._null_effect
	return temp


# Private
func _null_effect(_args: Array):
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
		ActionNames.BUILD_VANGUARD:
			building = load("res://units/Buildings/defense_tower.tscn").instantiate()
		_:
			_null_effect([])
			return false
	
	if highlight_tiles.is_empty():
		return false
	
	for tile in highlight_tiles:
		if !tile.valid:
			return false
	
	if GameInfo.players[GameInfo.active_player].aether < building.aether_cost or GameInfo.players[GameInfo.active_player].empyrium < building.empyrium_cost:
		print("INSUFFICIENT RESOURCES")
		return false
	
	GameInfo.players[GameInfo.active_player].aether -= building.aether_cost
	GameInfo.players[GameInfo.active_player].empyrium -= building.empyrium_cost
	
	@warning_ignore("integer_division")
	building.position = args[0]# + Vector2(0, highlight_footprint.y / 2 * GameInfo.GRID.y)
	args[1].add_child(building)
	clear_hover.emit(building)
	
	return true


# Effects
func build_nexus(args: Array) -> bool:
	return _build(ActionNames.BUILD_NEXUS, args)

func build_locus(args: Array) -> bool:
	return _build(ActionNames.BUILD_LOCUS, args)

func build_hierophant(args: Array) -> bool:
	return _build(ActionNames.BUILD_HIEROPHANT, args)
	
func build_vanguard(args: Array) -> bool:
	return _build(ActionNames.BUILD_VANGUARD, args)

func hover_locus(target_position: Vector2):
	hover_building(target_position, BlueprintTile.ResourceRequirement.RESOURCE_AETHER)

func hover_hierophant(target_position: Vector2):
	hover_building(target_position, BlueprintTile.ResourceRequirement.RESOURCE_EMPYRIUM)

func hover_building(target_position: Vector2, req: BlueprintTile.ResourceRequirement = BlueprintTile.ResourceRequirement.RESOURCE_NONE) -> void:
	clear_highlights()
	var grid_start = GameInfo.map.local_to_map(target_position)
	var tile = preload("res://ui/highlight_tile.tscn")
	for i in highlight_footprint.x:
		for j in highlight_footprint.y:
			var temp = tile.instantiate()
			@warning_ignore("integer_division")
			var offset = Vector2i(i - ((highlight_footprint.x / 2)), -j + floor((highlight_footprint.y / 2)))
			temp.position = GameInfo.map.map_to_local(grid_start + offset)
			# Center tile must be requirement if one is given
			if offset == Vector2i.ZERO:
				temp.resource_req = req
			temp.input_event.connect(_highlight_clicked)
			highlight_tiles.push_back(temp)
			GameInfo.map.add_child(temp)


# Public
func clear_highlights():
	for tile in highlight_tiles:
		tile.queue_free()
	highlight_tiles.clear()


# Signals
func _highlight_clicked(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event.is_action_pressed("click"):
		effect.call([GameInfo.camera_offset(event.position), GameInfo.map.get_tree().current_scene])
	elif event.is_action_pressed("alt_click"):
		clear_hover.emit(null)
