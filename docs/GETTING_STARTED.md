# 新手：完成第一次本地开发提交

仓库已经完成初始化。下面的“第一次提交”指你把仓库克隆到自己的电脑后，完成第一项开发任务并提交。

## 1. 克隆仓库

```bash
git clone https://github.com/theonetoo-ydd/cang-hai-ji-xing.git
cd cang-hai-ji-xing
```

## 2. 第一次使用 Git 时配置身份

先检查：

```bash
git config --global user.name
git config --global user.email
```

如果为空，再设置：

```bash
git config --global user.name "你的 GitHub 用户名"
git config --global user.email "你的 GitHub 邮箱"
```

## 3. 确认在 main 且本地最新

```bash
git switch main
git pull
```

## 4. 为一个任务创建分支

例如开始 T01：

```bash
git switch -c docs/tech-stack
```

## 5. 修改文件

按 TASKS.md 完成一个小任务。完成后查看改动：

```bash
git status
git diff
```

## 6. 暂存

只提交这次真正需要的文件：

```bash
git add docs/ADR-001-tech-stack.md
```

再次确认：

```bash
git status
```

## 7. 创建提交

```bash
git commit -m "docs: choose initial tech stack"
```

检查最近提交：

```bash
git log --oneline -5
```

## 8. 推送分支

```bash
git push -u origin docs/tech-stack
```

## 9. 在 GitHub 创建 Pull Request

目标分支选择 `main`。填写：
- 改了什么；
- 为什么这样做；
- 如何验证。

合并后，本地同步：

```bash
git switch main
git pull
git branch -d docs/tech-stack
```

## 遇到问题时先用这三个命令

```bash
git status
git diff
git log --oneline --decorate -10
```

它们分别告诉你：现在处于什么状态、改了什么、最近发生了什么。
