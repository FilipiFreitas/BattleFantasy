# BattleCoordinator.gd
# Inicializa e conecta os sistemas de batalha para um teste funcional.
# Carrega lutadores dos JSONs, monta times e lança a batalha.
extends Node2D

func _ready() -> void:
	# Aguarda 1 frame para garantir que todos os nós filhos estejam prontos
	await get_tree().process_frame
	_start_test_battle()

func _start_test_battle() -> void:
	var engine: BattleEngine = $"." as BattleEngine
	var hud: BattleHUD = $HUD as BattleHUD

	if engine == null or hud == null:
		push_error("BattleCoordinator: Engine ou HUD não encontrado!")
		return

	# ─── Carrega a matriz de tipos ───
	var matrix_file = FileAccess.open("res://src/data/types_matrix.json", FileAccess.READ)
	var type_matrix = {}
	if matrix_file:
		type_matrix = JSON.parse_string(matrix_file.get_as_text())
		matrix_file.close()

	# ─── Cria lutadores de teste ───
	var player_team = _create_test_team_player()
	var enemy_team = _create_test_team_enemy()

	# ─── Cria deck de teste (10 cartas simples) ───
	var test_deck = _create_test_deck()

	# ─── Conecta HUD ao engine ───
	hud.connect_to_engine(engine)

	# ─── Configura a batalha ───
	engine.setup_battle(
		player_team,
		enemy_team,
		test_deck,
		"1-3-1",   # Formação do jogador
		"2-1-2",   # Formação do inimigo
		type_matrix
	)

	# ─── Setup visual da HUD ───
	hud.setup_battle(player_team, enemy_team, "1-3-1", "2-1-2")

	# ─── Inicia! ───
	engine.start_battle()

# ─────────────────────────────────────────
# FÁBRICAS DE DADOS DE TESTE
# ─────────────────────────────────────────
func _create_test_team_player() -> Array:
	var fighters = []

	# F0 — Ignis (FIRE | RARE) — Posição Líder
	fighters.append(_make_fighter("ignis", "IGNIS", "FIRE", "RARE",
		1840, 210, 155, 90, 80, 130,
		[
			{"id":"ignis_basic","name":"Ember Slash","pt_cost":0,"cd":0,"damage_type":"PHYSICAL","power":1.0,"aoe":"SINGLE","status":{}},
			{"id":"ignis_flame_wave","name":"Flame Wave","pt_cost":2,"cd":3,"damage_type":"SPECIAL","power":1.6,"aoe":"SINGLE","status":{"type":"BURN","turns":2,"value":55}},
		]
	))

	# F1 — Kael (THUNDER | RARE)
	fighters.append(_make_fighter("kael", "KAEL", "THUNDER", "RARE",
		1560, 180, 130, 220, 160, 155,
		[
			{"id":"kael_basic","name":"Spark Punch","pt_cost":0,"cd":0,"damage_type":"PHYSICAL","power":1.0,"aoe":"SINGLE","status":{}},
			{"id":"kael_thunder","name":"Thunder Bolt","pt_cost":2,"cd":2,"damage_type":"SPECIAL","power":1.5,"aoe":"SINGLE","status":{"type":"OVERLOAD","turns":0,"value":0}},
		]
	))

	# F2 — Sapphira (WATER | RARE)
	fighters.append(_make_fighter("sapphira", "SAPPHIRA", "WATER", "RARE",
		1700, 130, 160, 200, 190, 140,
		[
			{"id":"sapphira_basic","name":"Water Slash","pt_cost":0,"cd":0,"damage_type":"PHYSICAL","power":1.0,"aoe":"SINGLE","status":{}},
			{"id":"sapphira_wave","name":"Tidal Wave","pt_cost":2,"cd":3,"damage_type":"SPECIAL","power":1.7,"aoe":"LINE","status":{"type":"EXTINGUISH","turns":2,"value":0}},
		]
	))

	# F3 — Frostia (ICE | RARE)
	fighters.append(_make_fighter("frostia", "FROSTIA", "ICE", "RARE",
		1480, 150, 140, 195, 170, 120,
		[
			{"id":"frostia_basic","name":"Ice Shard","pt_cost":0,"cd":0,"damage_type":"SPECIAL","power":1.0,"aoe":"SINGLE","status":{}},
			{"id":"frostia_blizzard","name":"Blizzard","pt_cost":3,"cd":3,"damage_type":"SPECIAL","power":1.8,"aoe":"SINGLE","status":{"type":"FREEZE","turns":1,"value":0}},
		]
	))

	# F4 — Azurath (DRAGON | MYTHIC) — Posição Base
	fighters.append(_make_fighter("azurath", "AZURATH", "DRAGON", "MYTHIC",
		3200, 340, 280, 310, 260, 195,
		[
			{"id":"azurath_basic","name":"Dragon Claw","pt_cost":0,"cd":0,"damage_type":"PHYSICAL","power":1.0,"aoe":"SINGLE","status":{}},
			{"id":"azurath_breath","name":"Dragon Breath","pt_cost":2,"cd":2,"damage_type":"SPECIAL","power":1.8,"aoe":"SINGLE","status":{"type":"BURN","turns":2,"value":90}},
			{"id":"azurath_wrath","name":"Sovereign's Wrath","pt_cost":4,"cd":5,"damage_type":"SPECIAL","power":3.5,"aoe":"TOTAL","status":{"type":"BURN","turns":3,"value":150}},
		]
	))

	return fighters

