extends Node

var columns: Dictionary = {
	Enums.ScoreColumns.DOWN: SColumn.createEmpty(),
	Enums.ScoreColumns.FREE: SColumn.createEmpty(),
	Enums.ScoreColumns.UP: SColumn.createEmpty(),
}

func get_cell_score(column: Enums.ScoreColumns, figure: Enums.Figures) -> int:
	var col: SColumn = columns[column]
	if col:
		var line: SLine = col.lines.filter(func(l: SLine): return l.figure == figure).front()
		if line:
			return line.score
	return -1

func get_total() -> int:
	return columns[Enums.ScoreColumns.DOWN].totals[Enums.SumCategories.TOTAL] + columns[Enums.ScoreColumns.FREE].totals[Enums.SumCategories.TOTAL] + columns[Enums.ScoreColumns.UP].totals[Enums.SumCategories.TOTAL]

func reset():
	columns = {
		Enums.ScoreColumns.DOWN: SColumn.createEmpty(),
		Enums.ScoreColumns.FREE: SColumn.createEmpty(),
		Enums.ScoreColumns.UP: SColumn.createEmpty(),
	}
	write_to_file()

func to_dict() -> Dictionary:
	return {
		Enums.ScoreColumns.DOWN: columns[Enums.ScoreColumns.DOWN].to_dict(),
		Enums.ScoreColumns.FREE: columns[Enums.ScoreColumns.FREE].to_dict(),
		Enums.ScoreColumns.UP: columns[Enums.ScoreColumns.UP].to_dict()
	}

func from_dict(data: Dictionary):
	for col in Enums.ScoreColumns.values():
		var cdata = data.get(str(col), null)
		if cdata:
			columns[col] = SColumn.from_dict(cdata)
		else:
			columns[col] = SColumn.createEmpty()

func write_to_file():
	Files.write_scores(to_dict())

func load_from_file():
	from_dict(Files.read_scores())
