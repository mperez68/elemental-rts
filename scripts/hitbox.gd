extends Area2D
class_name UnitHitBox

@onready var unit: Unit = get_parent().get_parent()

func damage(dmg: int):
	unit.damage(dmg)
