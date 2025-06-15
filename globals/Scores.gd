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
	var file = FileAccess.open(Game.SCORES_JSON_FILE, FileAccess.WRITE)
	if file:
		var json_content = JSON.stringify(to_dict(), "\t")
		file.store_string(json_content)
		file.close()
	else:
		push_error("Impossible de sauvegarder les scores")

func load_from_file():
	var file = FileAccess.open(Game.SCORES_JSON_FILE, FileAccess.READ)
	if file:
		var json_content = file.get_as_text()
		file.close()

		var json := JSON.new()
		var error := json.parse(json_content)

		if error != OK:
			push_error("Erreur lors du parsing JSON : %s" % json_content)
			return {}
		
		from_dict(json.data)
