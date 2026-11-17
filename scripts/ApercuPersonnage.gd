extends Node2D
## Aperçu animé d'un perso (sprites 16x20). À attacher à CharacterPreview (Node2D).

const PERSOS = preload("res://scripts/Persos.gd")
const VITESSE_ANIM: float = 6.0
const ORDRE_MARCHE: Array[int] = [0, 1, 2, 1]

@export_range(1.0, 8.0, 0.5) var echelle_apercu: float = 5.0

var perso_index: int = 0  ## 0 = perso nu, 1 à 8 = persos
var _sprite: Sprite2D
var _feuille: Texture2D
var _temps: float = 0.0
var _etape: int = 0
var _direction: String = "bas"
var _initialise: bool = false


func _ready() -> void:
	initialiser_apercu()


func initialiser_apercu() -> void:
	if _initialise:
		return
	_initialise = true
	_sprite = Sprite2D.new()
	_sprite.name = "Sprite"
	_sprite.centered = true
	_sprite.position = Vector2(0.0, -10.0)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_sprite)
	scale = Vector2.ONE * echelle_apercu
	afficher_perso(perso_index)


## index = 0 : perso nu, 1 à 8 : perso choisi.
func afficher_perso(index: int) -> void:
	perso_index = index
	var chemin: String = PERSOS.chemin_nu() if index <= 0 else PERSOS.chemin(index)
	_feuille = load(chemin) as Texture2D
	if _feuille == null:
		push_warning("Feuille introuvable : %s" % chemin)
		return
	_etape = 0
	_temps = 0.0
	_maj_frame()


func _process(delta: float) -> void:
	if _feuille == null:
		return
	_temps += delta
	if _temps >= 1.0 / VITESSE_ANIM:
		_temps = 0.0
		_etape = (_etape + 1) % ORDRE_MARCHE.size()
		_maj_frame()


func _maj_frame() -> void:
	var colonne: int = ORDRE_MARCHE[_etape]
	_sprite.texture = PERSOS.frame(_feuille, colonne, PERSOS.ligne(_direction))
