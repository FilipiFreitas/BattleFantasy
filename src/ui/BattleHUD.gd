# BattleHUD.gd — Layout Losango (4v4) conforme arte conceito
# ==============================================================================
# ATENÇÃO REDOBRADA (MENSAGEM PARA A IA):
# NÃO ALTERE AS POSIÇÕES, CONSTANTES DE FORMAÇÃO, TAMANHOS DE MARGINS OU ESTRUTURA
# DOS MENUS (_head_region, _field_region, _footer_region, _slot_layer).
# O LAYOUT ATUAL ESTÁ PERFEITO E DEFINITIVO. QUALQUER ALTERAÇÃO AQUI É PROIBIDA.
# ==============================================================================

class_name BattleHUD
extends CanvasLayer

const W: float = 720.0
const H: float = 1280.0

var _root: Control
var _main_layout: VBoxContainer
var _head_region: Panel
var _field_region: Control
var _footer_region: Panel
var _slot_layer: Control
var _skill_bar: HBoxContainer
var _battle_log: Label
var _round_label: Label
var _btn_attack: Button
var _turn_icons: Array[Panel] = []
var _pt_gems: Array[Panel] = []

var engine: BattleEngine = null
var _player_slots: Array[FighterSlotUI] = []
var _enemy_slots: Array[FighterSlotUI] = []

const FIELD_H: float = 960.0 # 1280 - 70 (head) - 250 (footer)

# Constantes de Formação (Losango 1-2-1)
const FORM_ALLY_CY: float = 612.0
const FORM_ENEMY_CY: float = 146.0
const FORM_DX: float = 160.0
const FORM_DY: float = 120.0
const FORM_OFFSET_X: float = 60.0 # Usado para ajustar o centro (W/2 - offset)

func _get_ally_pos(idx: int) -> Vector2:
	var cx: float = W / 2.0 - FORM_OFFSET_X
	var cy: float = FORM_ALLY_CY
	var dx: float = FORM_DX
	var dy: float = FORM_DY
	match idx:
		0: return Vector2(cx, cy - dy)
		1: return Vector2(cx - dx, cy)
		2: return Vector2(cx + dx, cy)
		3: return Vector2(cx, cy + dy)
		_: return Vector2(cx, cy)

