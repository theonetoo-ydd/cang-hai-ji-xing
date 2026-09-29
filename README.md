# 沧海纪行

> Ming-era Chinese navigator sailing trade game MVP

《沧海纪行》是一款以明代中国航海、贸易与探索为核心体验的单机游戏原型。首版目标不是做“大而全”的历史模拟，而是先验证一条可反复游玩的核心循环：

**接取目标 → 采购货物 → 规划航线 → 航行与事件 → 抵港交易 → 获利与成长 → 开启下一段航程**

## 当前阶段

项目刚初始化，当前版本是 **v0 项目骨架**。本阶段优先确定：
- 一条可玩的最小贸易闭环；
- 数据与逻辑分离的基础结构；
- 简单、可回退的 Git 工作流；
- 适合新手逐步实现的开发任务。

首版骨架暂时保持**引擎无关**，避免在需求尚未固化前把仓库锁死到某个技术栈。进入可玩原型阶段前再确认引擎；若以“新手友好、2D、快速原型”为优先，可优先评估 **Godot 4 + GDScript**。

## MVP 边界

首个可玩版本只验证“航海贸易是否有趣”，暂定包含：

1. 玩家拥有基础资金、货舱和船只状态；
2. 至少 3 个港口；
3. 至少 6 种商品；
4. 港口商品价格存在差异；
5. 玩家可以买入、装载、航行、抵港、卖出；
6. 航行消耗天数或补给；
7. 至少 3 类随机事件；
8. 完成一次贸易后可以看到利润变化；
9. 存档只要求支持单档或自动存档。

首版暂不做：
- 大规模海战；
- 复杂外交；
- 多角色剧情树；
- 写实天气/洋流模拟；
- 多人联机；
- 完整历史数据库。

## 目录结构

```text
cang-hai-ji-xing/
├─ README.md
├─ CONTRIBUTING.md
├─ TASKS.md
├─ .gitignore
├─ .gitattributes
├─ docs/
│  ├─ MVP.md
│  └─ ARCHITECTURE.md
├─ src/
│  └─ README.md
├─ data/
│  └─ README.md
├─ assets/
│  └─ README.md
└─ tests/
   └─ README.md
```

说明：
- `docs/`：玩法、规则、架构和决策记录；
- `src/`：未来的游戏逻辑与场景代码；
- `data/`：港口、商品、事件等可配置数据；
- `assets/`：美术、音频、字体等资源说明；
- `tests/`：规则测试、数据校验和回归测试。

## 开发顺序

推荐按以下顺序推进：

**M0：骨架**
- README、目录、Git 规则、MVP 定义。

**M1：纯逻辑贸易模拟**
- 不做 UI，先用最简单的脚本验证“买—航行—卖—盈利”。

**M2：最小可玩界面**
- 港口界面、货舱、航行按钮、结算界面。

**M3：事件与成长**
- 航行事件、船只状态、基础升级。

**M4：历史与内容扩展**
- 在核心循环稳定后再扩充真实港口、商品、人物和时代背景。

## 运行项目

首版技术栈已经确定为 **Godot 4.x + GDScript**。

1. 安装 Godot 4.x。
2. 用 Godot Project Manager 导入仓库根目录的 `project.godot`。
3. 点击 **Run Project**。

也可以在已经配置 Godot 命令行的环境中运行：

```bash
godot --path .
```

启动后应看到《沧海纪行》标题界面。点击“开始航行”会显示下一阶段 T03–T07 的提示。

技术栈决策见 [docs/ADR-001-tech-stack.md](docs/ADR-001-tech-stack.md)。

## Git 工作流

`main` 始终保持可用。日常开发从 `main` 新建短分支：

```bash
git switch main
git pull
git switch -c feat/trade-loop
```

分支建议：
- `feat/*`：新功能
- `fix/*`：修复
- `docs/*`：文档
- `chore/*`：工程与维护

提交信息使用简单的 Conventional Commits：

```text
feat: add basic trade calculation
fix: prevent cargo from exceeding capacity
docs: define MVP gameplay loop
chore: initialize project structure
```

开发完成后推送分支并通过 Pull Request 合并到 `main`。新手阶段建议优先 **Squash and merge**，让主分支历史保持清晰。

## 第一个里程碑

当下面这句话可以被真实操作验证时，MVP 第一阶段就算成立：

> 玩家能在港口 A 用资金买入商品，航行到港口 B，卖出商品，并看到资金与货舱正确变化。

具体任务见 [TASKS.md](TASKS.md)。

## 项目原则

- 先做可玩闭环，再做大世界；
- 先做数据模型，再堆内容；
- 先用假数据跑通，再考据真实历史；
- 一个任务尽量在 0.5–2 天内完成；
- 每次提交只解决一类问题；
- 无法验证的“大设计”先不实现。
