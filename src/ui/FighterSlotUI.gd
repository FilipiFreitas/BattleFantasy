# FighterSlotUI.gd
class_name FighterSlotUI
extends Button

signal clicked(slot: FighterSlotUI)

var _card: HeroCard
var _hp_label: Label
var fighter: Fighter = null

var _tween_glow: Tween = null
var _active_turn_border: ReferenceRect
var _is_targeting_valid: bool = false

func _ready() -> void:
	# Configurações de Botão (Hitbox Principal)
	custom_minimum_size = Vector2(120, 200)
	size = Vector2(120, 200)
	flat = true
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# Usamos gui_input para ter controle absoluto sobre toque/mouse
	# pressed.connect(_on_pressed) removido para usar a abordagem mais agressiva abaixo.

	# Componentes Visuais
	_card = HeroCard.new()
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE # Deixa o clique passar para o botão (pai)
	add_child(_card)

	_hp_label = Label.new()
	_hp_label.position = Vector2(0, 185)
	_hp_label.size = Vector2(120, 20)
	_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hp_label.add_theme_font_size_override("font_size", 14)
	_hp_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_hp_label.add_theme_constant_override("outline_size", 4)
	_hp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hp_label)
	
	_active_turn_border = ReferenceRect.new()
	_active_turn_border.set_anchors_preset(Control.PRESET_FULL_RECT)
	_active_turn_border.border_color = Color(1.0, 0.8, 0.2, 1.0) # Dourado
	_active_turn_border.border_width = 5.0
	_active_turn_border.editor_only = false
	_active_turn_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_active_turn_border.visible = false
	add_child(_active_turn_border)
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _gui_input(event: InputEvent) -> void:
	# Captura tanto clique do mouse quanto toque na tela (Mobile)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var fn = fighter.display_name if fighter else "Slot Vazio"
		print("\n[FighterSlotUI] ---> GUI_INPUT DETECTADO NO SLOT: ", fn)
		clicked.emit(self)
		accept_event()
	elif event is InputEventScreenTouch and event.pressed:
		var fn = fighter.display_name if fighter else "Slot Vazio"
		print("\n[FighterSlotUI] ---> TOUCH DETECTADO NO SLOT: ", fn)
		clicked.emit(self)
		accept_event()

func setup(f: Fighter, _side: bool) -> void:
	fighter = f
	if _card:
		_card.setup(f)
	_update_hp()

func refresh() -> void:
	if fighter == null: return
	_update_hp()
	if not fighter.is_alive:
		# Efeito de Morte Dramático (Escala de cinza e desvanecimento)
		var t = create_tween()
		t.tween_property(self, "modulate", Color(0.15, 0.15, 0.15, 0.4), 0.8)
		t.parallel().tween_property(self, "scale", Vector2(0.95, 0.95), 0.8)
		disabled = true
		set_targeting_visual(false)
		set_active_turn_visual(false)

func _update_hp() -> void:
	if fighter:
		_hp_label.text = "HP: %d / %d" % [fighter.hp, fighter.hp_max]

# --- Feedback Visual de Target ---
func set_targeting_visual(active: bool) -> void:
	_is_targeting_valid = active
	if _tween_glow:
		_tween_glow.kill()
	
	if active:
		modulate = Color(1.2, 1.2, 1.2, 1.0) # Leve brilho inicial
		_tween_glow = create_tween().set_loops()
		_tween_glow.tween_property(self, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.5)
		_tween_glow.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
	else:
		if fighter and fighter.is_alive:
			modulate = Color.WHITE
		elif fighter and not fighter.is_alive:
			modulate = Color(0.15, 0.15, 0.15, 0.4)

func set_active_turn_visual(active: bool) -> void:
	if _active_turn_border:
		_active_turn_border.visible = active

func _on_mouse_entered() -> void:
	if _is_targeting_valid and fighter and fighter.is_alive:
		# Efeito de hover marcante quando é alvo válido
		if _tween_glow: _tween_glow.kill()
		modulate = Color(2.0, 0.5, 0.5, 1.0) # Vermelho de alvo

func _on_mouse_exited() -> void:
	if _is_targeting_valid and fighter and fighter.is_alive:
		# Retoma o pulso
		set_targeting_visual(true)
