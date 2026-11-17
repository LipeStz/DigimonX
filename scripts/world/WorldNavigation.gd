extends Node

var pending_spawn_position: Vector2 = Vector2.INF
var pending_spawn_scene: String = ""


func set_spawn_position(spawn_position: Vector2, target_scene: String = "") -> void:
	pending_spawn_position = spawn_position
	pending_spawn_scene = target_scene.get_file().get_basename() if target_scene.contains("/") else target_scene


func consume_spawn_position(default_position: Vector2, current_scene: String = "") -> Vector2:
	if pending_spawn_position == Vector2.INF:
		return default_position
	if not pending_spawn_scene.is_empty() and current_scene != pending_spawn_scene:
		return default_position

	var spawn_position: Vector2 = pending_spawn_position
	pending_spawn_position = Vector2.INF
	pending_spawn_scene = ""
	return spawn_position