func _create_test_team_enemy() -> Array:
	var fighters = []

	fighters.append(_make_fighter("shadow_a", "SHADOW", "DARK", "RARE",
		1600, 190, 140, 210, 150, 125,
		[{"id":"shadow_a_basic","name":"Dark Slash","pt_cost":0,"cd":0,"damage_type":"PHYSICAL","power":1.0,"aoe":"SINGLE","status":{}},
		 {"id":"shadow_a_drain","name":"Soul Drain","pt_cost":2,"cd":3,"damage_type":"SPECIAL","power":1.5,"aoe":"SINGLE","status":{"type":"DRAIN","turns":0,"value":0.2}}]
	))
	fighters.append(_make_fighter("stone_b", "GOLEM", "STONE", "NORMAL",
		2200, 160, 230, 80, 200, 70,
		[{"id":"stone_b_basic","name":"Rock Smash","pt_cost":0,"cd":0,"damage_type":"PHYSICAL","power":1.0,"aoe":"SINGLE","status":{}}]
	))
	fighters.append(_make_fighter("psycho_c", "MINDER", "PSYCHIC", "RARE",
		1400, 100, 110, 240, 180, 160,
		[{"id":"psycho_c_basic","name":"Psy Blast","pt_cost":0,"cd":0,"damage_type":"SPECIAL","power":1.0,"aoe":"SINGLE","status":{}},
		 {"id":"psycho_c_confuse","name":"Confuse","pt_cost":2,"cd":3,"damage_type":"SPECIAL","power":1.2,"aoe":"SINGLE","status":{"type":"CONFUSE","turns":2,"value":0}}]
	))
	fighters.append(_make_fighter("grass_d", "SYLVAN", "GRASS", "NORMAL",
		1500, 170, 130, 150, 130, 145,
		[{"id":"grass_d_basic","name":"Vine Whip","pt_cost":0,"cd":0,"damage_type":"PHYSICAL","power":1.0,"aoe":"SINGLE","status":{}}]
	))
	fighters.append(_make_fighter("dark_lord", "DARKLORД", "DARK", "LEGENDARY",
		2600, 280, 220, 300, 240, 170,
		[{"id":"dark_lord_basic","name":"Death Claw","pt_cost":0,"cd":0,"damage_type":"PHYSICAL","power":1.0,"aoe":"SINGLE","status":{}},
		 {"id":"dark_lord_abyss","name":"Abyss Strike","pt_cost":3,"cd":4,"damage_type":"SPECIAL","power":2.5,"aoe":"CROSS","status":{"type":"DRAIN","turns":0,"value":0.2}}]
	))

	return fighters

func _create_test_deck() -> Array:
	var deck = []
	# Adiciona cartas de boost de diferentes tipos
	var card_defs = [
		{"id":"boost_fire_1","display_name":"Chama Ardente","card_type":"BOOST","pt_cost":2,"rarity":"RARE",
		 "boost_fighter_type":"FIRE","boost_stat":"DAMAGE","boost_value":1.8,"boost_duration":0,"description":"+80% dano skill de Fogo"},
		{"id":"boost_any_1","display_name":"Impulso Universal","card_type":"BOOST","pt_cost":1,"rarity":"NORMAL",
		 "boost_fighter_type":"ANY","boost_stat":"DAMAGE","boost_value":1.3,"boost_duration":0,"description":"+30% dano qualquer skill"},
		{"id":"heal_single_1","display_name":"Cura Sagrada","card_type":"HEAL","pt_cost":2,"rarity":"NORMAL",
		 "heal_value":400,"heal_target":"SINGLE","description":"Restaura 400 HP"},
		{"id":"boost_dragon_1","display_name":"Poder do Dragão","card_type":"BOOST","pt_cost":2,"rarity":"RARE",
		 "boost_fighter_type":"DRAGON","boost_stat":"DAMAGE","boost_value":1.7,"boost_duration":0,"description":"+70% dano skill de Dragão"},
		{"id":"equip_sword","display_name":"Espada de Dragão","card_type":"EQUIPMENT","pt_cost":2,"rarity":"RARE",
		 "equip_stat":"atk_f","equip_value":40,"description":"+40 ATK F permanente"},
		{"id":"heal_all","display_name":"Bênção Total","card_type":"HEAL","pt_cost":3,"rarity":"RARE",
		 "heal_value":150,"heal_target":"ALL","description":"Restaura 150 HP para todos"},
	]

	# Preenche o deck com variações
	for i in range(50):
		var def = card_defs[i % card_defs.size()].duplicate()
		deck.append(Card.from_dict(def))

	return deck

# ─────────────────────────────────────────
# HELPER
# ─────────────────────────────────────────
func _make_fighter(id: String, name: String, type: String, rarity: String,
	hp: int, atk_f: int, def_f: int, atk_s: int, def_s: int, agi: int,
	skills: Array) -> Fighter:
	var f = Fighter.new()
	f.id = id
	f.display_name = name
	f.fighter_type = type
	f.rarity = rarity
	f.hp_max = hp
	f.atk_f = atk_f
	f.def_f = def_f
	f.atk_s = atk_s
	f.def_s = def_s
	f.agi = agi
	f.skills = skills
	return f
