extends Node2D

@export var map_width: int = 72
@export var map_height: int = 54
@export var zone_id: String = "Zone01"
@export var map_name: String = "Centre"
@export var map_title: String = "ZONE"
@export var zone_exit_scene: String = ""
@export var zone_exit_direction: String = "north"
@export var zone_exit_target: String = ""
@export var zone_exit_spawn: Vector2 = Vector2.ZERO
@export var north_scene: String = ""
@export var north_spawn: Vector2 = Vector2.ZERO
@export var north_gate_center: float = 0.0
@export var south_scene: String = ""
@export var south_spawn: Vector2 = Vector2.ZERO
@export var south_gate_center: float = 0.0
@export var east_scene: String = ""
@export var east_spawn: Vector2 = Vector2.ZERO
@export var east_gate_center: float = 0.0
@export var west_scene: String = ""
@export var west_spawn: Vector2 = Vector2.ZERO
@export var west_gate_center: float = 0.0
@export var persist_player_data: bool = false
@export var auto_save_player: bool = false

var player: CharacterBody2D


func _ready() -> void:
	player = get_node_or_null("Joueur") as CharacterBody2D
	if player == null:
		push_error("ZoneTransition attend un CharacterBody2D nommé Joueur.")
		return
	player.position = WorldNavigation.consume_spawn_position(player.position, zone_id + "_" + map_name)
	if persist_player_data:
		player.tree_exiting.connect(_save_player_data)
	if auto_save_player:
		var save_timer := Timer.new()
		save_timer.name = "SauvegardeAutomatique"
		save_timer.wait_time = 15.0
		save_timer.autostart = true
		save_timer.timeout.connect(_save_player_data)
		add_child(save_timer)
	if not player.tree_exited.is_connected(_stop_processing):
		player.tree_exited.connect(_stop_processing)
	set_process(true)


func _process(_delta: float) -> void:
	if player == null:
		return

	var pos: Vector2 = player.position
	var passage_half_width: float = 80.0

	var transition_margin: float = 24.0
	if _zone_exit_reached(pos, transition_margin):
		_change_zone(zone_exit_scene, zone_exit_spawn)
	elif north_scene != "" and pos.y <= transition_margin and absf(pos.x - north_gate_center) <= passage_half_width:
		_change_zone(north_scene, north_spawn)
	elif south_scene != "" and pos.y >= float(map_height * 32) - transition_margin and absf(pos.x - south_gate_center) <= passage_half_width:
		_change_zone(south_scene, south_spawn)
	elif east_scene != "" and pos.x >= float(map_width * 32) - transition_margin and absf(pos.y - east_gate_center) <= passage_half_width:
		_change_zone(east_scene, east_spawn)
	elif west_scene != "" and pos.x <= transition_margin and absf(pos.y - west_gate_center) <= passage_half_width:
		_change_zone(west_scene, west_spawn)


func _zone_exit_reached(pos: Vector2, margin: float) -> bool:
	if zone_exit_scene.is_empty():
		return false
	match zone_exit_direction:
		"north":
			return pos.y <= margin
		"south":
			return pos.y >= float(map_height * 32) - margin
		"east":
			return pos.x >= float(map_width * 32) - margin
		"west":
			return pos.x <= margin
	return false


func _stop_processing() -> void:
	set_process(false)


func _save_player_data() -> void:
	if player != null and is_instance_valid(player) and Donnees.joueur_data is Dictionary:
		Donnees.joueur_data["map"] = {
			"zone": zone_id,
					"map": map_name,
			"position": {"x": player.position.x, "y": player.position.y},
		}
		Donnees.sauvegarder_joueur(Donnees.joueur_data)


func _change_zone(scene_path: String, spawn_position: Vector2) -> void:
	WorldNavigation.set_spawn_position(spawn_position, scene_path)
	get_tree().change_scene_to_file(scene_path)
