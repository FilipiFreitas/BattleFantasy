# FighterSlotUI.gd
class_name FighterSlotUI
extends Control

signal clicked(slot: FighterSlotUI)

var _card: HeroCard
var _hp_label: Label
var fighter: Fighter = null

func _ready() -> void:
	custom_minimum_size = Vector2(120, 200)
	size = Vector2(120, 200)

	_card = HeroCard.new()
	add_child(_card)

	_hp_label = Label.new()
	_hp_label.position = Vector2(0, 185)
	_hp_label.size = Vector2(120, 20)
	_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hp_label.add_theme_font_size_override("font_size", 14)
	_hp_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_hp_label.add_theme_constant_override("outline_size", 4)
	add_child(_hp_label)
	
	var btn = Button.new()
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.pressed.connect(func(): clicked.emit(self))
	add_child(btn)

func setup(f: Fighter, _side: bool) -> void:
	fighter = f
	_card.setup(f)
	_update_hp()

func refresh() -> void:
	if fighter == null:
		return
	_update_hp()
	if not fighter.is_alive:
		modulate = Color(0.3, 0.3, 0.3, 0.5)

func _update_hp() -> void:
	if fighter:
		_hp_label.text = "HP: %d / %d" % [fighter.hp, fighter.hp_max]
