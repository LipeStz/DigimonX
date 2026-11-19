@tool
extends Node2D

@export var apparences: Array[BatimentApparence] = []:
	set(valeur):
		apparences = valeur
		_index_apparence = clampi(_index_apparence, 0, maxi(apparences.size() - 1, 0))
		_appliquer_apparence()

@export var index_apparence: int = 0:
	get:
		return _index_apparence
	set(valeur):
		_index_apparence = clampi(valeur, 0, maxi(apparences.size() - 1, 0))
		_appliquer_apparence()

@export var zone_size: Vector2 = Vector2(32.0, 32.0)
@export var zone_offset: Vector2 = Vector2(0.0, -16.0)
@export var alpha_translucide: float = 0.5
@export var duree_transition: float = 0.2

var _index_apparence: int = 0
var _zone: Area2D
var _transition: Tween


func _ready() -> void:
	_appliquer_apparence()
	if Engine.is_editor_hint():
		return

	_zone = Area2D.new()
	_zone.name = "ZoneTranslucidite"
	_zone.collision_layer = 0
	_zone.collision_mask = 0xFFFFFFFF
	add_child(_zone)

	var forme := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = zone_size
	forme.shape = rectangle
	forme.position = zone_offset
	_zone.add_child(forme)

	_zone.body_entered.connect(_a_entree_du_corps)
	_zone.body_exited.connect(_a_sortie_du_corps)


func _appliquer_apparence() -> void:
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite == null:
		return

	if apparences.is_empty():
		sprite.texture = null
		sprite.region_enabled = false
		sprite.region_rect = Rect2()
		return

	var index := clampi(_index_apparence, 0, apparences.size() - 1)
	var apparence := apparences[index]
	if apparence == null:
		sprite.texture = null
		sprite.region_enabled = false
		sprite.region_rect = Rect2()
		return

	sprite.texture = apparence.texture
	sprite.region_enabled = apparence.region.has_area()
	sprite.region_rect = apparence.region


func _a_entree_du_corps(corps: Node2D) -> void:
	if _est_joueur(corps):
		_animer_alpha(alpha_translucide)


func _a_sortie_du_corps(corps: Node2D) -> void:
	if _est_joueur(corps):
		_animer_alpha(1.0)


func _est_joueur(corps: Node2D) -> bool:
	return corps.is_in_group("joueur") or (corps is CharacterBody2D and corps.name == "Joueur")


func _animer_alpha(valeur: float) -> void:
	if _transition != null and _transition.is_running():
		_transition.kill()
	_transition = create_tween()
	_transition.tween_property(self, "modulate:a", valeur, duree_transition)
