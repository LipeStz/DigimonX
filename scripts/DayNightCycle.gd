extends Node
## Cycle jour/nuit avec teinte progressive du CanvasModulate.
signal time_changed(hour: float)
@export_range(0.0,24.0,0.1) var time_of_day: float = 12.0
@export_range(30.0,3600.0,1.0) var seconds_per_day: float = 600.0
@export var canvas_modulate_path: NodePath = NodePath("../CanvasModulate")
@export var town_path: NodePath = NodePath("..")
var _canvas: CanvasModulate
var _town: Node
func _ready() -> void:
    _canvas=get_node(canvas_modulate_path) as CanvasModulate; _town=get_node(town_path); _apply_time()
func _process(delta: float) -> void:
    time_of_day=fposmod(time_of_day+24.0*delta/seconds_per_day,24.0); _apply_time()
func set_time(value: float) -> void:
    time_of_day=fposmod(value,24.0); _apply_time()
func _apply_time() -> void:
    var night: bool = time_of_day<6.0 or time_of_day>=19.5
    if _canvas: _canvas.color=Color(0.38,0.48,0.78) if night else Color.WHITE
    if _town and _town.has_method("set_night_mode"): _town.set_night_mode(night)
    time_changed.emit(time_of_day)
