# VFXServer.gd - Gerenciador global de feedback visual (Rule 7 & 15)
# Este sistema escuta os efeitos lógicos e decide o que spawnar na tela.
extends Node

## Sinal emitido quando um efeito de dano acontece
signal damage_vfx_requested(target: unit, amount: int, element: String)

## Sinal emitido quando uma habilidade inicia
signal skill_vfx_requested(user: unit, targets: Array, skill_name: String)

func request_damage_vfx(target: unit, amount: int, element: String = "physical"):
	damage_vfx_requested.emit(target, amount, element)

func request_skill_vfx(user: unit, targets: Array, skill_name: String):
	skill_vfx_requested.emit(user, targets, skill_name)
