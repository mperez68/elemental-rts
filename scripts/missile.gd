extends Area2D

var player_id = 0
@export var damage = 1
@export var speed = 1024
@export var elements: Array[Unit.Element]
const element_missiles: Array[String] = [ "none", "air", "earth", "fire", "water" ]
const hit_postfix: String = "_hit"

var velocity = Vector2.ZERO
var target: Unit
var last_position = position

# Engine
func _ready() -> void:
	if elements.is_empty():
		elements.push_back(Unit.Element.NONE)
	$AnimatedSprite2D.play(element_missiles[elements[0]])

func _process(delta: float) -> void:
	if target != null:
		rotation = position.direction_to(target.position).angle()
	last_position = position
	position += velocity * delta


# Public
func set_target(origin: Vector2, target_in: Vector2):
	position = origin
	rotation = origin.direction_to(target_in).angle()
	velocity = origin.direction_to(target_in) * speed
	last_position = position

func seek_target(origin: Vector2, target_in: Unit):
	set_target(origin, target_in.position)
	target = target_in

func set_element(new_elememntal_type: Unit.Element):
	elements.clear()
	elements.push_back(new_elememntal_type)

func put_elements(new_elememntal_type: Unit.Element):
	if !elements.has(new_elememntal_type):
		elements.push_back(new_elememntal_type)

# Signals
func _on_lifetime_timeout() -> void:
	$AnimatedSprite2D.play(element_missiles[elements[0]] + hit_postfix)

func _on_animated_sprite_2d_animation_finished() -> void:
	var anim: String = $AnimatedSprite2D.animation
	if anim.contains(hit_postfix) and multiplayer.is_server():
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area is UnitHitBox and area.unit.player_id != player_id:
		if multiplayer.is_server():
			area.unit.damage(damage)
		position = last_position
		velocity = Vector2.ZERO
		$AnimatedSprite2D.play(element_missiles[elements[0]] + hit_postfix)
		$Lifetime.stop()
