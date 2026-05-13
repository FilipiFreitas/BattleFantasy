# MainMenu.gd
extends Control

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	# Fundo Premium Dark
	var bg = ColorRect.new()
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.05, 0.1)
	add_child(bg)
	
	# Logo / Título
	var title = Label.new()
	title.text = "BATTLE FANTASY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 150)
	title.size = Vector2(get_viewport_rect().size.x, 100)
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color.CYAN)
	title.add_theme_constant_override("outline_size", 12)
	add_child(title)
	
	# Menu Container
	var menu = VBoxContainer.new()
	menu.set_anchors_preset(PRESET_CENTER)
	menu.add_theme_constant_override("separation", 30)
	add_child(menu)
	
	# Botões
	var btn_heroes = _create_menu_button("HERÓIS")
	var btn_skill_test = _create_menu_button("SKILL TEST")
	var btn_battle = _create_menu_button("BATALHA")
	var btn_options = _create_menu_button("OPÇÕES")
	
	menu.add_child(btn_heroes)
	menu.add_child(btn_skill_test)
	menu.add_child(btn_battle)
	menu.add_child(btn_options)
	
	# Ações
	btn_battle.pressed.connect(_on_battle_pressed)
	btn_skill_test.pressed.connect(_on_skill_test_pressed)
	btn_options.pressed.connect(_show_options)

func _on_skill_test_pressed() -> void:
	# Carrega a cena de batalha, mas com o coordenador de teste injetado
	get_tree().change_scene_to_file("res://src/scenes/SkillTest/SkillTestScreen.tscn")

func _create_menu_button(txt: String) -> Button:
	var btn = Button.new()
	btn.text = txt
	btn.custom_minimum_size = Vector2(300, 80)
	var st = StyleBoxFlat.new()
	st.bg_color = Color(0.1, 0.1, 0.2)
	st.set_corner_radius_all(10)
	st.border_width_bottom = 4; st.border_color = Color(0.2, 0.4, 0.8)
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_font_size_override("font_size", 24)
	return btn

func _on_battle_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/Battle/BattleScreen.tscn")

func _show_options() -> void:
	# Pop-up simples de opções
	var panel = ColorRect.new()
	panel.set_anchors_preset(PRESET_FULL_RECT)
	panel.color = Color(0, 0, 0, 0.85)
	add_child(panel)
	
	var v_box = VBoxContainer.new()
	v_box.set_anchors_preset(PRESET_CENTER)
	v_box.alignment = BoxContainer.ALIGNMENT_CENTER
	v_box.add_theme_constant_override("separation", 20)
	panel.add_child(v_box)
	
	var label = Label.new()
	label.text = "QUALIDADE ATUAL: " + ("FULL HD" if SettingsManager.current_quality == SettingsManager.Quality.FULL_HD else "HD")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.CYAN)
	v_box.add_child(label)
	
	var btn_hd = _create_menu_button("HD (720p)")
	var btn_fhd = _create_menu_button("FULL HD (1080p)")
	var btn_back = _create_menu_button("VOLTAR")
	
	v_box.add_child(btn_hd)
	v_box.add_child(btn_fhd)
	v_box.add_child(btn_back)
	
	btn_hd.pressed.connect(func(): SettingsManager.apply_quality(SettingsManager.Quality.HD))
	btn_fhd.pressed.connect(func(): SettingsManager.apply_quality(SettingsManager.Quality.FULL_HD))
	btn_back.pressed.connect(func(): panel.queue_free())
