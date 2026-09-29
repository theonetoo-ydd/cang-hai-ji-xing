extends RefCounted

const CargoItemScript = preload("res://src/models/cargo_item.gd")

static func buy(player, good, market_price, quantity: int, goods: Dictionary) -> Dictionary:
	if quantity <= 0:
		return _fail("购买数量必须大于 0。")

	var total_cost: int = market_price.buy_price * quantity
	var required_space: int = good.cargo_size * quantity

	if player.money < total_cost:
		return _fail("资金不足。")

	if player.free_capacity(goods) < required_space:
		return _fail("货舱空间不足。")

	var item = player.cargo.get(good.id)
	if item == null:
		item = CargoItemScript.new(good.id, 0, 0.0)
		player.cargo[good.id] = item

	var previous_cost: float = item.average_buy_price * item.quantity
	item.quantity += quantity
	item.average_buy_price = (previous_cost + total_cost) / float(item.quantity)
	player.money -= total_cost

	return {
		"ok": true,
		"message": "买入成功。",
		"quantity": quantity,
		"total_cost": total_cost,
		"money": player.money,
	}

static func sell(player, good, market_price, quantity: int) -> Dictionary:
	if quantity <= 0:
		return _fail("卖出数量必须大于 0。")

	var item = player.cargo.get(good.id)
	if item == null or item.quantity < quantity:
		return _fail("货物数量不足。")

	var revenue: int = market_price.sell_price * quantity
	var cost_basis: float = item.average_buy_price * quantity
	var profit: float = revenue - cost_basis

	item.quantity -= quantity
	player.money += revenue

	if item.quantity == 0:
		player.cargo.erase(good.id)

	return {
		"ok": true,
		"message": "卖出成功。",
		"quantity": quantity,
		"revenue": revenue,
		"profit": profit,
		"money": player.money,
	}

static func _fail(message: String) -> Dictionary:
	return {
		"ok": false,
		"message": message,
	}
