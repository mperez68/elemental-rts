extends Object
class_name Action

signal clear_hover

enum ActionNames{ BUILD_NEXUS, BUILD_PROSELYTIZER, BUILD_LOCUS, BUILD_HIEROPHANT, BUILD_FIRE_TEMPLE, BUILD_WATER_TEMPLE, BUILD_AIR_TEMPLE, BUILD_EARTH_TEMPLE, BUILD_VANGUARD, PRODUCE_SANCTIFIED, PRODUCE_LONGWEAVER, MOVE, STOP, ATTACK, STANCE, BUILD_TEMPLE }

var t = preload("res://ui/highlight_tile.tscn")

var action_name: String
var action_type: ActionNames
var shortcut: StringName
var effect: Callable
var hover: Callable
var hoverable: bool = true
var element: Unit.Element = Unit.Element.NONE
var player_id: int = 1
var calling_units: Array[Unit]
var aether_cost: int
var empyrium_cost: int

var highlight_footprint: Vector2i
var highlight_tiles: Array = []

# Public
static func build(action: ActionNames, id: int) -> Action:
	var temp = Action.new()
	temp.player_id = id
	temp.action_type = action
	if range(ActionNames.BUILD_NEXUS, ActionNames.BUILD_VANGUARD + 1).has(action):
		temp.hover = temp.hover_building
		temp.highlight_footprint = Vector2(1, 1)
	var b = null
	match action:
		ActionNames.BUILD_NEXUS:
			b = load("res://units/Buildings/nexus.tscn").instantiate()
			temp.highlight_footprint = b.footprint
			temp.action_name = "Build Nexus. A:%s, E:%s" % [b.aether_cost, b.empyrium_cost]
			temp.shortcut = "BuildNexus"
			temp.effect = temp.build_nexus
		ActionNames.BUILD_LOCUS:
			b = load("res://units/Buildings/locus.tscn").instantiate()
			temp.highlight_footprint = b.footprint
			temp.action_name = "Build Locus. A:%s, E:%s" % [b.aether_cost, b.empyrium_cost]
			temp.shortcut = "BuildLocus"
			temp.effect = temp.build_locus
			temp.hover = temp.hover_locus
		ActionNames.BUILD_HIEROPHANT:
			b = load("res://units/Buildings/hierophant.tscn").instantiate()
			temp.highlight_footprint = b.footprint
			temp.action_name = "Build Hierophant. A:%s, E:%s" % [b.aether_cost, b.empyrium_cost]
			temp.shortcut = "BuildHierophant"
			temp.effect = temp.build_hierophant
			temp.hover = temp.hover_hierophant
		ActionNames.BUILD_VANGUARD:
			b = load("res://units/Buildings/defense_tower.tscn").instantiate()
			temp.highlight_footprint = b.footprint
			temp.action_name = "Build Vanguard. A:%s, E:%s" % [b.aether_cost, b.empyrium_cost]
			temp.shortcut = "BuildVanguard"
			temp.effect = temp.build_vanguard
		ActionNames.BUILD_PROSELYTIZER:
			b = load("res://units/Buildings/proselytizer.tscn").instantiate()
			temp.highlight_footprint = b.footprint
			temp.action_name = "Build Proselytizer. A:%s, E:%s" % [b.aether_cost, b.empyrium_cost]
			temp.shortcut = "BuildProselytizer"
			temp.effect = temp.build_proselytizer
		ActionNames.BUILD_FIRE_TEMPLE:
			b = load("res://units/Buildings/temple.tscn").instantiate()
			temp.highlight_footprint = b.footprint
			temp.action_name = "Build Fire Temple. A:%s, E:%s" % [b.aether_cost, b.empyrium_cost]
			temp.shortcut = "BuildFireTemple"
			temp.element = Unit.Element.FIRE
			temp.effect = temp.build_temple
		ActionNames.BUILD_WATER_TEMPLE:
			b = load("res://units/Buildings/temple.tscn").instantiate()
			temp.highlight_footprint = b.footprint
			temp.action_name = "Build Water Temple. A:%s, E:%s" % [b.aether_cost, b.empyrium_cost]
			temp.shortcut = "BuildWaterTemple"
			temp.element = Unit.Element.WATER
			temp.effect = temp.build_temple
		ActionNames.BUILD_AIR_TEMPLE:
			b = load("res://units/Buildings/temple.tscn").instantiate()
			temp.highlight_footprint = b.footprint
			temp.action_name = "Build Air Temple. A:%s, E:%s" % [b.aether_cost, b.empyrium_cost]
			temp.shortcut = "BuildAirTemple"
			temp.element = Unit.Element.AIR
			temp.effect = temp.build_temple
		ActionNames.BUILD_EARTH_TEMPLE:
			b = load("res://units/Buildings/temple.tscn").instantiate()
			temp.highlight_footprint = b.footprint
			temp.action_name = "Build Earth Temple. A:%s, E:%s" % [b.aether_cost, b.empyrium_cost]
			temp.shortcut = "BuildEarthTemple"
			temp.element = Unit.Element.EARTH
			temp.effect = temp.build_temple
		ActionNames.PRODUCE_SANCTIFIED:
			b = load("res://units/sanctified.tscn").instantiate()
			temp.action_name = "Produce Sanctified. A:%s, E:%s" % [b.aether_cost, b.empyrium_cost]
			temp.shortcut = "ProduceSantified"
			temp.effect = temp.produce_sanctified
			temp.hover = temp.hover_unit
		ActionNames.PRODUCE_LONGWEAVER:
			b = load("res://units/farweaver.tscn").instantiate()
			temp.action_name = "Produce Longweaver. A:%s, E:%s" % [b.aether_cost, b.empyrium_cost]
			temp.shortcut = "ProduceLongweaver"
			temp.effect = temp.produce_longweaver
			temp.hover = temp.hover_unit
		ActionNames.MOVE:
			temp.action_name = "Move"
			temp.shortcut = "move"
			temp.effect = temp.move
			temp.hover = temp.hover_unit
		ActionNames.STOP:
			temp.action_name = "Stop"
			temp.shortcut = "stop"
			temp.effect = temp.stop
			temp.hoverable = false
		ActionNames.ATTACK:
			temp.action_name = "Attack"
			temp.shortcut = "attack"
			temp.effect = temp.attack
			temp.hover = temp.hover_unit
		ActionNames.STANCE:
			temp.action_name = "Stance"
			temp.shortcut = "stance"
			temp.effect = temp.stance
			temp.hoverable = false
		_:
			temp.effect = temp._null_effect
	if b != null:
		temp.aether_cost = b.aether_cost
		temp.empyrium_cost = b.empyrium_cost
	return temp


