extends Control

const COLOR_BG      := Color("#0a0f1f")
const COLOR_NEON    := Color("#19d3ff")
const COLOR_ORANGE  := Color("#ff9a3c")
const COLOR_GRID    := Color(0.1, 0.8, 1.0, 0.12)
const PROFILE_PICKER_PATH := "res://scripts/profile_picker.gd"
const GAME_SCENE := "res://scenes/zones/zone1/FileCity_TownSquare.tscn"
const NEW_GAME_SCENE := "res://scenes/creation/CharacterCreation.tscn"

# Les références sont récupérées prudemment : la scène peut être incomplète
# pendant l'édition ou l'autoload Donnees peut ne pas être configuré.
var grid: Control
var logo: Label
var subtitle: Label
var btn_new: Button
var btn_continue: Button
var btn_library: Button
var btn_settings: Button
var btn_quit: Button
var fade: ColorRect
var menu: VBoxContainer
var version_label: Label

var _grid_offset := 0.0
var _profile_picker: Control
var _donnees: Node
var _game_state: Node

func _ready() -> void:
	grid = get_node_or_null("Grid") as Control
	logo = get_node_or_null("Title/Logo") as Label
	subtitle = get_node_or_null("Title/SubTitle") as Label
	btn_new = get_node_or_null("Menu/BtnNew") as Button
	btn_continue = get_node_or_null("Menu/BtnContinue") as Button
	btn_library = get_node_or_null("Menu/BtnLibrary") as Button
	btn_settings = get_node_or_null("Menu/BtnSettings") as Button
	btn_quit = get_node_or_null("Menu/BtnQuit") as Button
	fade = get_node_or_null("Fade") as ColorRect
	menu = get_node_or_null("Menu") as VBoxContainer
	version_label = get_node_or_null("Version") as Label
	_donnees = get_node_or_null("/root/Donnees")
	_game_state = get_node_or_null("/root/GameState")

	var background := get_node_or_null("Background") as ColorRect
	if background != null:
		background.color = COLOR_BG
	_setup_texts()
	_setup_style()
	_connect_buttons()
	_refresh_buttons()
	if grid != null and not grid.draw.is_connected(_draw_grid):
		grid.draw.connect(_draw_grid)
	_play_intro()

func _process(delta: float) -> void:
	_grid_offset = fmod(_grid_offset + delta * 20.0, 48.0)
	if is_instance_valid(grid):
		grid.queue_redraw()

# --- Textes ---
func _setup_texts() -> void:
	if logo != null:
		logo.text = "DigimonX"
	if subtitle != null:
		subtitle.text = "A D V E N T U R E S"
	if btn_new != null:
		btn_new.text = "Nouvelle partie"
	if btn_continue != null:
		btn_continue.text = "Continuer"
	if btn_library != null:
		btn_library.text = "Librairie"
	if btn_settings != null:
		btn_settings.text = "Paramètres"
	if btn_quit != null:
		btn_quit.text = "Quitter"
	if version_label != null:
		version_label.text = "v0.1 By LipeStz"

# --- Style ---
func _setup_style() -> void:
	if logo != null:
		logo.add_theme_font_size_override("font_size", 72)
		logo.add_theme_color_override("font_color", COLOR_NEON)
		logo.add_theme_color_override("font_outline_color", Color.BLACK)
		logo.add_theme_constant_override("outline_size", 8)
		logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	if subtitle != null:
		subtitle.add_theme_font_size_override("font_size", 24)
		subtitle.add_theme_color_override("font_color", COLOR_ORANGE)
		subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	for button in [btn_new, btn_continue, btn_library, btn_settings, btn_quit]:
		if button != null:
			_style_button(button)

func _style_button(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.05, 0.1, 0.2, 0.85)
	normal.border_color = COLOR_NEON
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(6)

	var hover := normal.duplicate()
	hover.bg_color = Color(0.1, 0.25, 0.4, 0.95)
	hover.border_color = COLOR_ORANGE

	var pressed := normal.duplicate()
	pressed.bg_color = COLOR_ORANGE
	pressed.border_color = Color.WHITE

	var disabled := normal.duplicate()
	disabled.bg_color = Color(0.1, 0.1, 0.1, 0.5)
	disabled.border_color = Color(0.3, 0.3, 0.3)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.5))

