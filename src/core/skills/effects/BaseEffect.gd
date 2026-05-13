# BaseEffect.gd - Ação isolada que acontece em um alvo (Rule 6)
class_name BaseEffect
extends Resource

## Sinal emitido quando o efeito é aplicado (Rule 7/10: Visual separado da lógica)
## A HUD/VFX vai escutar isso para tocar sons ou spawnar partículas.
signal effect_applied(target, value: Variant)

## Método principal que cada efeito deve implementar.
func execute(_user, _target):
	pass
