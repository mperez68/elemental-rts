extends Camera2D

const ZOOM_MAX = 1
const ZOOM_MIN = 0.7

var hud_scroll_vector: Vector2i = Vector2i.ZERO

@export var start_focus: Unit
@export var start_position: Vector2i

# Engine
func _ready() -> void:
	GameInfo.camera = self
	if start_focus != null:
		position = start_focus.position
	else:
		position = start_position

func _process(delta: float) -> void:
	var move: Vector2i = Vector2i.ZERO

	move += Vector2i.LEFT * int(Input.is_action_pressed("ui_left"))
	move += Vector2i.RIGHT * int(Input.is_action_pressed("ui_right"))
	move += Vector2i.UP * int(Input.is_action_pressed("ui_up"))
	move += Vector2i.DOWN * int(Input.is_action_pressed("ui_down"))
	
	position += (move + hud_scroll_vector) * delta * GameInfo.scroll_speed

func _input(event):
	# Scroll with mouse
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		position -= (event.relative * 1 / zoom)
		position_smoothing_enabled = false
	else:
		position_smoothing_enabled = true
	
	# Zoom
	if event is InputEventMouseButton and event.is_pressed():
		var result = zoom.x
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			result = min(zoom.x + 0.1, ZOOM_MAX)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			result = max(zoom.x - 0.1, ZOOM_MIN)
		zoom = Vector2(result, result)
