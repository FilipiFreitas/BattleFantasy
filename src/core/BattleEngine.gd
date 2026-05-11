# BattleEngine.gd
# Orquestrador central da batalha no BattleFantasy.
# Coordena: TurnQueue, PTManager, DamageCalculator, mão do jogador e deck.
class_name BattleEngine
extends Node

# ─────────────────────────────────────────
# DEPENDÊNCIAS
# ─────────────────────────────────────────
var turn_queue: TurnQueue
var pt_manager: PTManager
var damage_calculator: DamageCalculator
var enemy_ai: Node

# ─────────────────────────────────────────
# ESTADO DA BATALHA
# ─────────────────────────────────────────
enum BattleState {
	IDLE,
	PLAYER_TURN,
	ENEMY_TURN,
	BOOST_PHASE,
	SKILL_PHASE,
	RESOLVING,
	VICTORY,
	DEFEAT,
	DRAW
}

var state: BattleState = BattleState.IDLE

var player_fighters: Array = []   # Array[Fighter] — time do jogador (5)
var enemy_fighters: Array = []    # Array[Fighter] — time inimigo (5)
var player_formation: String = "1-3-1"
var enemy_formation: String = "1-3-1"

var player_deck: Array = []       # Array[Card] restantes no deck
var player_hand: Array = []       # Array[Card] na mão (máx 5)
var active_boosts: Array = []     # Boosts jogados neste turno (ainda não consumidos)

var global_turn_counter: int = 0  # Contador global de turnos (para PT ramp)
var field_effects: Array = []     # Cartas de campo ativas

# ─────────────────────────────────────────
# SINAIS (para a UI se conectar)
# ─────────────────────────────────────────
signal battle_started()
signal turn_started(fighter: Fighter, is_player: bool)
signal pt_updated(current: int, maximum: int)
signal hand_updated(hand: Array)
signal damage_dealt(attacker: Fighter, defender: Fighter, result: Dictionary)
signal fighter_died(fighter: Fighter)
signal battle_ended(result: String)   # "VICTORY" | "DEFEAT" | "DRAW"
signal status_applied(fighter: Fighter, effect: Dictionary)
signal round_started(round_number: int)

# ─────────────────────────────────────────
# INICIALIZAÇÃO
# ─────────────────────────────────────────
func _ready() -> void:
	turn_queue = TurnQueue.new()
	pt_manager = PTManager.new()
	damage_calculator = DamageCalculator.new()

	# Inicia IA dos Inimigos
	enemy_ai = load("res://src/core/EnemyAI.gd").new()
	add_child(enemy_ai)
	enemy_ai.setup(self)

	# Conecta sinais do PTManager para retransmitir à UI
	pt_manager.pt_changed.connect(func(c, m): emit_signal("pt_updated", c, m))

	# Auto-inicia batalha de teste após 1 frame (aguarda HUD ficar pronto)
	await get_tree().process_frame
	_auto_start_test()

func _auto_start_test() -> void:
	var hud = get_node_or_null("HUD") as BattleHUD
	if hud == null:
		push_error("BattleEngine: nó HUD não encontrado!")
		return

	# Carrega matriz de tipos
	var type_matrix = {}
	var f = FileAccess.open("res://src/data/types_matrix.json", FileAccess.READ)
	if f:
		type_matrix = JSON.parse_string(f.get_as_text())
		f.close()

	var player_team = _make_test_player_team()
	var enemy_team  = _make_test_enemy_team()
	var test_deck   = _make_test_deck()

	hud.connect_to_engine(self)

	setup_battle(player_team, enemy_team, test_deck, "1-2-1", "1-2-1", type_matrix)
	hud.setup_battle(player_team, enemy_team, "1-2-1", "1-2-1")
	start_battle()

