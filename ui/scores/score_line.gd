extends Panel
class_name ScoreLine

@export var figure: Enums.Figures
@export var bg_color = Color(0.2, 0.2, 0.2)

var scores: Dictionary = {
	"A" = -1,
	"B" = -1,
	"C" = -1,
}

var hover_border_color: Color = Color.SKY_BLUE
var border_width: int = 1

var stylebox := StyleBoxFlat.new()
var game_variant: Enums.GameVariants = Enums.GameVariants.FULL
var is_active = false
@onready var score_cells := {
       Enums.ScoreColumns.A: %ScoreCellA,
       Enums.ScoreColumns.B: %ScoreCellB,
       Enums.ScoreColumns.C: %ScoreCellC,
}

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_PASS
	self.add_theme_stylebox_override("panel", stylebox)
	set_border(Color(0, 0, 0, 0), 0)
	Game.game_variant_changed.connect(_on_game_variant_changed)
	Game.active_figures_changed.connect(_on_active_figures_changed)
	
	%Label.text = Enums.figure_display_name(figure)
       for cell in [%ScoreCellA, %ScoreCellB, %ScoreCellC]:
               cell.set_score(-1)
	
func set_border(border_color: Color = Color(0, 0, 0, 0), border_size: int = 0):
	stylebox.border_color = border_color
	stylebox.border_width_left = border_size
	stylebox.border_width_top = border_size
	stylebox.border_width_right = border_size
	stylebox.border_width_bottom = border_size
	stylebox.draw_center = true
	stylebox.bg_color = bg_color

func set_value(column: Enums.ScoreColumns, new_value: int):
       if score_cells.has(column):
               score_cells[column].set_score(new_value)
			
func change_is_active(new_value: bool):
	is_active = new_value
	# TODO déterminer quelles cellules sont valides/sélectionnables en fonction du mode de jeu et des scores déjà marqués
       for cell in [%ScoreCellA, %ScoreCellB, %ScoreCellC]:
               cell.set_selectable(is_active)

func _on_mouse_entered() -> void:
	set_border(hover_border_color, border_width)

func _on_mouse_exited() -> void:
	set_border(hover_border_color, 0)

func _on_game_variant_changed(new_game_variant: Enums.GameVariants):
       game_variant = new_game_variant
       var show_extra := game_variant == Enums.GameVariants.FULL
       for cell in [%ScoreCellB, %ScoreCellC]:
               if show_extra:
                       cell.show()
               else:
                       cell.hide()

func _on_active_figures_changed():
	change_is_active(Game.active_figures.has(figure))
