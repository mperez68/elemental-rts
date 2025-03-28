extends PanelContainer

@onready var master_slider = $MarginContainer/VBoxContainer/MasterAudio/HSlider
@onready var music_slider = $MarginContainer/VBoxContainer/MusicAudio/HSlider
@onready var sfx_slider = $MarginContainer/VBoxContainer/SFXAudio/HSlider



func _on_master_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)

func _on_music_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), value)

func _on_sfx_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sfx"), value)
