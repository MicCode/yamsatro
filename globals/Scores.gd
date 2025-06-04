extends Node

class SLine:
	var figure: Enums.Figures
	var score: int = -1
	
	static func withFigure(new_figure: Enums.Figures):
		var line = SLine.new()
		line.figure = new_figure
		return line


class SColumn:
	var lines: Array[SLine] = []
	var totals: Dictionary = {
		"numbers": 0,
		"figures": 0,
		"total": 0
	}
	var has_numbers_bonus = false
	
	static func createEmpty() -> SColumn:
		var column = SColumn.new()
		for figure in Enums.Figures.keys():
			column.lines.append(SLine.withFigure(figure))
		return column
	
	func setScore(figure: Enums.Figures, new_score: int):
		var line = lines.find(func (l: SLine): return l.figure == figure)
		if line:
			line.score = new_score
			updateTotals()
	
	func getScore(figure: Enums.Figures) -> int:
		var line = lines.find(func (l: SLine): return l.figure == figure)
		if line && line.score > 0:
			return line.score
		else:
			return 0
	
	func updateTotals():
               var f = Enums.Figures
               totals["numbers"] = 0
               for figure in [f.SUM_1, f.SUM_2, f.SUM_3, f.SUM_4, f.SUM_5, f.SUM_6]:
                       totals["numbers"] += getScore(figure)
               if totals["numbers"] >= GameRules.NUMBERS_BONUS_THRESHOLD:
                       has_numbers_bonus = true
                       totals["numbers"] += GameRules.NUMBERS_BONUS
               else:
                       has_numbers_bonus = false

               totals["figures"] = 0
               for figure in [f.THREE_SAME, f.FOUR_SAME, f.FULL, f.SMALL_STRAIGHT, f.BIG_STRAIGHT, f.YAHTZEE, f.LUCK]:
                       totals["figures"] += getScore(figure)
		
		totals["total"] = totals["numbers"] + totals["figures"]
