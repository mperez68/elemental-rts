extends GridContainer

@onready var action_buttons: Array[Node] = get_children()
@onready var move_button = action_buttons[0]
@onready var stop_button = action_buttons[1]
@onready var attack_button = action_buttons[2]

var actions: Array[Action]
var active_action = -1

var selection: Array[Unit]

func _process(_delta: float) -> void:
	var in_reach = false
	for unit in selection:
		if unit.position.distance_to(GameInfo.camera_offset(get_viewport().get_mouse_position())) < unit.attack_radius.shape.radius * 2:
			in_reach = true
	
	if active_action > -1:
		if in_reach:
			actions[active_action - 4].hover.call(GameInfo.camera_offset(get_viewport().get_mouse_position()))
		else:
			actions[active_action - 4].clear_highlights()

func _on_hud_update_cards(new_sel: Array[Unit]) -> void:
	selection = new_sel
	update()

func update() -> void:
	# Reset
	for button in action_buttons:
		button.disabled = true
	if active_action > -1:
		actions[active_action - 4].clear_highlights()
	actions = []
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
		# specials/abilities/construction/etc.
		for action in selection[i].actions:
			if !unique_actions.has(action):
				unique_actions.push_back(action)
				action_buttons[unique_ability_counter].disabled = false
				unique_ability_counter += 1
	
	for action in unique_actions:
		actions.push_back(Action.build(action))


func _on_action_button_pressed(index: int) -> void:
	if active_action != index:
		active_action = index
	else:
		active_action = -1
