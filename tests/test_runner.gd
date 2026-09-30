extends SceneTree

const GameDataScript = preload("res://src/core/game_data.gd")
const ShipScript = preload("res://src/models/ship.gd")
const PlayerStateScript = preload("res://src/models/player_state.gd")
const TradeService = preload("res://src/economy/trade_service.gd")
const VoyageService = preload("res://src/sailing/voyage_service.gd")
const SaveService = preload("res://src/save/save_service.gd")

const TEST_SAVE_PATH := "user://test_savegame.json"

var passed := 0
var failed := 0
var goods: Dictionary
var ports: Dictionary

func _init() -> void:
	var data := GameDataScript.load_all()
	goods = data.get("goods", {})
	ports = data.get("ports", {})

	_test_buy_reduces_money()
	_test_over_capacity_is_rejected()
	_test_sell_profit()
	_test_voyage_state_transition()
	_test_save_load_round_trip()
	_test_three_port_trade_loop()

	print("")
	print("Tests: %d passed, %d failed" % [passed, failed])
	SaveService.delete_save(TEST_SAVE_PATH)
	quit(0 if failed == 0 else 1)

func _new_player(money: int = 1000, capacity: int = 20):
	return PlayerStateScript.new(money, "ningbo", ShipScript.new("test_ship", capacity, 100))

func _test_buy_reduces_money() -> void:
	var player = _new_player()
	var good = goods["silk"]
	var result := TradeService.buy(player, good, ports["ningbo"].prices["silk"], 2, goods)
	_expect(result.get("ok", false) and player.money == 840 and player.cargo_quantity("silk") == 2,
		"buy reduces money and adds cargo")

func _test_over_capacity_is_rejected() -> void:
	var player = _new_player(10000, 1)
	var good = goods["copper"]
	var result := TradeService.buy(player, good, ports["ningbo"].prices["copper"], 1, goods)
	_expect(not result.get("ok", true) and player.money == 10000 and player.cargo.is_empty(),
		"buy rejects cargo over capacity")

func _test_sell_profit() -> void:
	var player = _new_player()
	var good = goods["silk"]
	TradeService.buy(player, good, ports["ningbo"].prices["silk"], 5, goods)
	var result := TradeService.sell(player, good, ports["guangzhou"].prices["silk"], 5)
	_expect(result.get("ok", false) and player.money == 1125 and int(round(result["profit"])) == 125,
		"sell calculates revenue and profit")

func _test_voyage_state_transition() -> void:
	var player = _new_player()
	var start := VoyageService.start_voyage(player, ports["ningbo"], ports["guangzhou"])
	var started_ok := start.get("ok", false) and player.status == "SAILING"
	var finish := VoyageService.complete_voyage(player, start["voyage"])
	_expect(started_ok and finish.get("ok", false) and player.status == "IN_PORT"
		and player.current_port_id == "guangzhou" and player.day == 7,
		"voyage transitions state and advances time")

func _test_save_load_round_trip() -> void:
	var player = _new_player()
	var good = goods["silk"]
	TradeService.buy(player, good, ports["ningbo"].prices["silk"], 3, goods)
	player.day = 9
	player.current_port_id = "quanzhou"

	var saved := SaveService.save_game(player, TEST_SAVE_PATH)
	var loaded := SaveService.load_game(TEST_SAVE_PATH)
	var restored = loaded.get("player")

	_expect(saved.get("ok", false) and loaded.get("ok", false)
		and restored != null
		and restored.money == player.money
		and restored.day == 9
		and restored.current_port_id == "quanzhou"
		and restored.ship.capacity == player.ship.capacity
		and restored.cargo_quantity("silk") == 3,
		"save and load preserve core state")

func _expect(condition: bool, name: String) -> void:
	if condition:
		passed += 1
		print("PASS: %s" % name)
	else:
		failed += 1
		push_error("FAIL: %s" % name)


func _test_three_port_trade_loop() -> void:
	var player = _new_player()

	var buy_silk := TradeService.buy(player, goods["silk"], ports["ningbo"].prices["silk"], 5, goods)
	var leg_one := VoyageService.start_voyage(player, ports["ningbo"], ports["guangzhou"])
	var leg_one_done := VoyageService.complete_voyage(player, leg_one["voyage"])
	var sell_silk := TradeService.sell(player, goods["silk"], ports["guangzhou"].prices["silk"], 5)

	var buy_sugar := TradeService.buy(player, goods["sugar"], ports["guangzhou"].prices["sugar"], 10, goods)
	var leg_two := VoyageService.start_voyage(player, ports["guangzhou"], ports["quanzhou"])
	var leg_two_done := VoyageService.complete_voyage(player, leg_two["voyage"])
	var sell_sugar := TradeService.sell(player, goods["sugar"], ports["quanzhou"].prices["sugar"], 10)

	var buy_pepper := TradeService.buy(player, goods["pepper"], ports["quanzhou"].prices["pepper"], 5, goods)
	var leg_three := VoyageService.start_voyage(player, ports["quanzhou"], ports["ningbo"])
	var leg_three_done := VoyageService.complete_voyage(player, leg_three["voyage"])
	var sell_pepper := TradeService.sell(player, goods["pepper"], ports["ningbo"].prices["pepper"], 5)

	var all_ok := (
		buy_silk.get("ok", false)
		and leg_one.get("ok", false)
		and leg_one_done.get("ok", false)
		and sell_silk.get("ok", false)
		and buy_sugar.get("ok", false)
		and leg_two.get("ok", false)
		and leg_two_done.get("ok", false)
		and sell_sugar.get("ok", false)
		and buy_pepper.get("ok", false)
		and leg_three.get("ok", false)
		and leg_three_done.get("ok", false)
		and sell_pepper.get("ok", false)
	)

	_expect(all_ok
		and player.current_port_id == "ningbo"
		and player.day == 14
		and player.money == 1205
		and player.cargo.is_empty(),
		"three-port trade loop returns to Ningbo with profit")
