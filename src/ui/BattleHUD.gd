# BattleHUD.gd — v4: concept-faithful, compact, clicks fixed
class_name BattleHUD
extends CanvasLayer

var engine: BattleEngine = null
var _root: Control
var _enemy_slots: Array = []
var _player_slots: Array = []
var _pt_gems: Array = []
var _battle_log: Label
var _action_bg: ColorRect
var _btn_attack: Button
var _skill_panel: HBoxContainer
var _selected_target: Fighter = null
var _player_turn_active: bool = false

const W = 390.0; const H = 844.0

# ZONAS (concept-faithful)
# y=0-54     Turn Queue
# y=56-290   ENEMY (topo, centro y=170)
# y=292-294  Divisor
# y=296-510  ALLY TEAM (embaixo, centro y=400)
# y=512-534  Log + Turn Info
# y=536-636  Skills (só aparece ao selecionar alvo)
# y=638-700  PT + Cartas compacto
const ENEMY_CY = 200.0; const ALLY_CY = 460.0

const ALLY_OFF = [Vector2(0,-70), Vector2(-95,0), Vector2(95,0), Vector2(0,70)]
const EN_OFF_3 = [Vector2(-95,0), Vector2(0,-25), Vector2(95,0)]

func _ready() -> void:
	_build_ui()

func connect_to_engine(e: BattleEngine) -> void:
	engine = e
	e.turn_started.connect(_on_turn_started)
	e.pt_updated.connect(_on_pt_updated)
	e.hand_updated.connect(_on_hand_updated)
	e.damage_dealt.connect(_on_damage_dealt)
	e.fighter_died.connect(_on_fighter_died)
	e.battle_ended.connect(_on_battle_ended)
	e.round_started.connect(_on_round_started)
	e.status_applied.connect(_on_status_applied)

func setup_battle(pf: Array, ef: Array, _a: String, _b: String) -> void:
	for i in range(mini(ef.size(), _enemy_slots.size())):
		var o = ALLY_OFF[i] if ef.size() == 4 else (EN_OFF_3[i] if ef.size() <= 3 else Vector2(0,0))
		_enemy_slots[i].position = Vector2(W/2 + o.x - 36, ENEMY_CY + o.y - 55)
		_enemy_slots[i].setup(ef[i], false)
		_enemy_slots[i].visible = true
	for i in range(mini(pf.size(), _player_slots.size())):
		var o = ALLY_OFF[i]
		_player_slots[i].position = Vector2(W/2 + o.x - 36, ALLY_CY + o.y - 55)
		_player_slots[i].setup(pf[i], true)
		_player_slots[i].visible = true

