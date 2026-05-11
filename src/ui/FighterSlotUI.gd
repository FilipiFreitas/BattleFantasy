# FighterSlotUI.gd
# Componente visual de um lutador no campo de batalha.
# Exibe: portrait, nome, HP bar, tipo, status effects, cooldown visual.
class_name FighterSlotUI
extends Control

# ─────────────────────────────────────────
# NÓS INTERNOS
# ─────────────────────────────────────────
var _portrait: ColorRect          # Placeholder até ter sprite real
var _type_badge: Label
var _name_label: Label
var _hp_bar: ProgressBar
var _hp_label: Label
var _status_container: HBoxContainer
var _active_glow: Panel           # Destaque quando é o turno deste lutador
var _dead_overlay: ColorRect      # Overlay escuro ao morrer

var fighter: Fighter = null
var is_player_side: bool = true
var _is_targetable: bool = false

signal slot_clicked(slot: FighterSlotUI)

# Cores por tipo
const TYPE_COLORS = {
	"FIRE":    Color(1.0, 0.3, 0.1),
	"WATER":   Color(0.2, 0.5, 1.0),
	"EARTH":   Color(0.6, 0.4, 0.1),
	"THUNDER": Color(1.0, 0.9, 0.0),
	"ICE":     Color(0.5, 0.9, 1.0),
	"PSYCHIC": Color(0.8, 0.2, 0.9),
	"LIGHT":   Color(1.0, 1.0, 0.6),
	"DARK":    Color(0.3, 0.1, 0.5),
	"DRAGON":  Color(0.4, 0.1, 0.8),
	"FIGHTER": Color(0.9, 0.3, 0.3),
	"STONE":   Color(0.5, 0.5, 0.5),
	"GRASS":   Color(0.2, 0.8, 0.2),
}

const RARITY_COLORS = {
	"NORMAL":    Color(0.7, 0.7, 0.7),
	"RARE":      Color(0.2, 0.5, 1.0),
	"LEGENDARY": Color(1.0, 0.8, 0.0),
	"MYTHIC":    Color(0.9, 0.3, 1.0),
}

# ─────────────────────────────────────────
# INICIALIZAÇÃO
# ─────────────────────────────────────────
func _ready() -> void:
	_build_ui()
	_set_all_children_ignore(self)
	mouse_filter = Control.MOUSE_FILTER_STOP   # Root intercepta e processa o clique
	gui_input.connect(_on_gui_input)

