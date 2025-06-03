extends Node 

signal game_variant_changed
signal active_figures_changed

var game_variant: Enums.GameVariants
var active_figures: Array[Enums.Figures] = []

func init_game(game_variant: Enums.GameVariants):
	game_variant = game_variant
	game_variant_changed.emit(game_variant)

func update_active_figures(dice: Array[Die]):
	active_figures = []
	if dice.any(func (die: Die): return die.face.value == 1):
		active_figures.append(Enums.Figures.SUM_1)
	if dice.any(func (die: Die): return die.face.value == 2):
		active_figures.append(Enums.Figures.SUM_2)
	if dice.any(func (die: Die): return die.face.value == 3):
		active_figures.append(Enums.Figures.SUM_3)
	if dice.any(func (die: Die): return die.face.value == 4):
		active_figures.append(Enums.Figures.SUM_4)
	if dice.any(func (die: Die): return die.face.value == 5):
		active_figures.append(Enums.Figures.SUM_5)
	if dice.any(func (die: Die): return die.face.value == 6):
		active_figures.append(Enums.Figures.SUM_6)
		
	# TODO déterminer quelles figures sont possibles en fonction des dés donnés
	
		
	active_figures_changed.emit()
