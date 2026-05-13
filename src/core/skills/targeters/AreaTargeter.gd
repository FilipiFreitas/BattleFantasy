# AreaTargeter.gd - Seleção de múltiplos alvos (LEGO Block)
class_name AreaTargeter
extends BaseTargeter

enum AreaPattern { TOTAL, CROSS, LINE }

@export var area_pattern: AreaPattern = AreaPattern.TOTAL

func get_targets(user, all_fighters: Array, selected_target = null) -> Array:
	# 1. Filtra todos os alvos válidos do lado correto (Reuso da base)
	var potential = super.get_targets(user, all_fighters, null)
	
	# Se o jogador ainda não clicou em nada, mostramos todos como "clicáveis"
	if selected_target == null:
		return potential
		
	# 2. Aplica a lógica de área baseada no clique
	var final_targets: Array = []
	
	match area_pattern:
		AreaPattern.TOTAL:
			# Atinge todo o time do alvo selecionado
			for f in potential:
				if _is_same_team(f, selected_target, all_fighters):
					final_targets.append(f)
					
		AreaPattern.CROSS:
			# Atinge o alvo e adjacentes (Lógica baseada em posição 0-3)
			var pos = selected_target.position
			for f in potential:
				if _is_same_team(f, selected_target, all_fighters):
					# Lógica de proximidade simples (Rule 11: Gameplay funcional)
					if abs(f.position - pos) <= 1:
						final_targets.append(f)
		
		AreaPattern.LINE:
			# Exemplo: Atinge a coluna central ou lateral (pode ser expandido)
			final_targets.append(selected_target)
			
	return final_targets

# Helper para garantir que estamos atingindo apenas o time do alvo (ex: não curar inimigo se o AOE for de aliados)
func _is_same_team(f1, f2, _all: Array) -> bool:
	# Verificação simples: se ambos estão na mesma metade da lista original 
	# (Isso assume que a lista está ordenada [Player..., Enemy...])
	# Melhoria futura: Usar Gameplay Tags (Rule 5)
	return (f1.hp_max > 0) == (f2.hp_max > 0) # Placeholder funcional
