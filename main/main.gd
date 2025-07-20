extends Node2D

var game_variant = Enums.GameVariants.FULL
var game_state := Enums.GameState.INIT

func change_state(new_state: Enums.GameState):
    if game_state != new_state:
        # TODO ajouter des conditions de transition ?
        game_state = new_state
        print("Change state to [" + Enums.game_state_display_name(game_state) + "]")
        do_actions()

func _ready() -> void:
    randomize() # Pour initialiser la randomization (sinon tous les tirages seront prédictibles)
    Game.dice_rolling_changed.connect(_on_dice_rolling_changed)
    Game.remaining_rolls_changed.connect(update_ui)
    Game.scores_changed.connect(_on_scores_changed)
    Game.score_selected.connect(_on_score_selected)
    Game.game_finished_changed.connect(_on_game_finished)

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
        Game.init_game(Enums.GameVariants.FULL)
        #change_state(Enums.GameState.INIT)

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
    %MainUI.offset_bottom = - GUITheme.default_padding_px
    %MainUI.offset_top = GUITheme.default_padding_px
    %MainUI.offset_right = - GUITheme.default_padding_px
    %MainUI.offset_left = GUITheme.default_padding_px

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
            %MenuOverlay.register_new_score(Scores.get_total())
            show_menu()
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

func show_menu():
    var menu = %MenuOverlay as Panel
    menu.update()
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

func _on_menu_openned():
    %Background.hide()

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

func _on_menu_closed():
    %MenuOverlay.hide()
    %Background.show()

func _on_game_over_overlay_new_game_pressed() -> void:
    hide_menu()
    change_state(Enums.GameState.RESET)

func _on_menu_overlay_hide_menu_pressed() -> void:
    hide_menu()

func _on_menu_button_pressed() -> void:
    Sounds.click()
    show_menu()

func _on_game_finished():
    if Game.game_finished:
        change_state(Enums.GameState.FINISHED)

func _on_dice_rolling_changed():
    if !Game.dice_rolling:
        change_state(Enums.GameState.CHOOSESCORE)

func _on_score_selected():
    if !Game.game_finished:
        change_state(Enums.GameState.NEXTTURN)
