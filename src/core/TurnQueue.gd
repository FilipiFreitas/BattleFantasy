# TurnQueue.gd
# Gerencia a fila de turnos ordenada por AGI.
# Recalcula a fila a cada nova rodada para refletir debuffs de AGI (ex: Congelar).
class_name TurnQueue
extends RefCounted

# ─────────────────────────────────────────
# ESTADO
# ─────────────────────────────────────────
var _queue: Array = []          # Array de Fighter ordenado por AGI desc
var _current_index: int = 0
var _round_number: int = 0

signal turn_started(fighter: Fighter)
signal round_started(round_number: int)

# ─────────────────────────────────────────
# INICIALIZAÇÃO
# ─────────────────────────────────────────

# Recebe os 10 lutadores (5 aliados + 5 inimigos) e monta a fila inicial
func initialize(all_fighters: Array) -> void:
	_round_number = 0
	_current_index = 0
	_rebuild_queue(all_fighters)

# ─────────────────────────────────────────
# CONTROLE DE RODADA
# ─────────────────────────────────────────

# Chamado ao fim de cada rodada completa — reconstrói a fila com AGIs atualizadas
func start_new_round(all_fighters: Array) -> void:
	_round_number += 1
	_current_index = 0
	_rebuild_queue(all_fighters)
	emit_signal("round_started", _round_number)

# Retorna o lutador do turno atual
func get_active_fighter() -> Fighter:
	if _queue.is_empty():
		return null
	return _queue[_current_index]

# Avança para o próximo lutador na fila
# Retorna true se a rodada terminou (voltou ao índice 0)
func advance() -> bool:
	_current_index += 1
	if _current_index >= _queue.size():
		return true  # Rodada encerrada
	var next = _queue[_current_index]
	emit_signal("turn_started", next)
	return false

# Verifica se a rodada atual terminou
func is_round_over() -> bool:
	return _current_index >= _queue.size()

# ─────────────────────────────────────────
# INTERNOS
# ─────────────────────────────────────────

func _rebuild_queue(all_fighters: Array) -> void:
	# Filtra apenas lutadores vivos
	var alive = all_fighters.filter(func(f): return f.is_alive)

	# Ordena por AGI efetiva (decrescente)
	# Empate: posição menor age primeiro (Líder de formação priorizado)
	alive.sort_custom(func(a, b):
		var agi_a = a.get_effective_agi()
		var agi_b = b.get_effective_agi()
		if agi_a != agi_b:
			return agi_a > agi_b
		return a.position < b.position
	)

	_queue = alive

# ─────────────────────────────────────────
# UTILITÁRIOS
# ─────────────────────────────────────────

func get_queue_snapshot() -> Array:
	return _queue.map(func(f): return {
		"id": f.id,
		"display_name": f.display_name,
		"agi": f.get_effective_agi(),
		"hp": f.hp,
		"hp_max": f.hp_max,
		"is_active": _queue[_current_index] == f
	})

func get_round_number() -> int:
	return _round_number

func get_remaining_in_round() -> int:
	return _queue.size() - _current_index

# Retorna os próximos N lutadores na ordem (incluindo o atual)
func get_upcoming(count: int) -> Array:
	var upcoming = []
	var size = _queue.size()
	if size == 0: return upcoming
	
	for i in range(count):
		var idx = (_current_index + i) % size
		upcoming.append(_queue[idx])
	return upcoming
