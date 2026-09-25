# GPT 原生写入授权 — 排查清单

> **目的**：让 GPT 能自己写 `turns/00N_gpt.md`，不再需要 User 中转。
> **对象**：User 在 ChatGPT / GitHub 的授权界面操作。DeepSeek 无法代做（属 OpenAI 侧授权链路）。
> **当前状态**：GPT 原生写入 = ❌ 403。替代通道 `tools/bridge.ps1` = ✅ 已验证可用。

## 一、先分清两层（这是 403 的根因）

| 层 | 位置 | 作用 | 现状 |
|---|---|---|---|
| **动作层** | ChatGPT → 连接器 "Allow all actions" | 允许连接器**去调用**写操作 | ✅ 已开 |
| **授权层** | **GitHub 侧** App/OAuth 授权 | GitHub **实际授予**了哪些权限 | ❌ 疑为只读 |

**只开动作层、没开授权层 = 「有权调用一个必然被拒绝的操作」**，用户看到的就是「我明明允许了却还是 403」。

## 二、关键证据：全线 403 指向授权层

GPT 报告：写文件 **403**、底层 Git blob **403**、开 GitHub Issue **也 403**。

**这个「连 Issue 都 403」是强信号。** 如果只是缺 `Contents: write`，开 Issue 应当成功（那需要的是 `Issues: write`，是另一项权限）。**所有写操作全线 403，说明该连接根本没有拿到本仓库的写上下文**——最可能是 **GitHub App 未安装到本仓库**，或 installation 的仓库列表里没有 `rw-unit-guess`。

补充：GPT 的 GitHub 连接器基于 GitHub App 机制，**GitHub App 的权限由 installation 决定，ChatGPT 侧界面管不到它**。这是最容易漏的一环。

## 三、按顺序排查（每步做完让 GPT 重试一次）

### 步骤 1 — ChatGPT 侧：模式开关

在 ChatGPT 的 GitHub 连接器设置里查找**模式开关**（read-only ↔ read/write）。

- 「Allow all actions」是**权限门**，模式是**另一个门**，两者独立。
- 若找到 read-only，切换到读写模式后让 GPT 重试。

### 步骤 2 — GitHub 侧：确认 App 安装范围（最可能的问题所在）

1. GitHub → 右上头像 → **Settings**
2. 左侧 **Applications** → **Installed GitHub Apps**
3. 找到 ChatGPT 对应的连接器，点 **Configure**
4. 检查两件事：
   - **Repository access**：确认 `yetengyang8-eng/rw-unit-guess` **在此 installation 的仓库列表内**
     （若为 "Only select repositories"，需手动把本仓库加进去）
   - **Repository permissions**：确认 **Contents = Read and write**
5. 保存后让 GPT 重试

### 步骤 3 — 若前两步无效：改用细粒度 PAT

最可控的方案。GPT 连接器若支持填入 PAT：

1. GitHub → Settings → **Developer settings** → **Personal access tokens** → **Fine-grained tokens**
2. 新建 token：
   - **Repository access**：Only select repositories → 只选 `rw-unit-guess`
   - **Permissions** → Repository permissions → **Contents: Read and write**
   - （如需开 Issue 再加 `Issues: Read and write`）
3. 把 token 填入 ChatGPT 的 GitHub 连接器

> ⚠️ **安全**：PAT 等同密码。不要贴进本仓库、不要贴进聊天记录、不要 commit。
> 本仓库是公开仓库，一旦写入即等于泄露，需立即吊销。
> 授权范围请**只给这一个仓库**，不要给 `All repositories`。

## 四、修好后的验证方法

让 GPT 试写一个**无害的测试文件**（例：`turns/999_gpt_write_test.md`），确认：

1. GPT 报告写入成功（非 403）；
2. DeepSeek 端用 commit SHA 固定地址回读，确认远端确实存在；
3. 确认后删除测试文件。

**只有「远端回读成功」才算真的修好。** GPT 自报成功不算证据——它可能在本地缓存里成功了。

## 五、修好后如何与既有桥共存

- **原生写入修好** → 优先用原生，`tools/bridge.ps1` 保留为备用通道。
- **桥的建议用法（修好后）**：让 GPT 通过桥**主动发起 pull request**——桥可作为「GPT 请求人审」的通道，而不仅是替代写入路径。
- **不变的一点**：无论走哪条通道，**答案类信息都不得进入本仓库**。
