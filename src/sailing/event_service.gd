extends RefCounted

static func resolve(player) -> Dictionary:
	var roll := randi_range(1, 100)

	if roll <= 60:
		return {
			"type": "safe",
			"message": "一路顺风，平安抵港。",
		}

	if roll <= 85:
		var delay := randi_range(1, 2)
		player.day += delay
		return {
			"type": "delay",
			"message": "遭遇逆风，航程延误 %d 天。" % delay,
			"delay_days": delay,
		}

	if player.cargo.is_empty():
		return {
			"type": "rough_sea",
			"message": "遭遇风浪，但货舱为空，没有货物损失。",
		}

	var cargo_ids := player.cargo.keys()
	var good_id: String = str(cargo_ids.pick_random())
	var item = player.cargo[good_id]
	var lost := min(item.quantity, randi_range(1, 2))
	item.quantity -= lost

	if item.quantity <= 0:
		player.cargo.erase(good_id)

	return {
		"type": "cargo_loss",
		"message": "遭遇风浪，损失 %d 份货物。" % lost,
		"good_id": good_id,
		"lost_quantity": lost,
	}
