extends Node

#region signaux ========================================================================================================
signal game_variant_changed
signal game_finished_changed
signal active_figures_changed
signal remaining_rolls_changed
signal dice_rolling_changed
signal game_ready
signal scores_changed
signal score_selected
#endregion =============================================================================================================

#region init vars ======================================================================================================
var game_variant: Enums.GameVariants
var game_finished = false
var active_figures: Array[Enums.Figures] = []
var all_dice: Array[Die] = []
var remaining_rolls: int = 10000
var dice_rolling = false
var all_dice_faces: Array[DieFace] = [
    DieFace.build("1", 1, "0000001"),
    DieFace.build("2", 2, "0011000"),
    DieFace.build("3", 3, "0011001"),
    DieFace.build("4", 4, "1011010"),
    DieFace.build("5", 5, "1011011"),
    DieFace.build("6", 6, "1111110")
]
var lock_file_write = false
var initial_dice_values: Array = []
#endregion =============================================================================================================

#region setup partie ===================================================================================================
## Initialisation d'une partie (en partant de 0)
func init_game(new_game_variant: Enums.GameVariants):
    change_game_variant(new_game_variant)
    change_remaining_rolls(GameRules.MAX_REROLL_NUMBER)
    game_ready.emit()
    save_game_state_in_file()
    change_game_finished(false)

## Réinitialisation d'une partie (en partant d'une partie existante)
func reset_game():
    init_game(game_variant)
    change_remaining_rolls(GameRules.MAX_REROLL_NUMBER)
    change_game_finished(false)
    Scores.reset()
    scores_changed.emit()
    game_ready.emit()

## Attache les références à des dés (scènes) à une variable interne
func set_dice_reference(d: Array[Die]):
    all_dice = d
#endregion =============================================================================================================

#region changements états ==============================================================================================
func change_remaining_rolls(count: int):
    remaining_rolls = count
    remaining_rolls_changed.emit()
    save_game_state_in_file()

func change_dice_rolling(rolling: bool):
    dice_rolling = rolling
    dice_rolling_changed.emit()
    if all_dice.all(func(die: Die): return !die.rolling):
        save_game_state_in_file()

func change_game_variant(variant: Enums.GameVariants):
    game_variant = variant
    game_variant_changed.emit(game_variant)

func change_game_finished(finished: bool):
    game_finished = finished
    game_finished_changed.emit()
    save_game_state_in_file()
#endregion =============================================================================================================

#region règles et scores ===============================================================================================
## Met à jour la figure actuellement possible de scorer en fonction des valeurs des dés
func update_active_figures():
    active_figures = []

    var values: Array[int] = []
    var counts: Dictionary = {}
    for die in Game.all_dice:
        var val = die.face.value
        values.append(val)
        counts[val] = counts.get(val, 0) + 1

    if counts.get(1, 0) > 0:
            active_figures.append(Enums.Figures.SUM_1)
    if counts.get(2, 0) > 0:
            active_figures.append(Enums.Figures.SUM_2)
    if counts.get(3, 0) > 0:
            active_figures.append(Enums.Figures.SUM_3)
    if counts.get(4, 0) > 0:
            active_figures.append(Enums.Figures.SUM_4)
    if counts.get(5, 0) > 0:
            active_figures.append(Enums.Figures.SUM_5)
    if counts.get(6, 0) > 0:
            active_figures.append(Enums.Figures.SUM_6)

    var max_same := 0
    for c in counts.values():
        if c > max_same:
            max_same = c
    if max_same >= 3:
        active_figures.append(Enums.Figures.THREE_SAME)
    if max_same >= 4:
        active_figures.append(Enums.Figures.FOUR_SAME)
    if max_same == 5:
        active_figures.append(Enums.Figures.YAHTZEE)

    var has_three := false
    var has_two := false
    for c in counts.values():
        if c == 3:
            has_three = true
        elif c == 2:
            has_two = true
    if has_three and has_two:
        active_figures.append(Enums.Figures.FULL)

    var uniques: Array[int] = []
    for v in values:
        if !uniques.has(v):
            uniques.append(v)
    uniques.sort()

    if has_straight(uniques, 4):
        active_figures.append(Enums.Figures.SMALL_STRAIGHT)
    if has_straight(uniques, 5):
        active_figures.append(Enums.Figures.BIG_STRAIGHT)

    active_figures.append(Enums.Figures.LUCK)
    active_figures_changed.emit()

## Détermine si un ensemble de valeurs contient une suite de longueur donnée
func has_straight(values: Array[int], length: int) -> bool:
    for start in range(1, 8 - length):
        var ok := true
        for i in range(length):
            if !values.has(start + i):
                ok = false
                break
        if ok:
            return true
    return false

