extends RefCounted

var id: String
var display_name: String
var cargo_size: int

func _init(p_id: String = "", p_display_name: String = "", p_cargo_size: int = 1) -> void:
	id = p_id
	display_name = p_display_name
	cargo_size = p_cargo_size
