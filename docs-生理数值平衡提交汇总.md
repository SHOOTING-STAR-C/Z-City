# 生理数值平衡提交汇总

## 概述

本文档整理了 Z-City 项目中与玩家生理数值平衡相关的全部提交，按时间顺序排列。"宝宝巴士"主线分为三个阶段：

1. **第一轮削弱 (99739a9)** — 四肢伤害降低、添加防弹衣检查
2. **第二轮削弱 (f3cb90e)** — 断肢阈值10倍、夜视仪防护提升
3. **第三轮削弱 (3aeeb9b)** — 全体系×0.1（状态阈值10倍）
4. **宝宝巴士核心 (c54ad1b)** — 倒地/昏迷阈值百倍
5. **补丁修复 (3ae2199, a5bebf2)** — 修复 shock 上限、堵死后门
6. **NPC分离 (ec64a69)** — 玩家/NPC数值分离
7. **最终平衡 (ea23396)** — 玩家回调、NPC 3枪致死
8. **氧气修复 (8b8dbdd)** — 降低氧气影响、修复恢复死锁、提高晕倒阈值

---

## 提交明细

### 预置参数：氧气系统基线 (始终不变)

**文件**: `sv_lungs.lua` — org.o2 初始化参数

| 参数 | 值 | 说明 |
|------|-----|------|
| o2.range | 30 | 血氧上限 |
| o2.regen | 4 | 基础氧气恢复速率 |
| o2.k | 0.5 | halfValue2 曲线参数 |

> 血量对氧气上限的影响：`o2.range * min(blood/4500, 1)` — 失血会降低最大血氧容量。

### 1. 99739a9 — 四肢降低伤害倍率 + 防弹衣检查

**涉及文件**: `sv_bone.lua`

| 参数 | 原始值 | 新值 |
|------|--------|------|
| 腿部伤害倍率 (legs) | dmg×4 | dmg×1 |
| 手臂伤害倍率 (arms) | dmg×4 | dmg×1 |
| 腿部/手臂添加防弹衣检查 | 无 | 躯干防弹衣保护四肢 |
| 骨折痛觉加成 | +55 | +30 |
| 骨折 immobilization (腿) | +dmg×25 | +dmg×15 |
| 骨折 immobilization (臂) | +dmg×10 | +dmg×5 |
| 骨折 fear 加成 | +0.5 | +0.3 |
| 骨折阈值 | dmg≥1 | dmg≥1.5 |
| 脱臼痛觉 | +35 | +20 |
| 下颌添加防弹衣检查 | 无 | face+head 防弹衣保护 |

### 2. f3cb90e — 断肢阈值100→1000 + 夜视仪防护15→25

**涉及文件**: `sv_input.lua`, `sh_armorstuff.lua`

| 参数 | 原始值 | 新值 |
|------|--------|------|
| 命中组累积伤害上限 (hitgroup_max) | 100 | 1000 |
| nightvision1 防护值 | 15 | 25 |

### 3. 3aeeb9b — 全体系状态异常阈值×10

**涉及文件**: `sv_lungs.lua`, `sv_bone.lua`, `sv_organs.lua`, `sv_input.lua`

