extends RefCounted
## Données des 8 persos jouables (sprites 16x20, 3 colonnes x 4 lignes).
## Utilisation : const PERSOS = preload("res://scripts/Persos.gd")

const DOSSIER: String = "res://sprites/joueur/"
const NOMBRE: int = 16
const TAILLE_CASE: Vector2i = Vector2i(16, 20)
const COLONNES: int = 3
## Ordre des lignes de la feuille (à corriger ici si le sens est faux au test).
const LIGNE_BAS: int = 0
const LIGNE_GAUCHE: int = 1
const LIGNE_DROITE: int = 2
const LIGNE_HAUT: int = 3
## Colonne 1 = pose immobile, colonnes 0 et 2 = pas.
const COLONNE_IMMOBILE: int = 1


## Chemin de la feuille d'un perso (index 1 à 8).
static func chemin(index: int) -> String:
	return DOSSIER + "perso_%d.png" % clampi(index, 1, NOMBRE)


## Chemin de la feuille du perso nu (aperçu avant choix).
static func chemin_nu() -> String:
	return DOSSIER + "perso_nude.png"


## Ligne de la feuille pour une direction : "bas", "gauche", "droite", "haut".
static func ligne(direction: String) -> int:
	match direction:
		"gauche":
			return LIGNE_GAUCHE
		"droite":
			return LIGNE_DROITE
		"haut":
			return LIGNE_HAUT
		_:
			return LIGNE_BAS


## Découpe une image (frame) d'une feuille : colonne 0 à 2, ligne 0 à 3.
static func frame(feuille: Texture2D, colonne: int, ligne_index: int) -> AtlasTexture:
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = feuille
	atlas.region = Rect2(
		Vector2(colonne * TAILLE_CASE.x, ligne_index * TAILLE_CASE.y),
		Vector2(TAILLE_CASE)
	)
	return atlas
