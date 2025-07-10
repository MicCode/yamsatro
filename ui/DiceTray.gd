extends HBoxContainer

func _ready() -> void:
    await Game.game_ready
    Game.set_dice_reference(get_all_dice());
    position_dice()
    for die in Game.all_dice:
        die.pressed.connect(on_die_pressed.bind(die))
        die.finished_rolling.connect(_on_dice_roll_finished)

    if Game.initial_dice_values && Game.initial_dice_values.size() > 0:
        var data: Array = Game.initial_dice_values
        for i in data.size():
            Game.all_dice[i].set_face(Game.all_dice_faces[int(data[i].get("value", 0)) - 1])
            Game.all_dice[i].set_lock(bool(data[i].get("locked", false)))
    else:
        roll_all()
    

func roll_all():
    Game.change_dice_rolling(true)
    var some_rolled = false
    for die in Game.all_dice:
        if !die.locked:
            die.roll()
            some_rolled = true
    if some_rolled:
        Game.change_remaining_rolls(Game.remaining_rolls - 1)
            
func unlock_all():
    for die in Game.all_dice:
        if die.locked:
            die.toggle_lock()
    

func get_all_dice() -> Array[Die]:
    var dice: Array[Die] = []
    for child in get_children():
        if child is Die:
            dice.append(child)
    return dice

func on_die_pressed(die: Die):
    die.toggle_lock()
    pass
    
func _on_dice_roll_finished():
    var all_finished = Game.all_dice.all(func(die): return !die.rolling)
    if all_finished:
        Game.update_active_figures()
        Game.change_dice_rolling(false)

func position_dice():
    var x = 0.0
    for i in Game.all_dice.size():
        Game.all_dice[i].position = Vector2(x, 0.0)
        x += GUITheme.die_width + GUITheme.tray_space_between_dice