func _get_enemy_pos(idx: int) -> Vector2:
	var cx: float = W / 2.0 - FORM_OFFSET_X
	var cy: float = FORM_ENEMY_CY
	var dx: float = FORM_DX
	var dy: float = FORM_DY
	match idx:
		0: return Vector2(cx, cy + dy)
		1: return Vector2(cx - dx, cy)
		2: return Vector2(cx + dx, cy)
		3: return Vector2(cx, cy - dy)
		_: return Vector2(cx, cy)

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	if _root: _root.queue_free()
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	# BG degradê
	var bg = TextureRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	var grad = GradientTexture2D.new()
	grad.gradient = Gradient.new()
	grad.gradient.set_color(0, Color(0.04, 0.04, 0.12))
	grad.gradient.set_color(1, Color(0.12, 0.04, 0.12))
	grad.fill = GradientTexture2D.FILL_RADIAL
	grad.fill_from = Vector2(0.5, 0.3)
	bg.texture = grad
	_root.add_child(bg)

	_main_layout = VBoxContainer.new()
	_main_layout.set_anchors_preset(Control.PRESET_FULL_RECT)
	_main_layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_main_layout.add_theme_constant_override("separation", 0)
	_root.add_child(_main_layout)

	# ── 1. HEAD REGION ──
	_head_region = Panel.new()
	_head_region.custom_minimum_size.y = 70
	var tb_st = StyleBoxFlat.new()
	tb_st.bg_color = Color(0, 0, 0, 0.75)
	tb_st.border_width_bottom = 2
	tb_st.border_color = Color(0.4, 0.3, 0.2)
	_head_region.add_theme_stylebox_override("panel", tb_st)
	_main_layout.add_child(_head_region)

	var tq_label = Label.new()
	tq_label.text = "Turn Order Queue"
	tq_label.position = Vector2(W / 2.0 - 80, 2)
	tq_label.add_theme_font_size_override("font_size", 11)
	tq_label.modulate = Color(0.7, 0.6, 0.5)
	_head_region.add_child(tq_label)

	var tq_hbox = HBoxContainer.new()
	tq_hbox.position = Vector2(20, 24)
	tq_hbox.add_theme_constant_override("separation", 6)
	_head_region.add_child(tq_hbox)
	_turn_icons.clear()
	for i in range(8):
		var icon = Panel.new()
		icon.custom_minimum_size = Vector2(36, 36)
		var ist = StyleBoxFlat.new()
		ist.bg_color = Color(0.2, 0.2, 0.3)
		ist.set_corner_radius_all(18)
		ist.set_border_width_all(2)
		ist.border_color = Color(0.4, 0.4, 0.5)
		icon.add_theme_stylebox_override("panel", ist)
		tq_hbox.add_child(icon)
		_turn_icons.append(icon)

	# ── 2. FIELD REGION ──
	_field_region = Control.new()
	_field_region.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_field_region.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_main_layout.add_child(_field_region)

	_slot_layer = Control.new()
	_slot_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_slot_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_field_region.add_child(_slot_layer)

	# ── LABEL ENEMY ──
	var enemy_lbl = Label.new()
	enemy_lbl.text = "ENEMY TEAM"
	enemy_lbl.position = Vector2(0, 10)
	enemy_lbl.size = Vector2(W - 20, 25)
	enemy_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	enemy_lbl.add_theme_font_size_override("font_size", 14)
	enemy_lbl.modulate = Color(1.0, 0.4, 0.4)
	enemy_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE # Garantia total
	_field_region.add_child(enemy_lbl)

	# ── LABEL ALLY TEAM ──
	var ally_lbl = Label.new()
	ally_lbl.text = "ALLY TEAM"
	ally_lbl.position = Vector2(20, FIELD_H - 40)
	ally_lbl.size = Vector2(200, 25)
	ally_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	ally_lbl.add_theme_font_size_override("font_size", 14)
	ally_lbl.modulate = Color(0.4, 0.8, 1.0)
	ally_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE # Garantia total
	_field_region.add_child(ally_lbl)

	# Battle log (centro do field)
	_battle_log = Label.new()
	_battle_log.set_anchors_preset(Control.PRESET_CENTER)
	_battle_log.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_battle_log.add_theme_font_size_override("font_size", 28)
	_battle_log.add_theme_constant_override("outline_size", 6)
	_battle_log.modulate.a = 0
	_battle_log.z_index = 4096 # Fica por cima de TUDO (cartas, background, etc)
	_battle_log.mouse_filter = Control.MOUSE_FILTER_IGNORE # <--- NUNCA BLOQUEAR CLIQUES
	_field_region.add_child(_battle_log)

	# ── 3. FOOTER REGION (BOTTOM PANEL) ──
	_footer_region = Panel.new()
	_footer_region.custom_minimum_size.y = 250
	_footer_region.z_index = 4000 # Fixa sempre sobre as cartas
	var foot_st = StyleBoxFlat.new()
	foot_st.bg_color = Color(0.02, 0.02, 0.06, 0.92)
	foot_st.border_width_top = 3
	foot_st.border_color = Color(0.4, 0.3, 0.2)
	_footer_region.add_theme_stylebox_override("panel", foot_st)
	_main_layout.add_child(_footer_region)

	var bp_margin = MarginContainer.new()
	bp_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	bp_margin.add_theme_constant_override("margin_left", 15)
	bp_margin.add_theme_constant_override("margin_right", 15)
	bp_margin.add_theme_constant_override("margin_top", 10)
	bp_margin.add_theme_constant_override("margin_bottom", 8)
	_footer_region.add_child(bp_margin)

	var bp_vbox = VBoxContainer.new()
	bp_vbox.add_theme_constant_override("separation", 6)
	bp_margin.add_child(bp_vbox)

	# Info bar (HP + Turn)
	var info_hbox = HBoxContainer.new()
	info_hbox.add_theme_constant_override("separation", 15)
	bp_vbox.add_child(info_hbox)

	# PT gems
	var pt_lbl = Label.new()
	pt_lbl.text = "PT"
	pt_lbl.add_theme_font_size_override("font_size", 12)
	pt_lbl.modulate = Color(0.5, 0.8, 1.0)
	info_hbox.add_child(pt_lbl)
	_pt_gems.clear()
	for i in range(10):
		var gem = Panel.new()
		gem.custom_minimum_size = Vector2(16, 16)
		var g_st = StyleBoxFlat.new()
		g_st.bg_color = Color(0.12, 0.12, 0.2)
		g_st.set_corner_radius_all(8)
		g_st.set_border_width_all(1)
		g_st.border_color = Color(0.3, 0.3, 0.4)
		gem.add_theme_stylebox_override("panel", g_st)
		info_hbox.add_child(gem)
		_pt_gems.append(gem)

	_round_label = Label.new()
	_round_label.text = "TURN 1"
	_round_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_round_label.add_theme_font_size_override("font_size", 14)
	_round_label.modulate = Color(0.9, 0.8, 0.5)
	info_hbox.add_child(_round_label)

	# Actions row: ATTACK | SKILLS | SUPPORT
	var actions = HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	actions.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bp_vbox.add_child(actions)

	# ATTACK
	_btn_attack = Button.new()
	_btn_attack.text = "ATTACK"
	_btn_attack.custom_minimum_size = Vector2(100, 80)
	var atk_st = StyleBoxFlat.new()
	atk_st.bg_color = Color(0.15, 0.2, 0.4)
	atk_st.set_corner_radius_all(10)
	atk_st.set_border_width_all(3)
	atk_st.border_color = Color(0.3, 0.5, 0.9)
	_btn_attack.add_theme_stylebox_override("normal", atk_st)
	_btn_attack.add_theme_font_size_override("font_size", 14)
	
	# Blindagem para Mobile Touch no botão ATTACK
	_btn_attack.gui_input.connect(func(event: InputEvent):
		if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed):
			print("[BattleHUD] ---> ATTACK BOTÃO GUI_INPUT DISPARADO")
			_btn_attack.accept_event()
			_on_attack_pressed()
	)
	
	actions.add_child(_btn_attack)

	# SKILLS container
	var skill_panel = VBoxContainer.new()
	skill_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(skill_panel)
	var skill_title = Label.new()
	skill_title.text = "SKILLS"
	skill_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skill_title.add_theme_font_size_override("font_size", 11)
	skill_title.modulate = Color(0.6, 0.6, 0.7)
	skill_panel.add_child(skill_title)
	_skill_bar = HBoxContainer.new()
	_skill_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	_skill_bar.add_theme_constant_override("separation", 6)
	_skill_bar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	skill_panel.add_child(_skill_bar)

	# SUPPORT placeholder
	var sup_btn = Button.new()
	sup_btn.text = "SUPPORT"
	sup_btn.custom_minimum_size = Vector2(80, 80)
	var sup_st = StyleBoxFlat.new()
	sup_st.bg_color = Color(0.15, 0.12, 0.08)
	sup_st.set_corner_radius_all(10)
	sup_st.set_border_width_all(2)
	sup_st.border_color = Color(0.5, 0.4, 0.2)
	sup_btn.add_theme_stylebox_override("normal", sup_st)
	sup_btn.add_theme_font_size_override("font_size", 12)
	actions.add_child(sup_btn)

	# Pré-cria 4+4 slots
	_player_slots.clear()
	_enemy_slots.clear()
	for i in range(4):
		var s = FighterSlotUI.new()
		s.visible = false
		s.clicked.connect(_on_slot_clicked)
		_slot_layer.add_child(s)
		_player_slots.append(s)
	for i in range(4):
		var s = FighterSlotUI.new()
		s.visible = false
		s.clicked.connect(_on_slot_clicked)
		_slot_layer.add_child(s)
		_enemy_slots.append(s)

