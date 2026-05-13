# BaseTargeter.gd - Lógica de seleção de alvos (Rule 3)
class_name BaseTargeter
extends Resource

enum TargetType { SINGLE, ALL, ROW, COLUMN, SELF }
enum Side { ENEMIES, ALLIES, BOTH }

@export var target_type = TargetType.SINGLE
@export var target_side = Side.ENEMIES

## Retorna os lutadores que serão afetados pela habilidade.
## selected_target: O lutador que o jogador clicou (opcional para IA/AOE Total).
func get_targets(user: Fighter, all_fighters: Array, selected_target: Fighter = null) -> Array[Fighter]:
	var potential_targets: Array[Fighter] = []
	
	for f in all_fighters:
		if not f.is_alive: continue
		
		var is_ally = (f.fighter_type == user.fighter_type) # Simplificação temporária
		# Nota: Idealmente checaríamos se f está em player_fighters ou enemy_fighters via Engine
		
		match target_side:
			Side.ENEMIES: if is_ally: continue
			Side.ALLIES: if not is_ally: continue
	
		potential_targets.append(f)
		
	# Se for alvo único e temos uma seleção, retornamos apenas o selecionado
	if target_type == TargetType.SINGLE and selected_target != null:
		if potential_targets.has(selected_target):
			return [selected_target]
		return []
		
	return potential_targets
