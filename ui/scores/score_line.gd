extends Panel
class_name ScoreLine

@export var figure: Enums.Figures

var scores: Dictionary = {
	"A" = -1,
	"B" = -1,
	"C" = -1,
}

var normal_bg_color: Color = Color(0.2, 0.2, 0.2)
var hover_bg_color: Color = Color(0.3, 0.3, 0.3)
var hover_border_color: Color = Color.SKY_BLUE
var is_active_color: Color = Color.BURLYWOOD
var border_width: int = 2

var stylebox := StyleBoxFlat.new()
var game_variant: Enums.GameVariants = Enums.GameVariants.FULL
var is_active = false

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_PASS
	setup_style(normal_bg_color)
	self.add_theme_stylebox_override("panel", stylebox)
	Game.game_variant_changed.connect(_on_game_variant_changed)
	Game.active_figures_changed.connect(_on_active_figures_changed)
	
	%Label.text = Enums.figure_display_name(figure)
	%ScoreA.text = "-"
	%ScoreB.text = "-"
	%ScoreC.text = "-"
	
func setup_style(bg_color: Color, border_color: Color = Color(0, 0, 0, 0), border_size: int = 0):
	stylebox.bg_color = bg_color
	stylebox.border_color = border_color
	stylebox.border_width_left = border_size
	stylebox.border_width_top = border_size
	stylebox.border_width_right = border_size
	stylebox.border_width_bottom = border_size
	stylebox.draw_center = true  # Garde le fond actif

func set_value(column: Enums.ScoreColumns, new_value: int):
	match column:
		Enums.ScoreColumns.A:
			scores["A"] = new_value
			%ScoreA.text = str(new_value)
		Enums.ScoreColumns.B:
			scores["B"] = new_value
			%ScoreB.text = str(new_value)
		Enums.ScoreColumns.C:
			scores["C"] = new_value
			%ScoreC.text = str(new_value)
			
func change_is_active(new_value: bool):
	is_active = new_value
	if is_active:
		setup_style(is_active_color)
	else:
		setup_style(normal_bg_color)

func _on_mouse_entered() -> void:
	setup_style(hover_bg_color, hover_border_color, border_width)

func _on_mouse_exited() -> void:
	setup_style(normal_bg_color)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("cliqué sur " + Enums.figure_display_name(figure))

func _on_game_variant_changed(new_game_variant: Enums.GameVariants):
	game_variant = new_game_variant
	if game_variant == Enums.GameVariants.FULL:
		%ScoreB.show()
		%ScoreC.show()
	else:
		%ScoreB.hide()
		%ScoreC.hide()

func _on_active_figures_changed():
	change_is_active(Game.active_figures.has(figure))
