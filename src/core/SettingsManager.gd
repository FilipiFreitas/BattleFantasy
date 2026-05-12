# SettingsManager.gd (Autoload)
extends Node

enum Quality { HD, FULL_HD }
var current_quality: Quality = Quality.HD
var active_hud: Node = null

func register_hud(hud: Node) -> void:
	active_hud = hud

func _ready() -> void:
	apply_quality(current_quality)

func apply_quality(q: Quality) -> void:
	current_quality = q
	var size = Vector2i(720, 1280) if q == Quality.HD else Vector2i(1080, 1920)
	
	# Ajusta o Viewport
	get_window().size = size
	# Centraliza a janela no PC (opcional)
	var screen_pos = Vector2(DisplayServer.screen_get_position())
	var screen_size = Vector2(DisplayServer.screen_get_size())
	var screen_center = screen_pos + (screen_size / 2.0)
	get_window().position = Vector2i(screen_center - (Vector2(size) / 2.0))
	
	print("Qualidade aplicada: ", "Full HD" if q == Quality.FULL_HD else "HD")