# ─────────────────────────────────────────
func setup_battle(p_team: Array, e_team: Array, _f1: String, _f2: String) -> void:
	for i in range(p_team.size()):
		if i < _player_slots.size():
			_player_slots[i].setup(p_team[i], true)
			_player_slots[i].position = _get_ally_pos(i)
			_player_slots[i].z_index = int(_player_slots[i].position.y)
			_player_slots[i].visible = true
	for i in range(e_team.size()):
		if i < _enemy_slots.size():
			_enemy_slots[i].setup(e_team[i], false)
			_enemy_slots[i].position = _get_enemy_pos(i)
			_enemy_slots[i].z_index = int(_enemy_slots[i].position.y)
			_enemy_slots[i].visible = true

func connect_to_engine(eng: BattleEngine) -> void:
	engine = eng
	engine.turn_started.connect(_on_turn_started)
	engine.pt_updated.connect(_on_pt_updated)
	engine.damage_dealt.connect(_on_damage_dealt)
	engine.fighter_died.connect(_on_fighter_died)
	engine.battle_ended.connect(_on_battle_ended)
	engine.round_started.connect(_on_round_started)

# ─────────────────────────────────────────
# SISTEMA DE SINAIS MODULARES (Rule 7)
# ─────────────────────────────────────────

func register_skill_signals(skill: SkillResource) -> void:
	# Desconecta conexões antigas se houver (para evitar duplicatas)
	if skill.skill_activated.is_connected(_on_modular_skill_activated):
		skill.skill_activated.disconnect(_on_modular_skill_activated)
	
	skill.skill_activated.connect(_on_modular_skill_activated)
	
	for effect in skill.effects:
		if effect is DamageEffect:
			if effect.effect_applied.is_connected(_on_modular_damage_applied):
				effect.effect_applied.disconnect(_on_modular_damage_applied)
			effect.effect_applied.connect(_on_modular_damage_applied)

