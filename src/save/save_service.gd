extends RefCounted

const ShipScript = preload("res://src/models/ship.gd")
const CargoItemScript = preload("res://src/models/cargo_item.gd")
const PlayerStateScript = preload("res://src/models/player_state.gd")

const DEFAULT_SAVE_PATH := "user://savegame.json"

static func save_game(player, path: String = DEFAULT_SAVE_PATH) -> Dictionary:
	var cargo_rows: Array = []
	for good_id in player.cargo:
		var item = player.cargo[good_id]
		cargo_rows.append({
			"good_id": item.good_id,
			"quantity": item.quantity,
			"average_buy_price": item.average_buy_price,
		})

	var data := {
		"version": 1,
		"money": player.money,
		"current_port_id": player.current_port_id,
		"day": player.day,
		"status": player.status,
		"ship": {
			"id": player.ship.id,
			"capacity": player.ship.capacity,
			"condition": player.ship.condition,
		},
		"cargo": cargo_rows,
	}

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return _fail("无法创建存档：%s" % error_string(FileAccess.get_open_error()))

	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return {"ok": true, "message": "存档成功。"}

static func load_game(path: String = DEFAULT_SAVE_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _fail("尚无存档。")

	var text := FileAccess.get_file_as_string(path)
	var data = JSON.parse_string(text)
	if data == null or typeof(data) != TYPE_DICTIONARY:
		return _fail("存档格式无效。")

	var ship_data: Dictionary = data.get("ship", {})
	var ship = ShipScript.new(
		str(ship_data.get("id", "starter_ship")),
		int(ship_data.get("capacity", 20)),
		int(ship_data.get("condition", 100))
	)
	var player = PlayerStateScript.new(
		int(data.get("money", 1000)),
		str(data.get("current_port_id", "ningbo")),
		ship
	)
	player.day = int(data.get("day", 1))
	player.status = str(data.get("status", "IN_PORT"))

	var cargo_rows = data.get("cargo", [])
	if typeof(cargo_rows) == TYPE_ARRAY:
		for row in cargo_rows:
			if typeof(row) != TYPE_DICTIONARY:
				continue
			var item = CargoItemScript.new(
				str(row.get("good_id", "")),
				int(row.get("quantity", 0)),
				float(row.get("average_buy_price", 0.0))
			)
			if item.good_id != "" and item.quantity > 0:
				player.cargo[item.good_id] = item

	return {"ok": true, "message": "读取成功。", "player": player}

static func delete_save(path: String = DEFAULT_SAVE_PATH) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

static func _fail(message: String) -> Dictionary:
	return {"ok": false, "message": message}
