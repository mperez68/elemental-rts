extends PanelContainer

var list: Array[String] = []

# Engine
func _ready() -> void:
	GameInfo.update_player_list.connect(_update)
	if GameInfo.players.get_child_count() > 1:
		$ConnectContainer.visible = false
		$Lobby.visible = true

# Private
func _update():
	%PlayerList.clear()
	for player in GameInfo.players.get_children():
		%PlayerList.add_item(str(player.player_id))

@rpc("any_peer", "reliable")
func _show_hud():
	%Margins.visible = true
	visible = false


# Signals
func _on_start_button_pressed() -> void:
	_show_hud()
	_show_hud.rpc()
	var count = 0
	for player in GameInfo.players.get_children():
		if count >= GameInfo.map.start_locations.size():
			return
		var nexus = load("res://units/Buildings/nexus.tscn").instantiate()
		nexus.player_id = player.player_id
		nexus.position = GameInfo.map.start_locations[count]
		count += 1
		player.spawn_unit(nexus)
		if GameInfo.active_player == player.player_id:
			GameInfo.camera. position = nexus.position


# 	Host
func _on_host_button_pressed() -> void:
	$ConnectContainer.visible = false
	%LoadingText.visible = true
	await get_tree().create_timer(0.1).timeout
	%IpText.text = "Hosting at address: " + MultiplayerManager.host_session(false)
	%LoadingText.visible = false
	$Lobby.visible = true
	$Lobby/VBoxContainer/StartButton.disabled = false

func _on_host_local_button_pressed() -> void:
	$ConnectContainer.visible = false
	MultiplayerManager.host_session(true)
	%IpText.text = "Hosting Local Game"
	$Lobby.visible = true
	$Lobby/VBoxContainer/StartButton.disabled = false

# 	Join
func _on_join_button_pressed() -> void:
	$ConnectContainer.visible = false
	if %TextEdit.text != "":
		MultiplayerManager.join_session(%TextEdit.text)
	else:
		print("NO ADDRESS INPUT")
	$Lobby.visible = true

func _on_join_local_button_pressed() -> void:
	$ConnectContainer.visible = false
	MultiplayerManager.join_session(MultiplayerManager.LOCAL_HOST_ADDRESS)
	$Lobby.visible = true


func _on_back_pressed() -> void:
	$Lobby.visible = false
	$ConnectContainer.visible = true
	MultiplayerManager.end_session()
