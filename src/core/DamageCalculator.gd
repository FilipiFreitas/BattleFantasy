# DamageCalculator.gd
# Centraliza todos os cálculos de dano do BattleFantasy.
# Aplica: dano base, vantagem de tipo, bônus posicional e multiplicador de boost.
class_name DamageCalculator
extends RefCounted

# ─────────────────────────────────────────
# MATRIZ DE TIPOS
# Carregada do arquivo JSON types_matrix.json
# ─────────────────────────────────────────
const TYPE_ADVANTAGE: float = 1.5
const TYPE_NEUTRAL: float   = 1.0
const TYPE_WEAKNESS: float  = 0.7

# Matriz de vantagens: { "TIPO_ATACANTE": { "TIPO_DEFENSOR": "ADV" | "NEU" | "WEK" } }
var _type_matrix: Dictionary = {}

# Efeitos especiais de vantagem de tipo
var _type_effects: Dictionary = {
	"FIRE":    { "type": "BURN",     "turns": 2, "value": 50 },
	"WATER":   { "type": "EXTINGUISH", "turns": 2, "value": 0 },
	"EARTH":   { "type": "IMMUNITY", "turns": 0, "value": 0 },
	"THUNDER": { "type": "OVERLOAD", "turns": 0, "value": 0 },
	"ICE":     { "type": "FREEZE",   "turns": 1, "value": 0 },
	"PSYCHIC": { "type": "CONFUSE",  "turns": 2, "value": 0 },
	"LIGHT":   { "type": "PURIFY",   "turns": 0, "value": 0 },
	"DARK":    { "type": "DRAIN",    "turns": 0, "value": 0.20 },
}

# ─────────────────────────────────────────
# INICIALIZAÇÃO
# ─────────────────────────────────────────
func initialize(matrix_data: Dictionary) -> void:
	_type_matrix = matrix_data

# ─────────────────────────────────────────
# CÁLCULO PRINCIPAL
# ─────────────────────────────────────────
func calculate(params: Dictionary) -> Dictionary:
	# params = {
	#   "attacker": Fighter,
	#   "defender": Fighter,
	#   "skill": Dictionary,          # skill usada (ou {} para ataque básico)
	#   "boost_multiplier": float,    # 1.0 se sem boost
	#   "formation_bonus": float,     # multiplicador da posição na formação
	# }

	var attacker: Fighter = params["attacker"]
	var defender: Fighter = params["defender"]
	var skill: Dictionary = params.get("skill", {})
	var boost_mult: float = params.get("boost_multiplier", 1.0)
	var formation_bonus: float = params.get("formation_bonus", 1.0)

	# Determina se é dano físico ou especial
	var damage_type = skill.get("damage_type", "PHYSICAL")
	var is_special = (damage_type == "SPECIAL")

	# Atributos efetivos
	var atk = attacker.get_effective_atk_s() if is_special else attacker.get_effective_atk_f()
	var def = defender.get_effective_def_s() if is_special else defender.get_effective_def_f()

	# Poder da skill (1.0 = ataque básico)
	var power: float = skill.get("power", 1.0)

	# DANO BASE
	var base_damage = max(1, int((atk * power) - def))

	# MULTIPLICADOR DE TIPO
	var type_relation = _get_type_relation(attacker.fighter_type, defender.fighter_type)
	var type_mult = TYPE_NEUTRAL
	var triggered_effect: Dictionary = {}

	match type_relation:
		"ADV":
			type_mult = TYPE_ADVANTAGE
			triggered_effect = _type_effects.get(attacker.fighter_type, {})
		"WEK":
			type_mult = TYPE_WEAKNESS
		_:
			type_mult = TYPE_NEUTRAL

	# DANO FINAL
	var final_damage = int(base_damage * type_mult * formation_bonus * boost_mult)
	final_damage = max(1, final_damage)

	# DRENO: atacante recupera 20% do dano se tipo DARK com vantagem
	var drain_amount = 0
	if type_relation == "ADV" and attacker.fighter_type == "DARK":
		drain_amount = int(final_damage * 0.20)

	return {
		"damage": final_damage,
		"is_critical": false,              # Para uso futuro
		"type_relation": type_relation,    # "ADV" | "NEU" | "WEK"
		"type_mult": type_mult,
		"boost_mult": boost_mult,
		"formation_bonus": formation_bonus,
		"triggered_status": triggered_effect,  # Efeito de status ativado
		"drain_amount": drain_amount,
	}

# ─────────────────────────────────────────
# CURA
# ─────────────────────────────────────────
func calculate_heal(card: Card, _target: Fighter) -> int:
	return card.heal_value

# ─────────────────────────────────────────
# AUXILIARES
# ─────────────────────────────────────────
func _get_type_relation(attacker_type: String, defender_type: String) -> String:
	if _type_matrix.is_empty():
		return "NEU"
	var attacker_row = _type_matrix.get(attacker_type, {})
	return attacker_row.get(defender_type, "NEU")

# Retorna o multiplicador de formação para um lutador em determinada posição
static func get_formation_bonus(formation: String, position: int, stat: String) -> float:
	# formation: "1-3-1" | "2-1-2" | "1-2-2"
	# position: 0-4 (índice na formação)
	# stat: "atk_f" | "atk_s" | "def_f" | "agi"
	var bonus_table = {
		"1-3-1": [
			{ "def_f": 0.85 },           # 0 = Ponta/Líder (-15% dano = +15% DEF efetiva)
			{ "atk_f": 1.05, "atk_s": 1.05 }, # 1 = Centro Esq
			{ "atk_f": 1.10, "atk_s": 1.10 }, # 2 = Centro Meio
			{ "atk_f": 1.05, "atk_s": 1.05 }, # 3 = Centro Dir
			{ "agi": 1.10 },             # 4 = Base
		],
		"2-1-2": [
			{ "def_f": 0.90 },           # 0 = Frente Esq
			{ "def_f": 0.90 },           # 1 = Frente Dir
			{ "atk_f": 1.05, "atk_s": 1.05 }, # 2 = Centro/Líder
			{ "atk_s": 1.20 },           # 3 = Fundo Esq
			{ "atk_s": 1.20 },           # 4 = Fundo Dir
		],
		"1-2-2": [
			{ "def_f": 0.75 },           # 0 = Vanguarda/Líder (-25% dano)
			{ "agi": 1.10 },             # 1 = Mid Esq
			{ "agi": 1.10 },             # 2 = Mid Dir
			{ "atk_s": 1.15 },           # 3 = Rear Esq
			{ "atk_s": 1.15 },           # 4 = Rear Dir
		],
	}

	var table = bonus_table.get(formation, [])
	if position >= table.size():
		return 1.0
	return table[position].get(stat, 1.0)
