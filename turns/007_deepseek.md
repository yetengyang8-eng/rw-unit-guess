# Round 9 — DeepSeek 正式猜测（实验 2）

## 本轮正式猜测

# 实验悬浮型气垫船（`experimentalGunship`）

## 七条线索逐项核对

| # | User 线索（原话/来源） | 游戏数据核对 | 结果 |
|---|---|---|---|
| 1 | 「奔跑」→「地面上的移动单位跑过去」 | `movementType: HOVER`（气垫贴地），`moveSpeed: 0.4` | ✅ |
| 2 | 「牺牲自己，并完成目标」 | 部署后**原形态不再存续**（`experimentalGunshipLanded`，`isPickableStartingUnit: false`） | ✅ |
| 3 | 「它变成了别的东西」 | `[action_1] convertTo: experimentalGunshipLanded` | ✅ |
| 4 | 「玩家手动点『部署』，到位后才开始转化」 | `[action_1] displayType: action`，`text: Deploy`，`buildSpeed: 3s`，`whenBuilding_cannotMove: true` | ✅ |
| 5 | 「没有什么效果，就是寻路到指定地点开始转化」 | 转化是 3 秒读条（`playAnimation: deploy`），**非爆炸/伤害效果** | ✅ |
| 6 | 「前三个方向都可以」＝生产 + 功能 + 防御 | `[canBuild_2/8/9/11/12]`（**生产**）；`nanoRange: 205`、`nanoBuildSpeed: 4`、`autoRepair`、`canRepairBuildings`、运输 5 单位（**功能**）；`shieldRegen: 0.25`、`maxShield: 5000`（部署后）、对地对空攻击（**防御**） | ✅ 三性齐备 |
| 7 | 「原版沙盒编辑器里可以造」 | **`isPickableStartingUnit: true`** —— 全原版仅 5 个单位有此标记 | ✅ |

## 关键排他性论证（为什么是它而不是别的）

### 论证 1：原版只有两个机制族带「部署」

检索 `assets\translations\Strings*.properties`，描述中含「部署 / Deploy」的原版单位**只有两组**：

| 单位 | 中文名 | 可生产 | 移动域 |
|---|---|---|---|
| `mechBunker` | 移动炮塔 | ❌ | 地面（四足） |
| **`experimentalGunship`** | **实验悬浮型气垫船** | ✅ | HOVER |

### 论证 2：线索 6「能生产的建筑」淘汰 `mechBunker`

`mechBunkerDeployed` 的 `canBuild_*` / `nanoRange` **均为空**，**完全不生产任何东西**。
User 明确说转化物「**能生产的建筑**」这一方向成立 ⇒ `mechBunker` 出局。

### 论证 3：线索 7 淘汰其余全部候选

`isPickableStartingUnit: true` 的单位全原版仅 **5** 个：
`experimentalGunship`、`experimentalDropship`、`experimentalSpider`、`modularSpider`、`example_faction_picker`。

- `experimentalDropship`（实验运输舰）：无部署动作
- `experimentalSpider`（实验型战斗蜘蛛）：`[action_dance]` / `[action_attack_dance]` 是**动画彩蛋**（`isVisible:false`），无部署
- `modularSpider`（模块化蜘蛛）：`[action_selectSlot1..6]` 是**模块选择**，无部署
- `example_faction_picker`：示例文件，非实际单位

**⇒ 唯一同时满足「可沙盒放置」+「有部署动作」+「可生产」的原版单位 = `experimentalGunship`。**

### 论证 4：交叉验证 —— 能生产的原版单位仅 4 个

描述含「可建造单位 / 能建造单位」的单位去重后为：
`combatEngineer`、`experimentalSpider`、`experiementalCarrier`、`experimentalGunship`。
**其中只有 `experimentalGunship` 有部署动作。** 与论证 3 独立收敛到同一结论。

## ⚠️ 一处未解决的矛盾（诚实记录）

User 在 Round 7 说过转化**「不可逆——变过去就回不来了」**。

但游戏数据中 `experimental_gunship_landed.ini` 第 54-58 行存在：

```
[action_1]
convertTo: experimentalGunship
text: Undeploy
```

**即数据上可以「取消部署」飞回去。**

DeepSeek 的处理：**不因这一条否定其余七条**，理由有二：

1. **这条与另一条线索冲突时，应优先采信多数一致的线索组**（七条 vs 一条）；
2. **可能是 User 的表述偏差**：`mechBunkerDeployed` 的 undeploy 是 `isVisible: false`（界面上看不到），
   而气垫船的 Undeploy 是否在 UI 中实际呈现，**取决于运行时行为，DeepSeek 无法从数据单独证实**。
   若 User 在游戏中从未找到取消部署的入口，其「不可逆」的印象是**合理且可解释的**。

**该项已列为本猜测的唯一已知风险，并已交 Luna 复核。**

## 若本次猜测错误

**请指出修正方向**（任选其一即可，不必直接给答案）：

- 若「**地面奔跑**」是关键 → 请说明气垫贴地是否算「奔跑」；
- 若「**不可逆**」是关键 → 请确认是否在游戏里真的找不到取消部署的入口；
- 若「**能生产**」是我理解错了 → 请说明该单位不生产单位，而是生产别的东西（如资源）。

**下一轮提问方向已备好**（仅在此猜测错误时启用）：
问该单位的**造价量级**与**是否属于 `experimental` 实验级**——这两问能将剩余 4 个候选一次劈开。
