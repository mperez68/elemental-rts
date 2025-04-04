extends GridContainer

@onready var action_buttons: Array = get_children()
@onready var move_button = action_buttons[0]
@onready var stop_button = action_buttons[1]
@onready var attack_button = action_buttons[2]
@onready var stance_button = action_buttons[3]

var default_actions: Array[Action] = [
preload("res://scripts/action.gd").build(Action.ActionNames.MOVE, GameInfo.active_player),
preload("res://scripts/action.gd").build(Action.ActionNames.STOP, GameInfo.active_player),
preload("res://scripts/action.gd").build(Action.ActionNames.ATTACK, GameInfo.active_player),
preload("res://scripts/action.gd").build(Action.ActionNames.STANCE, GameInfo.active_player)
]
var actions: Array[Action]
var active_action = -1

var selection: Array[Unit]
var last_selection_size: int = 0

# Engine
func _ready() -> void:
	for action in default_actions:
		action.clear_hover.connect(clear_action)

func _process(_delta: float) -> void:
	var in_reach = false
	var count_valid = 0
	for unit in selection:
		if is_instance_valid(unit) and !unit.flags["dying"]:
			count_valid += 1
			var range_vector = Vector2(unit.position.direction_to(GameInfo.camera_offset(get_viewport().get_mouse_position())) * unit.attack_radius.shape.radius * 2)
			range_vector.y /= 2
			var build_radius: float = range_vector.length()
			if !unit.flags["dying"] and unit.position.distance_to(GameInfo.camera_offset(get_viewport().get_mouse_position())) < build_radius:
				in_reach = true
	
	if count_valid != last_selection_size:
		for i in range(selection.size() - 1, -1, -1):
			if !is_instance_valid(selection[i]) or selection[i].flags["dying"]:
				selection.remove_at(i)
		update()
	
	if active_action > -1:
		if (in_reach or actions[active_action].action_type >= Action.ActionNames.MOVE) and actions[active_action].hoverable:
			actions[active_action].hover.call(GameInfo.camera_offset(get_viewport().get_mouse_position()))
		else:
			actions[active_action].clear_highlights()

func _on_hud_update_cards(new_sel: Array[Unit]) -> void:
	selection = new_sel
	last_selection_size = new_sel.size()
	update()

func _on_action_button_pressed(index: int) -> void:
	if active_action != index:
		# Break if can't afford
		if !actions[index].can_afford():
			print("CAN'T AFFORD")
			return
		if actions[index].hoverable:
			active_action = index
		else:
			actions[index].effect.call([get_viewport().get_mouse_position()])
	else:
		active_action = -1


# Public
func clear_action(new_child: Node):
	if new_child != null and  !new_child.is_node_ready():
		await new_child.ready
	if active_action < actions.size():
		actions[active_action].clear_highlights()
	active_action = -1

func update() -> void:
	# Reset
	for button in action_buttons:
		button.disabled = true
	if active_action > -1:
		actions[active_action].clear_highlights()
	actions.clear()
	for button in action_buttons:
		button.tooltip_text = ""
		button.shortcut = null
		button.get_node("Icon").texture = null
	actions = default_actions.duplicate()
	active_action = -1
	
	var unique_ability_counter: int = 4
	var unique_actions: Array[Action.ActionNames] = []
	for i in selection.size():
		# Top row commands
		if selection[i].stance != Unit.Stance.BUILDING:
			move_button.disabled = false
			stop_button.disabled = false
		if selection[i].weapon_type != Unit.WeaponType.NONE:
			attack_button.disabled = false
			stance_button.disabled = false
		# specials/abilities/construction/etc.
		for action in selection[i].actions:
			if !unique_actions.has(action):
				unique_actions.push_back(action)
				action_buttons[unique_ability_counter].disabled = false
				unique_ability_counter += 1
	
	for action in unique_actions:
		var temp = Action.build(action, selection[0].player_id)
		if action > Action.ActionNames.BUILD_VANGUARD:
			temp.element = selection[0].element
		temp.clear_hover.connect(clear_action)
		actions.push_back(temp)
	for i in actions.size():
		actions[i].calling_units = selection
		action_buttons[i].tooltip_text = actions[i].action_name
		action_buttons[i].get_node("Icon").texture = actions[i].icon
		var temp: Shortcut = Shortcut.new()
		var act: InputEventAction = InputEventAction.new()
		act.action = actions[i].shortcut
		temp.events.push_back(act)
		action_buttons[i].shortcut = temp
		