| 参数 | 原始值 | 新值 | 说明 |
|------|--------|------|------|
| **器官伤害入参** (全部器官) | | | |
| 心脏 damageOrgan | dmg×0.3 | dmg×0.03 | ×0.1 |
| 肝脏 damageOrgan | dmg×1 | dmg×0.1 | ×0.1 |
| 胃 damageOrgan | dmg×1 | dmg×0.1 | ×0.1 |
| 肠道 damageOrgan | dmg×1 | dmg×0.1 | ×0.1 |
| 脑 damageOrgan | dmg×1 | dmg×0.1 | ×0.1 |
| 左肺 damageOrgan | dmg/4 | dmg/40 | ×0.1 |
| 右肺 damageOrgan | dmg/4 | dmg/40 | ×0.1 |
| **骨骼伤害入参** | | | |
| 头骨 damageBone | dmg×1 | dmg×0.1 | ×0.1 |
| 下颌 damageBone | dmg×1 | dmg×0.1 | ×0.1 |
| 肋骨 damageBone | dmg/4 | dmg/40 | ×0.1 |
| 骨盆 damageBone | dmg×0.5 | dmg×0.05 | ×0.1 |
| 脊椎 damageBone | dmg×2 | dmg×0.2 | ×0.1 |
| **附带效果同步×0.1** | | | |
| 心脏 shock | dmg×20 | dmg×2 | |
| 肝脏 shock | dmg×20 | dmg×2 | |
| 肝脏 painadd | dmg×35 | dmg×3.5 | |
| 脑 consciousness↓ | dmg×3 | dmg×0.3 | |
| 脑 disorientation | dmg×1 | dmg×0.1 | |
| 脑 shock | dmg×3 | dmg×0.3 | |
| 脑 painadd | dmg×10 | dmg×1 | |
| 头骨 shock (碎裂时) | dmg×40 | dmg×4 | |
| 头骨 avgpain (碎裂时) | dmg×30 | dmg×3 | |
| 头骨 shock (基础) | dmg×3 | dmg×0.3 | |
| 头骨 consciousness↓ | dmg×2 | dmg×0.2 | |
| 头骨 brain 受损 | dmg×0.05 | dmg×0.005 | |
| 头骨颅骨碎裂 brain+ | +0.1 | +0.01 | |
| 头骨 disorientation | dmg×1 | dmg×0.1 | |
| 头骨 shock (额外) | dmg>1?50:dmg×10 | dmg>1?5:dmg×1 | |
| 下颌 shock (碎裂) | dmg×40 | dmg×4 | |
| 下颌 avgpain (碎裂) | dmg×30 | dmg×3 | |
| 下颌 shock (基础) | dmg×3 | dmg×0.3 | |
| 下颌脱臼 shock | dmg×20 | dmg×2 | |
| 下颌脱臼 avgpain | dmg×20 | dmg×2 | |
| 肋骨 painadd | dmg×1 | dmg×0.1 | |
| 肋骨 shock | dmg×1 | dmg×0.1 | |
| 骨盆 painadd | dmg×1 | dmg×0.1 | |
| 骨盆 shock | dmg×1 | dmg×0.1 | |
| **碰撞伤害** | | | |
| 碰撞 fearadd | dmg×0.5 | dmg×0.05 | ×0.1 |
| 四肢碰撞阈值 | dmg×3>0.25 | dmg×3>2.5 | ×10 |
| 四肢碰撞阈值(手) | dmg×2>0.2 | dmg×2>2 | ×10 |
| 躯干碰撞阈值 | dmg×3>0.25 | dmg×3>2.5 | ×10 |
| 流血表面触发 | dmg×3>0.17 | dmg×3>1.7 | ×10 |
| internalBleed 触发 | dmg>0.2 | dmg>2 | ×10 |
| internalBleed 加成 | dmg×2.5 | dmg×0.25 | ×0.1 |
| 肾上腺素加成 | dmg×0.5 | dmg×0.05 | ×0.1 |
| 头部碰撞 skull 入参 | dmg×6 | dmg×0.6 | ×0.1 |
| 头部碰撞 consciousness↓ | dmg×20 | dmg×2 | ×0.1 |
| 头部碰撞 otrub 触发 | dmg×10>0.5 | dmg×10>5 | ×10 |
| 头部碰撞 otrub shock | +10 | +1 | ×0.1 |
| **脑损伤速率** | | | |
| 颅骨碎裂脑损伤 | /1000 | /10000 | ×0.1 |
| 缺氧脑损伤 (早期) | /300 | /3000 | ×0.1 |
| 缺氧脑损伤 (晚期) | /120 | /1200 | ×0.1 |
| **骨折阈值** | dmg≥1.5 | dmg≥15 | ×10 |

