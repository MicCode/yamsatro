extends Panel

signal show_menu(show: bool)

var game_variant = Enums.GameVariants.FULL
var game_state := Enums.GameState.INIT

func change_state(new_state: Enums.GameState):
    if game_state != new_state:
        # TODO ajouter des conditions de transition ?
        game_state = new_state
        print("Change state to [" + Enums.game_state_display_name(game_state) + "]")
        do_actions()

func _ready() -> void:
    Game.dice_rolling_changed.connect(_on_dice_rolling_changed)
    Game.remaining_rolls_changed.connect(update_ui)
    Game.scores_changed.connect(_on_scores_changed)
    Game.score_selected.connect(_on_score_selected)
    Game.game_finished_changed.connect(_on_game_finished)
    
    offset_bottom = - GUITheme.default_padding_px
    offset_top = GUITheme.default_padding_px
    offset_right = - GUITheme.default_padding_px
    offset_left = GUITheme.default_padding_px

func start_game():
    # Chargement des fichiers de sauvegarde existants et initialisation de la partie
    if FileAccess.file_exists(Files.GAME_JSON_FILE):
        Game.load_game_state_from_file()
        Scores.load_from_file()
        Game.scores_changed.emit()
        Game.update_active_figures()

        if Game.game_finished:
            change_state(Enums.GameState.FINISHED)
        elif Game.initial_dice_values && Game.initial_dice_values.size() > 0:
            change_state(Enums.GameState.CHOOSESCORE)
    else:
        change_state(Enums.GameState.ROLLDICE)

func do_actions():
    match game_state:
        Enums.GameState.INIT:
            Game.init_game(game_variant)
            Game.reset_game()
            Game.change_remaining_rolls(GameRules.MAX_REROLL_NUMBER)
            %DiceTray.unlock_all()
        Enums.GameState.RESET:
            Game.reset_game()
            %DiceTray.unlock_all()
            Game.change_remaining_rolls(GameRules.MAX_REROLL_NUMBER + 1)
            change_state(Enums.GameState.ROLLDICE)
        Enums.GameState.ROLLDICE:
            %DiceTray.roll_all()
        Enums.GameState.CHOOSESCORE:
            pass
        Enums.GameState.NEXTTURN:
            %DiceTray.unlock_all()
            if !Game.game_finished:
                print("Game not finished")
                Game.change_remaining_rolls(GameRules.MAX_REROLL_NUMBER + 1)
                change_state(Enums.GameState.ROLLDICE)
            else:
                change_state(Enums.GameState.FINISHED)
        Enums.GameState.FINISHED:
            Game.change_remaining_rolls(0)
            show_menu.emit(true)
    update_ui()

func update_ui():
    %RollButton.text = str("LANCER (%s)" % Game.remaining_rolls)
    if !Game.dice_rolling && Game.remaining_rolls > 0:
        %RollButton.disabled = false
    else:
        %RollButton.disabled = true
        
func _on_roll_button_pressed():
    Sounds.click()
    change_state(Enums.GameState.ROLLDICE)

func _on_scores_changed():
    update_ui()
    Scores.write_to_file()

func _on_menu_button_pressed() -> void:
    Sounds.click()
    show_menu.emit(true)

func _on_game_finished():
    if Game.game_finished:
        change_state(Enums.GameState.FINISHED)

func _on_dice_rolling_changed():
    if !Game.dice_rolling:
        change_state(Enums.GameState.CHOOSESCORE)

func _on_score_selected():
    if !Game.game_finished:
        change_state(Enums.GameState.NEXTTURN)
