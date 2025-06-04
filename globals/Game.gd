extends Node 

signal game_variant_changed
signal active_figures_changed

var game_variant: Enums.GameVariants
var active_figures: Array[Enums.Figures] = []

func init_game(new_game_variant: Enums.GameVariants):
		self.game_variant = new_game_variant
		game_variant_changed.emit(self.game_variant)

func update_active_figures(dice: Array[Die]):
		active_figures = []

		var values: Array[int] = []
		var counts: Dictionary = {}
		for die in dice:
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