### 4. c54ad1b — 宝宝巴士核心：倒地/昏迷阈值百倍

**涉及文件**: `sv_tier_0.lua`, `sv_blood.lua`, `sv_pain.lua`, `sv_bone.lua`, `sv_organs.lua`, `sv_input.lua`, `sv_organism.lua`

| 参数 | 原始值 (来自3aeeb9b) | 新值 | 说明 |
|------|---------------------|------|------|
| **shock 系统** | | | |
| shock_turn | 10 | 2000 | 意识丧失触发阈值×200 |
| shock 上限 | 70 | 1200 | 允许 shock 累积到触发值 |
| shock 目标值 (pain>80时) | 70 | shock_turn×1.5 | |
| shock 意识降低触发 | shock>30 | shock>shock_turn×1.5×analgesia | |
| **大脑/头部** | | | |
| brain damageOrgan | dmg×0.1 | dmg×0.00125 | ×0.0125 (相对3aeeb9b再÷80) |
| brain consciousness↓ | dmg×0.3 | dmg×0.003 | ×0.01 |
| skull consciousness↓ (rnd) | dmg×0.2 | dmg×0.0005 | ×0.0025 |
| skull LightStunPlayer 阈值 | dmg>4 | dmg>200 | ×50 |
| **脊椎** | | | |
| spine damageBone | dmg×0.2 | dmg×0.008 | ×0.04 |
| spine LightStunPlayer | 无条件 | dmg>20 | 新增条件 |
| spine painadd | dmg×0.2 | 不变 | |
| spine shock | dmg×0.5 | 不变 | |
| **四肢** | | | |
| 腿部伤害倍率 | dmg×1 | dmg×0.02 | ×0.02 |
| 手臂伤害倍率 | dmg×1 | dmg×0.02 | ×0.02 |
| 腿部骨折 cumulative 系统 | 无 | cum<80 不骨折 | 新增累积伤害系统 |
| 手臂骨折 cumulative 系统 | 无 | cum<60 不骨折 | 新增累积伤害系统 |
| 腿部 immobilization (骨折) | +dmg×15 | +dmg×2 | ÷7.5 |
| 腿部 immobilization (脱臼) | +dmg×5 | +dmg×1 | ÷5 |
| **出血系统** | | | |
| 出血警告阈值 | blood<2900 | blood<1000 | |
| 失血 otrub 阈值 | blood<2400/(adr/3+1) | blood<500/(adr/3+1) | |
| 出血速率乘数 | ×0.02 | ×0.005 | ÷4 |
| 凝血速率乘数 | ×0.04 | ×0.2 | ×5 |
| internalBleed 除数 | /14 | /50 | ÷3.6 |
| internalBleed 愈合速率 | /55 | /10 | ×5.5 |
| internalBleed 快速愈合阈值 | <0.5 | <5 | ×10 |
| internalBleed 呕吐触发 | >1 | >5 | ×5 |
| 失血 needfake 阈值 | blood<2700 | blood<500 | |
| blood→consciousness 除数 | blood/3000 | blood/1000 | |
| **碰撞** | | | |
| 头部碰撞 consciousness↓ | dmg×2 | dmg×0.0005 | ×0.00025 |
| 头部碰撞 spine3 伤害 | dmg×(rand)×3 | dmg×(rand)×0.1 | ÷30 |
| 头部碰撞 otrub 条件 | dmg×10>5 | dmg×10>5000 | ×1000 |
| 头部碰撞 otrub shock | +1 | +1 | 不变 |
| **其他** | | |
| spine3 假死阈值 (fake_spine3) | 0.5 | 1.0 | 不再因脊椎骨折直接倒地 |
| 假死 blood 阈值 | blood<2900 | blood<1000 | |
| Think循环修复 | | | 快照迭代防止修改表崩溃 |

### 5. 3ae2199 — 提高 shock 上限至 4000

**涉及文件**: `sv_input.lua`

