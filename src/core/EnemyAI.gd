class_name EnemyAI
extends Node

var engine: BattleEngine

func setup(battle_engine: BattleEngine) -> void:
	engine = battle_engine
	engine.turn_started.connect(_on_turn_started)

func _on_turn_started(fighter: Fighter, is_player: bool) -> void:
	if is_player or not fighter.is_alive: return
	
	# Delay for dramatic effect and to allow player to see whose turn it is
	await get_tree().create_timer(1.2).timeout
	
	# Double check if battle ended or fighter died during the delay
	var is_battle_over = engine.state in [engine.BattleState.VICTORY, engine.BattleState.DEFEAT, engine.BattleState.DRAW]
	var alive_players = engine.player_fighters.filter(func(f): return f.is_alive)
	if not fighter.is_alive or alive_players.is_empty() or is_battle_over:
		if not is_battle_over and engine.state == engine.BattleState.ENEMY_TURN:
			engine.skip_turn()
		return
	
	_take_turn(fighter, alive_players)

func _take_turn(fighter: Fighter, alive_players: Array) -> void:
	var target = _choose_target(alive_players)
	if not target:
		engine.skip_turn() # Fallback
		return
	
	var skill_id = _choose_skill(fighter)
	
	# Execute
	if engine.use_skill(skill_id, [target]):
		# Delay extra após o ataque para o jogador ver o efeito e respirar
		await get_tree().create_timer(1.5).timeout
	else:
		engine.skip_turn()

func _choose_target(alive_players: Array) -> Fighter:
	# Simple AI: attack lowest HP percentage
	var best_target = alive_players[0]
	var min_hp_pct = float(best_target.hp) / best_target.hp_max
	
	for i in range(1, alive_players.size()):
		var pct = float(alive_players[i].hp) / alive_players[i].hp_max
		if pct < min_hp_pct:
			min_hp_pct = pct
			best_target = alive_players[i]
			
	return best_target

func _choose_skill(fighter: Fighter) -> String:
	var pt = 99 # Ignora limitação de PT do jogador
	var basic_id = "basic"
	
	for sk in fighter.skills:
		if sk["id"].ends_with("_basic"): basic_id = sk["id"]
	
	var available_skills = []
	for sk in fighter.skills:
		if sk["id"].ends_with("_basic"): continue
		if fighter.is_skill_available(sk["id"], pt):
			available_skills.append(sk["id"])
	
	# 50% chance to use a special skill if available and affordable
	if not available_skills.is_empty() and randf() < 0.5:
		available_skills.shuffle()
		return available_skills[0]
		
	return basic_id
