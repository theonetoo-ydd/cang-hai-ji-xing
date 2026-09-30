extends Control

const GameDataScript = preload("res://src/core/game_data.gd")
const ShipScript = preload("res://src/models/ship.gd")
const PlayerStateScript = preload("res://src/models/player_state.gd")
const TradeService = preload("res://src/economy/trade_service.gd")
const VoyageService = preload("res://src/sailing/voyage_service.gd")
const EventService = preload("res://src/sailing/event_service.gd")
const SaveService = preload("res://src/save/save_service.gd")

@onready var tabs: TabContainer = $OuterMargin/RootVBox/MainTabs
@onready var date_label: Label = $OuterMargin/RootVBox/TopBar/TopMargin/TopHBox/DateLabel
@onready var money_label: Label = $OuterMargin/RootVBox/TopBar/TopMargin/TopHBox/MoneyLabel
@onready var save_button: Button = $OuterMargin/RootVBox/TopBar/TopMargin/TopHBox/SaveButton
@onready var load_button: Button = $OuterMargin/RootVBox/TopBar/TopMargin/TopHBox/LoadButton
@onready var help_button: Button = $OuterMargin/RootVBox/TopBar/TopMargin/TopHBox/HelpButton
@onready var tutorial_panel: PanelContainer = $TutorialPanel
@onready var tutorial_status: Label = $TutorialPanel/TutorialMargin/TutorialVBox/TutorialStatus
@onready var tutorial_close: Button = $TutorialPanel/TutorialMargin/TutorialVBox/TutorialClose
@onready var port_name: Label = $OuterMargin/RootVBox/MainTabs/港口/NavPanel/NavVBox/PortName
@onready var port_flavor: Label = $OuterMargin/RootVBox/MainTabs/港口/NavPanel/NavVBox/PortFlavor
@onready var map_nav: Button = $OuterMargin/RootVBox/MainTabs/港口/NavPanel/NavVBox/MapNav
@onready var scene_sky: ColorRect = $OuterMargin/RootVBox/MainTabs/港口/PortScene/SceneVBox/SceneSky
@onready var scene_title: Label = $OuterMargin/RootVBox/MainTabs/港口/PortScene/SceneVBox/SceneTitle
@onready var scene_description: Label = $OuterMargin/RootVBox/MainTabs/港口/PortScene/SceneVBox/SceneDescription
@onready var time_badge: Label = $OuterMargin/RootVBox/MainTabs/港口/PortScene/SceneVBox/TimeBadge
@onready var capacity_label: Label = $OuterMargin/RootVBox/MainTabs/港口/MarketPanel/MarketVBox/MarketHeader/CapacityLabel
@onready var market_list: ItemList = $OuterMargin/RootVBox/MainTabs/港口/MarketPanel/MarketVBox/MarketList
@onready var quantity_spin: SpinBox = $OuterMargin/RootVBox/MainTabs/港口/MarketPanel/MarketVBox/TradeRow/QuantitySpin
@onready var buy_button: Button = $OuterMargin/RootVBox/MainTabs/港口/MarketPanel/MarketVBox/TradeRow/BuyButton
@onready var sell_button: Button = $OuterMargin/RootVBox/MainTabs/港口/MarketPanel/MarketVBox/TradeRow/SellButton
@onready var ship_label: Label = $OuterMargin/RootVBox/MainTabs/港口/RightPanel/RightVBox/ShipLabel
@onready var cargo_label: Label = $OuterMargin/RootVBox/MainTabs/港口/RightPanel/RightVBox/CargoLabel
@onready var ningbo_button: Button = $OuterMargin/RootVBox/MainTabs/航海图/NingboButton
@onready var quanzhou_button: Button = $OuterMargin/RootVBox/MainTabs/航海图/QuanzhouButton
@onready var guangzhou_button: Button = $OuterMargin/RootVBox/MainTabs/航海图/GuangzhouButton
@onready var route_info: Label = $OuterMargin/RootVBox/MainTabs/航海图/RouteInfo
@onready var sail_button: Button = $OuterMargin/RootVBox/MainTabs/航海图/SailButton
@onready var portrait_label: Label = $OuterMargin/RootVBox/BottomLog/LogMargin/LogHBox/Portrait\n@onready var log_label: Label = $OuterMargin/RootVBox/BottomLog/LogMargin/LogHBox/LogLabel