| 参数 | 原始值 | 新值 |
|------|--------|------|
| shock 上限 (EntityTakeDamage) | 1200 | 4000 |

> **原因**: shock_turn=2000 → 意识丧失阈值=3000，但上限1200导致永远无法触发意识丧失，玩家陷入不死不活状态。

### 6. a5bebf2 — 堵死一枪倒地/死亡的后门

**涉及文件**: `sv_bone.lua`, `sv_organs.lua`

| 参数 | 原始值 (来自c54ad1b) | 新值 |
|------|---------------------|------|
| 肝脏伤害倍率 | dmg×0.1 | dmg×0.005 |
| 下颌 LightStunPlayer 阈值 | dmg>2 | dmg>200 |

> **原因**: 肝脏和下颌仍然可以一枪触发 StunPlayer/直接倒地。

### 7. ec64a69 — NPC/玩家数值分离

**涉及文件**: `sv_blood.lua`, `sv_lungs.lua`, `sv_pain.lua`, `sv_bone.lua`, `sv_organs.lua`, `sv_input.lua`, `sv_organism.lua`

核心策略：所有削弱通过 `org.isPly` 守卫——仅对玩家生效，NPC维持原始数值。

| 参数 | 玩家值 | NPC值 |
|------|--------|-------|
| **血液系统** | | |
| 血液恢复条件 (internalBleed) | <5 | <0.5 |
| 血液恢复条件 (bleed) | <0.5 | <0.05 |
| consciousness blood除数 | /1000 | /3000 |
| needotrub blood阈值 | <500 | <2400 |
| internalBleed 除数 | /50 | /14 |
| internalBleed 愈合速率 | /10 | /55 |
| needfake blood阈值 | <1000 | <2900 |
| needfake OrgThink阈值 | <500 | <2700 |
| **疼痛系统** | | |
| shock 上限 | 4000 | 70 |
| **器官伤害** | | |
| 绝大多数器官伤害倍率 | 宝宝巴士值 | 原始值×0.1 (3aeeb9b) |
| 肝脏伤害倍率 | dmg×0.005 | dmg×0.1 |
| 脑 damageOrgan | dmg×0.00125 | dmg×0.1 |
| 脑 consciousness↓ | dmg×0.003 | dmg×0.3 |
| 心脏 shock | dmg×2 | dmg×20 |
| **骨骼伤害** | | |
| 四肢伤害倍率 | dmg×0.02 | dmg×4 |
| 四肢骨折阈值 (累积) | cum<80/60 | dmg<1 (单发) |
| 四肢骨折阈值 (单发) | dmg≥15 | dmg≥1 |
| 脊椎 damageBone | dmg×0.008 | dmg×2 |
| 头骨 damageBone | dmg×0.1 | dmg×1 |
| 头骨 consciousness↓ | dmg×0.0005 | dmg×2 |
| 头骨 LightStunPlayer | dmg>200 | dmg>4 |
| 下颌 damageBone | dmg×0.1 | dmg×1 |
| 下颌 LightStunPlayer | dmg>200 | dmg>0.2 |
| 肋骨 damageBone | dmg/40 | dmg/4 |
| 骨盆 damageBone | dmg×0.05 | dmg×0.5 |
| **碰撞伤害** | | |
| internalBleed 触发阈值 | dmg>2 | dmg>0.2 |
| internalBleed 加成 | dmg×0.25 | dmg×2.5 |
| 肾上腺素加成 | dmg×0.05 | dmg×0.5 |
| 头部碰撞 skull入参 | dmg×0.6 | dmg×6 |
| 头部碰撞 consciousness↓ | dmg×0.0005 | dmg×20 |
| 头部碰撞 otrub 条件 | dmg×10>5000 | dmg×10>5 |
| 命中组入口阈值 | ×10 (3aeeb9b) | 原始 |
| **脑损伤速率** | | |
| 颅骨碎裂 /10000 | | /1000 |
| 缺氧 (早期) /3000 | | /300 |
| 缺氧 (晚期) /1200 | | /120 |

