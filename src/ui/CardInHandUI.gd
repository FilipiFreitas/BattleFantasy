# CardInHandUI.gd
# Componente visual de uma carta na mão do jogador.
# Exibe: arte, nome, custo PT, tipo e efeito. Suporta hover/seleção.
class_name CardInHandUI
extends Control

var card: Card = null
var card_index: int = 0
var is_selected: bool = false
var is_playable: bool = true

signal card_clicked(index: int)

const TYPE_COLORS = {
	"FIRE": Color(1.0, 0.3, 0.1), "WATER": Color(0.2, 0.5, 1.0),
	"EARTH": Color(0.6, 0.4, 0.1), "THUNDER": Color(1.0, 0.9, 0.0),
	"ICE": Color(0.5, 0.9, 1.0), "PSYCHIC": Color(0.8, 0.2, 0.9),
	"LIGHT": Color(1.0, 1.0, 0.6), "DARK": Color(0.3, 0.1, 0.5),
	"DRAGON": Color(0.4, 0.1, 0.8), "FIGHTER": Color(0.9, 0.3, 0.3),
	"STONE": Color(0.5, 0.5, 0.5), "GRASS": Color(0.2, 0.8, 0.2),
	"ANY": Color(0.8, 0.8, 0.8),
}

const CARD_TYPE_ICONS = {
	"BOOST": "⚡", "HEAL": "💚", "EQUIPMENT": "🛡️", "FIELD": "🌐"
}

var _bg: PanelContainer
var _pt_cost_label: Label
var _art_rect: ColorRect
var _card_type_icon: Label
var _name_label: Label
var _desc_label: Label

func _ready() -> void:
	custom_minimum_size = Vector2(62, 90)
	_build_ui()
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_hover_start)
	mouse_exited.connect(_on_hover_end)

func _build_ui() -> void:
	_bg = PanelContainer.new()
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_bg)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	_bg.add_child(vbox)

	# Linha superior: custo PT + ícone tipo de carta
	var top_row = HBoxContainer.new()
	vbox.add_child(top_row)

	_pt_cost_label = Label.new()
	_pt_cost_label.add_theme_font_size_override("font_size", 11)
	_pt_cost_label.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
	top_row.add_child(_pt_cost_label)

	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(spacer)

	_card_type_icon = Label.new()
	_card_type_icon.add_theme_font_size_override("font_size", 10)
	top_row.add_child(_card_type_icon)

	# Arte da carta
	_art_rect = ColorRect.new()
	_art_rect.custom_minimum_size = Vector2(0, 40)
	_art_rect.color = Color(0.15, 0.15, 0.25)
	vbox.add_child(_art_rect)

	# Nome
	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 7)
	_name_label.add_theme_color_override("font_color", Color.WHITE)
	_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_name_label.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(_name_label)

	# Descrição breve
	_desc_label = Label.new()
	_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_desc_label.add_theme_font_size_override("font_size", 6)
	_desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.visible = false  # Mostrar só no hover
	vbox.add_child(_desc_label)

func setup(c: Card, index: int, current_pt: int) -> void:
	card = c
	card_index = index
	is_playable = current_pt >= c.pt_cost
	_refresh_visuals()

func _refresh_visuals() -> void:
	if card == null:
		return

	# Custo PT
	_pt_cost_label.text = "●%d" % card.pt_cost

	# Ícone do tipo de carta
	_card_type_icon.text = CARD_TYPE_ICONS.get(card.card_type, "?")

	# Nome
	_name_label.text = card.display_name

	# Descrição
	_desc_label.text = card.description

	# Cor da arte baseada no tipo de boost (ou tipo da carta)
	var color_key = card.boost_fighter_type if card.card_type == "BOOST" else "ANY"
	var art_color = TYPE_COLORS.get(color_key, Color(0.2, 0.2, 0.3))
	_art_rect.color = Color(art_color.r * 0.4, art_color.g * 0.4, art_color.b * 0.4)

	# Estilo da carta baseado em jogável/selecionada
	_update_style()

func _update_style() -> void:
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6

	if is_selected:
		style.bg_color = Color(0.2, 0.3, 0.5, 0.95)
		style.border_color = Color(0.3, 0.7, 1.0)
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_width_left = 2
		style.border_width_right = 2
	elif not is_playable:
		style.bg_color = Color(0.1, 0.1, 0.15, 0.7)
		style.border_color = Color(0.3, 0.3, 0.3)
		style.border_width_top = 1
		style.border_width_bottom = 1
		style.border_width_left = 1
		style.border_width_right = 1
		modulate.a = 0.5
	else:
		style.bg_color = Color(0.15, 0.15, 0.25, 0.95)
		style.border_color = Color(0.4, 0.4, 0.6)
		style.border_width_top = 1
		style.border_width_bottom = 1
		style.border_width_left = 1
		style.border_width_right = 1
		modulate.a = 1.0

	_bg.add_theme_stylebox_override("panel", style)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_playable:
			emit_signal("card_clicked", card_index)

func _on_hover_start() -> void:
	if not is_playable:
		return
	_desc_label.visible = true
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 12, 0.15)

func _on_hover_end() -> void:
	_desc_label.visible = false
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y + 12, 0.15)

func set_selected(selected: bool) -> void:
	is_selected = selected
	_update_style()
