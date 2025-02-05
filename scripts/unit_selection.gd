extends HFlowContainer

var unit_card: PackedScene = preload("res://ui/unit_card.tscn")

var selection: Array[Unit]

func _ready() -> void:
	update()

func set_selection(new_sel: Array[Unit]):
	selection = new_sel
	update()

func update() -> void:
	for card in get_children():
		card.queue_free()
	for unit in selection:
		var temp = unit_card.instantiate()
		temp.set_unit(unit)
		add_child(temp)


func _on_hud_update_cards(new_sel: Array[Unit]) -> void:
	set_selection(new_sel)
