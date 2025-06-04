extends Panel

@export var label: String = "TOTAL"

var values: Dictionary = {
        "A" = 0,
        "B" = 0,
        "C" = 0,
}
@onready var value_nodes := {
       Enums.ScoreColumns.A: %ValueA,
       Enums.ScoreColumns.B: %ValueB,
       Enums.ScoreColumns.C: %ValueC,
}

func _ready() -> void:
       Game.game_variant_changed.connect(_on_game_variant_changed)
       %Label.text = label
       for col in value_nodes.keys():
               value_nodes[col].text = str(values["%s" % char(col + 65)])

func set_value(column: Enums.ScoreColumns, new_value: int):
       if value_nodes.has(column):
               var key = "%s" % char(column + 65)
               values[key] = new_value
               value_nodes[column].text = str(new_value)
			
func _on_game_variant_changed(new_game_variant: Enums.GameVariants):
       var show_extra := new_game_variant == Enums.GameVariants.FULL
       for node in [%ValueB, %ValueC]:
               if show_extra:
                       node.show()
               else:
                       node.hide()
