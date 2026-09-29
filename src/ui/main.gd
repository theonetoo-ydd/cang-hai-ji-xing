extends Control

const GameDataScript = preload("res://src/core/game_data.gd")
const ShipScript = preload("res://src/models/ship.gd")
const PlayerStateScript = preload("res://src/models/player_state.gd")
const TradeService = preload("res://src/economy/trade_service.gd")
const VoyageService = preload("res://src/sailing/voyage_service.gd")

@onready var status_label: Label = $Center/Panel/Margin/VBox/StatusLabel
@onready var start_button: Button = $Center/Panel/Margin/VBox/StartButton
@onready var hint_label: Label = $Center/Panel/Margin/VBox/HintLabel

var goods: Dictionary = {}
var ports: Dictionary = {}

func _ready() -> void:
	var game_data := GameDataScript.load_all()
	goods = game_data.get("goods", {})
	ports = game_data.get("ports", {})

	print("沧海纪行启动成功。")
	status_label.text = "MVP 0.2 · 已载入 %d 个港口 / %d 种商品" % [ports.size(), goods.size()]
	hint_label.text = "点击按钮运行 T03–T07：买入 → 航行 → 卖出"
	start_button.text = "运行首笔贸易 Demo"
	start_button.disabled = not _demo_data_ready()

	if not start_button.disabled:
		start_button.grab_focus()
	else:
		status_label.text = "数据加载失败：请检查 data/goods.json 与 data/ports.json"

func _on_start_button_pressed() -> void:
	status_label.text = _run_trade_demo()

func _demo_data_ready() -> bool:
	return (
		goods.has("silk")
		and ports.has("ningbo")
		and ports.has("guangzhou")
	)

func _run_trade_demo() -> String:
	var player = PlayerStateScript.new(
		1000,
		"ningbo",
		ShipScript.new("starter_ship", 20, 100)
	)

	var origin = ports["ningbo"]
	var destination = ports["guangzhou"]
	var good = goods["silk"]
	var quantity := 5

	var buy_result := TradeService.buy(
		player,
		good,
		origin.prices[good.id],
		quantity,
		goods
	)
	if not buy_result.get("ok", false):
		return "买入失败：%s" % buy_result.get("message", "未知错误")

	var voyage_result := VoyageService.start_voyage(player, origin, destination)
	if not voyage_result.get("ok", false):
		return "出航失败：%s" % voyage_result.get("message", "未知错误")

	var voyage = voyage_result["voyage"]
	var arrival_result := VoyageService.complete_voyage(player, voyage)
	if not arrival_result.get("ok", false):
		return "航行结算失败：%s" % arrival_result.get("message", "未知错误")

	var sell_result := TradeService.sell(
		player,
		good,
		destination.prices[good.id],
		quantity
	)
	if not sell_result.get("ok", false):
		return "卖出失败：%s" % sell_result.get("message", "未知错误")

	var profit := int(round(float(sell_result["profit"])))

	print(
		"Trade demo complete: start=1000, end=%d, profit=%d, day=%d"
		% [player.money, profit, player.day]
	)

	return (
		"T03–T07 贸易 Demo 成功\n"
		+ "宁波：买入 %d 份%s，支出 %d\n" % [quantity, good.display_name, buy_result["total_cost"]]
		+ "航行：宁波 → 广州，耗时 %d 天\n" % arrival_result["days"]
		+ "广州：卖出 %d 份%s，收入 %d\n" % [quantity, good.display_name, sell_result["revenue"]]
		+ "最终资金：%d　单次利润：+%d　当前第 %d 天"
		% [player.money, profit, player.day]
	)
