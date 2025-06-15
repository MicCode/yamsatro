extends Node2D

var game_variant = Enums.GameVariants.FULL

func _ready() -> void:
	randomize()
	Game.dice_rolling_changed.connect(update_state)
	Game.remaining_rolls_changed.connect(update_state)

	if FileAccess.file_exists(Game.GAME_JSON_FILE):
		Game.load_game_state_from_file()
		Scores.load_from_file()
		Game.score_changed.emit()
		Game.update_active_figures()
		if Game.game_finished:
			show_game_over()
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
	%DiceTray.roll_all()

func _on_score_changed():
	%DiceTray.unlock_all()
	%DiceTray.roll_all()
	Game.change_remaining_rolls(GameRules.MAX_REROLL_NUMBER)
	update_state()
	Scores.write_to_file()
	
	if Game.is_finished():
		%GameOverOverlay.register_new_score(Scores.get_total())
		show_game_over()

func _on_start_new_pressed() -> void:
	Game.reset_game()
	print("start again !")
	
func show_game_over():
	%GameOverOverlay.update()
	%GameOverOverlay.show()

func _on_game_over_overlay_new_game_pressed() -> void:
	%GameOverOverlay.hide()
	Game.reset_game()