# ─────────────────────────────────────────
# DADOS DE TESTE
# ─────────────────────────────────────────
func _make_fighter(id: String, f_name: String, type: String, rarity: String,
	hp: int, atk_f: int, def_f: int, atk_s: int, def_s: int, agi: int,
	skills: Array) -> Fighter:
	var fighter = Fighter.new()
	fighter.id = id
	fighter.display_name = f_name
	fighter.fighter_type = type
	fighter.rarity = rarity
	fighter.hp_max = hp
	fighter.atk_f = atk_f
	fighter.def_f = def_f
	fighter.atk_s = atk_s
	fighter.def_s = def_s
	fighter.agi = agi
	fighter.skills = skills
	return fighter

func _make_test_player_team() -> Array:
	return [
		_make_fighter("ignis","IGNIS","FIRE","RARE", 1840,210,155,90,80,130,
			[{"id":"ignis_basic","name":"Ember Slash","pt_cost":0,"cd":0,"damage_type":"PHYSICAL","power":1.0,"aoe":"SINGLE","status":{}},
			 {"id":"ignis_flame_wave","name":"Flame Wave","pt_cost":2,"cd":3,"damage_type":"SPECIAL","power":1.6,"aoe":"SINGLE","status":{"type":"BURN","turns":2,"value":55}},
			 {"id":"ignis_inferno","name":"Inferno Burst","pt_cost":3,"cd":4,"damage_type":"SPECIAL","power":2.2,"aoe":"TOTAL","status":{"type":"BURN","turns":3,"value":80}}]),
		_make_fighter("kael","KAEL","THUNDER","RARE", 1560,180,130,220,160,155,
			[{"id":"kael_basic","name":"Spark Punch","pt_cost":0,"cd":0,"damage_type":"PHYSICAL","power":1.0,"aoe":"SINGLE","status":{}},
			 {"id":"kael_thunder","name":"Thunder Bolt","pt_cost":2,"cd":2,"damage_type":"SPECIAL","power":1.5,"aoe":"SINGLE","status":{"type":"OVERLOAD","turns":0,"value":0}}]),
		_make_fighter("sapphira","SAPPHIRA","WATER","RARE", 1700,130,160,200,190,140,
			[{"id":"sapphira_basic","name":"Water Slash","pt_cost":0,"cd":0,"damage_type":"PHYSICAL","power":1.0,"aoe":"SINGLE","status":{}},
			 {"id":"sapphira_wave","name":"Tidal Wave","pt_cost":2,"cd":3,"damage_type":"SPECIAL","power":1.7,"aoe":"LINE","status":{"type":"EXTINGUISH","turns":2,"value":0}}]),
		_make_fighter("azurath","AZURATH","DRAGON","MYTHIC", 3200,340,280,310,260,195,
			[{"id":"azurath_basic","name":"Dragon Claw","pt_cost":0,"cd":0,"damage_type":"PHYSICAL","power":1.0,"aoe":"SINGLE","status":{}},
			 {"id":"azurath_breath","name":"Dragon Breath","pt_cost":2,"cd":2,"damage_type":"SPECIAL","power":1.8,"aoe":"SINGLE","status":{"type":"BURN","turns":2,"value":90}},
			 {"id":"azurath_wrath","name":"Sovereign Wrath","pt_cost":4,"cd":5,"damage_type":"SPECIAL","power":3.5,"aoe":"TOTAL","status":{"type":"BURN","turns":3,"value":150}}]),
	]

func _make_test_enemy_team() -> Array:
	return [
		_make_fighter("orc_boss","ORC BOSS","FIGHTER","LEGENDARY", 2400,260,200,140,130,105,
			[{"id":"orc_basic","name":"Heavy Smash","pt_cost":0,"cd":0,"damage_type":"PHYSICAL","power":1.2,"aoe":"SINGLE","status":{}},
			 {"id":"orc_roar","name":"War Roar","pt_cost":2,"cd":3,"damage_type":"PHYSICAL","power":1.8,"aoe":"LINE","status":{}}]),
		_make_fighter("goblin_a","GOBLIN A","GRASS","NORMAL", 1200,100,80,120,90,140,
			[{"id":"goblin_basic","name":"Stab","pt_cost":0,"cd":0,"damage_type":"PHYSICAL","power":1.0,"aoe":"SINGLE","status":{}}]),
		_make_fighter("shaman","SHAMAN","PSYCHIC","RARE", 1800,120,110,240,180,160,
			[{"id":"minder_basic","name":"Psy Blast","pt_cost":0,"cd":0,"damage_type":"SPECIAL","power":1.0,"aoe":"SINGLE","status":{}},
			 {"id":"minder_confuse","name":"Confuse","pt_cost":2,"cd":3,"damage_type":"SPECIAL","power":1.2,"aoe":"SINGLE","status":{"type":"CONFUSE","turns":2,"value":0}}]),
		_make_fighter("goblin_b","GOBLIN B","GRASS","NORMAL", 1000,100,80,120,90,140,
			[{"id":"goblin_basic","name":"Stab","pt_cost":0,"cd":0,"damage_type":"PHYSICAL","power":1.0,"aoe":"SINGLE","status":{}}]),
	]

