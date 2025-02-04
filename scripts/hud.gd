extends NinePatchRect


func _on_mouse_entered(direction: Vector2i) -> void:
	GameInfo.camera.hud_scroll_vector += direction


func _on_mouse_exited(direction: Vector2i) -> void:
	GameInfo.camera.hud_scroll_vector -= direction


func _on_menu_button_pressed() -> void:
	print("In-Game Menu")
