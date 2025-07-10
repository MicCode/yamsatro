extends Node

enum PanelNames {
	ScoresMenuOverlay,
	GameUi,
}

var is_ready = false
var _panels_references: Dictionary = {} # { PanelNames: panel_scene_ref }
var screen_size: Vector2
var current_panel: Panel
var previous_panel: Panel # TODO faire un historique des panels passés pour une navigation plus intelligente ?
var main_panel: Panel

func set_screen_size(_screen_size: Vector2):
	screen_size = _screen_size

func register(panel_name: PanelNames, panel: Panel):
	_panels_references.set(panel_name, panel)
	panel.size = screen_size

func set_main_panel(panel_name: PanelNames):
	var panel = _panels_references.get(panel_name)
	if !panel:
		print("Unable to find panel [" + str(panel_name) + "]")
		return
	
	panel.position = Vector2(0, 0)
	main_panel = panel

func show_overlay(panel_name: PanelNames) -> Tween:
	var panel = _panels_references.get(panel_name)
	if !panel:
		print("Unable to find panel [" + str(panel_name) + "]")
		return

	panel.update()
	panel.show()
	panel.position = Vector2(0, -screen_size.y)
	panel.modulate.a = 0.0
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "position", Vector2(0, 0), 0.4)
	tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.4)
	tween.connect("finished", func():
		previous_panel = current_panel
		current_panel = panel
	)

	return tween

func hide_overlay(panel_name: PanelNames) -> Tween:
	var panel = _panels_references.get(panel_name)
	if !panel:
		print("Unable to find panel [" + str(panel_name) + "]")
		return
	
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(panel, "position", Vector2(0, -screen_size.y), 0.4)
	tween.parallel().tween_property(panel, "modulate:a", 0.0, 0.4)
	tween.connect("finished", func():
		previous_panel = null
		current_panel = panel
	)

	return tween