## Retourne le score que permet la figure donnée en paramètre en fonction des valeurs des dés
func compute_score(figure: Enums.Figures) -> int:
    var f = Enums.Figures
    match figure:
        f.SUM_1:
            return all_dice.filter(func(d: Die): return d.face.value == 1).map(func(d: Die): return d.face.value).reduce(sum, 0)
        f.SUM_2:
            return all_dice.filter(func(d: Die): return d.face.value == 2).map(func(d: Die): return d.face.value).reduce(sum, 0)
        f.SUM_3:
            return all_dice.filter(func(d: Die): return d.face.value == 3).map(func(d: Die): return d.face.value).reduce(sum, 0)
        f.SUM_4:
            return all_dice.filter(func(d: Die): return d.face.value == 4).map(func(d: Die): return d.face.value).reduce(sum, 0)
        f.SUM_5:
            return all_dice.filter(func(d: Die): return d.face.value == 5).map(func(d: Die): return d.face.value).reduce(sum, 0)
        f.SUM_6:
            return all_dice.filter(func(d: Die): return d.face.value == 6).map(func(d: Die): return d.face.value).reduce(sum, 0)
        f.THREE_SAME:
            return n_same_sum(3, all_dice.map(func(d: Die): return d.face.value))
        f.FOUR_SAME:
            return n_same_sum(4, all_dice.map(func(d: Die): return d.face.value))
        f.FULL:
            return 25
        f.SMALL_STRAIGHT:
            return 30
        f.BIG_STRAIGHT:
            return 40
        f.YAHTZEE:
            return 50
        f.LUCK:
            return all_dice.map(func(d: Die): return d.face.value).reduce(sum, 0)
    return 0

## Calcule la somme des `n` valeurs qui sont égales dans un tableau de valeurs
func n_same_sum(n: int, values: Array) -> int:
    var counts: Dictionary = {}
    for value in values:
        if !counts.has(value):
            counts[value] = 0
        counts[value] += 1
    for key in counts.keys():
        if counts[key] >= n:
            return key * n
    return 0

## Calcule la somme de deux nombres (utilisé dans les .reduce())
func sum(accum, number):
    return accum + number

## Enregistre le `score` donné dans la bonne cellule
func registerScore(column: Enums.ScoreColumns, figure: Enums.Figures, score: int):
    var c: SColumn = Scores.columns[column]
    if c:
        c.setScore(figure, score)
        active_figures = []
        active_figures_changed.emit()
        if is_game_finished():
            change_game_finished(true)
        scores_changed.emit()
        score_selected.emit()

## Détermine si une case peut être scorée
func is_cell_scorable(figure: Enums.Figures, column: Enums.ScoreColumns):
    return active_figures.has(figure) && is_cell_playable(figure, column)

## Détermine si une case peut être jouée (soit scorée soit sacrifiée)
func is_cell_playable(figure: Enums.Figures, column: Enums.ScoreColumns) -> bool:
    var f = Enums.Figures
    var c = Enums.ScoreColumns
    var line: SLine = _get_line(figure, column)
    if line:
        if line.score < 0:
            var fkeys = f.values()
            var i = fkeys.find(figure)
            match column:
                c.DOWN:
                    if i == 0: return true
                    else:
                        var previous_line: SLine = _get_line(fkeys[i - 1], column)
                        if previous_line && previous_line.score > -1:
                            return true
                c.FREE:
                    return true
                c.UP:
                    if i >= fkeys.size() - 1: return true
                    else:
                        var next_line: SLine = _get_line(fkeys[i + 1], column)
                        if next_line && next_line.score > -1:
                            return true
    return false

func _get_line(figure: Enums.Figures, column: Enums.ScoreColumns):
    return Scores.columns[column].lines.filter(func(l: SLine): return l.figure == figure).front()

## Détermine si la partie est terminée en fonction des règles actuelles et des scores
func is_game_finished() -> bool:
    var down_column: SColumn = Scores.columns[Enums.ScoreColumns.DOWN]
    if down_column.is_complete():
        match game_variant:
            Enums.GameVariants.SIMPLE:
                return true
            Enums.GameVariants.FULL:
                var free_column: SColumn = Scores.columns[Enums.ScoreColumns.FREE]
                var up_column: SColumn = Scores.columns[Enums.ScoreColumns.UP]
                return free_column.is_complete() && up_column.is_complete()

    return false
#endregion =============================================================================================================

#region sauvegarde =====================================================================================================
func save_game_state_in_file():
    var dice_dict: Array = []
    if all_dice:
        dice_dict = all_dice.map(func(die: Die):
            if die.face:
                return {"value": die.face.value, "locked": die.locked}
            else:
                return {}
        )

    Files.write_game_state({
        "game_variant": game_variant,
        "game_finished": game_finished,
        "remaining_rolls": remaining_rolls,
        "dice": dice_dict
    })

func load_game_state_from_file():
    var json_data := Files.read_game_state()

    change_game_variant(Enums.GameVariants.values()[int(json_data.get("game_variant", 0))])
    change_game_finished(bool(json_data.get("game_finished", false)))
    change_remaining_rolls(int(json_data.get("remaining_rolls", GameRules.MAX_REROLL_NUMBER)))
    initial_dice_values = json_data.get("dice", [])

    game_ready.emit()
#endregion =============================================================================================================
