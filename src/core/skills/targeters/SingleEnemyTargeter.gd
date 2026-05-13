# SingleEnemyTargeter.gd - Seleciona um único inimigo (LEGO Block)
class_name SingleEnemyTargeter
extends BaseTargeter

func _init():
	target_type = TargetType.SINGLE
	target_side = Side.ENEMIES

## Sobrescreve para lógica específica se necessário. 
## Por padrão, o BaseTargeter já faz um filtro grosso.
## Aqui poderíamos adicionar lógica de 'mais vida', 'mais perto', etc.
func get_targets(user, all_fighters: Array, selected_target = null) -> Array:
	var potential = super.get_targets(user, all_fighters, selected_target)
	
	if potential.size() > 0:
		# Para IA, podemos retornar o primeiro. 
		# Para o Player, a HUD vai filtrar o clique.
		return [potential[0]] 
	
	return []
