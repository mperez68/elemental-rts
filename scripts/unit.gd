extends CharacterBody2D
class_name Unit

signal select_event(this: Unit)

const TURN_LIMIT = 80

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var hl = $Highlight
@onready var header = $Header
@onready var hp_meter = $Header/Health
@onready var attack_radius = $AttackRange
@onready var anim = $AnimationPlayer

var missile = preload("res://core/missile.tscn")


@export var team: int = 0
@export var max_hp: int = 10
@export var damage_multiplier: float = 1
@export var acceleration: float = 1024
@onready var hp: int = max_hp
var dying: bool = false
var selected: bool = false
var reveal = true



# Engine
func _ready() -> void:
	reveal = team == GameInfo.active_player
	if !reveal:
		$Light.queue_free()
		header.visible = false
	route(position)
	
	hp_meter.max_value = max_hp
	hp_meter.value = hp

func _process(delta: float) -> void:
	movement(delta)

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
	selected = enable
	hl.visible = enable
	header.visible = enable

func damage(dmg: int) -> void:
	hp -= dmg
	if hp <= 0:
		die()
	else:
		hp_meter.value = hp

func die():
	$AttackCooldown.stop()
	dying = true
	anim.play("die")
	header.visible = false
	hl.visible = false
	velocity = Vector2.ZERO

func movement(delta: float) -> void:
	if dying:
		return
	if !nav.is_navigation_finished():
		var direction = position.direction_to(nav.get_next_path_position())
		position += direction * acceleration * delta


# Signals
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
		velocity = safe_velocity


func _on_attack_cooldown_timeout() -> void:
	for target in attack_radius.collision_result:
		if target.collider is Unit and target.collider.team != team and !target.collider.dying:
			var m = missile.instantiate()
			m.damage *= damage_multiplier
			m.set_target(position, target.collider.position)
			m.team = team
			add_sibling(m)
			return


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		queue_free()


func _on_mouse_entered() -> void:
	if !selected:
		header.visible = true


func _on_mouse_exited() -> void:
	if !selected:
		header.visible = false


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		select_event.emit(self)
