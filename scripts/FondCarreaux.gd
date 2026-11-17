extends Control
## Reprend le fond du titre : bleu nuit, grille cyan fine, défilement diagonal lent.

@export var spacing: float = 48.0
@export var scroll_speed: float = 20.0
@export var grid_color: Color = Color(0.1, 0.8, 1.0, 0.12)
@export var background_color: Color = Color("#0A0F1F")

var _offset := Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	_offset.x = fposmod(_offset.x + scroll_speed * delta, spacing)
	_offset.y = fposmod(_offset.y + scroll_speed * delta, spacing)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), background_color, true)
	var x := -_offset.x
	while x < size.x:
		draw_line(Vector2(x, 0.0), Vector2(x, size.y), grid_color, 1.0)
		x += spacing
	var y := -_offset.y
	while y < size.y:
		draw_line(Vector2(0.0, y), Vector2(size.x, y), grid_color, 1.0)
		y += spacing
