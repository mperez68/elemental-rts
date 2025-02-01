extends CharacterBody2D
class_name Unit

var max_speed: float = 256
var acceleration: float = 512
var friction: float = 16

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var hl = $Highlight

# Engine
func _process(delta: float) -> void:
	if !nav.is_navigation_finished():
		var direction = position.direction_to(nav.get_next_path_position())
		velocity += direction * delta * acceleration
		if abs(velocity.length()) > friction:
			velocity -= direction * delta * friction
		if abs(direction) * max_speed < abs(velocity):
			velocity = direction * max_speed
	else:
		velocity = Vector2.ZERO
	#var max_speed_vector = velocity.normalized() * max_speed
	#if velocity.length() > max_speed_vector.length():
		#velocity = max_speed_vector
	move_and_slide()


# Public
func route(target: Vector2):
	if GameInfo.camera == null:
		return
	nav.target_position = Vector2(GameInfo.camera_offset(target))

func highlight(activate: bool = true):
	hl.visible = activate