func _on_modular_skill_activated(user: Fighter, targets: Array) -> void:
	show_message("%s uses %s!" % [user.display_name, "SKILL"]) # TODO: Pegar nome da skill

func _on_modular_damage_applied(target: Fighter, damage: int) -> void:
	# Reutiliza a lógica visual de dano (projétil + shake)
	var active = engine.turn_queue.get_active_fighter()
	_on_damage_dealt(active, target, {"damage": damage, "skill_name": "MODULAR"})

# ─────────────────────────────────────────
# HANDLERS DE SINAIS (LEGACY)
# ─────────────────────────────────────────

func _on_turn_started(fighter: Fighter, is_player: bool) -> void:
	# Atualiza o indicador visual da carta ativa
	for s in _player_slots + _enemy_slots:
		if s.fighter:
			s.set_active_turn_visual(s.fighter == fighter)

	if is_player:
		show_message(fighter.display_name + "'S TURN")
		_refresh_skills(fighter)
	else:
		show_message("ENEMY TURN")

func _on_pt_updated(current: int, _max_pt: int) -> void:
	for i in range(10):
		if i < _pt_gems.size():
			_pt_gems[i].modulate = Color(0.3, 1.0, 1.0) if i < current else Color(0.3, 0.3, 0.3)

func _on_damage_dealt(atk: Fighter, defender: Fighter, _res: Dictionary) -> void:
	var slot_atk = _find_slot(atk)
	var slot_def = _find_slot(defender)
	
	if slot_atk and slot_def and atk != defender:
		# Criação do projétil dinâmico
		var proj = ColorRect.new()
		var is_player_atk = _player_slots.has(slot_atk)
		proj.color = Color(1.0, 0.8, 0.2, 0.8) if is_player_atk else Color(1.0, 0.2, 0.2, 0.8)
		proj.size = Vector2(16, 16)
		# Centraliza na carta (que tem 120x200)
		proj.position = slot_atk.position + Vector2(52, 92)
		proj.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_slot_layer.add_child(proj)
		
		# Animação de voo (mais lenta a pedido do usuário)
		var tween = create_tween()
		tween.tween_property(proj, "position", slot_def.position + Vector2(52, 92), 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_callback(proj.queue_free)
		
		# Tremor (Shake) na carta defensora ao receber o impacto
		var original_x = slot_def.position.x
		var shake = create_tween()
		shake.tween_interval(0.4) # Espera o projétil chegar (ajustado para 0.4)
		shake.tween_property(slot_def, "position:x", original_x + 8, 0.05)
		shake.tween_property(slot_def, "position:x", original_x - 8, 0.05)
		shake.tween_property(slot_def, "position:x", original_x, 0.05)
		
		# Log de dano detalhado
		var dmg = _res.get("damage", 0)
		var s_name = _res.get("skill_name", "ATTACK")
		show_message("%s uses %s: %d DMG!" % [atk.display_name, s_name, dmg])
		
	if slot_def: slot_def.refresh()

func _on_fighter_died(fighter: Fighter) -> void:
	show_message("%s DEFEATED!" % fighter.display_name.to_upper())
	var slot = _find_slot(fighter)
	if slot: slot.refresh()

func _on_battle_ended(result: String) -> void:
	show_message(result)

func _on_round_started(round_num: int) -> void:
	_round_label.text = "TURN %d" % round_num

func _refresh_skills(fighter: Fighter) -> void:
	for c in _skill_bar.get_children(): c.queue_free()
	for s in fighter.skills:
		var btn = Button.new()
		
		# Suporte híbrido (Rule 15)
		var s_name = s.skill_name if s is SkillResource else s.get("name", "???")
		var s_id = s.skill_name.to_snake_case() if s is SkillResource else s.get("id", "")
		
		btn.text = s_name
		btn.custom_minimum_size = Vector2(90, 60)
		var s_st = StyleBoxFlat.new()
		s_st.bg_color = Color(0.12, 0.1, 0.2)
		s_st.set_corner_radius_all(8)
		s_st.set_border_width_all(2)
		s_st.border_color = Color(0.4, 0.3, 0.6)
		btn.add_theme_stylebox_override("normal", s_st)
		btn.add_theme_font_size_override("font_size", 10)
		
		# Blindagem para Mobile Touch
		btn.gui_input.connect(func(event: InputEvent):
			if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed):
				btn.accept_event()
				_on_skill_pressed(s_id)
		)
		
		_skill_bar.add_child(btn)