func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	# ── BG (tudo IGNORE para não bloquear cliques) ──
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.04, 0.12)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(bg)

	var field = ColorRect.new()
	field.position = Vector2(0, 54); field.size = Vector2(W, 460)
	field.color = Color(0.07, 0.06, 0.20, 0.4)
	field.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(field)

	var div = ColorRect.new()
	div.position = Vector2(20, 292); div.size = Vector2(W-40, 2)
	div.color = Color(0.5, 0.35, 0.9, 0.5)
	div.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(div)

	# Labels
	var el = Label.new()
	el.text = "ENEMY"; el.position = Vector2(W-72, 58)
	el.add_theme_font_size_override("font_size", 11)
	el.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	el.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(el)

	var al = Label.new()
	al.text = "ALLY TEAM"; al.position = Vector2(8, 296)
	al.add_theme_font_size_override("font_size", 11)
	al.add_theme_color_override("font_color", Color(0.45, 0.75, 1.0))
	al.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(al)

	# ── Turn Queue Bar ──
	var tq = ColorRect.new()
	tq.position = Vector2(0,0); tq.size = Vector2(W, 54)
	tq.color = Color(0.06, 0.06, 0.18, 0.97)
	tq.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(tq)
	var nl = Label.new()
	nl.text = "NEXT ▶  Turn Order Queue"
	nl.position = Vector2(8, 16)
	nl.add_theme_font_size_override("font_size", 10)
	nl.add_theme_color_override("font_color", Color(0.6, 0.5, 1.0))
	nl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(nl)

	# ── ENEMY SLOTS ── (z alto para receber clicks)
	for i in range(5):
		var s = FighterSlotUI.new()
		s.visible = false; s.z_index = 10
		_root.add_child(s)
		_enemy_slots.append(s)

	# ── ALLY SLOTS ──
	for i in range(4):
		var s = FighterSlotUI.new()
		s.visible = false; s.z_index = 10
		_root.add_child(s)
		_player_slots.append(s)

	# ── Battle Log ──
	_battle_log = Label.new()
	_battle_log.position = Vector2(0, 615)
	_battle_log.z_index = 20
	_battle_log.size = Vector2(W, 20)
	_battle_log.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_battle_log.add_theme_font_size_override("font_size", 10)
	_battle_log.add_theme_color_override("font_color", Color(1, 1, 0.6))
	_battle_log.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_battle_log)

	# ── ACTION PANEL (Bottom HUD) ──
	_action_bg = ColorRect.new()
	_action_bg.position = Vector2(0, 640); _action_bg.size = Vector2(W, H - 640)
	_action_bg.color = Color(0.04, 0.05, 0.12, 1.0)
	_action_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_action_bg)

	# Status Bar (HP/PT/Turn)
	var stat_bar = ColorRect.new()
	stat_bar.position = Vector2(0, 640); stat_bar.size = Vector2(W, 30)
	stat_bar.color = Color(0.1, 0.1, 0.2, 0.6)
	_root.add_child(stat_bar)
	
	var pt_row = HBoxContainer.new()
	pt_row.position = Vector2(W - 160, 645); pt_row.size = Vector2(150, 20)
	pt_row.alignment = BoxContainer.ALIGNMENT_END
	pt_row.add_theme_constant_override("separation", 2)
	_root.add_child(pt_row)
	var ptl = Label.new()
	ptl.text = "PT"; ptl.add_theme_font_size_override("font_size", 10)
	ptl.add_theme_color_override("font_color", Color(0.5, 0.7, 1))
	pt_row.add_child(ptl)
	for i in range(10):
		var p = PanelContainer.new()
		p.custom_minimum_size = Vector2(10, 10)
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.1, 0.15, 0.4, 0.5)
		p.add_theme_stylebox_override("panel", st)
		pt_row.add_child(p)
		_pt_gems.append(p)

	# Esquerda: ATTACK
	_btn_attack = Button.new()
	_btn_attack.position = Vector2(8, 680); _btn_attack.size = Vector2(80, 150)
	_btn_attack.text = "ATTACK"
	_btn_attack.add_theme_font_size_override("font_size", 14)
	var atk_style = StyleBoxFlat.new()
	atk_style.bg_color = Color(0.1, 0.4, 0.8)
	atk_style.border_color = Color(0.4, 0.8, 1.0)
	atk_style.border_width_top = 2; atk_style.border_width_bottom = 2
	atk_style.border_width_left = 2; atk_style.border_width_right = 2
	atk_style.corner_radius_top_left = 8; atk_style.corner_radius_top_right = 8
	atk_style.corner_radius_bottom_left = 8; atk_style.corner_radius_bottom_right = 8
	_btn_attack.add_theme_stylebox_override("normal", atk_style)
	_btn_attack.disabled = true
	_root.add_child(_btn_attack)

	# Centro: SKILLS
	var sb_bg = ColorRect.new()
	sb_bg.position = Vector2(96, 680); sb_bg.size = Vector2(200, 150)
	sb_bg.color = Color(0.06, 0.08, 0.16)
	var sb_border = StyleBoxFlat.new()
	sb_border.bg_color = Color(0,0,0,0)
	sb_border.border_color = Color(0.7, 0.6, 0.2)
	sb_border.border_width_top = 2; sb_border.border_width_bottom = 2
	sb_border.border_width_left = 2; sb_border.border_width_right = 2
	sb_border.corner_radius_top_left = 6; sb_border.corner_radius_top_right = 6
	sb_border.corner_radius_bottom_left = 6; sb_border.corner_radius_bottom_right = 6
	var sb_panel = Panel.new()
	sb_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	sb_panel.add_theme_stylebox_override("panel", sb_border)
	sb_bg.add_child(sb_panel)
	
	var sl = Label.new()
	sl.text = "SKILLS"; sl.position = Vector2(0, 4); sl.size = Vector2(200, 20)
	sl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sl.add_theme_font_size_override("font_size", 10)
	sb_bg.add_child(sl)

	_skill_panel = HBoxContainer.new()
	_skill_panel.position = Vector2(10, 30); _skill_panel.size = Vector2(180, 110)
	_skill_panel.alignment = BoxContainer.ALIGNMENT_CENTER
	_skill_panel.add_theme_constant_override("separation", 6)
	sb_bg.add_child(_skill_panel)
	_root.add_child(sb_bg)

	# Direita: SUPPORT
	var sup_bg = ColorRect.new()
	sup_bg.position = Vector2(304, 680); sup_bg.size = Vector2(78, 150)
	sup_bg.color = Color(0.06, 0.08, 0.16)
	var sup_panel = Panel.new()
	sup_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	sup_panel.add_theme_stylebox_override("panel", sb_border)
	sup_bg.add_child(sup_panel)
	
	var spl = Label.new()
	spl.text = "SUPPORT"; spl.position = Vector2(0, 4); spl.size = Vector2(78, 20)
	spl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spl.add_theme_font_size_override("font_size", 9)
	sup_bg.add_child(spl)
	_root.add_child(sup_bg)
	
	_hide_skills()