# --- Fond animé ---
func _draw_grid() -> void:
	if not is_instance_valid(grid):
		return
	var size_v := grid.size
	var step := 48.0
	var x := -_grid_offset
	while x < size_v.x:
		grid.draw_line(Vector2(x, 0), Vector2(x, size_v.y), COLOR_GRID, 1.0)
		x += step
	var y := -_grid_offset
	while y < size_v.y:
		grid.draw_line(Vector2(0, y), Vector2(size_v.x, y), COLOR_GRID, 1.0)
		y += step

# --- Intro animée ---
func _play_intro() -> void:
	if is_instance_valid(fade):
		fade.color = Color(0, 0, 0, 1)
	if is_instance_valid(logo):
		logo.modulate.a = 0.0
	if is_instance_valid(subtitle):
		subtitle.modulate.a = 0.0
	if is_instance_valid(menu):
		menu.modulate.a = 0.0

	var tween := create_tween()
	if is_instance_valid(fade):
		tween.tween_property(fade, "color:a", 0.0, 0.8)
	if is_instance_valid(logo):
		tween.tween_property(logo, "modulate:a", 1.0, 0.8)
	if is_instance_valid(subtitle):
		tween.tween_property(subtitle, "modulate:a", 1.0, 0.5)
	if is_instance_valid(menu):
		tween.tween_property(menu, "modulate:a", 1.0, 0.5)

# --- Boutons ---
func _connect_buttons() -> void:
	if btn_new != null:
		btn_new.pressed.connect(_on_new)
	if btn_continue != null:
		btn_continue.pressed.connect(_on_continue)
	if btn_library != null:
		btn_library.pressed.connect(_on_library)
	if btn_settings != null:
		btn_settings.pressed.connect(_on_settings)
	if btn_quit != null:
		btn_quit.pressed.connect(_on_quit)

func _refresh_buttons() -> void:
	if btn_continue != null:
		btn_continue.disabled = _charger_profils().is_empty()
	if btn_library != null:
		btn_library.disabled = true
	if btn_settings != null:
		btn_settings.disabled = true

func _charger_profils() -> Array:
	if not is_instance_valid(_donnees) or not _donnees.has_method("charger_profils"):
		return []
	var result: Variant = _donnees.call("charger_profils")
	return result if result is Array else []

func _on_new() -> void:
	if is_instance_valid(_game_state) and _game_state.has_method("reset"):
		_game_state.call("reset")
	_change_scene(NEW_GAME_SCENE)

func _on_continue() -> void:
	if _charger_profils().is_empty():
		_refresh_buttons()
		return
	if is_instance_valid(_profile_picker):
		return
	if not ResourceLoader.exists(PROFILE_PICKER_PATH):
		push_warning("Sélecteur de profils introuvable : " + PROFILE_PICKER_PATH)
		return
	var picker_script := load(PROFILE_PICKER_PATH) as Script
	if picker_script == null:
		push_warning("Impossible de charger le sélecteur de profils.")
		return
	var picker := picker_script.new() as Control
	if picker == null:
		push_warning("Le sélecteur de profils n'est pas un Control.")
		return
	picker.name = "ProfilePicker"
	picker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if picker.has_signal("profile_chosen"):
		picker.connect("profile_chosen", Callable(self, "_on_profile_chosen"))
	if picker.has_signal("dismissed"):
		picker.connect("dismissed", Callable(self, "_on_profile_picker_dismissed"))
	picker.tree_exited.connect(_on_profile_picker_dismissed)
	_profile_picker = picker
	add_child(picker)

func _on_profile_chosen(profile: Dictionary) -> void:
	if not is_instance_valid(_donnees) or not _donnees.has_method("activer_profil"):
		push_warning("Autoload Donnees absent ou sans méthode activer_profil().")
		return
	_donnees.call("activer_profil", profile)
	_change_scene(GAME_SCENE)

func _on_profile_picker_dismissed() -> void:
	_profile_picker = null

func _on_library() -> void:
	print("Librairie : à venir")

func _on_settings() -> void:
	print("Paramètres : à venir")

func _on_quit() -> void:
	get_tree().quit()

# --- Transition ---
func _change_scene(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_warning("res://scenes/zones/zone1/FileCity_TownSquare.tscn" + path)
		return
	if not is_instance_valid(fade):
		get_tree().change_scene_to_file(path)
		return
	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.5)
	tween.tween_callback(func(): get_tree().change_scene_to_file(path))