### 8. ea23396 — 最终伤害与生理平衡调整

**涉及文件**: `cl_screeneffects.lua`, `sh_inertia.lua`, `cl_main.lua`, `sv_blood.lua`, `sv_pain.lua`, `sv_bone.lua`, `sv_input.lua`, `sv_organism.lua`, `sv_equipment.lua`

#### 玩家侧调整

| 参数 | 上一版本值 | 新值 | 方向 |
|------|-----------|------|------|
| **四肢** | | | |
| 腿部伤害倍率 | dmg×0.02 | dmg×0.4 | ⬆×20 (回调) |
| 手臂伤害倍率 | dmg×0.02 | dmg×0.4 | ⬆×20 (回调) |
| 四肢防弹衣保护 | 有 (躯干) | **移除** | 不再受护甲保护 |
| 腿部骨折阈值 (累积cum) | cum<80 | cum<5 | ⬇÷16 |
| 手臂骨折阈值 (累积cum) | cum<60 | cum<5 | ⬇÷12 |
| 腿部骨折阈值 (单发) | dmg≥15 | dmg≥0.4 | ⬇÷37.5 |
| 手臂骨折阈值 (单发) | dmg≥15 | dmg≥0.4 | ⬇÷37.5 |
| 四肢 boneDmg 生效阈值 | <0.7/<0.6 | <0.2 | ⬇ 更低即可触发 |
| **视觉效果** | | | |
| consciousness暗屏触发 | <0.7 | <0.5 | ⬇ (更难触发) |
| consciousness暗屏强度乘数 | ×5 | ×3 | ⬇ |
| pain vignette ColorIntensity | pain/40+shock/3 | pain/80+shock/5 | ⬇÷2 |
| pain vignette Vignette | pain/40+shock/3 | pain/80+shock/5 | ⬇÷2 |
| painMat Lerp/Vignette | pain/90 | pain/180 | ⬇÷2 |
| 模糊效果 pain除数 | pain/30 | pain/60 | ⬇÷2 |
| blood颜色效果除数 | /5000 | /3500 | ⬆ |
| blood亮度效果除数 | /5000 | /3500 | ⬆ |
| **意识恢复** | | | |
| shock衰减速率 | ×4 | ×8 | ⬆×2 |
| consciousness趋近速率 (休克) | /5 | /10 | ⬇÷2 (减速) |
| consciousness自然恢复 | /15 | /5 | ⬆×3 (加速) |
| 醒来时间 (uncon_timer) | >6秒 | >2秒 | ⬇÷3 |
| **移动惩罚** | | | |
| pain移动减速除数 | 20/(pain+1) | 40/(pain+1) | ⬆ pain影响减半 |
| **血液系统** | | | |
| consciousness blood除数 | /1000 | /1000 | 不变 (此提交前ec64a69设为player 1000) |
| needotrub blood阈值 | <500 | <500 | 不变 |

#### NPC侧调整

| 参数 | 上一版本值 | 新值 | 说明 |
|------|-----------|------|------|
| consciousness blood除数 | /3000 | /4500 | ⬆ 更难失去意识 |
| needotrub blood阈值 | <2400 | <3600 | ⬆ 更难触发 |
| needfake (ShouldFakeUp) | <2900 | <4000 | ⬆ 更难倒地 |
| needfake (OrgThink) | <2700 | <3800 | ⬆ 更难倒地 |
| internalBleed 愈合速率 | /55 | /120 | ⬇ 愈合变慢 |
| internalBleed 加成 (碰撞) | dmg×2.5 | dmg×6 | ⬆ 更多内出血 |
| **新增: 直接扣血** | 无 | org.blood -= dmgBlood×5 | 确保3枪致死节奏 |
| 布娃娃伤害倍率 | NPC×1 | 玩家×RagdollMul | NPC不受骨骼减伤 |

### 9. 8b8dbdd — 修复氧气恢复死锁，降低氧气影响，提高晕倒阈值

