extends RefCounted

var good_id: String
var quantity: int
var average_buy_price: float

func _init(p_good_id: String = "", p_quantity: int = 0, p_average_buy_price: float = 0.0) -> void:
	good_id = p_good_id
	quantity = p_quantity
	average_buy_price = p_average_buy_price
