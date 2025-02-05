extends GridContainer

@onready var action_buttons: Array[Node] = get_children()
@onready var move_button = action_buttons[0]
@onready var stop_button = action_buttons[1]
@onready var attack_button = action_buttons[2]

var actions: Array
var selection: Array[Unit]

func _on_hud_update_cards(new_sel: Array[Unit]) -> void:
	selection = new_sel
	update()

func update() -> void:
	# Reset
	for button in action_buttons:
		button.disabled = true
	actions = []
	
	var unique_ability_counter: int = 4
	for i in selection.size():
		# Top row commands
		if selection[i].stance != Unit.Stance.BUILDING:
			move_button.disabled = false
			stop_button.disabled = false
		if selection[i].weapon_type != Unit.WeaponType.NONE:
			attack_button.disabled = false
		# specials/abilities/construction/etc.
		for action in selection[i].actions:
			if !actions.has(action):
				actions.push_back(action)
				action_buttons[unique_ability_counter].disabled = false
				unique_ability_counter += 1
				
		
	
	
