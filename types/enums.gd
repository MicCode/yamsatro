extends Node

enum Figures {
	SUM_1,
	SUM_2,
	SUM_3,
	SUM_4,
	SUM_5,
	SUM_6,
	THREE_SAME,
	FOUR_SAME,
	FULL,
	SMALL_STRAIGHT,
	BIG_STRAIGHT,
	YAHTZEE,
	LUCK
}

enum GameVariants {
	SIMPLE,
	FULL,
}

enum ScoreColumns {
	DOWN,
	FREE,
	UP
}

func score_columns_display_name(column: ScoreColumns) -> String:
	match column:
		ScoreColumns.DOWN: return "descendante"
		ScoreColumns.FREE: return "libre"
		ScoreColumns.UP: return "montante"
		_: return "????"

enum SumCategories {
	BONUS,
	NUMBERS,
	FIGURES,
	TOTAL,
}

func figure_display_name(figure: Figures) -> String:
	match figure:
		Figures.SUM_1: return "Somme des 1"
		Figures.SUM_2: return "Somme des 2"
		Figures.SUM_3: return "Somme des 3"
		Figures.SUM_4: return "Somme des 4"
		Figures.SUM_5: return "Somme des 5"
		Figures.SUM_6: return "Somme des 6"
		Figures.THREE_SAME: return "Brelan"
		Figures.FOUR_SAME: return "Carré"
		Figures.FULL: return "Full"
		Figures.SMALL_STRAIGHT: return "Petite suite"
		Figures.BIG_STRAIGHT: return "Grande suite"
		Figures.YAHTZEE: return "Yam's"
		Figures.LUCK: return "Chance"
		_: return "????"
