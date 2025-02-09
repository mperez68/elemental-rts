extends PanelContainer


# Host Signals
func _on_host_button_pressed() -> void:
	MultiplayerManager.host_session(false)
	visible = false

func _on_host_local_button_pressed() -> void:
	MultiplayerManager.host_session(true)
	visible = false


# Join Signals
func _on_join_button_pressed() -> void:
	if %TextEdit.text != "":
		MultiplayerManager.join_session(%TextEdit.text)
	else:
		print("NO ADDRESS INPUT")
	visible = false

func _on_join_local_button_pressed() -> void:
	MultiplayerManager.join_session(MultiplayerManager.LOCAL_HOST_ADDRESS)
	visible = false
