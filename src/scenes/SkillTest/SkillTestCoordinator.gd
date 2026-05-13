# SkillTestCoordinator.gd - Orquestrador do Laboratório de Habilidades
extends Node2D

func _ready() -> void:
	await get_tree().process_frame
	_setup_skill_test()

func _setup_skill_test() -> void:
	# No Laboratório, usamos a mesma BattleEngine, mas com o HUD especializado
	var engine: BattleEngine = get_parent() as BattleEngine
	var hud: BattleHUD = get_parent().get_node_or_null("HUD")
	
	if hud:
		# Transforma o HUD comum em HUD de Teste dinamicamente
		hud.set_script(load("res://src/scenes/SkillTest/SkillTestHUD.gd"))
		hud._build_ui()
		hud.connect_to_engine(engine)

	# Carrega os heróis de teste com as novas skills modulares
	var player_team = _get_modular_test_team()
	var enemy_team = _get_dummy_enemies()
	
	engine.setup_battle(player_team, enemy_team, [], "1-2-1", "1-2-1", {})
	hud.setup_battle(player_team, enemy_team, "1-2-1", "1-2-1")
	engine.start_battle()
	
	print("[SkillTest] Laboratório iniciado com sucesso!")

func _get_modular_test_team() -> Array:
	# Carrega os heróis reais que criamos como Resources
	var kael = load("res://data/heroes/Kael.tres")
	var ignis = load("res://data/heroes/Ignis.tres")
	
	# Inicializa o HP deles para a batalha
	kael.initialize()
	ignis.initialize()
	
	return [kael, ignis]

func _get_dummy_enemies() -> Array:
	var enemies = [
		load("res://data/enemies/GoblinCharacter.tres"),
		load("res://data/enemies/GoblinArcher.tres"),
		load("res://data/enemies/GoblinShaman.tres"),
		load("res://data/enemies/Troll.tres")
	]
	
	for e in enemies:
		e.initialize()
		
	return enemies
