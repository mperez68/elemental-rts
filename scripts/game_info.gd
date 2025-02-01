extends Node

var camera: Camera2D = null
@onready var screen_size: Vector2i = get_viewport().get_visible_rect().size

var scroll_speed: int = 1024

func _ready() -> void:
	get_tree().get_root().size_changed.connect(resize)

func resize() -> void:
	screen_size = get_viewport().get_visible_rect().size

func camera_offset(target: Vector2) -> Vector2:
	return ((target - Vector2( screen_size / 2 )) / camera.zoom) + camera.position
