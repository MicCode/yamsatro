extends HBoxContainer
class_name GameOverScoreLine

var score: PastScore

static func create(past_score: PastScore) -> GameOverScoreLine:
	var line = preload("res://ui/game_over/GameOverScoreLine.tscn").instantiate()
	line.score = past_score
	return line

func print_score():
	%Date.text = score.date
	%Score.text = str(score.score)
