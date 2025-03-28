extends Node

signal update_player_list

const GRID: Vector2i = Vector2i(64, 32)

var p = preload("res://core/player.tscn")

@export var active_player: int = 1

@onready var music_manager = $MusicManager
@onready var screen_size: Vector2i = get_viewport().get_visible_rect().size
@onready var players = $Players

var camera: Camera2D = null
var map: TileMapLayer = null

var nexuses: Dictionary = {  }
var scroll_speed: int = 2048


# Engine
func _ready() -> void:
	get_tree().get_root().size_changed.connect(resize)
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CONFINED)


# Public
func add_player(id: int) -> void:
	var new_player = p.instantiate()
	new_player.player_id = id
	players.add_child(new_player, true)
	update_player_list.emit()

func del_player(id: int) -> void:
	get_player(id).queue_free()
	update_player_list.emit()

func clear_players() -> void:
	for player in players.get_children():
		player.queue_free()

func add_nexus(id: int):
	if !nexuses.has(id):
		nexuses[id] = 0
	nexuses[id] += 1

func remove_nexus(id: int):
	nexuses[id] -= 1
	var active: Array[int] = [  ]
	for nexus in nexuses.keys():
		if nexuses[nexus] > 0:
			active.push_back(nexus)
	if active.size() == 1:
		get_tree().current_scene.end_game(get_player(active[0]))


# Private
@rpc("any_peer", "reliable")
func _handoff(node_name: String) -> void:
	var node
	var count = 0
	@warning_ignore("unassigned_variable")
	while node == null:
		if $Players.has_node(node_name):
			node = $Players.get_node(node_name)
		count += 1
		if count > 10:
			print("COULD NOT FIND NODE")
			return
		await get_tree().create_timer(0.1).timeout
	node.set_multiplayer_authority(node.player_id)


# Util
func resize() -> void:
	screen_size = get_viewport().get_visible_rect().size

func camera_offset(target: Vector2) -> Vector2:
	return ((target - Vector2( screen_size / 2 )) / camera.zoom) + camera.position

func get_player(player_id: int):
	for player in players.get_children():
		if player.player_id == player_id:
			return player
	return null


# Signal
func _on_multiplayer_spawner_spawned(node: Node) -> void:
	_handoff.rpc(node.name)
	update_player_list.emit()


func _on_players_child_entered_tree(node: Node) -> void:
	_handoff.rpc(node.name)
	update_player_list.emit()