# Private
func _null_effect(_args: Array):
	print("NO EFFECT SET")

## Args[ target_position, manager_node ]
func _build(action: ActionNames, args: Array) -> bool:
	var building = load("res://units/Buildings/temple.tscn").instantiate()
	
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
	building.element = element
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
func move(args: Array) -> bool:
	clear_highlights()
	for unit in calling_units:
		unit.route(args[0])
	return true
	
func stop(_args: Array) -> bool:
	for unit in calling_units:
		unit.route(unit.position)
	return true
	
func attack(args: Array) -> bool:
	clear_highlights()
	for unit in calling_units:
		print("%s attacking towards %s" % [unit.name, args[0]])
	return true
	
func stance(_args: Array) -> bool:
	var new_stance: Unit.Stance
	if calling_units and calling_units.size() > 0:
		if calling_units[0].stance == 0:
			return true
		@warning_ignore("int_as_enum_without_cast")
		new_stance = (calling_units[0].stance + 1) % Unit.Stance.size()
		if new_stance == 0:
			@warning_ignore("int_as_enum_without_cast")
			new_stance += 1
	for unit in calling_units:
		unit.stance = new_stance
	return true

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

func can_afford():
	var player: Player = GameInfo.get_player(GameInfo.active_player)
	return player.aether >= aether_cost and player.empyrium >= empyrium_cost


# Signals
func _highlight_clicked(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event.is_action_pressed("click"):
		effect.call([GameInfo.camera_offset(event.position), GameInfo.map.get_tree().current_scene.get_node("Units"), element])
	if event.is_action_pressed("click") or event.is_action_pressed("alt_click"):
		clear_hover.emit(null)
