# tests

首版测试使用 Godot 自带的 headless 模式，不依赖第三方测试框架。

## 运行

```bash
godot --headless --path . --script res://tests/test_runner.gd
```

如果系统命令名是 `godot4`：

```bash
godot4 --headless --path . --script res://tests/test_runner.gd
```

## 当前覆盖

1. 买入后资金减少、货舱增加；
2. 超过货舱容量时拒绝交易；
3. 卖出收入和利润计算；
4. `IN_PORT → SAILING → IN_PORT` 航行状态与天数推进；
5. 保存后读取，港口、天数、资金、船只与货舱关键状态一致；\n6. 连续三港贸易：宁波丝绸 → 广州砂糖 → 泉州胡椒 → 宁波，验证最终资金、天数、港口与空货舱。

测试使用独立的 `user://test_savegame.json`，结束后会删除，不影响正常单档存档。

## 约定

测试通过：进程退出码 `0`。  
存在失败：进程退出码 `1`。