# ══ SINAIS ══
func _on_turn_started(fighter: Fighter, is_player: bool) -> void:
	for s in _player_slots + _enemy_slots: s.set_active(false)
	_player_turn_active = is_player
	for s in (_player_slots if is_player else _enemy_slots):
		if s.fighter == fighter: s.set_active(true); break
	if is_player:
		_selected_target = null
		_show_skills(fighter, false)
		_make_enemies_clickable()
		_battle_log.text = "← Selecione o inimigo"
	else:
		_selected_target = null; _hide_skills(); _clear_enemy_clicks()
		_battle_log.text = "Turno: %s" % fighter.display_name

func _on_pt_updated(c: int, m: int) -> void:
	for i in range(_pt_gems.size()):
		var st = StyleBoxFlat.new()
		st.corner_radius_top_left = 3; st.corner_radius_top_right = 3
		st.corner_radius_bottom_left = 3; st.corner_radius_bottom_right = 3
		st.bg_color = Color(0.3,0.55,1,0.95) if i < c else (Color(0.1,0.15,0.4,0.6) if i < m else Color(0.05,0.05,0.12,0.3))
		_pt_gems[i].add_theme_stylebox_override("panel", st)

func _on_hand_updated(_hand: Array) -> void:
	pass # Cards hand replaced by direct skill HUD

func _on_damage_dealt(at: Fighter, df: Fighter, r: Dictionary) -> void:
	for s in _player_slots + _enemy_slots:
		if s.fighter == df: s.flash_damage(); s.refresh()
		if s.fighter == at and r["drain_amount"] > 0: s.flash_heal(); s.refresh()
	var sfx = " ✦ADV!" if r["type_relation"]=="ADV" else (" ▼WEK" if r["type_relation"]=="WEK" else "")
	_battle_log.text = "%s → %d dmg%s" % [at.display_name.left(8), r["damage"], sfx]

func _on_fighter_died(f: Fighter) -> void:
	for s in _player_slots + _enemy_slots:
		if s.fighter == f: s.refresh()
	_battle_log.text = "💀 %s derrotado!" % f.display_name

func _on_battle_ended(r: String) -> void:
	_hide_skills()
	_battle_log.text = {"VICTORY":"🏆 VITÓRIA!","DEFEAT":"💀 DERROTA...","DRAW":"🤝 EMPATE"}.get(r,"")

func _on_round_started(n: int) -> void:
	_battle_log.text = "═ Rodada %d ═" % n

func _on_status_applied(f: Fighter, _e: Dictionary) -> void:
	for s in _player_slots + _enemy_slots:
		if s.fighter == f: s.refresh()

