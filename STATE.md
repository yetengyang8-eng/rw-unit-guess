# Current State

Round: 2 — **已完成（实验达成胜利条件）**

Status: experiment_complete

## Confirmed clues

- **科技层级 = T2**（需要先造 T2 建造厂 / 实验室）。来源：Round 1 Q2 回答 B。
- **领域 / 移动方式：原框架有缺口**。Round 1 Q1 的 A–E 五类「没有严格符合的选项」。
  - **GPT 纠错（Round 1）**：原因不止「水下」缺失，还有 **DeepSeek 把「陆行」定义为「轮式或履带」，漏掉了步行机甲**。此外 Heavy Sub（纯水下）与 Amphibious Jet（多形态）也不属于任何单类。
- **Round 2 Q1 = 机械工厂（Mech Factory）**。来源：User 回答 D。
- **Round 2 Q2 = 建造 / 维修 / 生产单位**。来源：User 回答 A。
- 上述两问的交叉格在候选矩阵中**唯一对应一个单位**，无需进一步缩小。

## Rejected candidates

- Round 1 猜测「T1 陆行单位」→ **错误**。
- 「Heavy Sub 为唯一高概率候选」的方向 → GPT 否决，DeepSeek 采纳。
- 全部 T1 / T3 / 实验级 / 战役专属单位（因层级确认为 T2 而排除）。

## Current leading candidates

**已命中。** Round 2 正式猜测经 User 判定为**正确**，实验胜利条件达成。

> 依据 `README.md` 核心规则第 1 条「真正答案不得提前写入 GitHub」，
> 被猜中单位的具体名称**不记入本仓库**。命中路径复盘见 `turns/002_deepseek_result.md`。

## 协作机制评估

本轮命中是「**GPT 纠错 → 矩阵化提问**」的直接产物：

| 环节 | 贡献者 | 内容 |
|---|---|---|
| 纠错 | GPT | 指出「陆行 = 轮式或履带」定义过窄，补回步行机甲线 |
| 结构化 | GPT | 提出「工厂 × 武器」二维矩阵，把开放描述换成封闭枚举 |
| 提问 | DeepSeek | 采纳矩阵，微调为「工厂 + 能力」 |
| 命中 | — | (机械工厂, 建造) → 唯一解 |

**若没有 GPT 的纠错，DeepSeek 会沿 Heavy Sub 单线继续提问，轮数会显著增加。** 协作机制有效。

## GPT 写入桥状态

- ✅ **已修复（替代通道）**：`tools/bridge.ps1` 已实现并端到端验证。
- ✅ `turns/001_gpt.md` 已通过桥发布，并用 commit SHA 固定地址回读确认（HTTP 200）。
- ⏳ **GPT 侧原生写入仍为 403**，根因在 GitHub 授权层（GitHub App 未对仓库授予 `contents: write`，或 OAuth scope 仅只读）。需在 GitHub 侧授权界面解决。详见 `tools/README.md`。

## Protocol

每轮：DeepSeek 提 2 个问题 → User 回答 → DeepSeek 给出正式猜测 → User 判定 → DeepSeek 写 `turns/00N_deepseek.md` → GPT 写 `turns/00N_gpt.md`。

## Last writer

DeepSeek
