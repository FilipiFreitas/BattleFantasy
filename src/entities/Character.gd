# Character.gd
# Representa um personagem (Herói, Inimigo ou Boss) no campo de batalha.
class_name Character
extends Resource

# ─────────────────────────────────────────
# IDENTIDADE
# ─────────────────────────────────────────
@export var id: String = ""
@export var display_name: String = ""
@export_enum("PHYSICAL", "FIRE", "WATER", "WIND", "EARTH", "THUNDER", "LIGHT", "DARK", "MAGIC", "DRAGON", "NEUTRAL") var fighter_type: String = "NEUTRAL"
@export_enum("NORMAL", "RARE", "LEGENDARY", "MYTHIC") var rarity: String = "NORMAL"
@export var portrait_path: String = ""  # Caminho para sprite da carta
@export var level: int = 1
@export var stars: int = 1               # 1 a 6 estrelas
@export_enum("D", "C", "B", "A", "S", "SS", "SSS") var rank_type: String = "D"

# ─────────────────────────────────────────
# ATRIBUTOS BASE (NÍVEL 1)
# ─────────────────────────────────────────
@export_group("Atributos Base (Lv 1)")
@export var hp_max_base: int = 1000
@export var atk_f_base: int = 100
@export var def_f_base: int = 80
@export var atk_s_base: int = 100
@export var def_s_base: int = 80
@export var agi_base: int = 100

# ─────────────────────────────────────────
# CRESCIMENTO (POR NÍVEL)
# ─────────────────────────────────────────
@export_group("Crescimento por Nível")
@export var hp_growth: int = 50
@export var atk_f_growth: int = 5
@export var def_f_growth: int = 4
@export var atk_s_growth: int = 5
@export var def_s_growth: int = 4
@export var agi_growth: int = 1

# ─────────────────────────────────────────
# HABILIDADES (Regra 1 + 3 + 1)
# ─────────────────────────────────────────
@export_group("Habilidades")
@export var basic_attack: SkillResource
@export var skill_1: SkillResource
@export var skill_2: SkillResource
@export var skill_3: SkillResource
@export var extra_skill: SkillResource # Slot de Equipamento

# Lista interna consolidada para o motor de batalha
var skills: Array = []

# ─────────────────────────────────────────
# ESTADO DE BATALHA (Calculado no initialize)
# ─────────────────────────────────────────
var hp_max: int = 0
var atk_f: int = 0
var def_f: int = 0
var atk_s: int = 0
var def_s: int = 0
var agi: int = 0

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
# INICIALIZAÇÃO
# ─────────────────────────────────────────
func initialize() -> void:
	# Cálculo de Atributos por Nível (LEGO Rule 15: Progressão Dinâmica)
	var level_factor = level - 1
	hp_max = hp_max_base + (hp_growth * level_factor)
	atk_f = atk_f_base + (atk_f_growth * level_factor)
	def_f = def_f_base + (def_f_growth * level_factor)
	atk_s = atk_s_base + (atk_s_growth * level_factor)
	def_s = def_s_base + (def_s_growth * level_factor)
	agi = agi_base + (agi_growth * level_factor)

	hp = hp_max
	is_alive = true
	cooldowns = {}
	status_effects = []
	active_boosts = []
	equipment_buffs = { "atk_f": 0, "def_f": 0, "atk_s": 0, "def_s": 0, "agi": 0 }
	
	# Consolida as habilidades dos slots na lista única de execução
	skills = []
	if basic_attack: skills.append(basic_attack)
	if skill_1: skills.append(skill_1)
	if skill_2: skills.append(skill_2)
	if skill_3: skills.append(skill_3)
	if extra_skill: skills.append(extra_skill)
	
	# Inicializa cooldowns
	for skill in skills:
		var s_id = _get_skill_id(skill)
		if s_id != "":
			cooldowns[s_id] = 0

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
# HELPER PRIVADO (Modularização)
# ─────────────────────────────────────────
func _get_skill_id(skill: Variant) -> String:
	if skill is Dictionary: return skill.get("id", "")
	if skill is SkillResource: return skill.skill_name.to_snake_case()
	return ""

func _get_skill_pt_cost(skill: Variant) -> int:
	if skill is Dictionary: return skill.get("pt_cost", 0)
	if skill is SkillResource: return skill.pt_cost
	return 0 

func _get_skill_cd(skill: Variant) -> int:
	if skill is Dictionary: return skill.get("cd", 0)
	if skill is SkillResource: return skill.cooldown
	return 0

# ─────────────────────────────────────────
# SKILLS — VERIFICAÇÕES
# ─────────────────────────────────────────
func is_skill_available(skill_id: String, current_pt: int) -> bool:
	var skill = get_skill_by_id(skill_id)
	if skill == null: return false
	
	var cd = cooldowns.get(skill_id, 0)
	if cd > 0: return false
	
	var cost = _get_skill_pt_cost(skill)
	if cost > current_pt: return false
	
	return true

func get_skill_by_id(skill_id: String) -> Variant:
	for skill in skills:
		if _get_skill_id(skill) == skill_id:
			return skill
	return null

func get_available_skills(current_pt: int) -> Array:
	var available = []
	for skill in skills:
		var s_id = _get_skill_id(skill)
		if is_skill_available(s_id, current_pt):
			available.append(skill)
	return available

# ─────────────────────────────────────────
# COOLDOWNS E STATUS
# ─────────────────────────────────────────
func activate_cooldown(skill_id: String) -> void:
	var skill = get_skill_by_id(skill_id)
	if skill:
		cooldowns[skill_id] = _get_skill_cd(skill)

func tick_cooldowns() -> void:
	for skill_id in cooldowns:
		if cooldowns[skill_id] > 0:
			cooldowns[skill_id] -= 1

func tick_status_effects() -> int:
	var expired = []
	var damage_from_status = 0
	for effect in status_effects:
		if effect["turns"] > 0:
			if effect["type"] == "BURN":
				damage_from_status += effect["value"]
			elif effect["type"] == "POISON":
				damage_from_status += int(hp_max * effect.get("value", 0.0))
		effect["turns"] -= 1
		if effect["turns"] <= 0:
			expired.append(effect)
	for e in expired:
		status_effects.erase(e)
		
	var actual_dmg = 0
	if damage_from_status > 0:
		actual_dmg = take_damage(damage_from_status)
		
	return actual_dmg

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