func _make_test_deck() -> Array:
	var deck = []
	var defs = [
		{"id":"boost_fire","display_name":"Chama Ardente","card_type":"BOOST","pt_cost":2,"rarity":"RARE",
		 "boost_fighter_type":"FIRE","boost_stat":"DAMAGE","boost_value":1.8,"boost_duration":0,"description":"+80% dano Fogo"},
		{"id":"boost_any","display_name":"Impulso Universal","card_type":"BOOST","pt_cost":1,"rarity":"NORMAL",
		 "boost_fighter_type":"ANY","boost_stat":"DAMAGE","boost_value":1.3,"boost_duration":0,"description":"+30% qualquer skill"},
		{"id":"heal_single","display_name":"Cura Sagrada","card_type":"HEAL","pt_cost":2,"rarity":"NORMAL",
		 "heal_value":400,"heal_target":"SINGLE","description":"Restaura 400 HP"},
		{"id":"boost_dragon","display_name":"Poder Dragão","card_type":"BOOST","pt_cost":2,"rarity":"RARE",
		 "boost_fighter_type":"DRAGON","boost_stat":"DAMAGE","boost_value":1.7,"boost_duration":0,"description":"+70% dano Dragão"},
		{"id":"equip_sword","display_name":"Espada de Dragão","card_type":"EQUIPMENT","pt_cost":2,"rarity":"RARE",
		 "equip_stat":"atk_f","equip_value":40,"description":"+40 ATK F"},
		{"id":"heal_all","display_name":"Bênção Total","card_type":"HEAL","pt_cost":3,"rarity":"RARE",
		 "heal_value":150,"heal_target":"ALL","description":"Restaura 150 HP p/ todos"},
	]
	for i in range(50):
		deck.append(Card.from_dict(defs[i % defs.size()].duplicate()))
	return deck

func setup_battle(
	p_fighters: Array,
	e_fighters: Array,
	p_deck: Array,
	p_formation: String,
	e_formation: String,
	type_matrix: Dictionary
) -> void:
	player_fighters = p_fighters
	enemy_fighters = e_fighters
	player_formation = p_formation
	enemy_formation = e_formation
	player_deck = p_deck.duplicate()
	player_deck.shuffle()

	damage_calculator.initialize(type_matrix)
	pt_manager.initialize()

	# Inicializa todos os lutadores
	for fighter in player_fighters + enemy_fighters:
		fighter.initialize()

	# Atribui posições
	for i in range(player_fighters.size()):
		player_fighters[i].position = i
	for i in range(enemy_fighters.size()):
		enemy_fighters[i].position = i

	# Compõe a mão inicial (5 cartas)
	for i in range(5):
		_draw_card()

	# Monta a fila de turnos
	turn_queue.initialize(player_fighters + enemy_fighters)

# ─────────────────────────────────────────
# LOOP PRINCIPAL DE BATALHA
# ─────────────────────────────────────────
func start_battle() -> void:
	state = BattleState.IDLE
	global_turn_counter = 0
	emit_signal("battle_started")
	_begin_next_turn()

