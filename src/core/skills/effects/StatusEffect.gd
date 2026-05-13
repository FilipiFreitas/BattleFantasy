# StatusEffect.gd - Aplica buffs/debuffs a um alvo (LEGO Block)
class_name StatusEffect
extends BaseEffect

@export_enum("BURN", "POISON", "FREEZE", "STUN", "BLEED") var status_type: String = "BURN"
@export var turns: int = 2
@export var value: int = 50

func execute(user, target):
	var status_data = {
		"type": status_type,
		"turns": turns,
		"value": value,
		"source": user.display_name
	}
	
	target.apply_status(status_data)
	
	# Rule 7: Sinal para feedback visual (ícones flutuantes, etc)
	effect_applied.emit(target, status_data)
	print("Effect: %s applied %s to %s for %d turns" % [user.display_name, status_type, target.display_name, turns])
