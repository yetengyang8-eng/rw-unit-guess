# Current State

Round: 3 — **实验 2 开局**（Round 1 / 2 属实验 1，已结束）

Status: waiting_for_user

## 实验编号

| 实验 | 回合 | 单位 | 状态 |
|---|---|---|---|
| 实验 1 | `001` – `002` | Mech Engineer | ✅ 已结束（Round 2 命中） |
| **实验 2** | **`003` 起** | **未公开** | 🟡 进行中 |

## Confirmed clues（实验 2）

暂无。Round 3 提问已发出，等待 User 回答。

## Rejected candidates（实验 2）

暂无。

## Current leading candidates（实验 2）

**刻意为空，且不入库。** 依据实验 1 教训 2：把候选名单写入本仓库会使结果可被反推，破坏盲测。候选推理仅在聊天中进行。

## ⚠️ 实验 2 新增纪律（三项，来自实验 1 复盘）

1. **开局禁用固定选项** — 实验 1 因「陆行 = 轮式或履带」定义过窄漏掉步行机甲，浪费一轮。实验 2 前几轮一律开放式提问，由 User 用自己的话描述。
2. **禁止候选名单入库** — 「Mech Engineer」早在 commit `2306b0e` 就作为候选进了仓库，事后公布结果时盲测设计已被削弱。候选池不入库。
3. **GPT 写入须同守纪律** — User 已将 GPT 切换到 **Codex 模式**，该模式有 git 身份、**可直接写入本仓库**。GPT 只写分析与纠错，**不写候选名单、不写答案**。

## Protocol

每轮：DeepSeek 提 2 个问题 → User 回答 → DeepSeek 给出正式猜测 → User 判定 → DeepSeek 写 `turns/00N_deepseek.md` → GPT 写 `turns/00N_gpt.md`。

## 工具状态

- DeepSeek 本机 git：✅ 读写可用
- `tools/bridge.ps1`：✅ 已验证（备用通道）
- GPT 原生写入：🟡 改用 **Codex 模式** 试一轮；原生授权清单见 `tools/GPT_GITHUB_WRITE_FIX.md`

## Last writer

DeepSeek
