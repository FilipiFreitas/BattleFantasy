# Fighter.gd
# Representa um lutador no campo de batalha.
# Contém todos os atributos base, estado de batalha, skills e efeitos de status.
class_name Fighter
extends Resource

# ─────────────────────────────────────────
# IDENTIDADE
# ─────────────────────────────────────────
@export var id: String = ""
@export var display_name: String = ""
@export var fighter_type: String = ""   # "FIRE" | "WATER" | "DRAGON" | etc.
@export var rarity: String = "NORMAL"   # "NORMAL" | "RARE" | "LEGENDARY" | "MYTHIC"
@export var portrait_path: String = ""  # Caminho para sprite da carta

# ─────────────────────────────────────────
# ATRIBUTOS BASE
# ─────────────────────────────────────────
@export var hp_max: int = 1000
@export var atk_f: int = 100   # Ataque Físico
@export var def_f: int = 80    # Defesa Física
@export var atk_s: int = 100   # Ataque Especial
@export var def_s: int = 80    # Defesa Especial
@export var agi: int = 100     # Agilidade (define ordem na TurnQueue)

# ─────────────────────────────────────────
# ESTADO DE BATALHA (mutável durante a luta)
# ─────────────────────────────────────────
var hp: int = 0
var position: int = 0            # Índice 0-4 na formação
var is_alive: bool = true
var cooldowns: Dictionary = {}   # { "skill_id": turns_remaining }
var status_effects: Array = []   # [{ "type", "turns", "value", "source" }]
var active_boosts: Array = []    # Boosts aplicados da mão (expiram ao usar)
var equipment_buffs: Dictionary = {
	"atk_f": 0, "def_f": 0, "atk_s": 0, "def_s": 0, "agi": 0
}

# ─────────────────────────────────────────
# HABILIDADES (built-in — não vêm do deck)
# ─────────────────────────────────────────
@export var skills: Array = []
# Formato de cada skill:
# {
#   "id": "ignis_flame_wave",
#   "name": "Flame Wave",
#   "pt_cost": 2,
#   "cd": 3,
#   "type": "FIRE",
#   "damage_type": "SPECIAL",   # "PHYSICAL" | "SPECIAL"
#   "power": 1.4,               # Multiplicador do ATK base
#   "aoe": "SINGLE",            # "SINGLE" | "LINE" | "CROSS" | "TOTAL"
#   "status": { "type": "BURN", "turns": 2, "value": 50 }
# }

@export var passive: Dictionary = {}
# Formato: { "id": "...", "description": "...", "effect_type": "...", "value": ... }

@export var leadership: Dictionary = {}
# Exclusivo Míticas. Ativo quando na posição de Líder da formação.

# ─────────────────────────────────────────
# INICIALIZAÇÃO
# ─────────────────────────────────────────
func initialize() -> void:
	hp = hp_max
	cooldowns = {}
	status_effects = []
	active_boosts = []
	equipment_buffs = { "atk_f": 0, "def_f": 0, "atk_s": 0, "def_s": 0, "agi": 0 }
	is_alive = true
	for skill in skills:
		cooldowns[skill["id"]] = 0

# ─────────────────────────────────────────
# ATRIBUTOS EFETIVOS (base + buffs de equipamento)
# ─────────────────────────────────────────
func get_effective_atk_f() -> int:
	return atk_f + equipment_buffs["atk_f"]

func get_effective_def_f() -> int:
	return def_f + equipment_buffs["def_f"]

func get_effective_atk_s() -> int:
	return atk_s + equipment_buffs["atk_s"]

func get_effective_def_s() -> int:
	return def_s + equipment_buffs["def_s"]

func get_effective_agi() -> int:
	var base = agi + equipment_buffs["agi"]
	# Aplica debuff de Congelar se ativo
	for effect in status_effects:
		if effect["type"] == "FREEZE":
			return int(base * 0.5)
	return base

# ─────────────────────────────────────────
# DANO E CURA
# ─────────────────────────────────────────
func take_damage(amount: int) -> int:
	var actual = max(1, amount)
	hp = max(0, hp - actual)
	if hp == 0:
		is_alive = false
	return actual

func heal(amount: int) -> int:
	var actual = min(amount, hp_max - hp)
	hp += actual
	return actual

# ─────────────────────────────────────────
# SKILLS — VERIFICAÇÕES
# ─────────────────────────────────────────
func is_skill_available(skill_id: String, current_pt: int) -> bool:
	var skill = get_skill_by_id(skill_id)
	if skill.is_empty():
		return false
	var cd = cooldowns.get(skill_id, 0)
	if cd > 0:
		return false
	if skill["pt_cost"] > current_pt:
		return false
	return true

func get_skill_by_id(skill_id: String) -> Dictionary:
	for skill in skills:
		if skill["id"] == skill_id:
			return skill
	return {}

func get_available_skills(current_pt: int) -> Array:
	var available = []
	for skill in skills:
		if is_skill_available(skill["id"], current_pt):
			available.append(skill)
	return available

# ─────────────────────────────────────────
# COOLDOWNS E STATUS
# ─────────────────────────────────────────
func activate_cooldown(skill_id: String) -> void:
	var skill = get_skill_by_id(skill_id)
	if not skill.is_empty():
		cooldowns[skill_id] = skill["cd"]

func tick_cooldowns() -> void:
	for skill_id in cooldowns:
		if cooldowns[skill_id] > 0:
			cooldowns[skill_id] -= 1

func tick_status_effects() -> Array:
	var expired = []
	var damage_from_burn = 0
	for effect in status_effects:
		if effect["type"] == "BURN":
			damage_from_burn += effect["value"]
		effect["turns"] -= 1
		if effect["turns"] <= 0:
			expired.append(effect)
	for e in expired:
		status_effects.erase(e)
	if damage_from_burn > 0:
		take_damage(damage_from_burn)
	return expired

func apply_status(effect: Dictionary) -> void:
	# Evita duplicata do mesmo tipo (atualiza se já existe)
	for existing in status_effects:
		if existing["type"] == effect["type"]:
			existing["turns"] = max(existing["turns"], effect["turns"])
			existing["value"] = max(existing["value"], effect.get("value", 0))
			return
	status_effects.append(effect.duplicate())

func remove_all_buffs() -> void:
	# Purificação: remove todos os efeitos positivos
	status_effects = status_effects.filter(
		func(e): return e.get("is_buff", false) == false
	)

# ─────────────────────────────────────────
# EQUIPAMENTO
# ─────────────────────────────────────────
func apply_equipment(card_data: Dictionary) -> void:
	var stat = card_data.get("equip_stat", "")
	var value = card_data.get("equip_value", 0)
	if stat in equipment_buffs:
		equipment_buffs[stat] += value

# ─────────────────────────────────────────
# SERIALIZAÇÃO (para debug e rede)
# ─────────────────────────────────────────
func to_dict() -> Dictionary:
	return {
		"id": id,
		"display_name": display_name,
		"type": fighter_type,
		"rarity": rarity,
		"hp": hp,
		"hp_max": hp_max,
		"atk_f": get_effective_atk_f(),
		"def_f": get_effective_def_f(),
		"atk_s": get_effective_atk_s(),
		"def_s": get_effective_def_s(),
		"agi": get_effective_agi(),
		"position": position,
		"is_alive": is_alive,
		"status_effects": status_effects,
		"cooldowns": cooldowns
	}
