# DamageEffect.gd - Aplica dano bruto a um alvo.
class_name DamageEffect
extends BaseEffect

@export var damage_value: int = 10
@export_enum("physical", "fire", "water", "wind", "earth", "thunder", "light", "dark") var element: String = "physical"

func execute(user, target):
	# Aqui entrariam cálculos de defesa, buffs, etc. (Rule 4: DamageSystem)
	# Por enquanto, aplicação direta para validar a estrutura.
	var final_dmg = damage_value 
	
	target.take_damage(final_dmg)
	
	# Rule 7: Emitimos o sinal. O visual (VFX/SFX) decide o que fazer.
	effect_applied.emit(target, final_dmg)
	print("Effect: %s dealt %d %s dmg to %s" % [user.name, final_dmg, element, target.name])
