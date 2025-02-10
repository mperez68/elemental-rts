extends PanelContainer

var list: Array[String] = []

# Engine
func _ready() -> void:
	GameInfo.update_player_list.connect(_update)

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


# 	Host
func _on_host_button_pressed() -> void:
	$ConnectContainer.visible = false
	MultiplayerManager.host_session(false)
	$Lobby.visible = true
	$Lobby/VBoxContainer/StartButton.visible = true

func _on_host_local_button_pressed() -> void:
	$ConnectContainer.visible = false
	MultiplayerManager.host_session(true)
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
