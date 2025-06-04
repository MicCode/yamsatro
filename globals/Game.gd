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

               var sums = [Enums.Figures.SUM_1, Enums.Figures.SUM_2, Enums.Figures.SUM_3, Enums.Figures.SUM_4, Enums.Figures.SUM_5, Enums.Figures.SUM_6]
               for i in range(6):
                               if counts.get(i + 1, 0) > 0:
                                               active_figures.append(sums[i])

               var max_same := 0
               for c in counts.values():
                               max_same = max(c, max_same)
		if max_same >= 3:
				active_figures.append(Enums.Figures.THREE_SAME)
		if max_same >= 4:
				active_figures.append(Enums.Figures.FOUR_SAME)
		if max_same == 5:
				active_figures.append(Enums.Figures.YAHTZEE)

               var has_three := counts.values().has(3)
               var has_two := counts.values().has(2)
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
