extends Area2D

var team = 0
@export var damage = 1
@export var speed = 1024

var velocity = Vector2.ZERO
var target: Unit
var last_position = position

# Engine
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


# Signals
func _on_lifetime_timeout() -> void:
	$AnimatedSprite2D.play("hit")

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "hit":
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area is UnitHitBox and area.unit.team != team:
		area.unit.damage(damage)
		position = last_position
		velocity = Vector2.ZERO
		$AnimatedSprite2D.play("hit")
		$Lifetime.stop()
