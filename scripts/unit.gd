extends CharacterBody2D
class_name Unit

var speed: float = 128

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var hl = $Highlight

# Engine
func _process(_delta: float) -> void:
	position = position.move_toward(nav.get_next_path_position(), speed * _delta)
	move_and_slide()


# Public
func route(target: Vector2):
	if GameInfo.camera == null:
		return
	nav.target_position = Vector2(GameInfo.camera_offset(target))

func highlight(activate: bool = true):
	hl.visible = activate
