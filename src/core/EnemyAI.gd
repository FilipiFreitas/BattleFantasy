# EnemyAI.gd
# Lógica simples de IA para inimigos.
extends RefCounted

var engine

func setup(_engine) -> void:
	self.engine = _engine
	engine.turn_started.connect(_on_turn_started)

func _on_turn_started(unit, is_player: bool) -> void:
	if is_player or not unit.is_alive:
		return
		
	# Espera um pouco antes de agir (Rule 11)
	await engine.get_tree().create_timer(0.8).timeout
	_take_turn(unit, engine.player_characters)

func _take_turn(unit, alive_players: Array) -> void:
	if alive_players.is_empty():
		return

	var target = _choose_target(alive_players)
	var skill_id = _choose_skill(unit)
	
	print("[EnemyAI] %s usa %s em %s" % [unit.display_name, skill_id, target.display_name])
	engine.use_skill(skill_id, [target])

func _choose_target(alive_players: Array):
	# Prioriza o jogador com menor HP (estratégico)
	var best_target = alive_players[0]
	for i in range(1, alive_players.size()):
		if alive_players[i].hp < best_target.hp:
			best_target = alive_players[i]
			
	return best_target

func _choose_skill(unit) -> String:
	var pt = 99 # Inimigos ignoram PT por enquanto para simplificar
	
	# Busca habilidades disponíveis (LEGO Rule 12)
	var available_ids = []
	for sk in unit.skills:
		var s_id = unit._get_skill_id(sk)
		if s_id == "basic" or s_id == "": continue # Pula o básico na lista de 'especiais'
		
		if unit.is_skill_available(s_id, pt):
			available_ids.append(s_id)
	
	# 40% de chance de usar uma skill especial se houver alguma disponível
	if not available_ids.is_empty() and randf() < 0.4:
		available_ids.shuffle()
		return available_ids[0]
	
	# Caso contrário, usa o ataque básico padrão
	return "basic"