func _begin_next_turn() -> void:
	global_turn_counter += 1

	# Verifica condição de vitória antes do turno
	if _check_battle_end():
		return

	var active = turn_queue.get_active_fighter()
	if active == null:
		return

	if not active.is_alive:
		_advance_turn()
		return

	# PT refresh (apenas no turno do jogador por enquanto; inimigo tem lógica própria)
	var is_player_turn = player_fighters.has(active)
	if is_player_turn:
		pt_manager.on_turn_start(global_turn_counter)
		_draw_card()
		state = BattleState.PLAYER_TURN
	else:
		state = BattleState.ENEMY_TURN

	emit_signal("turn_started", active, is_player_turn)

# ─────────────────────────────────────────
# AÇÕES DO JOGADOR
# ─────────────────────────────────────────

# Jogador joga uma carta da mão (Boost, Heal, Equipment)
func play_card(card_index: int, target_fighter: Fighter = null) -> bool:
	if card_index >= player_hand.size():
		return false
	var card: Card = player_hand[card_index]
	if not pt_manager.can_afford(card.pt_cost):
		return false

	pt_manager.spend(card.pt_cost)
	player_hand.remove_at(card_index)

	match card.card_type:
		"BOOST":
			active_boosts.append(card)
		"HEAL":
			_resolve_heal(card, target_fighter)
		"EQUIPMENT":
			if target_fighter:
				target_fighter.apply_equipment(card.to_dict())
		"FIELD":
			_apply_field_effect(card)

	emit_signal("hand_updated", player_hand)
	return true

# Lutador (Jogador ou Inimigo) usa uma skill (ou ataque básico)
func use_skill(skill_id: String, targets: Array) -> bool:
	var active = turn_queue.get_active_fighter()
	if active == null:
		return false
		
	var is_player = player_fighters.has(active)

	# Ataque básico (skill_id = "basic")
	if skill_id == "basic":
		_execute_attack(active, targets, {}, _consume_boosts(active) if is_player else 1.0)
		_end_turn()
		return true

	# Skill específica
	var skill = active.get_skill_by_id(skill_id)
	
	if is_player:
		if not active.is_skill_available(skill_id, pt_manager.get_current()): return false
		pt_manager.spend(skill["pt_cost"])
		
	active.activate_cooldown(skill_id)

	var boost_mult = _consume_boosts(active) if is_player else 1.0
	_execute_attack(active, targets, skill, boost_mult)
	_end_turn()
	return true

# ─────────────────────────────────────────
# RESOLUÇÃO DE COMBATE
# ─────────────────────────────────────────
func _execute_attack(
	attacker: Fighter,
	targets: Array,
	skill: Dictionary,
	boost_mult: float
) -> void:
	state = BattleState.RESOLVING

	for target in targets:
		if not target.is_alive:
			continue

		var is_player_attacker = player_fighters.has(attacker)
		var formation = player_formation if is_player_attacker else enemy_formation
		var damage_stat = "atk_s" if skill.get("damage_type", "PHYSICAL") == "SPECIAL" else "atk_f"
		var formation_bonus = DamageCalculator.get_formation_bonus(
			formation, attacker.position, damage_stat
		)

		var result = damage_calculator.calculate({
			"attacker": attacker,
			"defender": target,
			"skill": skill,
			"boost_multiplier": boost_mult,
			"formation_bonus": formation_bonus,
		})

		# Aplica dano
		target.take_damage(result["damage"])

		# Aplica status se vantagem de tipo
		if not result["triggered_status"].is_empty():
			target.apply_status(result["triggered_status"])
			emit_signal("status_applied", target, result["triggered_status"])

		# Aplica dreno (DARK type)
		if result["drain_amount"] > 0:
			attacker.heal(result["drain_amount"])

		emit_signal("damage_dealt", attacker, target, result)

		# Verifica morte
		if not target.is_alive:
			emit_signal("fighter_died", target)

	# Verifica vitória após resolução
	if _check_battle_end():
		return

func _resolve_heal(card: Card, target: Fighter) -> void:
	if target == null:
		return
	match card.heal_target:
		"SINGLE":
			target.heal(card.heal_value)
		"ALL":
			for f in player_fighters:
				if f.is_alive:
					f.heal(card.heal_value)
		"LOWEST_HP":
			var lowest = _get_lowest_hp_fighter(player_fighters)
			if lowest:
				lowest.heal(card.heal_value)

