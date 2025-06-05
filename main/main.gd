extends Node2D

func _ready() -> void:
	randomize()
	Game.init_game(Enums.GameVariants.FULL)
	Game.remaining_rolls_changed.connect(update_state)
	Game.change_remaining_rolls(GameRules.MAX_REROLL_NUMBER)
	Game.dice_rolling_changed.connect(update_state)
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
	Game.change_remaining_rolls(GameRules.MAX_REROLL_NUMBER)
	%DiceTray.roll_all()
	update_state()
