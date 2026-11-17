extends Control

const PANEL_SIZE: Vector2 = Vector2(192.0, 160.0)
const CELL_SIZE: float = 40.0
const CELL_GAP: float = 4.0
const GRID_POSITION: Vector2 = Vector2(32.0, 22.0)
const MAP_COLOR: Color = Color("#287e36")
const PATH_COLOR: Color = Color("#c29a5d")
const PLAYER_COLOR: Color = Color("#37e8ff")
const MAP_POSITIONS: Dictionary = {
	"Centre": Vector2i(1, 1),
	"Nord": Vector2i(1, 0),
	"Sud": Vector2i(1, 2),
	"Est": Vector2i(2, 1),
	"Ouest": Vector2i(0, 1),
}

@export var zone_title: String = "ZONE"
@export var map_position: Vector2i = Vector2i.ONE
@export var connected_directions: PackedStringArray = PackedStringArray()
## Taille de la carte en pixels (2304×1728 pour la zone 2 ; 1152×864 pour la zone 1).
@export var taille_carte: Vector2 = Vector2(72 * 32, 54 * 32)

@onready var player: Node2D = get_node("../../Joueur")


func _ready() -> void:
	custom_minimum_size = PANEL_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, PANEL_SIZE), Color("#080d1a", 0.92), true)
	draw_rect(Rect2(Vector2.ZERO, PANEL_SIZE), Color("#42d9e8"), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(8.0, 17.0), zone_title, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11, Color("#42d9e8"))

	for map_name: String in ["Ouest", "Nord", "Centre", "Sud", "Est"]:
		var cell_position: Vector2i = MAP_POSITIONS[map_name]
		var cell_rect: Rect2 = _cell_rect(cell_position)
		draw_rect(cell_rect, MAP_COLOR, true)
		draw_rect(cell_rect, Color("#b5e982"), false, 2.0)
		var map_label: String = map_name.left(1)
		draw_string(ThemeDB.fallback_font, cell_rect.position + Vector2(4.0, 11.0), map_label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9, Color("#d8f7a5"))

	var current_rect: Rect2 = _cell_rect(map_position)
	draw_rect(current_rect, Color("#f6a83a"), false, 2.0)

	var center: Rect2 = _cell_rect(Vector2i.ONE)
	for direction: String in connected_directions:
		var target: Vector2i = _direction_position(direction)
		var neighbour: Rect2 = _cell_rect(target)
		var bridge := _bridge_rect(center, neighbour, direction)
		draw_rect(bridge, PATH_COLOR, true)

	if is_instance_valid(player):
		var marker_rect: Rect2 = _cell_rect(map_position)
		var local_position := Vector2(
			clampf(player.position.x / taille_carte.x, 0.0, 1.0),
			clampf(player.position.y / taille_carte.y, 0.0, 1.0)
		)
		var marker_position: Vector2 = marker_rect.position + local_position * marker_rect.size
		draw_circle(marker_position, 5.0, Color.BLACK)
		draw_circle(marker_position, 3.0, PLAYER_COLOR)


func _cell_rect(pos: Vector2i) -> Rect2:
	return Rect2(GRID_POSITION + Vector2(pos) * (CELL_SIZE + CELL_GAP), Vector2(CELL_SIZE, CELL_SIZE))


func _direction_position(direction: String) -> Vector2i:
	match direction:
		"north":
			return Vector2i(1, 0)
		"south":
			return Vector2i(1, 2)
		"east":
			return Vector2i(2, 1)
		_:
			return Vector2i(0, 1)


func _bridge_rect(center: Rect2, neighbour: Rect2, direction: String) -> Rect2:
	match direction:
		"north":
			return Rect2(Vector2(center.get_center().x - 5.0, neighbour.end.y - 2.0), Vector2(10.0, CELL_GAP + 4.0))
		"south":
			return Rect2(Vector2(center.get_center().x - 5.0, center.end.y - 2.0), Vector2(10.0, CELL_GAP + 4.0))
		"east":
			return Rect2(Vector2(center.end.x - 2.0, center.get_center().y - 5.0), Vector2(CELL_GAP + 4.0, 10.0))
		_:
			return Rect2(Vector2(neighbour.end.x - 2.0, center.get_center().y - 5.0), Vector2(CELL_GAP + 4.0, 10.0))
