extends Node

var columns: Dictionary = {
	Enums.ScoreColumns.DOWN: SColumn.createEmpty(),
	Enums.ScoreColumns.FREE: SColumn.createEmpty(),
	Enums.ScoreColumns.UP: SColumn.createEmpty(),
}

func get_total() -> int:
	return columns[Enums.ScoreColumns.DOWN].totals[Enums.SumCategories.TOTAL] + columns[Enums.ScoreColumns.FREE].totals[Enums.SumCategories.TOTAL] + columns[Enums.ScoreColumns.UP].totals[Enums.SumCategories.TOTAL]