**涉及文件**: `sv_lungs.lua`, `sv_organism.lua`

#### 氧气系统预置参数 (始终不变)

| 参数 | 值 | 说明 |
|------|-----|------|
| o2.range | 30 | 血氧上限 |
| o2.regen | 4 | 基础氧气恢复速率 |
| o2.k | 0.5 | halfValue2 曲线参数 |

> 实际氧气上限受血量影响：`o2.range * min(blood/4500, 1) * max(1 - (lungsL[1]+lungsR[1])/2, 0.5)` — 失血和肺损伤都会降低最大血氧容量。

#### 数值变更

| 参数 | 原始值 | 新值 | 说明 |
|------|--------|------|------|
| **氧气通知阈值 (降低)** | | | |
| 面具窒息紧急通知 | o2<15 | o2<10 | ⬇ |
| 呼吸不足通知范围 | o2 12~25 | o2 8~20 | ⬇ |
| 低氧警告 | o2<12 | o2<8 | ⬇ |
| 极低氧窒息警告 | o2<6 | o2<4 | ⬇ |
| **氧气生理阈值 (大幅降低)** | | | |
| StunPlayer (击晕) | o2<10 | o2<3 | ⬇÷3.3 |
| needfake (强制倒地) | o2<12 | o2<5 | ⬇÷2.4 |
| needotrub (意识丧失) | o2<4 | o2<1 | ⬇÷4 |
| **肺损伤自愈 (之前注释掉, 现在启用)** | | | |
| lungsR[1] 自愈速率 | 无 (注释掉) | /600 (needle时/120) | 新增 |
| lungsL[1] 自愈速率 | 无 (注释掉) | /600 (needle时/120) | 新增 |
| **修复死锁** | | | |
| 肺功能关闭 (o2=0时) | 无条件 | +needle==0 守卫 | needle可打破死锁 |
| 肺功能关闭 (双肺全毁) | 无条件 | +needle==0 守卫 | needle可打破死锁 |
| 肺功能恢复条件 | rand(50)==1 | +needle>0 必定恢复 | needle保证恢复 |
| 心脏停跳自动恢复 | 无 | needle+brain<0.6 自动恢复 | 新增 |
| **晕倒阈值** | | | |
| consciousness 假死阈值 | ≤0.4 | ≤0.1 | ⬇÷4 (更难晕倒) |

> **核心修复**: 当玩家肺被毁或氧气耗尽导致 `lungsfunction=false` 后，即使使用 needle (肾上腺素针) 也无法恢复——因为氧气恢复需要 `lungsfunction=true`，而恢复 `lungsfunction` 又需要氧气。添加 `needle` 守卫打破了这个死循环。

#### 氧气系统阈值演变追踪

| 阶段 | StunPlayer | needfake | needotrub | 肺自愈 | 死锁修复 |
|------|-----------|----------|----------|--------|---------|
| 原始 | o2<10 | o2<12 | o2<4 | 无 | 无 |
| 氧气修复(8b8dbdd) | o2<3 | o2<5 | o2<1 | /600 | needle守卫 |

> 注意：o2 阈值不受 NPC/玩家分离影响——NPC 一般没有 organism 系统，只有玩家受氧气系统影响。

---

## 关键数值演变追踪（玩家侧）

### shock 系统
| 阶段 | shock_turn | shock上限 | shock衰减 | 意识丧失触发 |
|------|-----------|----------|----------|-------------|
| 原始 | 10 | 70 | ×4 | shock>30 |
| 宝宝巴士(c54ad1b) | 2000 | 1200 | ×4 | shock>2000×1.5×analgesia |
| shock补丁(3ae2199) | 2000 | 4000 | ×4 | 同上 |
| 最终平衡(ea23396) | 2000 | 4000 | ×8 | 同上 |