# Garante que NENHUM filho consuma o clique. Assim o root Control recebe gui_input.
func _set_all_children_ignore(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_set_all_children_ignore(child)


func _build_ui() -> void:
	# Tamanho explícito no root é OBRIGATÓRIO para gui_input funcionar
	custom_minimum_size = Vector2(72, 115)
	size = Vector2(72, 115)

	# Fundo invisível para capturar cliques de forma confiável
	var click_bg = ColorRect.new()
	click_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	click_bg.color = Color(1, 1, 1, 0)
	click_bg.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(click_bg)

	# Container principal — PASS para não bloquear cliques no root
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 2)
	vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(vbox)

	# Glow de turno ativo (atrás de tudo)
	_active_glow = Panel.new()
	_active_glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var glow_style = StyleBoxFlat.new()
	glow_style.bg_color = Color(1.0, 0.9, 0.0, 0.0)
	glow_style.corner_radius_top_left = 8
	glow_style.corner_radius_top_right = 8
	glow_style.corner_radius_bottom_left = 8
	glow_style.corner_radius_bottom_right = 8
	_active_glow.add_theme_stylebox_override("panel", glow_style)
	add_child(_active_glow)
	_active_glow.z_index = -1

	# Badge de tipo (topo)
	_type_badge = Label.new()
	_type_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_type_badge.add_theme_font_size_override("font_size", 8)
	_type_badge.custom_minimum_size = Vector2(0, 14)
	vbox.add_child(_type_badge)

	# Portrait (placeholder colorido)
	_portrait = ColorRect.new()
	_portrait.custom_minimum_size = Vector2(72, 60)
	_portrait.color = Color(0.2, 0.2, 0.3)
	var portrait_container = PanelContainer.new()
	var portrait_style = StyleBoxFlat.new()
	portrait_style.bg_color = Color(0.1, 0.1, 0.2)
	portrait_style.corner_radius_top_left = 6
	portrait_style.corner_radius_top_right = 6
	portrait_container.add_theme_stylebox_override("panel", portrait_style)
	portrait_container.add_child(_portrait)
	vbox.add_child(portrait_container)

	# Nome
	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 7)
	_name_label.add_theme_color_override("font_color", Color.WHITE)
	_name_label.custom_minimum_size = Vector2(0, 12)
	_name_label.clip_text = true
	vbox.add_child(_name_label)

	# HP Bar
	_hp_bar = ProgressBar.new()
	_hp_bar.custom_minimum_size = Vector2(0, 8)
	_hp_bar.show_percentage = false
	var hp_style_bg = StyleBoxFlat.new()
	hp_style_bg.bg_color = Color(0.3, 0.0, 0.0)
	hp_style_bg.corner_radius_top_left = 4
	hp_style_bg.corner_radius_top_right = 4
	hp_style_bg.corner_radius_bottom_left = 4
	hp_style_bg.corner_radius_bottom_right = 4
	var hp_style_fill = StyleBoxFlat.new()
	hp_style_fill.bg_color = Color(0.0, 0.9, 0.3)
	hp_style_fill.corner_radius_top_left = 4
	hp_style_fill.corner_radius_top_right = 4
	hp_style_fill.corner_radius_bottom_left = 4
	hp_style_fill.corner_radius_bottom_right = 4
	_hp_bar.add_theme_stylebox_override("background", hp_style_bg)
	_hp_bar.add_theme_stylebox_override("fill", hp_style_fill)
	vbox.add_child(_hp_bar)

	# HP Label
	_hp_label = Label.new()
	_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hp_label.add_theme_font_size_override("font_size", 7)
	_hp_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vbox.add_child(_hp_label)

	# Status effects
	_status_container = HBoxContainer.new()
	_status_container.add_theme_constant_override("separation", 1)
	vbox.add_child(_status_container)

	# Overlay de morte
	_dead_overlay = ColorRect.new()
	_dead_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dead_overlay.color = Color(0.0, 0.0, 0.0, 0.7)
	_dead_overlay.visible = false
	add_child(_dead_overlay)

# ─────────────────────────────────────────
# CONFIGURAÇÃO COM DADOS DO LUTADOR
# ─────────────────────────────────────────
func setup(f: Fighter, player_side: bool) -> void:
	fighter = f
	is_player_side = player_side
	refresh()

	# Cor do tipo no badge e portrait
	var type_color = TYPE_COLORS.get(f.fighter_type, Color.WHITE)
	_type_badge.text = f.fighter_type
	_type_badge.add_theme_color_override("font_color", type_color)
	_portrait.color = Color(type_color.r * 0.3, type_color.g * 0.3, type_color.b * 0.3)

	# Cor da borda pela raridade
	var rarity_color = RARITY_COLORS.get(f.rarity, Color.WHITE)
	var border_style = StyleBoxFlat.new()
	border_style.bg_color = Color(0.1, 0.1, 0.2, 0.8)
	border_style.border_color = rarity_color
	border_style.border_width_top = 2
	border_style.border_width_bottom = 2
	border_style.border_width_left = 2
	border_style.border_width_right = 2
	border_style.corner_radius_top_left = 8
	border_style.corner_radius_top_right = 8
	border_style.corner_radius_bottom_left = 8
	border_style.corner_radius_bottom_right = 8
	add_theme_stylebox_override("panel", border_style)

# ─────────────────────────────────────────
# REFRESH — atualiza estado visual
# ─────────────────────────────────────────
func refresh() -> void:
	if fighter == null:
		return
	# HP
	_hp_bar.max_value = fighter.hp_max
	_hp_bar.value = fighter.hp
	_hp_label.text = "%d" % fighter.hp

	# HP bar muda de cor conforme percentual
	var hp_pct = float(fighter.hp) / float(fighter.hp_max)
	var fill_style = StyleBoxFlat.new()
	if hp_pct > 0.5:
		fill_style.bg_color = Color(0.0, 0.9, 0.3)
	elif hp_pct > 0.25:
		fill_style.bg_color = Color(1.0, 0.8, 0.0)
	else:
		fill_style.bg_color = Color(0.9, 0.2, 0.1)
	fill_style.corner_radius_top_left = 4
	fill_style.corner_radius_top_right = 4
	fill_style.corner_radius_bottom_left = 4
	fill_style.corner_radius_bottom_right = 4
	_hp_bar.add_theme_stylebox_override("fill", fill_style)

	# Nome curto
	var short_name = fighter.display_name.split("—")[0].strip_edges()
	_name_label.text = short_name

	# Morte
	_dead_overlay.visible = not fighter.is_alive

	# Status effects
	_refresh_status_icons()

