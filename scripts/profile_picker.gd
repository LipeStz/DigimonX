extends Control
## Popup réutilisable de sélection/chargement des profils stockés par Donnees.

signal profile_chosen(profile: Dictionary)
signal dismissed

const UI_STYLE = preload("res://scripts/ui/UiStyle.gd")

var _list: VBoxContainer
var _empty_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	_refresh_profiles()


func _build_ui() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.055, 0.86)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520.0, 360.0)
	var panel_box: StyleBoxFlat = UI_STYLE.style_box(
		UI_STYLE.NAVY_DEEP, UI_STYLE.CYAN, 2, 14
	)
	panel.add_theme_stylebox_override("panel", panel_box)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)

	var title := Label.new()
	title.text = "Continuer — choisir un profil"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", UI_STYLE.CYAN)
	title.add_theme_font_size_override("font_size", 24)
	column.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 8)
	scroll.add_child(_list)
	_empty_label = Label.new()
	_empty_label.text = "Aucun profil enregistré."
	_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_label.add_theme_color_override("font_color", UI_STYLE.WHITE)
	column.add_child(_empty_label)

	var back := Button.new()
	back.text = "Retour"
	back.custom_minimum_size.y = 44.0
	UI_STYLE.apply_button(back)
	back.pressed.connect(_on_back_pressed)
	column.add_child(back)


func _refresh_profiles() -> void:
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	var profiles: Array[Dictionary] = Donnees.profils_tries()
	_empty_label.visible = profiles.is_empty()
	for profile: Dictionary in profiles:
		var name := str(profile.get("name", "Profil sans nom"))
		var stamp := Donnees.formater_date_profil(profile)
		var row := Button.new()
		row.text = "%s\n%s" % [name, stamp]
		row.custom_minimum_size.y = 64.0
		row.alignment = HORIZONTAL_ALIGNMENT_LEFT
		UI_STYLE.apply_button(row)
		row.pressed.connect(_on_profile_pressed.bind(profile.duplicate(true)))
		_list.add_child(row)


func _on_profile_pressed(profile: Dictionary) -> void:
	profile_chosen.emit(profile)
	queue_free()


func _on_back_pressed() -> void:
	dismissed.emit()
	queue_free()