func _apply_field_effect(card: Card) -> void:
	field_effects.append({
		"type": card.field_effect_type,
		"duration": card.field_duration,
		"value": card.field_value,
		"target_type": card.field_target_type
	})

# ─────────────────────────────────────────
# FIM DE TURNO
# ─────────────────────────────────────────
func skip_turn() -> void:
	_end_turn()

func _end_turn() -> void:
	var active = turn_queue.get_active_fighter()
	var is_player = player_fighters.has(active)
	
	if is_player:
		pt_manager.on_turn_end()
		active_boosts.clear()

	if active:
		active.tick_cooldowns()
		active.tick_status_effects()

	_advance_turn()

func _advance_turn() -> void:
	var round_over = turn_queue.advance()
	if round_over:
		_begin_new_round()
	else:
		_begin_next_turn()

func _begin_new_round() -> void:
	# Decrementa field effects
	var expired_fields = []
	for effect in field_effects:
		effect["duration"] -= 1
		if effect["duration"] <= 0:
			expired_fields.append(effect)
	for e in expired_fields:
		field_effects.erase(e)

	# Reconstrói a fila com AGIs atualizadas
	var all_alive = player_fighters.filter(func(f): return f.is_alive) + \
				   enemy_fighters.filter(func(f): return f.is_alive)
	turn_queue.start_new_round(all_alive)
	emit_signal("round_started", turn_queue.get_round_number())
	_begin_next_turn()

# ─────────────────────────────────────────
# DECK E MÃO
# ─────────────────────────────────────────
func _draw_card() -> void:
	if player_hand.size() >= 5 or player_deck.is_empty():
		return
	var card = player_deck.pop_front()
	player_hand.append(card)
	emit_signal("hand_updated", player_hand)

# ─────────────────────────────────────────
# BOOSTS
# ─────────────────────────────────────────
func _consume_boosts(attacker: Fighter) -> float:
	var multiplier = 1.0
	var consumed = []
	for boost in active_boosts:
		if boost.applies_to_fighter(attacker.fighter_type):
			multiplier *= boost.get_boost_multiplier(attacker.fighter_type)
			consumed.append(boost)
	for b in consumed:
		active_boosts.erase(b)
	return multiplier

# ─────────────────────────────────────────
# VITÓRIA / DERROTA
# ─────────────────────────────────────────
func _check_battle_end() -> bool:
	var player_alive = player_fighters.any(func(f): return f.is_alive)
	var enemy_alive = enemy_fighters.any(func(f): return f.is_alive)

	if not player_alive and not enemy_alive:
		state = BattleState.DRAW
		emit_signal("battle_ended", "DRAW")
		return true
	elif not player_alive:
		state = BattleState.DEFEAT
		emit_signal("battle_ended", "DEFEAT")
		return true
	elif not enemy_alive:
		state = BattleState.VICTORY
		emit_signal("battle_ended", "VICTORY")
		return true

	return false

# ─────────────────────────────────────────
# UTILITÁRIOS
# ─────────────────────────────────────────
func _get_lowest_hp_fighter(fighters: Array) -> Fighter:
	var lowest: Fighter = null
	for f in fighters:
		if f.is_alive:
			if lowest == null or f.hp < lowest.hp:
				lowest = f
	return lowest

func get_valid_targets(skill: Dictionary, attacker: Fighter) -> Array:
	var aoe = skill.get("aoe", "SINGLE")
	var is_player = player_fighters.has(attacker)
	var enemies = enemy_fighters if is_player else player_fighters

	match aoe:
		"SINGLE":
			return enemies.filter(func(f): return f.is_alive)
		"LINE":
			# Vanguarda (pos 0) e Retaguarda (pos 4)
			return enemies.filter(func(f): return f.is_alive and f.position in [0, 4])
		"CROSS":
			# Alvo + adjacentes (posição ± 1)
			return enemies.filter(func(f): return f.is_alive)  # UI filtra o alvo central
		"TOTAL":
			return enemies.filter(func(f): return f.is_alive)
		_:
			return []
