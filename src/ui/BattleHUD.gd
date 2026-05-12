# BattleHUD.gd — Layout Losango (4v4) conforme arte conceito
class_name BattleHUD
extends CanvasLayer

const W: float = 720.0
const H: float = 1280.0

var _root: Control
var _slot_layer: Control
var _ui_layer: Control
var _skill_bar: HBoxContainer
var _battle_log: Label
var _round_label: Label
var _btn_attack: Button
var _turn_icons: Array[Panel] = []
var _pt_gems: Array[Panel] = []

var engine: BattleEngine = null
var _player_slots: Array[FighterSlotUI] = []
var _enemy_slots: Array[FighterSlotUI] = []

# Formação Losango 1-2-1
func _get_ally_pos(idx: int) -> Vector2:
	var cx: float = W / 2.0 - 60.0
	var cy: float = H * 0.54
	var dx: float = 160.0
	var dy: float = 120.0
	match idx:
		0: return Vector2(cx, cy - dy)
		1: return Vector2(cx - dx, cy)
		2: return Vector2(cx + dx, cy)
		3: return Vector2(cx, cy + dy)
		_: return Vector2(cx, cy)

func _get_enemy_pos(idx: int) -> Vector2:
	var cx: float = W / 2.0 - 60.0
	var cy: float = H * 0.16
	var dx: float = 160.0
	var dy: float = 120.0
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

	_slot_layer = Control.new()
	_slot_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_slot_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_slot_layer)

	_ui_layer = Control.new()
	_ui_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_ui_layer)

	# ── TURN ORDER QUEUE (topo) ──
	var top_bar = Panel.new()
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.custom_minimum_size.y = 55
	var tb_st = StyleBoxFlat.new()
	tb_st.bg_color = Color(0, 0, 0, 0.75)
	tb_st.border_width_bottom = 2
	tb_st.border_color = Color(0.4, 0.3, 0.2)
	top_bar.add_theme_stylebox_override("panel", tb_st)
	_ui_layer.add_child(top_bar)

	var tq_label = Label.new()
	tq_label.text = "Turn Order Queue"
	tq_label.position = Vector2(W / 2.0 - 80, 2)
	tq_label.add_theme_font_size_override("font_size", 11)
	tq_label.modulate = Color(0.7, 0.6, 0.5)
	top_bar.add_child(tq_label)

	var tq_hbox = HBoxContainer.new()
	tq_hbox.position = Vector2(20, 18)
	tq_hbox.add_theme_constant_override("separation", 6)
	top_bar.add_child(tq_hbox)
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

	# ── LABEL ENEMY ──
	var enemy_lbl = Label.new()
	enemy_lbl.text = "── ENEMY ──"
	enemy_lbl.position = Vector2(0, H * 0.09)
	enemy_lbl.size = Vector2(W, 25)
	enemy_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enemy_lbl.add_theme_font_size_override("font_size", 14)
	enemy_lbl.modulate = Color(1.0, 0.4, 0.4)
	_ui_layer.add_child(enemy_lbl)

	# ── LABEL ALLY TEAM ──
	var ally_lbl = Label.new()
	ally_lbl.text = "── ALLY TEAM ──"
	ally_lbl.position = Vector2(0, H * 0.39)
	ally_lbl.size = Vector2(W, 25)
	ally_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ally_lbl.add_theme_font_size_override("font_size", 14)
	ally_lbl.modulate = Color(0.4, 0.8, 1.0)
	_ui_layer.add_child(ally_lbl)

	# ── BOTTOM PANEL ──
	var bp = Panel.new()
	bp.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bp.anchor_top = 1.0
	bp.offset_top = -250
	var bp_st = StyleBoxFlat.new()
	bp_st.bg_color = Color(0.02, 0.02, 0.06, 0.92)
	bp_st.set_corner_radius_all(16)
	bp_st.corner_radius_bottom_left = 0
	bp_st.corner_radius_bottom_right = 0
	bp_st.border_width_top = 3
	bp_st.border_color = Color(0.4, 0.3, 0.2)
	bp.add_theme_stylebox_override("panel", bp_st)
	_ui_layer.add_child(bp)

	var bp_margin = MarginContainer.new()
	bp_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	bp_margin.add_theme_constant_override("margin_left", 15)
	bp_margin.add_theme_constant_override("margin_right", 15)
	bp_margin.add_theme_constant_override("margin_top", 10)
	bp_margin.add_theme_constant_override("margin_bottom", 8)
	bp.add_child(bp_margin)

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
	_btn_attack.pressed.connect(_on_attack_pressed)
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

	# Battle log (centro da tela)
	_battle_log = Label.new()
	_battle_log.set_anchors_preset(Control.PRESET_CENTER)
	_battle_log.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_battle_log.add_theme_font_size_override("font_size", 28)
	_battle_log.add_theme_constant_override("outline_size", 6)
	_battle_log.modulate.a = 0
	_ui_layer.add_child(_battle_log)

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
func _on_turn_started(fighter: Fighter, is_player: bool) -> void:
	if is_player:
		show_message(fighter.display_name + "'S TURN")
		_refresh_skills(fighter)
	else:
		show_message("ENEMY TURN")

