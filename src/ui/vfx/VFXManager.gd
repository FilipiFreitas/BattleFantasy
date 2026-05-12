# VFXManager.gd
# Gerencia efeitos visuais temporários no campo de batalha (projéteis, impactos, feixes).
# Segue boas práticas de modularização, isolando a lógica visual da lógica de HUD.
class_name VFXManager
extends Node

# Lança um projétil procedural entre dois pontos
static func launch_projectile(parent: Node, from: Vector2, to: Vector2, color: Color, on_hit: Callable) -> void:
	var dot = ColorRect.new()
	dot.size = Vector2(8, 8)
	dot.pivot_offset = Vector2(4, 4)
	dot.color = color
	dot.z_index = 100
	parent.add_child(dot)
	dot.global_position = from - Vector2(4, 4)
	
	var t = parent.create_tween()
	# Trajetória
	t.tween_property(dot, "global_position", to - Vector2(4, 4), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Efeito de escala (pulso)
	t.parallel().tween_property(dot, "scale", Vector2(2.5, 2.5), 0.1)
	t.parallel().tween_property(dot, "scale", Vector2(1.0, 1.0), 0.15).set_delay(0.1)
	
	# Callback de impacto e limpeza
	t.tween_callback(on_hit)
	t.tween_callback(dot.queue_free)

# Cria um efeito de "explosão" ou brilho no ponto de impacto
static func spawn_impact_flash(parent: Node, pos: Vector2, color: Color) -> void:
	var flash = ColorRect.new()
	flash.size = Vector2(40, 40)
	flash.pivot_offset = Vector2(20, 20)
	flash.color = color
	flash.color.a = 0.6
	flash.z_index = 90
	parent.add_child(flash)
	flash.global_position = pos - Vector2(20, 20)
	
	var t = parent.create_tween()
	t.tween_property(flash, "scale", Vector2(2.0, 2.0), 0.15)
	t.parallel().tween_property(flash, "modulate:a", 0.0, 0.15)
	t.tween_callback(flash.queue_free)
