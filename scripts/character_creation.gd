extends Control
## Création du personnage : nom + choix libre parmi 8 persos.
## Script à attacher à la racine Control de CharacterCreation.

const PERSOS = preload("res://scripts/Persos.gd")
const UI_STYLE = preload("res://scripts/ui/UiStyle.gd")
const BACKGROUND_SCRIPT = preload("res://scripts/FondCarreaux.gd")
const PREVIEW_PATH: NodePath = ^"Margin/Main/Content/PreviewColumn/PreviewCenter/CharacterPreview"
const FORM_PATH: String = "Margin/Main/Content/FormScroll/FormColumn"

var perso_choisi: int = 1
var boutons: Array[TextureButton] = []

@onready var name_input: LineEdit = get_node_or_null(NodePath(FORM_PATH + "/NameInput")) as LineEdit
@onready var style_grid: GridContainer = get_node_or_null(NodePath(FORM_PATH + "/StyleGrid")) as GridContainer
@onready var validate_button: Button = get_node_or_null(NodePath(FORM_PATH + "/ValidateButton")) as Button
@onready var character_preview: Node2D = get_node_or_null(PREVIEW_PATH) as Node2D


func _ready() -> void:
	_installer_fond()
	_masquer_anciens_noeuds()
	if name_input == null or style_grid == null or validate_button == null or character_preview == null:
		push_error("CharacterCreation : NameInput, StyleGrid, ValidateButton ou CharacterPreview introuvable.")
		return
	character_preview.call("initialiser_apercu")
	UI_STYLE.apply_line_edit(name_input)
	UI_STYLE.apply_button(validate_button)
	var titre := get_node_or_null("Margin/Main/TitleLabel") as Label
	if titre != null:
		titre.add_theme_color_override("font_color", UI_STYLE.CYAN)
	_construire_grille()
	validate_button.pressed.connect(_on_validate_pressed)
	_choisir(1)


func _installer_fond() -> void:
	var fond := Control.new()
	fond.name = "FondCarreauxAnime"
	fond.set_script(BACKGROUND_SCRIPT)
	add_child(fond)
	move_child(fond, 0)
	var ancien := get_node_or_null("Background") as ColorRect
	if ancien != null:
		ancien.color = Color(0.031, 0.051, 0.102, 0.0)


## Masque les anciens contrôles (sexe, onglets, couleurs) devenus inutiles.
func _masquer_anciens_noeuds() -> void:
	for nom: String in ["GenderOption", "CategoryTabs", "ColorGrid", "GenderLabel", "SexeLabel", "SkinLabel", "ColorLabel", "CouleurLabel"]:
		var n := get_node_or_null(NodePath(FORM_PATH + "/" + nom)) as Control
		if n != null:
			n.visible = false
	# Masque aussi tout label dont le texte est "Sexe", "Couleur" ou "Style" hors grille
	var form := get_node_or_null(FORM_PATH)
	if form != null:
		for enfant: Node in form.get_children():
			if enfant is Label and enfant.text in ["Sexe", "Couleur"]:
				enfant.visible = false

func _construire_grille() -> void:
	for enfant: Node in style_grid.get_children():
		style_grid.remove_child(enfant)
		enfant.queue_free()
	boutons.clear()
	style_grid.columns = 4
	for i: int in range(1, PERSOS.NOMBRE + 1):
		var feuille: Texture2D = load(PERSOS.chemin(i)) as Texture2D
		var bouton: TextureButton = TextureButton.new()
		bouton.custom_minimum_size = Vector2(72.0, 90.0)
		bouton.ignore_texture_size = true
		bouton.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		bouton.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		bouton.toggle_mode = true
		bouton.tooltip_text = "Personnage %d" % i
		if feuille != null:
			var vignette: AtlasTexture = PERSOS.frame(feuille, PERSOS.COLONNE_IMMOBILE, PERSOS.LIGNE_BAS)
			bouton.texture_normal = vignette
			bouton.texture_hover = vignette
			bouton.texture_pressed = vignette
		UI_STYLE.apply_texture_button(bouton)
		bouton.pressed.connect(_choisir.bind(i))
		style_grid.add_child(bouton)
		boutons.append(bouton)


func _choisir(index: int) -> void:
	perso_choisi = index
	for i: int in range(boutons.size()):
		boutons[i].button_pressed = (i + 1 == index)
	character_preview.call("afficher_perso", index)


func _on_validate_pressed() -> void:
	if name_input.text.strip_edges().is_empty():
		push_warning("Saisissez un nom avant de valider.")
		name_input.grab_focus()
		return
	var donnees_joueur: Dictionary = {
		"name": name_input.text.strip_edges(),
		"perso": perso_choisi,
	}
	if not Donnees.sauvegarder_profil(donnees_joueur):
		push_warning("Profil non sauvegardé : vérifiez le nom et l'accès à user://profiles.json.")
		return
	Donnees.activer_profil(donnees_joueur)
	Donnees.sauvegarder_joueur(donnees_joueur)
	get_tree().change_scene_to_file("res://scenes/FileCity_TownSquare.tscn")
