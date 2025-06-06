extends Node

signal game_variant_changed
signal active_figures_changed
signal remaining_rolls_changed
signal dice_rolling_changed
signal game_ready
signal score_changed

var game_variant: Enums.GameVariants
var active_figures: Array[Enums.Figures] = []
var all_dice: Array[Die] = []
var remaining_rolls: int = 10000
var dice_rolling = false
var all_dice_faces: Array[DieFace] = []

func init_game(new_game_variant: Enums.GameVariants):
	self.game_variant = new_game_variant
	game_variant_changed.emit(self.game_variant)
	change_remaining_rolls(GameRules.MAX_REROLL_NUMBER)
	all_dice_faces = DieFace.load_from_json()
	game_ready.emit()

func set_dice_reference(d: Array[Die]):
	all_dice = d

func update_active_figures():
	active_figures = []

	var values: Array[int] = []
	var counts: Dictionary = {}
	for die in Game.all_dice:
			var val := die.face.value
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

	if _has_straight(uniques, 4):
			active_figures.append(Enums.Figures.SMALL_STRAIGHT)
	if _has_straight(uniques, 5):
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
	var c = Scores.columns[column] as Scores.SColumn
	if c:
		c.setScore(figure, score)
		active_figures = []
		active_figures_changed.emit()
		score_changed.emit()

func change_remaining_rolls(count: int):
	remaining_rolls = count
	remaining_rolls_changed.emit()
	
func change_dice_rolling(rolling: bool):
	dice_rolling = rolling
	dice_rolling_changed.emit()

func _has_straight(values: Array[int], length: int) -> bool:
	for start in range(1, 8 - length):
		var ok := true
		for i in range(length):
			if !values.has(start + i):
				ok = false
				break
		if ok:
			return true
	return false
