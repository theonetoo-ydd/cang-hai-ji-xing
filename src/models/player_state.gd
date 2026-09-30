extends RefCounted

var money: int
var current_port_id: String
var day: int
var ship
var cargo: Dictionary
var status: String

func _init(p_money: int, p_current_port_id: String, p_ship) -> void:
	money = p_money
	current_port_id = p_current_port_id
	day = 1
	ship = p_ship
	cargo = {}
	status = "IN_PORT"

func cargo_quantity(good_id: String) -> int:
	if not cargo.has(good_id):
		return 0
	return cargo[good_id].quantity

func used_capacity(goods: Dictionary) -> int:
	var used := 0
	for good_id in cargo:
		if goods.has(good_id):
			used += cargo[good_id].quantity * goods[good_id].cargo_size
	return used

func free_capacity(goods: Dictionary) -> int:
	return ship.capacity - used_capacity(goods)