var goods: Dictionary = {}
var ports: Dictionary = {}
var player
var market_good_ids: Array[String] = []
var selected_destination_id := ""\nvar last_money := 1000

const PORT_FLAVOR := {
	"ningbo": "东海商舶云集之地",
	"quanzhou": "刺桐旧港，南货北珍交汇",
	"guangzhou": "南海门户，番舶百货所聚",
}

const PORT_SCENES := {
	"ningbo": {
		"title": "东海晨雾",
		"description": "潮声拍岸，帆樯在薄雾中次第显现。来自江南的丝绸与瓷器正装上商船。",
		"color": Color(0.34, 0.48, 0.49, 1),
	},
	"quanzhou": {
		"title": "刺桐斜阳",
		"description": "夕光落在石岸与桅杆之间。南北货物在码头交汇，海商正在议价。",
		"color": Color(0.52, 0.36, 0.23, 1),
	},
	"guangzhou": {
		"title": "南海晴岚",
		"description": "暖风越过珠江口，远来番舶停泊外港。香料、砂糖与百货汇聚于此。",
		"color": Color(0.28, 0.45, 0.4, 1),
	},
}

const GOOD_MARKS := {
	"silk": "绫",
	"porcelain": "瓷",
	"tea": "茶",
	"copper": "铜",
	"pepper": "香",
	"sugar": "糖",
}

func _ready() -> void:
	var game_data := GameDataScript.load_all()
	goods = game_data.get("goods", {})
	ports = game_data.get("ports", {})
	player = PlayerStateScript.new(1000, "ningbo", ShipScript.new("starter_ship", 20, 100))

	market_list.item_selected.connect(_on_market_item_selected)
	buy_button.pressed.connect(_on_buy_pressed)
	sell_button.pressed.connect(_on_sell_pressed)
	map_nav.pressed.connect(_open_map)
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	help_button.pressed.connect(_on_help_pressed)
	tutorial_close.pressed.connect(_on_tutorial_close_pressed)
	ningbo_button.pressed.connect(_select_destination.bind("ningbo"))
	quanzhou_button.pressed.connect(_select_destination.bind("quanzhou"))
	guangzhou_button.pressed.connect(_select_destination.bind("guangzhou"))
	sail_button.pressed.connect(_on_sail_pressed)

	_refresh_all()
	_set_log("客官，船已泊于宁波。可先在商馆采买，再从海图选择航路。")

func _refresh_all() -> void:
	_refresh_header()
	_refresh_port()
	_refresh_market()
	_refresh_cargo()
	_refresh_map()
	_update_tutorial_hint()

func _refresh_header() -> void:
	date_label.text = "航海历 · 第 %d 天" % player.day
	var delta := player.money - last_money
	if delta == 0:
	\tmoney_label.text = "银两 %d" % player.money
	else:
	\tmoney_label.text = "银两 %d　%+d" % [player.money, delta]
	last_money = player.money

