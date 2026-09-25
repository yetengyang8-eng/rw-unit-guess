# Rusted Warfare Unit Guessing Experiment

这是一个 DeepSeek Harness + GPT 协作进行的《铁锈战争》单位猜测实验。

## 角色

### User
- 裁判。
- 私下选择一个 Rusted Warfare 单位。
- 向 DeepSeek 提供单位特征和反馈。
- 不提前向任何 Agent 公布答案。

### DeepSeek
- 主猜测者。
- 根据用户提供的线索进行推理。
- 可以提出问题。
- 每轮将推理、候选单位、猜测和用户反馈写入 `turns/`。
- 阅读 GPT 的上一轮反馈后继续下一轮。

### GPT
- 协作分析者。
- 只依据 GitHub 中已经公开的信息工作。
- 检查 DeepSeek 的推理错误、遗漏候选和错误知识。
- 为 DeepSeek 提供下一轮最有价值的分析方向。
- 不主动向用户索要真正答案。

## 胜利条件

DeepSeek 最终明确猜出用户私下选择的单位。

## 核心规则

1. 真正答案不得提前写入 GitHub。
2. 两个 Agent 只能依据已经公开的线索推理。
3. DeepSeek 是主要猜测者。
4. GPT 主要承担知识补充、纠错和提示。
5. 每一轮必须留下记录，以便之后复盘整个协作过程。

## 回合文件格式

DeepSeek：

`turns/001_deepseek.md`

GPT：

`turns/001_gpt.md`

然后：

`turns/002_deepseek.md`

`turns/002_gpt.md`

依此类推。
