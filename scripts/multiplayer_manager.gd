extends Node

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var _spawner

# Public
func host_session():
	print("HOST SESSION AT %s:%s" % [SERVER_IP, SERVER_PORT])
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	_spawner = get_tree().current_scene.get_node("Units")
	
	GameInfo.get_player(GameInfo.active_player).aether += 566
	multiplayer.peer_connected.connect(_connect)
	multiplayer.peer_disconnected.connect(_disconnect)

func join_session():
	print("JOIN P2P SESSION AT %s:%s" % [SERVER_IP, SERVER_PORT])
	
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	
	multiplayer.multiplayer_peer = client_peer
	print(multiplayer.get_unique_id())
	GameInfo.active_player = multiplayer.get_unique_id()


# Signals
func _connect(id: int):
	print("%s joining session" % id)
	
	GameInfo.add_player(id)
	
	var my_new_guy = load("res://units/sanctified.tscn").instantiate()
	my_new_guy.player_id = 1
	my_new_guy.element = Unit.Element.FIRE
	my_new_guy.position = Vector2(-256, 0)
	_spawner.add_child(my_new_guy, true)
	
	var new_guy = load("res://units/sanctified.tscn").instantiate()
	new_guy.player_id = id
	new_guy.element = Unit.Element.WATER
	new_guy.position = Vector2(256, 0)
	_spawner.add_child(new_guy, true)


func _disconnect(id: int):
	print("%s leaving session" % id)
	GameInfo.get_player(id).queue_free()
