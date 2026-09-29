# 参与开发

本项目当前以“小步提交、先跑通 MVP”为原则。

## 第一次开始

```bash
git clone https://github.com/theonetoo-ydd/cang-hai-ji-xing.git
cd cang-hai-ji-xing
git switch main
git pull
```

之后不要直接在 main 上做日常功能开发，而是建立短分支：

```bash
git switch -c feat/trade-loop
```

## 每次开发的最小流程

1. 只选择 TASKS.md 中一个小任务。
2. 完成后先检查：
   ```bash
   git status
   git diff
   ```
3. 暂存并提交：
   ```bash
   git add .
   git commit -m "feat: add basic trade calculation"
   ```
4. 推送：
   ```bash
   git push -u origin feat/trade-loop
   ```
5. 在 GitHub 创建 Pull Request，确认改动范围后合并。

## 分支命名

- `feat/*`：新功能
- `fix/*`：修复
- `docs/*`：文档
- `test/*`：测试
- `chore/*`：工程维护

## 提交信息

常用类型：`feat`、`fix`、`docs`、`test`、`refactor`、`chore`。

## 新手规则

- 一次只解决一类问题。
- 先跑通，再优化。
- 不把大量美术资源和逻辑代码混在一次提交中。
- 不把密码、密钥或私有素材上传到仓库。
- 改玩法规则时，同时更新 docs/。
