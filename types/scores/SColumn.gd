extends Node
class_name SColumn

var lines: Array[SLine] = []
var totals: Dictionary = {
    Enums.SumCategories.BONUS: 0,
    Enums.SumCategories.NUMBERS: 0,
    Enums.SumCategories.FIGURES: 0,
    Enums.SumCategories.TOTAL: 0
}
var has_numbers_bonus = false

static func createEmpty() -> SColumn:
    var column = new()
    for figure in Enums.Figures.values():
        column.lines.append(SLine.withFigure(figure))
    return column

func setScore(figure: Enums.Figures, new_score: int):
    var line = lines.filter(func(l: SLine): return l.figure == figure).front()
    if line:
        line.score = new_score
        updateTotals()

func getScore(figure: Enums.Figures) -> int:
    var line = lines.filter(func(l: SLine): return l.figure == figure).front()
    if line && line.score > 0:
        return line.score
    else:
        return 0

func updateTotals():
    var f = Enums.Figures
    totals[Enums.SumCategories.NUMBERS] = getScore(f.SUM_1) + getScore(f.SUM_2) + getScore(f.SUM_3) + getScore(f.SUM_4) + getScore(f.SUM_5) + getScore(f.SUM_6)
    if totals[Enums.SumCategories.NUMBERS] >= GameRules.NUMBERS_BONUS_THRESHOLD:
        has_numbers_bonus = true
        totals[Enums.SumCategories.NUMBERS] += GameRules.NUMBERS_BONUS
        totals[Enums.SumCategories.BONUS] = GameRules.NUMBERS_BONUS
    else:
        has_numbers_bonus = false
        totals[Enums.SumCategories.BONUS] = 0
    
    totals[Enums.SumCategories.FIGURES] = getScore(f.THREE_SAME) + getScore(f.FOUR_SAME) + getScore(f.FULL) + getScore(f.SMALL_STRAIGHT) + getScore(f.BIG_STRAIGHT) + getScore(f.YAHTZEE) + getScore(f.LUCK)
    
    totals[Enums.SumCategories.TOTAL] = totals[Enums.SumCategories.NUMBERS] + totals[Enums.SumCategories.FIGURES]

func is_complete() -> bool:
    return lines.all(func(line: SLine): return line.score >= 0)

func to_dict() -> Dictionary:
    return {
        "lines": lines.map(func(line: SLine) -> Dictionary: return line.to_dict()),
        "totals": totals,
        "has_numbers_bonus": has_numbers_bonus
    }

static func from_dict(data: Dictionary) -> SColumn:
    var column := new()
    var raw_lines: Array = data.get("lines", [])
    for raw_line in raw_lines:
        column.lines.append(SLine.from_dict(raw_line))
    column.updateTotals()
    return column