extends RefCounted

var id: String
var display_name: String
var prices: Dictionary
var routes: Dictionary

func _init(
	p_id: String = "",
	p_display_name: String = "",
	p_prices: Dictionary = {},
	p_routes: Dictionary = {}
) -> void:
	id = p_id
	display_name = p_display_name
	prices = p_prices
	routes = p_routes
