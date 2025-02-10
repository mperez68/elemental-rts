extends NinePatchRect

signal update_cards(selection: Array[Unit])

func _ready() -> void:
	%MultiplayerContainer.visible = true
	%Margins.visible = false


func update(selection: Array[Unit]):
	update_cards.emit(selection)


func _on_mouse_entered(direction: Vector2i) -> void:
	GameInfo.camera.hud_scroll_vector += direction


func _on_mouse_exited(direction: Vector2i) -> void:
	GameInfo.camera.hud_scroll_vector -= direction


func _on_menu_button_pressed() -> void:
	print("In-Game Menu")
