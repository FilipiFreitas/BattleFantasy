# PTManager.gd
# Gerencia os Pontos de Turno (PT) — o sistema de mana do BattleFantasy.
# Sistema de RAMPA: começa em 1 PT no turno 1, ganha +1 por turno, máximo 10.
# Mecânicas especiais podem conceder +1 PT/turno permanente.
class_name PTManager
extends RefCounted

# ─────────────────────────────────────────
# CONSTANTES
# ─────────────────────────────────────────
const PT_MAX_BASE: int = 10
const PT_START: int = 1

# ─────────────────────────────────────────
# ESTADO
# ─────────────────────────────────────────
var _turn_number: int = 0
var _pt_current: int = 0
var _pt_max_current: int = 0
var _pt_bonus_per_turn: int = 0   # Bônus permanente de mecânicas especiais

signal pt_changed(current: int, maximum: int)

# ─────────────────────────────────────────
# INICIALIZAÇÃO
# ─────────────────────────────────────────
func initialize() -> void:
	_turn_number = 0
	_pt_current = 0
	_pt_max_current = 0
	_pt_bonus_per_turn = 0

# ─────────────────────────────────────────
# INÍCIO DE TURNO — Refresh de PT
# ─────────────────────────────────────────
func on_turn_start(turn_number: int) -> void:
	_turn_number = turn_number
	# Rampa: PT máximo = turno atual + bonus, limitado pelo cap base
	_pt_max_current = mini(turn_number + _pt_bonus_per_turn, PT_MAX_BASE)
	_pt_current = _pt_max_current
	emit_signal("pt_changed", _pt_current, _pt_max_current)

# ─────────────────────────────────────────
# GASTO DE PT
# ─────────────────────────────────────────

# Tenta gastar PT. Retorna true se sucesso, false se PT insuficiente.
func spend(amount: int) -> bool:
	if amount > _pt_current:
		return false
	_pt_current -= amount
	emit_signal("pt_changed", _pt_current, _pt_max_current)
	return true

# Verifica se há PT suficiente sem gastar
func can_afford(amount: int) -> bool:
	return _pt_current >= amount

# ─────────────────────────────────────────
# BÔNUS PERMANENTE (mecânicas especiais)
# ─────────────────────────────────────────

# Adiciona +1 PT por turno permanentemente (ex: habilidade passiva de lutador)
func add_permanent_pt_bonus(amount: int = 1) -> void:
	_pt_bonus_per_turn += amount
	# Já aplica no turno atual se estivermos no meio de uma batalha
	_pt_max_current = mini(_pt_max_current + amount, PT_MAX_BASE)
	_pt_current = mini(_pt_current + amount, _pt_max_current)
	emit_signal("pt_changed", _pt_current, _pt_max_current)

# ─────────────────────────────────────────
# FIM DE TURNO — PT não usado é perdido
# ─────────────────────────────────────────
func on_turn_end() -> void:
	_pt_current = 0
	emit_signal("pt_changed", _pt_current, _pt_max_current)

# ─────────────────────────────────────────
# GETTERS
# ─────────────────────────────────────────
func get_current() -> int:
	return _pt_current

func get_maximum() -> int:
	return _pt_max_current

func get_turn_number() -> int:
	return _turn_number

# Retorna array de bools para renderizar a barra de PT na UI
# Ex: [true, true, true, false, false, ...] para 3/10 PT
func get_pt_bar_state() -> Array:
	var bar = []
	for i in range(PT_MAX_BASE):
		bar.append(i < _pt_current)
	return bar
