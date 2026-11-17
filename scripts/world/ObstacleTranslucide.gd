extends Node2D
## À attacher à un décor Node2D pour le rendre translucide au contact du joueur.

@export var zone_size: Vector2 = Vector2(32.0, 96.0)
@export var zone_offset: Vector2 = Vector2(0.0, -32.0)
@export var alpha_translucide: float = 0.5
@export var duree_transition: float = 0.2

var _zone: Area2D
var _transition: Tween


func _ready() -> void:
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
