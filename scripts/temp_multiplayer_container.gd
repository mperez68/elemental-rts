extends PanelContainer


# Host Signals
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


# Join Signals
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


func _on_start_button_pressed() -> void:
	_show_hud()
	_show_hud.rpc()
	#for player in GameInfo.players.get_children():
	var my_new_guy = load("res://units/Buildings/nexus.tscn").instantiate()
	my_new_guy.player_id = 1
	my_new_guy.position = Vector2(-256, 0)
	GameInfo.players.get_children()[0].spawn_unit(my_new_guy)
	
	var new_guy = load("res://units/Buildings/nexus.tscn").instantiate()
	new_guy.player_id = GameInfo.players.get_children()[1].player_id
	new_guy.position = Vector2(256, 0)
	GameInfo.players.get_children()[1].spawn_unit(new_guy)

@rpc("any_peer", "reliable")
func _show_hud():
	%Margins.visible = true
	visible = false
