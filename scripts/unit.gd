extends CharacterBody2D
class_name Unit

const TURN_LIMIT = 80

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var hl = $Highlight

@onready var slow_distance: float = nav.target_desired_distance * 2

var acceleration: float = 1024

# Engine
func _ready() -> void:
	route(position)

func _process(delta: float) -> void:
	var new_velocity: Vector2 = velocity
	# Accelerate towards target
	if nav.is_navigation_finished():
		nav.avoidance_priority = 0.5
		new_velocity = Vector2.ZERO
		if position.distance_to(nav.get_final_position()) > nav.target_desired_distance:
			route(nav.get_final_position())
	else:
		nav.avoidance_priority = 1
		var direction = position.direction_to(nav.get_next_path_position())
		new_velocity += direction * acceleration * delta
		#if position.distance_to(nav.get_final_position()) < slow_distance:
			#new_velocity = new_velocity * max((position.distance_to(nav.get_final_position()) / slow_distance), 0.5)
			
		var ang = rad_to_deg(position.direction_to(nav.get_next_path_position()).angle_to(velocity))
		if ang > TURN_LIMIT or ang < -TURN_LIMIT:
			new_velocity = position.direction_to(nav.get_next_path_position()).normalized() * new_velocity.length()
		position.direction_to(nav.get_next_path_position()).angle_to(velocity)
	
	if nav.avoidance_enabled:
		nav.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	
	# Debug
	queue_redraw()
	
	# Resolve
	move_and_slide()

func _draw() -> void:
	if nav.debug_enabled:
		draw_line(Vector2.ZERO, position.direction_to(nav.get_next_path_position()) * 32, Color.BLUE, 1)
		draw_circle(position.direction_to(nav.get_next_path_position()) * 32, 3, Color.BLACK)
		var color = Color.BLACK
		var ang = rad_to_deg(position.direction_to(nav.get_next_path_position()).angle_to(velocity))
		if ang > TURN_LIMIT or ang < -TURN_LIMIT:
			color = Color.RED
		draw_line(Vector2.ZERO, velocity, color, 2)


# Public
func route(target: Vector2):
	if GameInfo.camera == null:
		return
	nav.target_position = target

func highlight(activate: bool = true):
	hl.visible = activate


# Signals
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
		velocity = safe_velocity
