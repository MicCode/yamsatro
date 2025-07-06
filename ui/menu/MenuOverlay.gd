extends Panel

signal new_game_pressed
signal hide_menu_pressed

var past_scores: Array[PastScore] = []
var top_score: int = 0

func _ready() -> void:
	set_background_color(GUITheme.neutral_color)
	set_best_score_color(GUITheme.accent_color)
	update()
	
func update() -> void:
	if Game.game_finished:
		%FinishedGameTitle.show()
		# %GameFinishedBackground.show()
	else:
		%FinishedGameTitle.hide()
		# %GameFinishedBackground.hide()
	load_past_scores()
	
func set_background_color(color: Color):
	var background_material = %GameFinishedBackground.material as ShaderMaterial
	if background_material:
		background_material.set_shader_parameter("circle_color", color)

func set_best_score_color(color: Color):
	var best_score_material = %BestScoreBackground.material as ShaderMaterial
	if best_score_material:
		best_score_material.set_shader_parameter("color", color)

func register_new_score(score_value: int):
	past_scores.append(PastScore.create_new(score_value))
	if score_value > top_score:
		top_score = score_value
	write_scores_file()
	

func load_past_scores():
	past_scores = load_scores_from_file()
	top_score = 0
	for past_score in past_scores:
		if past_score.score > top_score:
			top_score = past_score.score
			
	refresh_ui()

func refresh_ui():
	for child in %ScoresList.get_children():
		child.queue_free()
	for past_score in past_scores:
		var line = MenuScoreLine.create(past_score)
		%ScoresList.add_child(line)
		line.print_score()
	%TopScore.text = str(top_score)
	%Score.text = str(Scores.get_total())
	%GamesNumber.text = str(past_scores.size())
	if past_scores.size() > 1:
		%GamesNumberLabel.text = "parties jouées"
	else:
		%GamesNumberLabel.text = "partie jouée"
		
	if Game.game_finished && Scores.get_total() >= top_score:
		#set_background_color(GUITheme.accent_color)
		%BestScoreBackground.show()
		Sounds.tada()
		%TopScoreLabel.text = "Nouveau meilleur score !"
		%TopScoreLabel.modulate = GUITheme.accent_color
		%TopScore.hide()
	else:
		#set_background_color(GUITheme.neutral_color)
		%BestScoreBackground.hide()
		%TopScoreLabel.text = "Meilleur score: "
		%TopScoreLabel.modulate = Color.WHITE
		%TopScore.show()

func _on_restart_button_pressed() -> void:
	Sounds.click()
	new_game_pressed.emit()

func _on_hide_menu_button_pressed() -> void:
	Sounds.click()
	hide_menu_pressed.emit()


func load_scores_from_file() -> Array[PastScore]:
	var scores: Array[PastScore] = []
	var file = FileAccess.open(Game.PAST_SCORES_JSON_FILE, FileAccess.READ)
	if file:
		var json_content = file.get_as_text()
		file.close()

		var json := JSON.new()
		var error := json.parse(json_content)

		if error != OK:
			push_error("Erreur lors du parsing JSON : %s" % json_content)
			return []
		
		for score in json.data:
			var past_score = PastScore.from_dict(score)
			scores.append(past_score)
	
	scores.sort_custom(
		func(s1: PastScore, s2: PastScore):
			if s1.score > s2.score:
				return true
			else:
				return false
	)
	
	return scores

func write_scores_file():
	var array: Array[Dictionary] = []
	for past_score in past_scores:
		array.push_front(past_score.to_dict())
	var file = FileAccess.open(Game.PAST_SCORES_JSON_FILE, FileAccess.WRITE)
	if file:
		var json_content = JSON.stringify(array, "\t")
		file.store_string(json_content)
		file.close()
	else:
		push_error("Impossible de sauvegarder les scores dans l'historique")
