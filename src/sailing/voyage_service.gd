extends RefCounted

const VoyageScript = preload("res://src/models/voyage.gd")

static func start_voyage(player, origin, destination) -> Dictionary:
	if player.status != "IN_PORT":
		return _fail("当前不在港口，无法再次出航。")

	if player.current_port_id != origin.id:
		return _fail("玩家不在出发港。")

	if not origin.routes.has(destination.id):
		return _fail("该航线尚未开放。")

	var duration: int = int(origin.routes[destination.id])
	var voyage = VoyageScript.new(origin.id, destination.id, duration)
	player.status = "SAILING"

	return {
		"ok": true,
		"voyage": voyage,
	}

static func complete_voyage(player, voyage) -> Dictionary:
	if player.status != "SAILING":
		return _fail("当前没有进行中的航行。")

	voyage.elapsed = voyage.duration
	voyage.status = "ARRIVED"
	player.day += voyage.duration
	player.current_port_id = voyage.destination_id
	player.status = "IN_PORT"

	return {
		"ok": true,
		"days": voyage.duration,
		"current_day": player.day,
		"destination_id": player.current_port_id,
	}

static func _fail(message: String) -> Dictionary:
	return {
		"ok": false,
		"message": message,
	}