# ══ SKILLS ══
func _show_skills(fighter: Fighter, target_selected: bool) -> void:
	# O painel nunca fica invisível, apenas esvaziamos e recriamos desabilitados se sem alvo
	for c in _skill_panel.get_children(): c.queue_free()
	var pt = engine.pt_manager.get_current() if engine else 0
	
	# Mapeia ataque básico para o botão esquerdo (ATTACK)
	var basic_id = "basic"
	for sk in fighter.skills:
		if sk["id"].ends_with("_basic"): basic_id = sk["id"]
	
	if _btn_attack:
		for c in _btn_attack.pressed.get_connections(): _btn_attack.pressed.disconnect(c.callable)
		var can_afford = fighter.is_skill_available(basic_id, pt)
		_btn_attack.disabled = not (target_selected and can_afford)
		_btn_attack.pressed.connect(func(): _on_skill_pressed(basic_id, fighter))

	# Mapeia skills especiais para o centro
	for sk in fighter.skills:
		if sk["id"].ends_with("_basic"): continue
		var can_afford = fighter.is_skill_available(sk["id"], pt)
		var ok = target_selected and can_afford
		_mk_skill_btn(sk["id"], sk["name"], sk["pt_cost"], ok, fighter)

func _hide_skills() -> void:
	if _btn_attack: _btn_attack.disabled = true
	for c in _skill_panel.get_children(): c.queue_free()

func _mk_skill_btn(sid: String, skill_name: String, cost: int, ok: bool, fighter: Fighter) -> void:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(40, 60)
	btn.text = "%s\n●%d" % [skill_name.left(5), cost]
	btn.disabled = not ok
	btn.add_theme_font_size_override("font_size", 8)
	var s = StyleBoxFlat.new()
	s.corner_radius_top_left = 4; s.corner_radius_top_right = 4
	s.corner_radius_bottom_left = 4; s.corner_radius_bottom_right = 4
	s.border_width_top = 1; s.border_width_bottom = 1
	s.border_width_left = 1; s.border_width_right = 1
	s.bg_color = Color(0.2,0.1,0.3,0.95) if ok else Color(0.08,0.08,0.16,0.7)
	s.border_color = Color(0.8,0.2,0.9) if ok else Color(0.25,0.25,0.35)
	btn.add_theme_stylebox_override("normal", s)
	btn.add_theme_stylebox_override("disabled", s)
	
	if ok:
		var s_hover = s.duplicate()
		s_hover.bg_color = s.bg_color.lightened(0.2)
		btn.add_theme_stylebox_override("hover", s_hover)
		
	btn.pressed.connect(func(): _on_skill_pressed(sid, fighter))
	_skill_panel.add_child(btn)

# ══ INTERAÇÃO ══
func _on_skill_pressed(sid: String, attacker: Fighter) -> void:
	var skill = attacker.get_skill_by_id(sid)
	var aoe = "SINGLE" if sid == "basic" else skill.get("aoe", "SINGLE")
	if aoe == "TOTAL":
		if engine: engine.use_skill(sid, engine.enemy_fighters.filter(func(f): return f.is_alive))
		return
	if _selected_target == null or not _selected_target.is_alive:
		_battle_log.text = "⚠️ Sem alvo!"; return
	if engine: engine.use_skill(sid, [_selected_target])
	_selected_target = null; _clear_enemy_clicks(); _hide_skills()

# ══ SELEÇÃO DE ALVO ══
func _make_enemies_clickable() -> void:
	for slot in _enemy_slots:
		if slot.fighter == null or not slot.fighter.is_alive: continue
		slot.set_targetable(true)
		if not slot.slot_clicked.is_connected(_on_enemy_clicked):
			slot.slot_clicked.connect(_on_enemy_clicked)

func _clear_enemy_clicks() -> void:
	for slot in _enemy_slots:
		slot.set_targetable(false); slot.set_selected_target(false)
		if slot.slot_clicked.is_connected(_on_enemy_clicked):
			slot.slot_clicked.disconnect(_on_enemy_clicked)

func _on_enemy_clicked(slot: FighterSlotUI) -> void:
	if not _player_turn_active: return
	for s in _enemy_slots: s.set_selected_target(false)
	_selected_target = slot.fighter
	slot.set_selected_target(true)
	_battle_log.text = "🎯 %s → escolha a skill!" % slot.fighter.display_name
	# Mostra skills do lutador ativo
	var active = engine.turn_queue.get_active_fighter() if engine else null
	if active: _show_skills(active, true)