func _on_pt_updated(current: int, _max_pt: int) -> void:
	for i in range(10):
		if i < _pt_gems.size():
			_pt_gems[i].modulate = Color(0.3, 1.0, 1.0) if i < current else Color(0.3, 0.3, 0.3)

func _on_damage_dealt(_atk: Fighter, defender: Fighter, _res: Dictionary) -> void:
	var slot = _find_slot(defender)
	if slot: slot.refresh()

func _on_fighter_died(fighter: Fighter) -> void:
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
		btn.text = s.get("name", "???")
		btn.custom_minimum_size = Vector2(90, 60)
		var s_st = StyleBoxFlat.new()
		s_st.bg_color = Color(0.12, 0.1, 0.2)
		s_st.set_corner_radius_all(8)
		s_st.set_border_width_all(2)
		s_st.border_color = Color(0.4, 0.3, 0.6)
		btn.add_theme_stylebox_override("normal", s_st)
		btn.add_theme_font_size_override("font_size", 10)
		btn.pressed.connect(func(): _on_skill_pressed(s["id"]))
		_skill_bar.add_child(btn)

var targeting_mode: bool = false
var pending_skill: String = ""

func _on_attack_pressed() -> void:
	if engine.state != engine.BattleState.PLAYER_TURN: return
	pending_skill = "basic"
	targeting_mode = true
	show_message("SELECT TARGET")

func _on_skill_pressed(skill_id: String) -> void:
	if engine.state != engine.BattleState.PLAYER_TURN: return
	var active = engine.turn_queue.get_active_fighter()
	if not active.is_skill_available(skill_id, engine.pt_manager.get_current()):
		show_message("NOT ENOUGH PT / ON COOLDOWN")
		return
	pending_skill = skill_id
	targeting_mode = true
	show_message("SELECT TARGET")

func _on_slot_clicked(slot: FighterSlotUI) -> void:
	if not targeting_mode: return
	if not slot.fighter or not slot.fighter.is_alive: return
	
	var active = engine.turn_queue.get_active_fighter()
	if not active: return
	
	var is_player = engine.player_fighters.has(active)
	var target_is_player = engine.player_fighters.has(slot.fighter)
	if is_player == target_is_player:
		show_message("INVALID TARGET")
		return
		
	var skill = {"id": pending_skill, "aoe": "SINGLE"}
	if pending_skill != "basic":
		skill = active.get_skill_by_id(pending_skill)
		
	var valid_targets = engine.get_valid_targets(skill, active)
	if not valid_targets.has(slot.fighter):
		show_message("INVALID TARGET")
		return
		
	targeting_mode = false
	var final_targets = []
	var aoe = skill.get("aoe", "SINGLE")
	
	if aoe == "SINGLE":
		final_targets = [slot.fighter]
	elif aoe == "TOTAL" or aoe == "LINE":
		final_targets = valid_targets
	elif aoe == "CROSS":
		var team = engine.player_fighters if target_is_player else engine.enemy_fighters
		for f in team:
			if f.is_alive and abs(f.position - slot.fighter.position) <= 1:
				final_targets.append(f)
				
	engine.use_skill(pending_skill, final_targets)

func _find_slot(fighter: Fighter) -> FighterSlotUI:
	for s in _player_slots + _enemy_slots:
		if s.fighter == fighter: return s
	return null

func show_message(msg: String) -> void:
	_battle_log.text = msg
	var t = create_tween()
	t.tween_property(_battle_log, "modulate:a", 1.0, 0.3)
	t.tween_interval(1.5)
	t.tween_property(_battle_log, "modulate:a", 0.0, 0.5)
