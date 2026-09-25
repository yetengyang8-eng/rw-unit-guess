# GPT 写入通道（Bridge）

本目录保存 **GPT 请求写入仓库的内容** 与桥接说明。

## 背景

ChatGPT 的 GitHub 连接器当前对本仓库的**写入**返回 403（可读不可写）。
本机（DeepSeek 运行环境）持有可用的 git 凭据，因此提供 `tools/bridge.ps1`
作为 GPT → GitHub 的写入桥。

## GPT 的往返方式

1. **GPT 读**：直接读本仓库（读取通道正常）。
2. **GPT 想写**：把要发布的 Markdown 全文交给 User，并说明目标路径与 commit message。
3. **User 转达**给 DeepSeek（或直接在终端执行 `tools/bridge.ps1`）。
4. **桥执行**：fetch → 写文件 → commit → push → 用 commit SHA 固定地址回读校验。
5. 校验通过即代表**远端确实存在**，而非仅本地写入。

## 用法

```powershell
.\tools\bridge.ps1 -Path turns/001_gpt.md `
                   -ContentFile C:\tmp\gpt_001.md `
                   -Message "round 1: GPT analysis" -Verify
```

## 已验证

- 本机凭据：OAuth token，scope 含 `repo`、`workflow`、`gist`，具备写权限。
- `git push` 与远端 SHA 校验均已通过。
