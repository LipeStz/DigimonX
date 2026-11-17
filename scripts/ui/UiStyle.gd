extends RefCounted
## Styles communs pour le menu titre et les écrans de création.

const NAVY := Color("#0A1A33")
const NAVY_DEEP := Color("#0A0F1F")
const CYAN := Color("#19D3FF")
const ORANGE := Color("#FF9A3C")
const WHITE := Color("#F4F8FF")
const MUTED := Color("#8290A5")
const DISABLED_BG := Color("#202A3B")


static func style_box(
	background: Color = NAVY,
	border: Color = CYAN,
	border_width: int = 2,
	radius: int = 9
) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = background
	box.border_color = border
	box.set_border_width_all(border_width)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 12.0
	box.content_margin_right = 12.0
	box.content_margin_top = 7.0
	box.content_margin_bottom = 7.0
	return box


static func apply_button(button: Button) -> void:
	var normal := style_box()
	var hover := style_box(Color("#102B4E"), CYAN, 3, 9)
	var pressed := style_box(Color("#123B5A"), Color("#71E4FF"), 3, 9)
	var disabled := style_box(DISABLED_BG, Color("#465164"), 1, 9)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("hover_pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", WHITE)
	button.add_theme_color_override("font_hover_color", Color("#FFFFFF"))
	button.add_theme_color_override("font_pressed_color", Color("#FFFFFF"))
	button.add_theme_color_override("font_disabled_color", MUTED)
	button.add_theme_font_size_override("font_size", 18)
	button.focus_mode = Control.FOCUS_ALL


static func apply_option_button(option: OptionButton) -> void:
	apply_button(option)
	var popup := option.get_popup()
	popup.add_theme_stylebox_override("panel", style_box(NAVY_DEEP, CYAN, 2, 6))
	popup.add_theme_stylebox_override("hover", style_box(Color("#102B4E"), CYAN, 1, 4))
	popup.add_theme_color_override("font_color", WHITE)
	popup.add_theme_color_override("font_hover_color", Color("#FFFFFF"))
	popup.add_theme_color_override("font_disabled_color", MUTED)


static func apply_line_edit(edit: LineEdit) -> void:
	edit.add_theme_stylebox_override("normal", style_box(NAVY, Color("#55718D"), 1, 7))
	edit.add_theme_stylebox_override("focus", style_box(NAVY, CYAN, 2, 7))
	edit.add_theme_stylebox_override("read_only", style_box(DISABLED_BG, Color("#465164"), 1, 7))
	edit.add_theme_color_override("font_color", WHITE)
	edit.add_theme_color_override("font_placeholder_color", MUTED)
	edit.add_theme_color_override("caret_color", CYAN)


static func apply_texture_button(button: TextureButton) -> void:
	var normal := style_box(NAVY_DEEP, Color("#55718D"), 1, 7)
	var selected := style_box(Color("#102B4E"), CYAN, 2, 7)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", selected)
	button.add_theme_stylebox_override("pressed", selected)
	button.add_theme_stylebox_override("focus", selected)


static func apply_tree(root: Node) -> void:
	for node in root.find_children("*", "Control", true, false):
		if node is OptionButton:
			apply_option_button(node)
		elif node is LineEdit:
			apply_line_edit(node)
		elif node is Button:
			apply_button(node)
		elif node is TextureButton:
			apply_texture_button(node)
