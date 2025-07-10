extends Node2D

func _ready() -> void:
	randomize() # Pour initialiser la randomization (sinon tous les tirages seront prédictibles)
	
	PanelManager.set_screen_size(get_viewport().get_visible_rect().size)
	PanelManager.register(PanelManager.PanelNames.GameUi, %GameUI)
	PanelManager.register(PanelManager.PanelNames.ScoresMenuOverlay, %ScoresMenuOverlay)
	PanelManager.set_main_panel(PanelManager.PanelNames.GameUi)
	
	# Application des couleurs du thème au shader du fonc
	var background_shader = %Background.material
	if background_shader is ShaderMaterial:
		background_shader.set_shader_parameter("colour_1", GUITheme.accent_color)
		background_shader.set_shader_parameter("colour_2", GUITheme.complementary_color)
		background_shader.set_shader_parameter("colour_3", GUITheme.background_color)
	# Centrage du fond
	var size = get_viewport_rect().size
	%Background.offset_left = - size.y / 2
	%Background.offset_right = size.y / 2
	%Camera.position = size / 2

func _on_scores_changed():
	pass
	
func show_menu():
	PanelManager.show_overlay(PanelManager.PanelNames.ScoresMenuOverlay).connect("finished", func():
		%Background.hide()
	)
	
func hide_menu():
	%Background.show()
	PanelManager.hide_overlay(PanelManager.PanelNames.ScoresMenuOverlay).connect("finished", func():
		%Background.show()
	)

func _on_game_over_overlay_new_game_pressed() -> void:
	%GameUI.change_state(Enums.GameState.RESET)
	hide_menu()

func _on_menu_overlay_hide_menu_pressed() -> void:
    hide_menu()

func _on_menu_button_pressed() -> void:
    Sounds.click()
    show_menu()

func _on_main_ui_show_menu(_show: bool) -> void:
	if _show:
		show_menu()
	else:
		hide_menu()
