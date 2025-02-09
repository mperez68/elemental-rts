extends PanelContainer



func _on_host_button_pressed() -> void:
	MultiplayerManager.host_session()
	visible = false


func _on_join_button_pressed() -> void:
	MultiplayerManager.join_session()
	visible = false
