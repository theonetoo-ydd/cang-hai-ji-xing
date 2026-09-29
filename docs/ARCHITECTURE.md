# 首版架构原则

当前不绑定具体引擎 API。无论最终采用何种技术栈，优先保持以下分层。

## 1. Data 数据层

负责静态配置：
- 港口；
- 商品；
- 基础价格；
- 航线；
- 事件定义。

要求：尽量可编辑、可验证，不把价格等内容硬编码进 UI。

## 2. Domain 规则层

负责纯游戏规则：
- 买入；
- 卖出；
- 货舱容量；
- 利润；
- 航行时间；
- 事件结果；
- 玩家状态变化。

原则：尽量不依赖具体 UI，这样规则更容易测试。

## 3. Game Flow 流程层

负责把规则串成游戏：
- 进入港口；
- 打开市场；
- 买卖；
- 选择目的港；
- 出航；
- 处理事件；
- 抵港；
- 结算。

建议最小状态：

```text
IN_PORT → SAILING → IN_PORT
```

之后需要时再扩展 BATTLE、STORY、GAME_OVER 等状态。

## 4. Presentation 表现层

负责：
- 界面；
- 地图；
- 按钮；
- 动画；
- 音效；
- 文本提示。

表现层读取状态并发出玩家操作，不直接保存核心经济规则。

## 第一版核心对象

### Port
- id
- name
- market prices
- routes

### Good
- id
- name
- base value
- cargo size

### Ship
- id
- capacity
- condition

### CargoItem
- good_id
- quantity
- average_buy_price

### PlayerState
- money
- current_port
- day
- ship
- cargo

### Voyage
- origin
- destination
- duration
- elapsed
- status

## 重要约束

- 先让规则可测试，再做漂亮 UI。
- 游戏数据和代码分开。
- 不在同一对象里同时塞入历史资料、UI、交易逻辑和存档逻辑。
- MVP 可以简单，但状态变化必须可解释。
