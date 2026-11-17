extends CharacterBody2D
## Joueur 16x20 : animation de marche, nom au-dessus, perso choisi en création.

const PERSOS = preload("res://scripts/Persos.gd")
const VITESSE: float = 90.0
const VITESSE_ANIM: float = 7.0
const ORDRE_MARCHE: Array[int] = [0, 1, 2, 1]

@onready var sprite: Sprite2D = $Sprite2D
@onready var label_nom: Label = $LabelNom

var _feuille: Texture2D
var _image_feuille: Image
var _direction: String = "bas"
var _etape: int = 0
var _temps: float = 0.0


func _ready() -> void:
	var donnees: Dictionary = Donnees.joueur_data
	var index: int = int(donnees.get("perso", 1))
	_feuille = load(PERSOS.chemin(index)) as Texture2D
	if _feuille != null:
		_image_feuille = _feuille.get_image()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	label_nom.text = str(donnees.get("name", "Joueur"))
	label_nom.visible = false
	_maj_frame()


func _process(_delta: float) -> void:
	label_nom.visible = _pixel_visible_sous_souris()


func _pixel_visible_sous_souris() -> bool:
	if _image_feuille == null or _image_feuille.is_empty() or sprite.texture == null:
		return false

	# On convertit la souris dans le repère local du sprite.
	var souris_locale: Vector2 = sprite.to_local(get_global_mouse_position())
	var rectangle: Rect2 = sprite.get_rect()
	if not rectangle.has_point(souris_locale):
		return false

	# Le sprite affiche une seule frame de 16x20 découpée dans la feuille.
	var taille: Vector2i = PERSOS.TAILLE_CASE
	var pixel_x: int = floori((souris_locale.x - rectangle.position.x) / rectangle.size.x * taille.x)
	var pixel_y: int = floori((souris_locale.y - rectangle.position.y) / rectangle.size.y * taille.y)
	if pixel_x < 0 or pixel_x >= taille.x or pixel_y < 0 or pixel_y >= taille.y:
		return false

	var colonne: int = ORDRE_MARCHE[_etape]
	var ligne: int = PERSOS.ligne(_direction)
	var pixel_feuille_x: int = colonne * taille.x + pixel_x
	var pixel_feuille_y: int = ligne * taille.y + pixel_y
	if pixel_feuille_x >= _image_feuille.get_width() or pixel_feuille_y >= _image_feuille.get_height():
		return false

	# Un pixel transparent ne déclenche pas l'affichage du nom.
	return _image_feuille.get_pixel(pixel_feuille_x, pixel_feuille_y).a > 0.0


func _physics_process(delta: float) -> void:
	var dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * VITESSE
	move_and_slide()

	if dir != Vector2.ZERO:
		_direction = _direction_depuis(dir)
		_temps += delta
		if _temps >= 1.0 / VITESSE_ANIM:
			_temps = 0.0
			_etape = (_etape + 1) % ORDRE_MARCHE.size()
	else:
		# À l'arrêt : frame de repos (colonne du milieu)
		_etape = 1
		_temps = 0.0
	_maj_frame()


func _direction_depuis(dir: Vector2) -> String:
	if absf(dir.x) > absf(dir.y):
		return "droite" if dir.x > 0.0 else "gauche"
	return "bas" if dir.y > 0.0 else "haut"


func _maj_frame() -> void:
	if _feuille == null:
		return
	var colonne: int = ORDRE_MARCHE[_etape]
	sprite.texture = PERSOS.frame(_feuille, colonne, PERSOS.ligne(_direction))
