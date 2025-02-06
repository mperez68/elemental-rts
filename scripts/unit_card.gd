extends PanelContainer

@onready var name_text: Label = $Margins/VBoxContainer/Name
@onready var tags: Array[Node] = $Margins/VBoxContainer/Tags.get_children()
@onready var hp_bar: ProgressBar = $Margins/VBoxContainer/HPBar

var unit: Unit

func _process(delta: float) -> void:
	hp_bar.value = unit.hp
	if unit.hp <= 0:
		queue_free()

func set_unit(u: Unit) -> bool:
	unit = u
	if is_node_ready():
		update_text()
		return true
	return false

func _ready() -> void:
	update_text()

func update_text() -> void:
	if unit == null:
		return
	name_text.text = unit.unit_name
	hp_bar.max_value = unit.max_hp
	hp_bar.value = unit.hp
	for i in tags.size():
		if unit.tags.size() > i:
			tags[i].texture = unit.tags[i]
		else:
			tags[i].texture = null
