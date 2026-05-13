# SkillResource.gd - O Container LEGO (Rule 8 & 12)
class_name SkillResource
extends Resource

@export var skill_name: String = "New Skill"
@export var icon: Texture2D
@export var description: String = ""

## Componentes LEGO
@export var targeter: BaseTargeter
@export var effects: Array[BaseEffect] = []

## Sinal para o sistema de VFX global (Rule 7)
signal skill_activated(user: Fighter, targets: Array)

## Executa o pipeline da habilidade (Rule 12)
func activate(user: Fighter, all_fighters: Array, selected_target: Fighter = null):
	if not targeter: 
		printerr("Skill %s sem Targeter!" % skill_name)
		return
		
	var targets = targeter.get_targets(user, all_fighters, selected_target)
	
	# Rule 10: Notifica ativação (VFX de 'cast' acontece aqui)
	skill_activated.emit(user, targets)
	
	for target in targets:
		for effect in effects:
			effect.execute(user, target)
	
	print("Skill %s finalizada por %s" % [skill_name, user.name])
