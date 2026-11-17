extends Node2D

@export var cible: Node2D
@export var distance_suivi: float = 48.0
@export var vitesse: float = 160.0
@export var id_digimon: String = "XKW02"
@export var echelle_sprite: float = 1.0

var donnees: Dictionary = {}
var sprite: Sprite2D

func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.name = "SpriteDigimon"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)

	donnees = Donnees.get_digimon(id_digimon)
	if donnees.is_empty():
		push_error("Digimon introuvable : " + id_digimon)
		return

	print("Partenaire : ", donnees["nom"], " | stade ", donnees["stade_nom"],
		" | type ", donnees["type"], " | puissance ", donnees["puissance"])

	_afficher_sprite()

	var hud = get_tree().current_scene.get_node("Interface/HUD")
	hud.afficher_partenaire.call_deferred(donnees)

func _afficher_sprite() -> void:
	var tex: Texture2D = Donnees.get_art(id_digimon)
	if tex == null:
		tex = Donnees.get_icone(id_digimon)
	if tex == null:
		push_warning("Aucun sprite pour : " + id_digimon)
		return
	sprite.texture = tex
	sprite.scale = Vector2(echelle_sprite, echelle_sprite)
	print("Sprite charge : ", tex.get_size())

func _physics_process(delta: float) -> void:
	if cible == null:
		return
	var ecart: Vector2 = cible.global_position - global_position
	if ecart.length() > distance_suivi:
		global_position += ecart.normalized() * vitesse * delta
