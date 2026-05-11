# Card.gd
# Representa uma carta do deck do jogador (Boost, Heal ou Equipamento).
# NÃO é um lutador — é uma carta de suporte jogada da mão durante a batalha.
class_name Card
extends Resource

# ─────────────────────────────────────────
# IDENTIDADE
# ─────────────────────────────────────────
@export var id: String = ""
@export var display_name: String = ""
@export var card_type: String = "BOOST"   # "BOOST" | "HEAL" | "EQUIPMENT"
@export var pt_cost: int = 1              # Custo em Pontos de Turno (1–3)
@export var rarity: String = "NORMAL"     # "NORMAL" | "RARE" | "LEGENDARY" | "MYTHIC"
@export var art_path: String = ""         # Caminho para arte da carta
@export var description: String = ""      # Texto descritivo exibido na carta

# ─────────────────────────────────────────
# BOOST (amplifica a próxima skill do lutador ativo)
# ─────────────────────────────────────────
@export var boost_fighter_type: String = "ANY"   # Tipo-alvo ou "ANY"
@export var boost_stat: String = "DAMAGE"        # "DAMAGE" | "ATK_F" | "ATK_S"
@export var boost_value: float = 1.0             # Multiplicador (ex: 1.8 = +80%)
@export var boost_duration: int = 0              # 0 = apenas a próxima skill usada

# ─────────────────────────────────────────
# HEAL (restaura HP de lutador(es) aliado(s))
# ─────────────────────────────────────────
@export var heal_value: int = 0
@export var heal_target: String = "SINGLE"   # "SINGLE" | "ALL" | "LOWEST_HP"

# ─────────────────────────────────────────
# EQUIPMENT (buff permanente até o fim da batalha)
# ─────────────────────────────────────────
@export var equip_stat: String = ""    # "atk_f" | "def_f" | "atk_s" | "def_s" | "agi"
@export var equip_value: int = 0       # Valor do buff

# ─────────────────────────────────────────
# CAMPO (altera o cenário global)
# ─────────────────────────────────────────
@export var is_field_card: bool = false
@export var field_effect_type: String = ""   # "MISS_CHANCE" | "TYPE_BUFF" | "REGEN" | etc.
@export var field_duration: int = 0
@export var field_value: float = 0.0
@export var field_target_type: String = ""   # Tipo afetado (se aplicável)

# ─────────────────────────────────────────
# LÓGICA DE VALIDAÇÃO
# ─────────────────────────────────────────

# Verifica se o boost desta carta se aplica ao tipo de lutador
func applies_to_fighter(fighter_type: String) -> bool:
	if card_type != "BOOST":
		return false
	return boost_fighter_type == "ANY" or boost_fighter_type == fighter_type

# Retorna o multiplicador final de boost (com bônus de tipo se combinar)
func get_boost_multiplier(fighter_type: String) -> float:
	if not applies_to_fighter(fighter_type):
		return 1.0
	# Bônus de +20% se o tipo da carta for o mesmo do lutador (não é ANY)
	if boost_fighter_type != "ANY" and boost_fighter_type == fighter_type:
		return boost_value + 0.20
	return boost_value

# ─────────────────────────────────────────
# FACTORY — cria uma Card a partir de um dicionário JSON
# ─────────────────────────────────────────
static func from_dict(data: Dictionary) -> Card:
	var card = Card.new()
	card.id = data.get("id", "")
	card.display_name = data.get("display_name", "")
	card.card_type = data.get("card_type", "BOOST")
	card.pt_cost = data.get("pt_cost", 1)
	card.rarity = data.get("rarity", "NORMAL")
	card.art_path = data.get("art_path", "")
	card.description = data.get("description", "")

	match card.card_type:
		"BOOST":
			card.boost_fighter_type = data.get("boost_fighter_type", "ANY")
			card.boost_stat = data.get("boost_stat", "DAMAGE")
			card.boost_value = data.get("boost_value", 1.0)
			card.boost_duration = data.get("boost_duration", 0)
		"HEAL":
			card.heal_value = data.get("heal_value", 0)
			card.heal_target = data.get("heal_target", "SINGLE")
		"EQUIPMENT":
			card.equip_stat = data.get("equip_stat", "")
			card.equip_value = data.get("equip_value", 0)
		"FIELD":
			card.is_field_card = true
			card.field_effect_type = data.get("field_effect_type", "")
			card.field_duration = data.get("field_duration", 0)
			card.field_value = data.get("field_value", 0.0)
			card.field_target_type = data.get("field_target_type", "")

	return card

# ─────────────────────────────────────────
# SERIALIZAÇÃO
# ─────────────────────────────────────────
func to_dict() -> Dictionary:
	return {
		"id": id,
		"display_name": display_name,
		"card_type": card_type,
		"pt_cost": pt_cost,
		"rarity": rarity,
		"description": description
	}