func _refresh_status_icons() -> void:
	for child in _status_container.get_children():
		child.queue_free()
	for effect in fighter.status_effects:
		var icon = Label.new()
		icon.add_theme_font_size_override("font_size", 8)
		match effect["type"]:
			"BURN":     icon.text = "🔥"
			"FREEZE":   icon.text = "❄️"
			"CONFUSE":  icon.text = "🌀"
			"DRAIN":    icon.text = "🌑"
			"IMMUNITY": icon.text = "🛡️"
			"OVERLOAD": icon.text = "⚡"
			_:          icon.text = "?"
		_status_container.add_child(icon)

# ─────────────────────────────────────────
# ANIMAÇÕES
# ─────────────────────────────────────────
func set_active(is_active: bool) -> void:
	var glow_style = _active_glow.get_theme_stylebox("panel") as StyleBoxFlat
	if glow_style:
		glow_style.bg_color.a = 0.25 if is_active else 0.0

	if is_active:
		var tween = create_tween().set_loops()
		tween.tween_property(_active_glow, "modulate:a", 0.4, 0.6)
		tween.tween_property(_active_glow, "modulate:a", 1.0, 0.6)
	else:
		modulate = Color.WHITE

func flash_damage() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 0.2, 0.2), 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)

func flash_heal() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.2, 1.0, 0.4), 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.4)

# ─────────────────────────────────────────
# SELEÇÃO DE ALVO
# ─────────────────────────────────────────
func set_targetable(enabled: bool) -> void:
	_is_targetable = enabled
	var glow_style = StyleBoxFlat.new()
	glow_style.corner_radius_top_left = 8
	glow_style.corner_radius_top_right = 8
	glow_style.corner_radius_bottom_left = 8
	glow_style.corner_radius_bottom_right = 8

	if enabled:
		glow_style.bg_color = Color(0.8, 0.1, 0.1, 0.2)
		glow_style.border_color = Color(1.0, 0.3, 0.3, 0.7)
		glow_style.border_width_top = 2
		glow_style.border_width_bottom = 2
		glow_style.border_width_left = 2
		glow_style.border_width_right = 2
		_active_glow.add_theme_stylebox_override("panel", glow_style)
		_active_glow.visible = true
		mouse_default_cursor_shape = Control.CURSOR_CROSS
	else:
		glow_style.bg_color = Color(0, 0, 0, 0)
		_active_glow.add_theme_stylebox_override("panel", glow_style)
		mouse_default_cursor_shape = Control.CURSOR_ARROW

func set_selected_target(enabled: bool) -> void:
	var glow_style = StyleBoxFlat.new()
	glow_style.corner_radius_top_left = 8
	glow_style.corner_radius_top_right = 8
	glow_style.corner_radius_bottom_left = 8
	glow_style.corner_radius_bottom_right = 8

	if enabled:
		# Destaque dourado = alvo confirmado
		glow_style.bg_color = Color(1.0, 0.85, 0.0, 0.25)
		glow_style.border_color = Color(1.0, 0.9, 0.2)
		glow_style.border_width_top = 3
		glow_style.border_width_bottom = 3
		glow_style.border_width_left = 3
		glow_style.border_width_right = 3
		_active_glow.add_theme_stylebox_override("panel", glow_style)
		_active_glow.visible = true
		# Pulso dourado suave
		var tween = create_tween().set_loops()
		tween.tween_property(_active_glow, "modulate:a", 0.5, 0.3)
		tween.tween_property(_active_glow, "modulate:a", 1.0, 0.3)
	else:
		glow_style.bg_color = Color(0, 0, 0, 0)
		_active_glow.add_theme_stylebox_override("panel", glow_style)
		_active_glow.visible = false

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if _is_targetable and fighter != null and fighter.is_alive:
				emit_signal("slot_clicked", self)