### 四肢骨折系统（腿部为例）
| 阶段 | 伤害倍率 | 累积阈值 | 单发阈值 | immobilization | 防弹衣 |
|------|---------|---------|---------|---------------|--------|
| 原始 | dmg×4 | 无 | dmg≥1 | +dmg×25 | 无 |
| 第一轮(99739a9) | dmg×1 | 无 | dmg≥1.5 | +dmg×15 | 有 |
| 第三轮(3aeeb9b) | dmg×1 | 无 | dmg≥15 | +dmg×15 | 有 |
| 宝宝巴士(c54ad1b) | dmg×0.02 | cum<80 | dmg≥15 | +dmg×2 | 有 |
| 最终(ea23396) | dmg×0.4 | cum<5 | dmg≥0.4 | +dmg×2 | **无** |

### 出血系统
| 阶段 | 出血速率 | 凝血速率 | intBleed除数 | 愈合速率 | needotrub | needfake |
|------|---------|---------|-------------|---------|----------|---------|
| 原始 | ×0.02 | ×0.04 | /14 | /55 | <2400 | <2700 |
| 宝宝巴士 | ×0.005 | ×0.2 | /50 | /10 | <500 | <500 |
| 最终 | ×0.005 | ×0.2 | /50 | /10 | <500 | <500 |

### 头部/大脑
| 阶段 | brain伤害倍率 | skull意识降低 | skull LightStun | 碰撞意识降低 |
|------|-------------|-------------|-----------------|-------------|
| 原始(相对3aeeb9b后) | dmg×0.1 | dmg×0.2 | dmg>4 | dmg×2 |
| 宝宝巴士 | dmg×0.00125 | dmg×0.0005 | dmg>200 | dmg×0.0005 |
| 最终 | dmg×0.00125 | dmg×0.0005 | dmg>200 | dmg×0.0005 |

---

## 涉及的核心文件

| 文件 | 功能 |
|------|------|
| `lua/homigrad/organism/tier_1/sv_input.lua` | 伤害入口、shock上限、碰撞伤害、断肢阈值 |
| `lua/homigrad/organism/tier_1/sv_organism.lua` | 生理主循环、假死条件、醒来时间 |
| `lua/homigrad/organism/tier_1/modules/sv_blood.lua` | 出血/凝血/失血/内出血 |
| `lua/homigrad/organism/tier_1/modules/sv_pain.lua` | 疼痛/shock/意识系统 |
| `lua/homigrad/organism/tier_1/modules/sv_lungs.lua` | 肺/氧气/脑损伤/呼吸/窒息 |
| `lua/homigrad/organism/tier_1/modules_input/sv_bone.lua` | 骨骼伤害(四肢/脊椎/头骨/肋骨/骨盆/下颌) |
| `lua/homigrad/organism/tier_1/modules_input/sv_organs.lua` | 器官伤害(脑/心脏/肝脏/胃/肠道/肺) |
| `lua/homigrad/organism/tier_0/sv_tier_0.lua` | Think循环(快照迭代修复) |
| `lua/homigrad/cl_screeneffects.lua` | 客户端疼痛/意识视觉效果 |
| `lua/homigrad/organism/tier_1/cl_main.lua` | 客户端模糊/blood颜色效果 |
| `lua/homigrad/movement/sh_inertia.lua` | 疼痛对移动速度的影响 |
| `lua/homigrad/sh_armorstuff.lua` | 夜视仪/面部防护值 |
| `lua/homigrad/sv_equipment.lua` | 护甲保护计算 (protec函数) |

---

## 验证方法

1. 启动 GMod 多人监听服务器，加载 Z-City
2. 使用 `hg_noscreenfx 0` 确保视觉效果开启
3. 测试玩家承受枪击：应能承受多枪不倒（宝宝巴士效果）
4. 测试 NPC（恐魔/僵尸）：应在3枪内致死（NPC 3枪机制）
5. 观察 UI 中 shock/pain/consciousness/blood 数值变化
6. 确认骨折/脱臼/内出血等异常状态正常触发
7. 确认布娃娃倒地/复活/醒来流程正常
