extends Node2D

var game_variant = Enums.GameVariants.FULL

func _ready() -> void:
	randomize()
	Game.dice_rolling_changed.connect(update_state)
	Game.remaining_rolls_changed.connect(update_state)
	
	var background_shader = %Background.material
	if background_shader is ShaderMaterial:
		background_shader.set_shader_parameter("colour_1", GUITheme.accent_color)
		background_shader.set_shader_parameter("colour_2", GUITheme.complementary_color)
		background_shader.set_shader_parameter("colour_3", GUITheme.background_color)

	if FileAccess.file_exists(Game.GAME_JSON_FILE):
		Game.load_game_state_from_file()
		Scores.load_from_file()
		Game.score_changed.emit()
		Game.update_active_figures()
		if Game.game_finished:
			show_menu()
	else:
		Game.init_game(game_variant)
		Game.change_remaining_rolls(GameRules.MAX_REROLL_NUMBER)
	Game.score_changed.connect(_on_score_changed)
	
func update_state():
	%RollButton.text = str("LANCER (%s)" % Game.remaining_rolls)
	if !Game.dice_rolling && Game.remaining_rolls > 0:
		%RollButton.disabled = false
	else:
		%RollButton.disabled = true
		
func _on_roll_button_pressed():
	Sounds.click()
	%DiceTray.roll_all()

func _on_score_changed():
	%DiceTray.unlock_all()
	%DiceTray.roll_all()
	Game.change_remaining_rolls(GameRules.MAX_REROLL_NUMBER)
	update_state()
	Scores.write_to_file()
	
	if Game.is_finished():
		%MenuOverlay.register_new_score(Scores.get_total())
		show_menu()
	
func show_menu():
	var menu = %MenuOverlay as Panel
	menu.show()
	var screen_size = get_viewport().get_visible_rect().size
	menu.position = Vector2(0, -screen_size.y)
	menu.modulate.a = 0.0
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(menu, "position", Vector2(0, 0), 0.4)
	tween.parallel().tween_property(menu, "modulate:a", 1.0, 0.4)
	tween.connect("finished", Callable(self, "_on_menu_openned"))

func hide_menu():
	%Background.show()
	var menu = %MenuOverlay as Panel
	var screen_size = get_viewport().get_visible_rect().size
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(menu, "position", Vector2(0, -screen_size.y), 0.4)
	tween.parallel().tween_property(menu, "modulate:a", 0.0, 0.4)
	tween.connect("finished", Callable(self, "_on_menu_closed"))

func _on_game_over_overlay_new_game_pressed() -> void:
	%MenuOverlay.hide()
	Game.reset_game()

func _on_menu_overlay_hide_menu_pressed() -> void:
	hide_menu()

func _on_menu_button_pressed() -> void:
	Sounds.click()
	show_menu()

func _on_menu_openned():
	%Background.hide()

func _on_menu_closed():
	%MenuOverlay.hide()