var targeting_mode: bool = false
var pending_skill: String = ""

func _on_attack_pressed() -> void:
	print("\n[BattleHUD] ---> BOTÃO ATTACK CLICADO!")
	if engine.state != engine.BattleState.PLAYER_TURN: 
		print("[BattleHUD] Ignorado: state não é PLAYER_TURN. State atual: ", engine.state)
		return
	pending_skill = "basic"
	_start_targeting("basic")

func _on_skill_pressed(skill_id: String) -> void:
	if engine.state != engine.BattleState.PLAYER_TURN: return
	var active = engine.turn_queue.get_active_fighter()
	if not active.is_skill_available(skill_id, engine.pt_manager.get_current()):
		show_message("NOT ENOUGH PT / ON COOLDOWN")
		return
	pending_skill = skill_id
	_start_targeting(skill_id)

func _start_targeting(skill_id: String) -> void:
	targeting_mode = true
	show_message("SELECT TARGET")
	
	var active = engine.turn_queue.get_active_fighter()
	var skill = active.get_skill_by_id(skill_id)
	
	# Se for modular, usamos o Targeter para saber quem destacar
	var valid = []
	if skill is SkillResource:
		valid = skill.targeter.get_targets(active, engine.player_fighters + engine.enemy_fighters)
	else:
		# Fallback legacy
		var legacy_skill = {"id": skill_id, "aoe": "SINGLE"}
		if skill_id != "basic": legacy_skill = skill
		valid = engine.get_valid_targets(legacy_skill, active)
	
	for s in _player_slots + _enemy_slots:
		s.set_targeting_visual(s.fighter in valid)

func _clear_targeting_highlights() -> void:
	for s in _player_slots + _enemy_slots:
		s.set_targeting_visual(false)

func _on_slot_clicked(slot: FighterSlotUI) -> void:
	if not targeting_mode or not slot.fighter or not slot.fighter.is_alive: return
	
	var active = engine.turn_queue.get_active_fighter()
	if not active: return
	
	# Validação básica de alvo (Modular ou Legacy)
	targeting_mode = false
	_clear_targeting_highlights()
	
	# Note: A BattleEngine agora lida com a expansão do alvo (AOE) internamente
	# via SkillResource.activate(), então passamos apenas o clicado como referência.
	engine.use_skill(pending_skill, [slot.fighter])

func _find_slot(fighter: Fighter) -> FighterSlotUI:
	for s in _player_slots + _enemy_slots:
		if s.fighter == fighter: return s
	return null

var _msg_tween: Tween = null

func show_message(msg: String) -> void:
	if _msg_tween:
		_msg_tween.kill()
		
	_battle_log.text = msg
	_battle_log.modulate.a = 0.0 # Reset
	
	_msg_tween = create_tween()
	_msg_tween.tween_property(_battle_log, "modulate:a", 1.0, 0.2)
	_msg_tween.tween_interval(1.5)
	_msg_tween.tween_property(_battle_log, "modulate:a", 0.0, 0.4)
