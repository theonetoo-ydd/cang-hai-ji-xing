extends RefCounted

var id: String
var capacity: int
var condition: int

func _init(p_id: String = "starter_ship", p_capacity: int = 20, p_condition: int = 100) -> void:
	id = p_id
	capacity = p_capacity
	condition = p_condition
