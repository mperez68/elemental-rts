extends CharacterBody2D
class_name Unit

enum WeaponType { NONE, MISSILE, HITSCAN }
enum TargetingType { SINGLE, MULTI }
enum Stance { BUILDING, AGGRESSIVE, DEFENSIVE, HOLD_FIRE }

signal select_event(this: Unit)

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var hl = $Highlight
@onready var header = $Header
@onready var hp_meter = $Header/Health
@onready var attack_radius = $AttackRange
@onready var attack_cooldown = $AttackCooldown
@onready var return_timer = $ReturnTimer
@onready var anim = $AnimationPlayer
@onready var missile_collision = $MissileCollision
@onready var unit_collision = $UnitCollision

var missile = preload("res://core/missile.tscn")

@export var team: int = 0
@export var max_hp: int = 10
@export var damage_multiplier: float = 1
@export var acceleration: float = 1024
@export var weapon_type: WeaponType = WeaponType.NONE
@export var targetting_type: TargetingType = TargetingType.SINGLE
@export var stance: Stance = Stance.AGGRESSIVE
@onready var hp: int = max_hp

static var priority_tie_break: int = 1

var flags: Dictionary = {
	"dying": false,
	"selected": false,
	"reveal": true,
	"multi_select": true
}

var collider_target: Vector2 = position
var last_targets: Array = [ ]


# Engine
func _ready() -> void:
	# set visibility by team
	flags["reveal"] = team == GameInfo.active_player
	if !flags["reveal"]:
		$Light.queue_free()
		header.visible = false
	route(position)
	# Set bars
	hp_meter.max_value = max_hp
	hp_meter.value = hp
	# Set missile collider center
	var vertices: PackedVector2Array = missile_collision.polygon
	var sum: Vector2 = Vector2.ZERO
	for vertex in vertices:
		sum += vertex
	sum = sum / vertices.size()
	collider_target = sum

func _process(delta: float) -> void:
	movement(delta)

func _draw() -> void:
	if nav.debug_enabled:
		draw_line(Vector2.ZERO, position.direction_to(nav.get_next_path_position()) * 32, Color.BLUE, 1)
		draw_circle(position.direction_to(nav.get_next_path_position()) * 32, 3, Color.BLACK)
		draw_line(Vector2.ZERO, velocity, Color.RED, 2)


# Public
func route(target: Vector2, clear_chase: bool = false):
	if clear_chase:
		last_targets.clear()
	nav.target_position = target

func select(enable: bool = true):
	flags["selected"] = enable
	hl.visible = enable
	header.visible = enable

func damage(dmg: int) -> void:
	hp -= dmg
	if hp <= 0:
		die()
	else:
		hp_meter.value = hp

func get_collider_position() -> Vector2:
	return collider_target + position

# Private
func die():
	$AttackCooldown.stop()
	flags["dying"] = true
	anim.play("die")
	header.visible = false
	hl.visible = false
	velocity = Vector2.ZERO

func movement(delta: float) -> void:
	# Dead men don't move
	if flags["dying"]:
		return
	
	if nav.is_navigation_finished():
		# If target reached, hang out unless we got pushed too far from away
		nav.avoidance_priority = 0.4
		if position.distance_to(nav.target_position) > GameInfo.GRID.length() / 8 and return_timer.is_stopped():
			return_timer.start()
	else:
		# Approach nav target
		priority_tie_break = (priority_tie_break + 1) % 100
		nav.avoidance_priority = 0.5 + (float(priority_tie_break) * 0.001)
		var direction = position.direction_to(nav.get_next_path_position())
		nav.set_velocity(direction * (acceleration * delta))
		if !attack_cooldown.is_stopped():
			attack_cooldown.stop()
	
	move_and_slide()

func _attack():
	var new_targets: Array = []
	for target in attack_radius.collision_result:
		if target.collider is Unit and target.collider.team != team and !target.collider.flags["dying"]:
			match weapon_type:
				WeaponType.MISSILE:
					_missile(target.collider)
				WeaponType.HITSCAN:
					_hit_scan(target.collider)
				_:
					print("no attack")
			new_targets.push_back(target.collider)
			if targetting_type == TargetingType.SINGLE:
				break
	# Chase/Stop when in range
	if stance == Stance.AGGRESSIVE and new_targets.is_empty():
			for unit in last_targets:
				if unit != null and unit.hp > 0 and !unit.flags["dying"]:
					route(unit.position - ( position.direction_to(unit.position) * (position.distance_to(unit.position) - attack_radius.shape.radius)))
					last_targets.clear()
					last_targets.push_back(unit)
					return
	last_targets.clear()
	last_targets = new_targets

func _missile(target: Unit):
	var m = missile.instantiate()
	m.damage *= damage_multiplier
	m.set_target(get_collider_position(), target.get_collider_position())
	m.team = team
	add_sibling(m)
	
func _hit_scan(target: Unit):
	var m = missile.instantiate()
	m.damage *= damage_multiplier
	m.set_target(target.position, target.get_collider_position())
	m.team = team
	m.z_index += 1
	add_sibling(m)

# Signals
func _on_attack_cooldown_timeout() -> void:
	# Simple Missile
	if nav.is_navigation_finished():
		_attack()
	else:
		attack_cooldown.stop()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		queue_free()

func _on_mouse_entered() -> void:
	if !flags["selected"]:
		header.visible = true

func _on_mouse_exited() -> void:
	if !flags["selected"]:
		header.visible = false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		select_event.emit(self)


func _on_navigation_finished() -> void:
	_on_attack_cooldown_timeout()
	attack_cooldown.start()


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity


func _on_return_timer_timeout() -> void:
	route(nav.target_position)