func _refresh_port() -> void:
	var port = ports[player.current_port_id]
	port_name.text = "%s港" % port.display_name
	port_flavor.text = PORT_FLAVOR.get(player.current_port_id, "海路通商之港")
	var scene: Dictionary = PORT_SCENES.get(player.current_port_id, {})
	scene_title.text = str(scene.get("title", "海港风物"))
	scene_description.text = str(scene.get("description", "潮来潮往，商旅不绝。"))
	scene_sky.color = scene.get("color", Color(0.34, 0.48, 0.49, 1))
	time_badge.text = _time_badge()
	capacity_label.text = "货舱 %d/%d" % [player.used_capacity(goods), player.ship.capacity]
	ship_label.text = "福船 · 近海商船\n耐久 %d / 100\n货舱 %d / %d\n状态：泊港整备" % [
		player.ship.condition,
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
		market_good_ids.append(good_id)
		var trend := _market_hint(good_id, price)
		var mark: String = GOOD_MARKS.get(good_id, "货")
		market_list.add_item("【%s】%-6s　买 %4d　卖 %4d　持有 %2d　%s" % [
			mark, good.display_name, price.buy_price, price.sell_price,
			player.cargo_quantity(good_id), trend
		])

	if selected_good_id != "":
		var index := market_good_ids.find(selected_good_id)
		if index >= 0:
			market_list.select(index)
	if market_list.get_selected_items().is_empty() and market_list.item_count > 0:
		market_list.select(0)

func _refresh_cargo() -> void:
	if player.cargo.is_empty():
		cargo_label.text = "货 舱\n\n（空）"
		return
	var lines: Array[String] = ["货 舱", ""]
	for good_id in player.cargo:
		var item = player.cargo[good_id]
		var name := goods[good_id].display_name if goods.has(good_id) else good_id
		lines.append("%s × %d\n成本 %.1f" % [name, item.quantity, item.average_buy_price])
	cargo_label.text = "\n".join(lines)

func _refresh_map() -> void:
	selected_destination_id = ""
	route_info.text = "当前停泊：%s。请选择可达港口。" % ports[player.current_port_id].display_name
	sail_button.disabled = true

	var current = ports[player.current_port_id]
	for entry in [
		["ningbo", ningbo_button],
		["quanzhou", quanzhou_button],
		["guangzhou", guangzhou_button],
	]:
		var port_id: String = entry[0]
		var button: Button = entry[1]
		if port_id == player.current_port_id:
			button.disabled = true
			button.text = "%s · 当前" % ports[port_id].display_name
		elif current.routes.has(port_id):
			button.disabled = false
			button.text = ports[port_id].display_name
		else:
			button.disabled = true
			button.text = "%s · 未通航" % ports[port_id].display_name

func _selected_good_id() -> String:
	var selected := market_list.get_selected_items()
	if selected.is_empty():
		return ""
	var index: int = selected[0]
	if index < 0 or index >= market_good_ids.size():
		return ""
	return market_good_ids[index]

func _on_market_item_selected(_index: int) -> void:
	pass

func _on_buy_pressed() -> void:
	var good_id := _selected_good_id()
	if good_id == "":
		return
	var quantity := int(quantity_spin.value)
	var port = ports[player.current_port_id]
	var result := TradeService.buy(player, goods[good_id], port.prices[good_id], quantity, goods)
	if result.get("ok", false):
		_set_speaker("商 馆 掌 柜")
		_set_log("成交。收您 %d 两，%d 份%s已经装船。" % [result["total_cost"], quantity, goods[good_id].display_name])
	else:
		_set_speaker("商 馆 掌 柜")
		_set_log("这笔买卖做不成——%s" % result.get("message", "未知错误"))
	_refresh_all()

func _on_sell_pressed() -> void:
	var good_id := _selected_good_id()
	if good_id == "":
		return
	var quantity := int(quantity_spin.value)
	var port = ports[player.current_port_id]
	var result := TradeService.sell(player, goods[good_id], port.prices[good_id], quantity)
	if result.get("ok", false):
		_set_speaker("商 馆 掌 柜")
		_set_log("货收下了。入账 %d 两，本笔盈亏 %+.0f。" % [result["revenue"], result["profit"]])
	else:
		_set_log("掌柜：这笔买卖做不成——%s" % result.get("message", "未知错误"))
	_refresh_all()

func _open_map() -> void:
	tabs.current_tab = 1
	_refresh_map()
	_set_speaker("舵 手")
	_set_log("请在海图上指定下一处港口。")

func _select_destination(port_id: String) -> void:
	if not ports[player.current_port_id].routes.has(port_id):
		return
	selected_destination_id = port_id
	var days: int = ports[player.current_port_id].routes[port_id]
	route_info.text = "%s → %s　预计 %d 天" % [
		ports[player.current_port_id].display_name,
		ports[port_id].display_name,
		days
	]
	sail_button.disabled = false

func _on_sail_pressed() -> void:
	if selected_destination_id == "":
		return
	var origin = ports[player.current_port_id]
	var destination = ports[selected_destination_id]
	var result := VoyageService.start_voyage(player, origin, destination)
	if not result.get("ok", false):
		_set_log("无法出航：%s" % result.get("message", "未知错误"))
		return

	var event_result := EventService.resolve(player)
	var arrival := VoyageService.complete_voyage(player, result["voyage"])
	if not arrival.get("ok", false):
		_set_log("航行结算失败。")
		return

	tabs.current_tab = 0
	_refresh_all()
	_set_speaker("航 海 日 志")
	_set_log("抵达%s。%s" % [destination.display_name, event_result.get("message", "")])

func _on_save_pressed() -> void:
	var result := SaveService.save_game(player)
	_set_log(result.get("message", "存档操作完成。"))

func _on_load_pressed() -> void:
	var result := SaveService.load_game()
	if not result.get("ok", false):
		_set_log("读取失败：%s" % result.get("message", "未知错误"))
		return
	var loaded_player = result.get("player")
	if loaded_player == null or not ports.has(loaded_player.current_port_id):
		_set_log("读取失败：存档状态无效。")
		return
	player = loaded_player
	tabs.current_tab = 0
	_refresh_all()
	_set_log("旧航海日志已展开：回到%s，第 %d 天。" % [ports[player.current_port_id].display_name, player.day])

func _set_speaker(name: String) -> void:
	portrait_label.text = name

func _set_log(message: String) -> void:
	log_label.text = message
	print(message)


func _time_badge() -> String:
	var phase := player.day % 4
	match phase:
		0:
			return "卯时 · 晨雾"
		1:
			return "辰时 · 微风"
		2:
			return "午后 · 晴"
		_:
			return "酉时 · 斜阳"

func _market_hint(good_id: String, price) -> String:
	var good = goods.get(good_id)
	if good == null:
		return "行情平"
	var spread: int = price.buy_price - price.sell_price
	if price.buy_price <= 55:
		return "价低"
	if spread <= 5:
		return "活跃"
	if price.buy_price >= 100:
		return "价高"
	return "平稳"


func _on_help_pressed() -> void:
	tutorial_panel.visible = true
	_update_tutorial_hint()

func _on_tutorial_close_pressed() -> void:
	tutorial_panel.visible = false

func _update_tutorial_hint() -> void:
	if tutorial_status == null or player == null:
		return

	var silk_quantity := player.cargo_quantity("silk")
	if player.current_port_id == "ningbo" and silk_quantity == 0:
		tutorial_status.text = "当前目标 1/4：选择【绫】丝绸，建议先买 5 份。"
	elif player.current_port_id == "ningbo" and silk_quantity > 0:
		tutorial_status.text = "当前目标 2/4：打开海图，选择广州并出航。"
	elif player.current_port_id == "guangzhou" and silk_quantity > 0:
		tutorial_status.text = "当前目标 3/4：在广州商馆卖出携带的丝绸。"
	elif player.current_port_id == "guangzhou" and player.money > 1000:
		tutorial_status.text = "初航完成：第一笔跨港贸易已盈利。接下来可以自由跑商。"
	else:
		tutorial_status.text = "自由航行：比较各港买卖价，低买高卖，留意货舱容量。"
