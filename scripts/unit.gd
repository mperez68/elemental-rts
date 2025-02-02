extends CharacterBody2D
class_name Unit

signal update_fog(target: Vector2)

const TURN_LIMIT = 80

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var hl = $Highlight
@onready var header = $Header
@onready var hp_meter = $Header/Health

var reveal = true

@export var team: int = 0
@export var max_hp: int = 10
@export var hp: int = max_hp


var acceleration: float = 1024

# Engine
func _ready() -> void:
	if !reveal:
		$PointLight2D.queue_free()
	route(position)
	
	hp_meter.value = hp

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
			
		var ang = rad_to_deg(position.direction_to(nav.get_next_path_position()).angle_to(velocity))
		if ang > TURN_LIMIT or ang < -TURN_LIMIT:
			new_velocity = position.direction_to(nav.get_next_path_position()).normalized() * new_velocity.length()
		position.direction_to(nav.get_next_path_position()).angle_to(velocity)
		update_fog.emit(position)
	
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

func select(enable: bool = true):
	hl.visible = enable
	header.visible = enable


# Signals
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
		velocity = safe_velocity
