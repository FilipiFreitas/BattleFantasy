# HeroCard.gd - VERSÃO BLINDADA
class_name HeroCard
extends Control

const CARD_W = 120
const CARD_H = 180

var _fighter: Fighter

func _ready() -> void:
	custom_minimum_size = Vector2(CARD_W, CARD_H)
	size = Vector2(CARD_W, CARD_H)
	_build_fallback_ui()

func setup(f: Fighter) -> void:
	_fighter = f
	_build_fallback_ui()

func _build_fallback_ui() -> void:
	for c in get_children(): c.queue_free()
	
	# Fundo Sólido (Garante Visibilidade)
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = _get_element_color()
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	
	# Borda Nítida
	var border = ReferenceRect.new()
	border.set_anchors_preset(Control.PRESET_FULL_RECT)
	border.border_color = Color.WHITE
	border.border_width = 4.0
	border.editor_only = false
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(border)
	
	# Nome do Herói
	if _fighter:
		var lbl = Label.new()
		lbl.text = _fighter.display_name
		lbl.position = Vector2(0, CARD_H - 40)
		lbl.size = Vector2(CARD_W, 20)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.add_theme_color_override("font_outline_color", Color.BLACK)
		lbl.add_theme_constant_override("outline_size", 4)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(lbl)																																																
		
		# Tipo do elemento (topo)
		var type_lbl = Label.new()
		type_lbl.text = _fighter.fighter_type
		type_lbl.position = Vector2(4, 4)
		type_lbl.add_theme_font_size_override("font_size", 10)
		type_lbl.add_theme_color_override("font_outline_color", Color.BLACK)
		type_lbl.add_theme_constant_override("outline_size", 3)
		type_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(type_lbl)

func _get_element_color() -> Color:
	if not _fighter: return Color(0.2, 0.2, 0.2)
	match _fighter.fighter_type.to_upper():
		"FIRE": return Color(0.8, 0.2, 0.1)
		"WATER": return Color(0.1, 0.4, 0.8)
		"THUNDER": return Color(0.5, 0.3, 0.8)
		"ICE": return Color(0.3, 0.7, 0.9)
		"LIGHT": return Color(0.9, 0.8, 0.3)
		"DARK": return Color(0.3, 0.1, 0.4)
		"DRAGON": return Color(0.7, 0.5, 0.1)
		"GRASS": return Color(0.2, 0.6, 0.2)
		"PSYCHIC": return Color(0.7, 0.3, 0.6)
		"STONE": return Color(0.5, 0.4, 0.3)
		"FIGHTER": return Color(0.6, 0.2, 0.2)
		_: return Color(0.3, 0.3, 0.3)
