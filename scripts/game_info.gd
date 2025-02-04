extends Node

const GRID: Vector2i = Vector2i(64, 32)

@export var active_player: int = 0
var players: Array[Player] = [ Player.new(), Player.new() ]

@onready var music_manager = $MusicManager
@onready var screen_size: Vector2i = get_viewport().get_visible_rect().size
var camera: Camera2D = null
var map: TileMapLayer = null

var scroll_speed: int = 2048


# Engine
func _ready() -> void:
	get_tree().get_root().size_changed.connect(resize)
	music_manager.play(music_manager.THEME)
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CONFINED)


# Util
func resize() -> void:
	screen_size = get_viewport().get_visible_rect().size

func camera_offset(target: Vector2) -> Vector2:
	return ((target - Vector2( screen_size / 2 )) / camera.zoom) + camera.position


func _on_production_timer_timeout() -> void:
	for player in players:
		for producer in player.producers:
			player.aether += producer.aether_production
			player.empyrium += producer.empyrium_production
