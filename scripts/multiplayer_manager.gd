extends Node

const SERVER_PORT = 5555
const LOCAL_HOST_ADDRESS = "localhost"

var _spawner: Node


# Public
func host_session(local: bool):
	print("HOST SESSION ON PORT %s" % SERVER_PORT)
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	_spawner = get_tree().current_scene.get_node("Units")
	
	multiplayer.peer_connected.connect(_connect)
	multiplayer.peer_disconnected.connect(_disconnect)
	
	_connect(1)
	
	if local:
		return LOCAL_HOST_ADDRESS
	else:
		return _upnp_setup()

func join_session(server_ip: String):
	print("JOINING P2P SESSION AT %s:%s" % [server_ip, SERVER_PORT])
	
	var client_peer = ENetMultiplayerPeer.new()
	
	client_peer.create_client(server_ip, SERVER_PORT)
	multiplayer.multiplayer_peer = client_peer
	
	GameInfo.active_player = multiplayer.get_unique_id()
	print("NEW PLAYER, ID:", GameInfo.active_player)

func end_session():
	print("leaving session")
	pass

# Private
func _upnp_setup():
	var upnp = UPNP.new()
	
	# Find address
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)
	
	# Validate gateway
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")
	
	# Port mapping
	var map_result = upnp.add_port_mapping(SERVER_PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	# Success, return valid address for display
	print("Success! Join Address: %s" % upnp.query_external_address())
	return upnp.query_external_address()


# Signals
func _connect(id: int):
	print("%s joining session" % id)
	GameInfo.add_player(id)


func _disconnect(id: int):
	print("%s leaving session" % id)
	GameInfo.del_player(id)
