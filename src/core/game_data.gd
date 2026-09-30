extends RefCounted

const GoodScript = preload("res://src/models/good.gd")
const MarketPriceScript = preload("res://src/models/market_price.gd")
const PortScript = preload("res://src/models/port.gd")

static func load_all() -> Dictionary:
	return {
		"goods": load_goods(),
		"ports": load_ports(),
	}

static func load_goods() -> Dictionary:
	var rows = _load_json_array("res://data/goods.json")
	var goods := {}
	for row in rows:
		var good = GoodScript.new(
			str(row.get("id", "")),
			str(row.get("name", "")),
			int(row.get("cargo_size", 1))
		)
		goods[good.id] = good
	return goods

static func load_ports() -> Dictionary:
	var rows = _load_json_array("res://data/ports.json")
	var ports := {}

	for row in rows:
		var prices := {}
		var raw_prices: Dictionary = row.get("prices", {})
		for good_id in raw_prices:
			var price_row: Dictionary = raw_prices[good_id]
			prices[good_id] = MarketPriceScript.new(
				int(price_row.get("buy", 0)),
				int(price_row.get("sell", 0))
			)

		var routes := {}
		var raw_routes: Dictionary = row.get("routes", {})
		for destination_id in raw_routes:
			routes[destination_id] = int(raw_routes[destination_id])

		var port = PortScript.new(
			str(row.get("id", "")),
			str(row.get("name", "")),
			prices,
			routes
		)
		ports[port.id] = port

	return ports

static func _load_json_array(path: String) -> Array:
	if not FileAccess.file_exists(path):
		push_error("Missing data file: %s" % path)
		return []

	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)

	if parsed == null or typeof(parsed) != TYPE_ARRAY:
		push_error("Invalid JSON array: %s" % path)
		return []

	return parsed
