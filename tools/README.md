# GPT 写入通道（Bridge）

本目录提供 **GPT → GitHub 的写入桥**，以及桥接说明。

## 背景：为什么需要桥

两条通道是**相互独立**的：

| 通道 | 持有者 | 状态 |
|---|---|---|
| 本机 git + Credential Manager | DeepSeek 运行环境 | ✅ 读写均可用 |
| ChatGPT GitHub 连接器 | GPT 端 | ⚠️ 可读，**写入返回 403** |

**「Allow all actions」是 ChatGPT 侧的开关，它只允许连接器去调用操作，不等于 GitHub 侧真正授予了写权限。** 这是两层不同的授权 —— 这就是 GPT 看到「我获准了却仍然 403」的原因。

GPT 侧 403 需在 GitHub 授权层解决（GitHub App 需对 `yetengyang8-eng/rw-unit-guess` 授予 `contents: write`，或改用 PAT）。在修好之前，本桥是可用的替代通道。

## GPT 的往返方式

1. **GPT 读**：直接读本仓库（读取通道正常，无需桥）。
2. **GPT 想写**：把要发布的 Markdown 全文交给 User，说明目标路径与 commit message。
3. **User 转达**给 DeepSeek，内容落到 `G:\rw-bridge-inbox\<name>.md`。
4. **桥执行**：sync → 写文件 → commit → push → 用 commit SHA 固定地址回读校验。
5. 校验通过即代表**远端确实存在**，而非仅本地写入。

## 用法

> ⚠️ 本机执行策略禁止直接运行 `.ps1`，**必须**用 `powershell.exe -ExecutionPolicy Bypass`。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\bridge.ps1 `
    -Path turns/001_gpt.md `
    -ContentFile G:\rw-bridge-inbox\001_gpt.md `
    -Message "round 1: GPT analysis" -Verify
```

## 桥的行为约定

- **拒绝在有未提交改动时运行**（退出码 2），避免 `reset`/`checkout` 静默丢弃数据。先 commit 或 stash。
- 用 `merge --ff-only` 同步，工作副本分叉时直接报错而非强推。
- 路径做了 `..` 与绝对路径校验，防止越出仓库。
- 不打印、不存储任何凭据。

## 已验证

- 本机凭据：OAuth token，scope 含 `repo`、`workflow`、`gist`，具备写权限。
- `git push` 与远端 SHA 校验均已通过。
- `turns/001_gpt.md` 已通过本桥发布，并用 commit SHA 固定地址回读确认（HTTP 200）。
- 脏工作副本守卫生效（退出码 2，拒绝运行）。

## 相关文档

- **`GPT_GITHUB_WRITE_FIX.md`** — 让 GPT 恢复**原生写入**的排查清单（ChatGPT 模式开关 / GitHub App 安装范围 / 细粒度 PAT）。桥是替代通道，那份文档才是根治。
