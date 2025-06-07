extends Node

signal game_variant_changed
signal game_finished_changed
signal active_figures_changed
signal remaining_rolls_changed
signal dice_rolling_changed
signal game_ready
signal score_changed

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

func init_game(new_game_variant: Enums.GameVariants):
	change_game_variant(new_game_variant)
	change_remaining_rolls(GameRules.MAX_REROLL_NUMBER)
	game_ready.emit()
	save_game_state_in_file()

func reset_game():
	init_game(game_variant)
	change_remaining_rolls(GameRules.MAX_REROLL_NUMBER)
	Scores.reset()
	score_changed.emit()
	game_finished_changed.emit()
	game_ready.emit()

func set_dice_reference(d: Array[Die]):
	all_dice = d

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

func sum(accum, number):
	return accum + number

func registerScore(column: Enums.ScoreColumns, figure: Enums.Figures, score: int):
	var c: SColumn = Scores.columns[column]
	if c:
		c.setScore(figure, score)
		active_figures = []
		active_figures_changed.emit()
		score_changed.emit()
		if is_finished():
			change_game_finished(true)

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

func is_scorable(figure: Enums.Figures, column: Enums.ScoreColumns):
	if !active_figures.has(figure):
		return false

	var f = Enums.Figures
	var c = Enums.ScoreColumns

	var line: SLine = get_line(figure, column)
	if line:
		if line.score < 0:
			var fkeys = f.values()
			var i = fkeys.find(figure)
			match column:
				c.DOWN:
					if i == 0: return true
					else:
						var previous_line: SLine = get_line(fkeys[i - 1], column)
						if previous_line && previous_line.score > -1:
							return true
				c.FREE:
					return true
				c.UP:
					if i >= fkeys.size() - 1: return true
					else:
						var next_line: SLine = get_line(fkeys[i + 1], column)
						if next_line && next_line.score > -1:
							return true
	
	return false

func get_line(figure: Enums.Figures, column: Enums.ScoreColumns):
	return Scores.columns[column].lines.filter(func(l: SLine): return l.figure == figure).front()

func is_finished() -> bool:
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

func save_game_state_in_file():
	if !lock_file_write:
		var file = FileAccess.open("user://game.json", FileAccess.WRITE)
		if file:
			var dice_dict: Array = []
			if all_dice:
				dice_dict = all_dice.map(func(die: Die):
					if die.face:
						return {"value": die.face.value, "locked": die.locked}
					else:
						return {}
				)
			var game_dict: Dictionary = {
				"game_variant": game_variant,
				"game_finished": game_finished,
				"remaining_rolls": remaining_rolls,
				"dice": dice_dict
			}
			var json_content = JSON.stringify(game_dict, "\t")
			file.store_string(json_content)
			file.close()
		else:
			push_error("Impossible de sauvegarder la partie")

func load_game_state_from_file():
	lock_file_write = true
	var file = FileAccess.open("user://game.json", FileAccess.READ)
	if file:
		var json_content = file.get_as_text()
		file.close()

		var json := JSON.new()
		var error := json.parse(json_content)

		if error != OK:
			push_error("Erreur lors du parsing JSON : %s" % json_content)
			return {}
		
		change_game_variant(Enums.GameVariants.values()[int(json.data.get("game_variant", 0))])
		change_game_finished(bool(json.data.get("game_finished", false)))
		change_remaining_rolls(int(json.data.get("remaining_rolls", GameRules.MAX_REROLL_NUMBER)))
		initial_dice_values = json.data.get("dice", [])

		game_ready.emit()
	else:
		push_error("Fichier d'état de partie non trouvé")

	lock_file_write = false
