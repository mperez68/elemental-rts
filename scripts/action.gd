extends Object
class_name Action

signal clear_hover

enum ActionNames{ BUILD_NEXUS, BUILD_PROSELYTIZER, BUILD_LOCUS, BUILD_HIEROPHANT, BUILD_TEMPLE, BUILD_VANGUARD, PRODUCE_SANCTIFIED, PRODUCE_LONGWEAVER }

var t = preload("res://ui/highlight_tile.tscn")

var action_name: String
var shortcut: StringName
var effect: Callable
var hover: Callable
var element = Unit.Element.NONE
var player_id: int = 1

var highlight_footprint: Vector2i
var highlight_tiles: Array = []

# Public
static func build(action: ActionNames, id: int) -> Action:
	var temp = Action.new()
	temp.player_id = id
	if range(ActionNames.BUILD_NEXUS, ActionNames.BUILD_VANGUARD + 1).has(action):
		temp.hover = temp.hover_building
	match action:
		ActionNames.BUILD_NEXUS:
			temp.action_name = "Build [u]N[/u]exus"
			temp.shortcut = "BuildNexus"
			temp.effect = temp.build_nexus
			temp.highlight_footprint = load("res://units/Buildings/nexus.tscn").instantiate().footprint
		ActionNames.BUILD_LOCUS:
			temp.action_name = "Build [u]L[/u]ocus"
			temp.shortcut = "BuildLocus"
			temp.effect = temp.build_locus
			temp.highlight_footprint = load("res://units/Buildings/locus.tscn").instantiate().footprint
			temp.hover = temp.hover_locus
		ActionNames.BUILD_HIEROPHANT:
			temp.action_name = "Build [u]H[/u]ierophant"
			temp.shortcut = "BuildHierophant"
			temp.effect = temp.build_hierophant
			temp.highlight_footprint = load("res://units/Buildings/hierophant.tscn").instantiate().footprint
			temp.hover = temp.hover_hierophant
		ActionNames.BUILD_VANGUARD:
			temp.action_name = "Build [u]V[/u]anguard"
			temp.shortcut = "BuildVanguard"
			temp.effect = temp.build_vanguard
			temp.highlight_footprint = load("res://units/Buildings/defense_tower.tscn").instantiate().footprint
		ActionNames.BUILD_PROSELYTIZER:
			temp.action_name = "Build [u]P[/u]roselytizer"
			temp.shortcut = "BuildProselytizer"
			temp.effect = temp.build_proselytizer
			temp.highlight_footprint = load("res://units/Buildings/proselytizer.tscn").instantiate().footprint
		ActionNames.BUILD_TEMPLE:
			temp.action_name = "Build [u]T[/u]emple"
			temp.shortcut = "BuildTemple"
			temp.effect = temp.build_temple
			temp.highlight_footprint = load("res://units/Buildings/temple.tscn").instantiate().footprint
		ActionNames.PRODUCE_SANCTIFIED:
			temp.action_name = "Produce San[i]c[/i]tifier"
			temp.shortcut = "ProduceSanctifier"
			temp.effect = temp.produce_sanctified
			temp.highlight_footprint = Vector2(1, 1)
			temp.hover = temp.hover_unit
		ActionNames.PRODUCE_LONGWEAVER:
			temp.action_name = "Produce L[i]o[/i]ngweaver"
			temp.shortcut = "ProduceLongweaver"
			temp.effect = temp.produce_longweaver
			temp.highlight_footprint = Vector2(1, 1)
			temp.hover = temp.hover_unit
			
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
		ActionNames.BUILD_PROSELYTIZER:
			building = load("res://units/Buildings/proselytizer.tscn").instantiate()
		ActionNames.BUILD_TEMPLE:
			building = load("res://units/Buildings/temple.tscn").instantiate()
		_:
			_null_effect([])
			return false
	
	if highlight_tiles.is_empty():
		return false
	
	for tile in highlight_tiles:
		if !tile.valid:
			return false
	
	if GameInfo.get_player(GameInfo.active_player).aether < building.aether_cost or GameInfo.get_player(GameInfo.active_player).empyrium < building.empyrium_cost:
		print("INSUFFICIENT RESOURCES")
		return false
	
	GameInfo.get_player(GameInfo.active_player).aether -= building.aether_cost
	GameInfo.get_player(GameInfo.active_player).empyrium -= building.empyrium_cost
	
	@warning_ignore("integer_division")
	building.position = args[0]
	building.player_id = player_id
	GameInfo.get_player(GameInfo.active_player).spawn_unit(building)
	clear_hover.emit(building)
	
	return true

## Args[ target_position, manager_node, element ]
func _produce(action: ActionNames, args: Array):
	var unit
	
	match action:
		ActionNames.PRODUCE_SANCTIFIED:
			unit = load("res://units/sanctified.tscn").instantiate()
		ActionNames.PRODUCE_LONGWEAVER:
			unit = load("res://units/farweaver.tscn").instantiate()
		_:
			_null_effect([])
			return false
	
	if GameInfo.get_player(GameInfo.active_player).aether < unit.aether_cost or GameInfo.get_player(GameInfo.active_player).empyrium < unit.empyrium_cost:
		print("INSUFFICIENT RESOURCES")
		return false
	
	GameInfo.get_player(GameInfo.active_player).aether -= unit.aether_cost
	GameInfo.get_player(GameInfo.active_player).empyrium -= unit.empyrium_cost
	
	@warning_ignore("integer_division")
	unit.position = args[0]
	unit.player_id = player_id
	unit.element = args[2]
	GameInfo.get_player(GameInfo.active_player).spawn_unit(unit)
	
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

func build_proselytizer(args: Array) -> bool:
	return _build(ActionNames.BUILD_PROSELYTIZER, args)

func build_temple(args: Array) -> bool:
	return _build(ActionNames.BUILD_TEMPLE, args)

func produce_sanctified(args: Array) -> bool:
	return _produce(ActionNames.PRODUCE_SANCTIFIED, args)

func produce_longweaver(args: Array) -> bool:
	return _produce(ActionNames.PRODUCE_LONGWEAVER, args)

func hover_locus(target_position: Vector2):
	hover_building(target_position, BlueprintTile.ResourceRequirement.RESOURCE_AETHER)

func hover_hierophant(target_position: Vector2):
	hover_building(target_position, BlueprintTile.ResourceRequirement.RESOURCE_EMPYRIUM)

func hover_building(target_position: Vector2, req: BlueprintTile.ResourceRequirement = BlueprintTile.ResourceRequirement.RESOURCE_NONE) -> void:
	clear_highlights()
	var grid_start = GameInfo.map.local_to_map(target_position)
	for i in highlight_footprint.x:
		for j in highlight_footprint.y:
			var temp = t.instantiate()
			@warning_ignore("integer_division")
			var offset = Vector2i(i - ((highlight_footprint.x / 2)), -j + floor((highlight_footprint.y / 2)))
			temp.position = GameInfo.map.map_to_local(grid_start + offset)
			# Center tile must be requirement if one is given
			if offset == Vector2i.ZERO:
				temp.resource_req = req
			temp.input_event.connect(_highlight_clicked)
			highlight_tiles.push_back(temp)
			GameInfo.map.add_child(temp)

func hover_unit(target_position: Vector2) -> void:
	clear_highlights()
	var temp = t.instantiate()
	temp.position = target_position
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
		effect.call([GameInfo.camera_offset(event.position), GameInfo.map.get_tree().current_scene.get_node("Units"), element])
	elif event.is_action_pressed("alt_click"):
		clear_hover.emit(null)
