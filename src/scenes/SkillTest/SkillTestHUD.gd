# SkillTestHUD.gd - Versão especializada do HUD para testes (LEGO Rule 14)
class_name SkillTestHUD
extends BattleHUD

func _build_ui() -> void:
	super._build_ui() # Constrói o HUD base padrão
	
	# Adiciona o rótulo de modo teste apenas aqui
	var test_lbl = Label.new()
	test_lbl.text = "SANDBOX / SKILL TEST"
	test_lbl.position = Vector2(10, 2)
	test_lbl.add_theme_font_size_override("font_size", 9)
	test_lbl.modulate = Color(1.0, 0.8, 0.2, 0.7)
	_head_region.add_child(test_lbl)
	
	# Adiciona o botão de restart apenas aqui
	var btn_restart = Button.new()
	btn_restart.text = "↺"
	btn_restart.custom_minimum_size = Vector2(24, 24)
	btn_restart.position = Vector2(W - 40, 24)
	btn_restart.add_theme_font_size_override("font_size", 14)
	var res_st = StyleBoxFlat.new()
	res_st.bg_color = Color(0.3, 0.1, 0.1, 0.5)
	res_st.set_corner_radius_all(4)
	btn_restart.add_theme_stylebox_override("normal", res_st)
	btn_restart.pressed.connect(func(): engine.restart_battle())
	_head_region.add_child(btn_restart)

# Sobrescreve o clique para permitir a seleção livre no modo teste
func _on_slot_clicked(slot: CharacterSlotUI) -> void:
	if not slot.unit or not slot.unit.is_alive: return
	
	if not targeting_mode:
		if engine.player_characters.has(slot.unit):
			engine.force_active_character(slot.unit)
		return

	super._on_slot_clicked(slot)

func _on_modular_skill_activated(user: unit, _targets: Array, skill: SkillResource) -> void:
	super._on_modular_skill_activated(user, _targets, skill)
