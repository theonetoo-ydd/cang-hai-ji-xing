extends RefCounted

var buy_price: int
var sell_price: int

func _init(p_buy_price: int = 0, p_sell_price: int = 0) -> void:
	buy_price = p_buy_price
	sell_price = p_sell_price
