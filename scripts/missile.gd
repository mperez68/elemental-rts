extends Area2D

var team = 0
@export var damage = 1
@export var speed = 1024

var velocity = Vector2.ZERO

# Engine
func _process(delta: float) -> void:
	position += velocity * delta


# Public
func set_target(origin: Vector2, target: Vector2):
	position = origin
	rotation = origin.direction_to(target).angle()
	velocity = origin.direction_to(target) * speed

func seek_target(origin: Vector2, target: Unit):
	pass


# Signals
func _on_lifetime_timeout() -> void:
	$AnimatedSprite2D.play("hit")

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "hit":
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body is Unit and body.team != team:
		body.damage(damage)
		velocity = Vector2.ZERO
		$AnimatedSprite2D.play("hit")
		$Lifetime.stop()
