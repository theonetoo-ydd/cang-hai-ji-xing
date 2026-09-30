extends Control

const GameDataScript = preload("res://src/core/game_data.gd")
const ShipScript = preload("res://src/models/ship.gd")
const PlayerStateScript = preload("res://src/models/player_state.gd")
const TradeService = preload("res://src/economy/trade_service.gd")
const VoyageService = preload("res://src/sailing/voyage_service.gd")
const EventService = preload("res://src/sailing/event_service.gd")

@onready var location_label: Label = $Margin/MainVBox/Header/LocationLabel
@onready var stats_label: Label = $Margin/MainVBox/Header/StatsLabel
@onready var market_list: ItemList = $Margin/MainVBox/Body/MarketPanel/MarketVBox/MarketList
@onready var quantity_spin: SpinBox = $Margin/MainVBox/Body/MarketPanel/MarketVBox/TradeRow/QuantitySpin
@onready var buy_button: Button = $Margin/MainVBox/Body/MarketPanel/MarketVBox/TradeRow/BuyButton
@onready var sell_button: Button = $Margin/MainVBox/Body/MarketPanel/MarketVBox/TradeRow/SellButton
@onready var cargo_label: Label = $Margin/MainVBox/Body/SidePanel/SideVBox/CargoLabel
@onready var destination_option: OptionButton = $Margin/MainVBox/Body/SidePanel/SideVBox/DestinationOption
@onready var sail_button: Button = $Margin/MainVBox/Body/SidePanel/SideVBox/SailButton
@onready var log_label: Label = $Margin/MainVBox/LogPanel/LogMargin/LogLabel

var goods: Dictionary = {}
var ports: Dictionary = {}
var player
var market_good_ids: Array[String] = []
var destination_ids: Array[String] = []

func _ready() -> void:
	var game_data := GameDataScript.load_all()
	goods = game_data.get("goods", {})
	ports = game_data.get("ports", {})
	player = PlayerStateScript.new(1000, "ningbo", ShipScript.new("starter_ship", 20, 100))

	if goods.is_empty() or ports.is_empty():
		_set_log("数据加载失败，请检查 data/ 目录。")
		return

	market_list.item_selected.connect(_on_market_item_selected)
	buy_button.pressed.connect(_on_buy_pressed)
	sell_button.pressed.connect(_on_sell_pressed)
	sail_button.pressed.connect(_on_sail_pressed)

	_refresh_all()
	_set_log("船已泊于宁波。先选择商品进行交易，再选择目的港出航。")

func _refresh_all() -> void:
	_refresh_header()
	_refresh_market()
	_refresh_cargo()
	_refresh_destinations()
	_refresh_trade_buttons()

func _refresh_header() -> void:
	var port = ports[player.current_port_id]
	location_label.text = "当前港口：%s" % port.display_name
	stats_label.text = "第 %d 天　资金：%d　货舱：%d/%d" % [
		player.day,
		player.money,
		player.used_capacity(goods),
		player.ship.capacity
	]

func _refresh_market() -> void:
	var selected_good_id := _selected_good_id()
	var port = ports[player.current_port_id]

	market_list.clear()
	market_good_ids.clear()

	for good_id in port.prices:
		if not goods.has(good_id):
			continue
		var good = goods[good_id]
		var price = port.prices[good_id]
		var owned := player.cargo_quantity(good_id)
		market_good_ids.append(good_id)
		market_list.add_item("%s　买 %d / 卖 %d　持有 %d" % [
			good.display_name,
			price.buy_price,
			price.sell_price,
			owned
		])

	if selected_good_id != "":
		var index := market_good_ids.find(selected_good_id)
		if index >= 0:
			market_list.select(index)

	if market_list.get_selected_items().is_empty() and market_list.item_count > 0:
		market_list.select(0)

func _refresh_cargo() -> void:
	if player.cargo.is_empty():
		cargo_label.text = "货舱\n\n（空）"
		return

	var lines: Array[String] = ["货舱"]
	for good_id in player.cargo:
		var item = player.cargo[good_id]
		var good_name := good_id
		if goods.has(good_id):
			good_name = goods[good_id].display_name
		lines.append("%s × %d　均价 %.1f" % [good_name, item.quantity, item.average_buy_price])

	cargo_label.text = "\n".join(lines)

func _refresh_destinations() -> void:
	var previous_id := _selected_destination_id()
	var port = ports[player.current_port_id]

	destination_option.clear()
	destination_ids.clear()

	for destination_id in port.routes:
		if not ports.has(destination_id):
			continue
		destination_ids.append(destination_id)
		var destination = ports[destination_id]
		destination_option.add_item("%s（%d 天）" % [destination.display_name, port.routes[destination_id]])

	if previous_id != "":
		var index := destination_ids.find(previous_id)
		if index >= 0:
			destination_option.select(index)

func _refresh_trade_buttons() -> void:
	var has_good := _selected_good_id() != ""
	buy_button.disabled = not has_good
	sell_button.disabled = not has_good
	sail_button.disabled = destination_ids.is_empty()

func _selected_good_id() -> String:
	var selected := market_list.get_selected_items()
	if selected.is_empty():
		return ""
	var index: int = selected[0]
	if index < 0 or index >= market_good_ids.size():
		return ""
	return market_good_ids[index]

func _selected_destination_id() -> String:
	var index := destination_option.selected
	if index < 0 or index >= destination_ids.size():
		return ""
	return destination_ids[index]

func _on_market_item_selected(_index: int) -> void:
	_refresh_trade_buttons()

func _on_buy_pressed() -> void:
	var good_id := _selected_good_id()
	if good_id == "":
		return

	var quantity := int(quantity_spin.value)
	var port = ports[player.current_port_id]
	var result := TradeService.buy(player, goods[good_id], port.prices[good_id], quantity, goods)

	if result.get("ok", false):
		_set_log("买入 %d 份%s，支出 %d。" % [quantity, goods[good_id].display_name, result["total_cost"]])
	else:
		_set_log("买入失败：%s" % result.get("message", "未知错误"))

	_refresh_all()

func _on_sell_pressed() -> void:
	var good_id := _selected_good_id()
	if good_id == "":
		return

	var quantity := int(quantity_spin.value)
	var port = ports[player.current_port_id]
	var result := TradeService.sell(player, goods[good_id], port.prices[good_id], quantity)

	if result.get("ok", false):
		_set_log("卖出 %d 份%s，收入 %d，本笔利润 %.0f。" % [
			quantity,
			goods[good_id].display_name,
			result["revenue"],
			result["profit"]
		])
	else:
		_set_log("卖出失败：%s" % result.get("message", "未知错误"))

	_refresh_all()

func _on_sail_pressed() -> void:
	var destination_id := _selected_destination_id()
	if destination_id == "":
		return

	var origin = ports[player.current_port_id]
	var destination = ports[destination_id]
	var start_result := VoyageService.start_voyage(player, origin, destination)

	if not start_result.get("ok", false):
		_set_log("出航失败：%s" % start_result.get("message", "未知错误"))
		return

	var voyage = start_result["voyage"]
	var event_result := EventService.resolve(player)
	var arrival_result := VoyageService.complete_voyage(player, voyage)

	if not arrival_result.get("ok", false):
		_set_log("航行结算失败：%s" % arrival_result.get("message", "未知错误"))
		return

	_set_log("%s → %s，基础航程 %d 天。%s" % [
		origin.display_name,
		destination.display_name,
		arrival_result["days"],
		event_result.get("message", "")
	])
	_refresh_all()

func _set_log(message: String) -> void:
	log_label.text = message
	print(message)
