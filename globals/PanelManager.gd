extends Node

enum PanelNames {
    HomeMenu,
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
    panel.set_deferred("size", screen_size)
    panel.position = Vector2(0, -screen_size.y)

func set_main(panel_name: PanelNames):
    var panel = _panels_references.get(panel_name)
    if !panel:
        print("Unable to find panel [" + str(panel_name) + "]")
        return
    
    panel.position = Vector2(0, 0)
    main_panel = panel
    current_panel = panel

func show(panel_name: PanelNames) -> PropertyTweener:
    var panel = _panels_references.get(panel_name)
    if !panel:
        print("Unable to find panel [" + str(panel_name) + "]")
        return

    if current_panel:
        _get_out(current_panel)
    var tween = _get_in(panel)
    tween.connect("finished", func():
        previous_panel = current_panel
        current_panel = panel
        #print("finished get_in: previous_panel=" + str(previous_panel) + ", current_panel=" + str(current_panel))
    )
    return tween

func hide(panel_name: PanelNames) -> PropertyTweener:
    var panel = _panels_references.get(panel_name)
    if !panel:
        print("Unable to find panel [" + str(panel_name) + "]")
        return
        
    if previous_panel:
        _get_in(previous_panel)
    var tween = _get_out(panel)
    tween.connect("finished", func():
        current_panel = previous_panel
        previous_panel = panel
        #print("finished get_out: previous_panel=" + str(previous_panel) + ", current_panel=" + str(current_panel))
    )
    return tween

func _get_in(panel: Panel) -> PropertyTweener:
    #print("get_in " + str(panel))
    panel.position = Vector2(0, -screen_size.y)
    panel.modulate.a = 0.0
    var tween = get_tree().create_tween()
    tween.set_trans(Tween.TRANS_CUBIC)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(panel, "position", Vector2(0, 0), 0.4)
    return tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.4)

func _get_out(panel: Panel) -> PropertyTweener:
    #print("get_out " + str(panel))
    var tween = get_tree().create_tween()
    tween.set_trans(Tween.TRANS_CUBIC)
    tween.set_ease(Tween.EASE_IN)
    tween.tween_property(panel, "position", Vector2(0, -screen_size.y), 0.4)
    return tween.parallel().tween_property(panel, "modulate:a", 0.0, 0.4)
