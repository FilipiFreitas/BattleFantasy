# HealEffect.gd - Restaura HP de um alvo (LEGO Block)
class_name HealEffect
extends BaseEffect

@export var heal_amount: int = 20

func execute(user, target):
	var actual_heal = target.heal(heal_amount)
	
	# Rule 7: Emitimos o sinal para que a HUD mostre números verdes
	effect_applied.emit(target, actual_heal)
	print("Effect: %s healed %s for %d HP" % [user.display_name, target.display_name, actual_heal])
