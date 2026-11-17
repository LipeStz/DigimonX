extends Control

@onready var label_partenaire: Label = $LabelPartenaire

func afficher_partenaire(d: Dictionary) -> void:
	label_partenaire.text = "%s\nStade : %s\nType : %s\nPuissance : %d" % [
		d["nom"], d["stade_nom"], d["type"], int(d["puissance"])
	]
