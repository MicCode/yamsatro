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
		totals["numbers"] = getScore(f.SUM_1) + getScore(f.SUM_2) + getScore(f.SUM_3) + getScore(f.SUM_4) + getScore(f.SUM_5) + getScore(f.SUM_6)
		if totals["numbers"] >= GameRules.NUMBERS_BONUS_THRESHOLD:
			has_numbers_bonus = true
			totals["numbers"] += GameRules.NUMBERS_BONUS
		else:
			has_numbers_bonus = false
		
		totals["figures"] = getScore(f.THREE_SAME) + getScore(f.FOUR_SAME) + getScore(f.FULL) + getScore(f.SMALL_STRAIGHT) + getScore(f.BIG_STRAIGHT) + getScore(f.YAHTZEE) + getScore(f.LUCK)
		
		totals["total"] = totals["numbers"] + totals["figures"]
