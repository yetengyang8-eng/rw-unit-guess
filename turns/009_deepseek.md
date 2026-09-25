# Round 10 — DeepSeek 修正猜测（实验 2）

## ❌ 上一猜被否决

**「实验悬浮型气垫船（`experimentalGunship`）」——错误。**

Luna 的复核在事前就指出了该猜的三处缺陷（HOVER ≠ 地面、Undeploy 非隐藏、`builtFrom` 全是注释），
**DeepSeek 当时用「七条对一条」的计数法压过了这些矛盾，这是方法论错误。**
本次否决**证实了 Luna 的判断，而非 DeepSeek 的论证**。

## User 的三条新约束（原话）

| # | User 原话 | 性质 |
|---|---|---|
| 1 | 「能从工厂里造出来，只是我不想直接告诉你生产它的工厂叫啥」 | 排除「非工厂产物」；工厂名被刻意隐瞒 |
| 2 | 「它的设计观感就是在地面上跑，我不知道在代码层面你怎么理解它」 | **以观感为准，不以 `movementType` 为准** |
| 3 | 「我曾后悔给它的一个指令，想要撤销发现不能」 | **不可撤销的动作 = 一手行为证据** |

## 用约束 3 做排他性筛选（关键）

遍历全 assets 的**每一个带 `convertTo` 的动作块**，检查其 `isVisible`：

| 单位 | 动作 | `isVisible` | 能否撤销 |
|---|---|---|---|
| `experimentalGunshipLanded` | Undeploy | （无该字段） | ✅ 可撤销 |
| `mechBunkerDeployed` | Undeploy | **`true`** | ✅ 可撤销 |
| `aaBeamGunship_afterburn` | Cancel Burn | — | ✅ 可撤销 |
| `extractorT3_overclocked` | Refund | — | ✅ 可撤销 |
| `extractorT3_reinforced` | Refund | — | ✅ 可撤销 |
| `amphibiousJet_underwater` | Fly | — | ✅ 可撤销 |
| `nautilusSubmarine` | Surface | — | ✅ 可撤销 |
| **`modularSpider` 槽位模块** | **Reclaim Slot** | **`if self.completed`** | ❌ **无法撤回「装了哪个模块」** |

**排除链**：User 说「想撤销发现不能」⇒ 排除一切带可见撤销动作的单位
⇒ `experimentalGunship`、`mechBunker`、`amphibiousJet`、`nautilus`、`extractor` **全部出局**。

## ✅ 修正后的正式猜测

# 模块化蜘蛛（`modularSpider`）

## 逐条核对

| # | User 线索 | 游戏数据 | 结果 |
|---|---|---|---|
| 1 | 「奔跑」/「在地面上跑」 | `movementType: OVER_CLIFF_WATER`，`startFallingWhenStartingUnit: true`——**蜘蛛形态、多条腿**（`leg.png`），观感即在地面爬/跑 | ✅ |
| 2 | 「牺牲自己，并完成目标」 | 在**自身槽位**上装入模块：`[action_buildFabricator]` / `_buildShieldGen` / `_buildSpeed` 等 11 种 | ✅ |
| 3 | 「它变成了别的东西」 | `convertTo: modularSpider_fabricator` 等——**原本的空槽变成了一个模块** | ✅ |
| 4 | 「玩家手动点『部署』，到位后才开始转化」 | `[action_build*]` 属 `displayType: action`，需玩家主动执行 | ✅ |
| 5 | 「没有什么效果，就是…开始转化」 | `buildSpeed` 为构建读条，**无爆炸/伤害** | ✅ |
| 6 | **「后悔想撤销发现不能」** | `[action_reclaim]`（回收槽位）**只能把模块变成空槽**，`convertTo: modularSpider_emptySlot`，**无法还原成你原本想装的另一个模块**；`description` 自述「Free up slot for **another** turret type」 | ✅ **强吻合** |
| 7 | 「生产 + 功能 + 防御」三合一 | `[action_buildFabricator]`（**生产**）/ `_buildNano`、`_buildSpeed`、`_buildBlink`（**功能**）/ `_buildLaserdefense`、`_buildShieldGen`、`_buildAntinuke`（**防御**） | ✅ |
| 8 | 「可以从沙盒编辑器直接放出来」 | **`isPickableStartingUnit: true`**（全原版仅 5 个） | ✅ |
| 9 | 「能从工厂里造出来」 | ⚠️ **数据中 `builtFrom_1_name` 为注释**（同气垫船情形） | ⚠️ **存疑** |

## ⚠️ 仍未解决的一项：约束 1「能从工厂里造出来」

`modular_spider.ini` 第 53-54 行：

```
#builtFrom_1_name: experimentalLandFactory
#builtFrom_1_pos:  6
```

**是注释。** 且全库检索**没有任何单位的 `canBuild` 列表包含 `modularSpider`**。

**这与 User 的约束 1 冲突。** 两种可能：

- **(a)** 该单位的工厂产物注册在**本机数据之外**（如 1.15 与 User 实际版本的差异，或 `game-lib.jar` 内的定义）；
- **(b)** User 所指的「工厂里出来」是**泛称**——包含「作为起始单位选取」这一途径。

**DeepSeek 不自行裁定，交由裁判确认。**

## 若本猜错误

**请只回答一个问题**（不必给答案）：
**「它变成的那个东西，是留在它自己身上，还是变成了一个独立存在的新东西？」**

- 若「留在它自己身上」→ 指向槽位/模块类机制；
- 若「变成独立的新东西」→ 指向部署成建筑类机制，DeepSeek 需回到 `mechBunker` 方向重查
  （但需解释「不可撤销」与该单位 `Undeploy: isVisible: true` 的矛盾）。

## 交给 Luna 的任务

1. 复核 `modularSpider` 是否满足约束 1（工厂可生产）——**特别是 1.16 版本数据**：
   本机 `C:\Users\Administrator\Downloads\` 下有 `1.16.rwmod` ~ `1.16p15.rwmod` 多个包，
   **可直接解包对比**。
2. 若 `modularSpider` 在 1.16 中被某工厂建造，请给出该工厂名。
3. 其余 `isPickableStartingUnit` 单位（`experimentalDropship`、`experimentalSpider`）是否
   更能满足约束 3「不可撤销」？
