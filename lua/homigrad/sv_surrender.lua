--[[
    NPC 投降反应系统 - 服务端脚本
    监听玩家的投降/跪下状态（由其他mod设置的网络变量）
    当玩家处于投降状态时，NPC 将停止攻击并失去敌意
    取消投降后，恢复NPC的原始敌意
]]

local surrenderedPlayers = {}
local originalEnemies = {}  -- 记录NPC的原始敌人 {npc = {ply1, ply2, ...}}

-- NPC 守卫近战攻击配置
local NPC_ATTACK_ENABLED  = CreateConVar("surrender_npc_attack", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "NPC是否近战攻击投降玩家 (0=仅守卫, 1=靠近后攻击)", 0, 1)
local NPC_ATTACK_RANGE    = CreateConVar("surrender_npc_attack_range", "80", FCVAR_ARCHIVE + FCVAR_NOTIFY, "NPC近战攻击触发距离", 30, 200)
local NPC_ATTACK_DAMAGE   = CreateConVar("surrender_npc_attack_damage", "30", FCVAR_ARCHIVE + FCVAR_NOTIFY, "NPC近战伤害值", 5, 100)
local NPC_ATTACK_DELAY    = CreateConVar("surrender_npc_attack_delay", "2.0", FCVAR_ARCHIVE + FCVAR_NOTIFY, "NPC靠近后等待秒数再攻击", 0, 10)
local NPC_ATTACK_FORCE    = CreateConVar("surrender_npc_attack_force", "3000", FCVAR_ARCHIVE + FCVAR_NOTIFY, "布娃娃击退力度", 500, 10000)
local NPC_EXECUTE_TIME    = CreateConVar("surrender_npc_execute_time", "8", FCVAR_ARCHIVE + FCVAR_NOTIFY, "NPC处决起身后强制跪地等待秒数", 3, 30)

util.AddNetworkString("hg_surrender_force_kneel")

-- 检测玩家是否处于投降状态
local function isPlayerSurrendered(ply)
    if not IsValid(ply) or not ply:Alive() then return false end

    -- 检查网络变量（由投降mod设置）
    if ply:GetNWBool("Surrendering", false) or ply:GetNWBool("Kneeling", false) then
        return true
    end

    return false
end

-- 阻止 NPC 射击投降玩家
hook.Add("1`", "Surrender_BlockFire", function(ent, data)
    if not IsValid(ent) or not ent:IsNPC() then return end
    local enemy = ent:GetEnemy()
    if IsValid(enemy) then
        -- 检查敌人是否是投降玩家
        if enemy:IsPlayer() and surrenderedPlayers[enemy] then
            return false
        end
        -- 检查敌人是否是投降玩家的 bullseye
        if enemy:GetClass() == "npc_bullseye" and enemy.ply and surrenderedPlayers[enemy.ply] then
            return false
        end
    end
end)

-- 阻止 NPC 对投降玩家造成伤害
hook.Add("EntityTakeDamage", "Surrender_BlockDamage", function(target, dmginfo)
    if not IsValid(target) or not target:IsPlayer() then return end
    if not surrenderedPlayers[target] then return end

    -- 放行 NPC 守卫的处决攻击
    if target.surrenderGuardAttack then return end

    local attacker = dmginfo:GetAttacker()
    if IsValid(attacker) and attacker:IsNPC() then
        return true -- 阻止伤害
    end
end)

-- NPC 守卫对投降玩家执行近战处决攻击
local function ExecuteNPCGuardAttack(npc, ply)
    if not IsValid(npc) or not IsValid(ply) then return end
    if not NPC_ATTACK_ENABLED:GetBool() then return end

    -- 安全检查：玩家已布娃娃则跳过
    if IsValid(ply.FakeRagdoll) or not ply:Alive() then return end

    print("[Surrender] NPC " .. npc:GetClass() .. " 对 " .. ply:Nick() .. " 执行近战处决")

    -- 攻击方向
    local attackDir = (ply:GetPos() - npc:GetPos()):GetNormalized()

    -- 1. 立即造成伤害（让 organism 系统处理伤口/流血/shock）
    local dmgInfo = DamageInfo()
    dmgInfo:SetAttacker(npc)
    dmgInfo:SetInflictor(npc)
    dmgInfo:SetDamage(NPC_ATTACK_DAMAGE:GetFloat())
    dmgInfo:SetDamageType(DMG_SLASH)
    dmgInfo:SetDamageForce(attackDir * NPC_ATTACK_FORCE:GetFloat())
    dmgInfo:SetDamagePosition(ply:GetPos() + Vector(0, 0, 40))

    ply.surrenderGuardAttack = true
    ply:TakeDamageInfo(dmgInfo)
    ply.surrenderGuardAttack = nil

    -- 2. NPC 播放近战动画 + 挥击音效
    npc:SetSchedule(SCHED_MELEE_ATTACK1)
    npc:EmitSound("weapons/slam/throw.wav", 75, math.random(95, 105))

    -- 3. 0.5 秒后倒地（给肘击动画一点时间）
    timer.Simple(0.5, function()
        if not IsValid(ply) or not IsValid(npc) then return end
        if IsValid(ply.FakeRagdoll) or not ply:Alive() then return end

        -- 强制布娃娃（no_freemove=true 防止爬走）
        hg.Fake(ply, nil, true)

        -- 标记为守卫处决，起身后强制跪地处决
        ply.guardExecution = {
            npc = npc,
            attackedAt = CurTime()
        }

        -- 击退力（骨盆方向）
        if IsValid(ply.FakeRagdoll) then
            local pelvisBone = ply.FakeRagdoll:TranslateBoneToPhysBone(
                ply.FakeRagdoll:LookupBone("ValveBiped.Bip01_Pelvis"))
            hg.AddForceRag(ply, pelvisBone or 0, attackDir * NPC_ATTACK_FORCE:GetFloat(), 0.5)
        end

        -- 倒地音效
        timer.Simple(0.2, function()
            if IsValid(ply) and IsValid(ply.FakeRagdoll) then
                ply.FakeRagdoll:EmitSound("physics/flesh/flesh_impact_hard" .. math.random(6) .. ".wav", 75, math.random(95, 105))
            end
        end)
    end)
end

-- 让 NPC 失去对投降玩家的敌意（记录原始敌人并设置为中立）
local function ClearNPCEnemies(ply)
    print("[Surrender Debug] 开始清除敌意: " .. ply:Nick())
    local clearedCount = 0
    local nearestNPC = nil
    local nearestDist = math.huge

    for _, npc in ipairs(ents.FindByClass("npc_*")) do
        if not IsValid(npc) or not npc:IsNPC() then continue end
        if npc:GetClass() == "npc_bullseye" then continue end

        local enemy = npc:GetEnemy()

        -- 检查 NPC 的敌人是否指向投降玩家
        local isTargetingPly = false
        if enemy == ply then
            isTargetingPly = true
        elseif IsValid(enemy) and enemy:GetClass() == "npc_bullseye" and enemy.ply == ply then
            isTargetingPly = true
        elseif IsValid(ply.bull) and enemy == ply.bull then
            isTargetingPly = true
        end

        if isTargetingPly then
            -- 记录原始关系
            originalEnemies[npc] = originalEnemies[npc] or {}
            if not table.HasValue(originalEnemies[npc], ply) then
                table.insert(originalEnemies[npc], ply)
            end

            -- 对玩家和其bullseye设置中立关系
            if IsValid(ply.bull) and npc.AddEntityRelationship then
                npc:AddEntityRelationship(ply.bull, D_NU, 99)
            end
            if npc.AddEntityRelationship then
                npc:AddEntityRelationship(ply, D_NU, 99)
            end

            -- 清除敌意
            npc:ClearEnemyMemory()
            npc:SetEnemy(NULL)
            npc:SetNPCState(NPC_STATE_IDLE)
            npc:SetSchedule(SCHED_IDLE_WANDER)

            -- 找最近的 NPC
            local dist = npc:GetPos():DistToSqr(ply:GetPos())
            if dist < nearestDist then
                nearestDist = dist
                nearestNPC = npc
            end

            print("[Surrender Debug] 已清除 NPC: " .. npc:GetClass() .. " 对 " .. ply:Nick() .. " 的敌意")
            clearedCount = clearedCount + 1
        end
    end

    -- 让最近的 NPC 走向玩家并瞄准
    if IsValid(nearestNPC) then
        nearestNPC.guardingPlayer = ply
        nearestNPC:SetLastPosition(ply:GetPos())
        -- 覆盖之前在循环里设置的 IDLE_WANDER，避免 NPC 分心散步
        nearestNPC:ClearEnemyMemory()
        nearestNPC:SetEnemy(NULL)
        nearestNPC:SetNPCState(NPC_STATE_ALERT)
        nearestNPC:SetSchedule(SCHED_FORCED_GO_RUN)
        nearestNPC:SetMaxLookDistance(6000) -- 防止 sex 等外部 mod 修改视距

        -- 定时器持续控制这个 NPC
        local npcGuard = nearestNPC
        local wasClose = false  -- 滞后标记：上一次是否在近距离
        local wasRunning = true -- 当前 schedule 是否是跑向玩家
        timer.Create("Surrender_GuardNPC" .. ply:UserID(), 0.1, 0, function()
            if not IsValid(npcGuard) or not IsValid(ply) or not surrenderedPlayers[ply] then
                if IsValid(npcGuard) then
                    npcGuard.guardingPlayer = nil
                    npcGuard:ClearEnemyMemory()
                    npcGuard:SetNPCState(NPC_STATE_IDLE)
                    npcGuard:SetSchedule(SCHED_IDLE_WANDER)
                end
                -- 清理已完成/中断的处决状态（killAt 存在说明已进入跪地处决阶段）
                if IsValid(ply) and ply.guardExecution and ply.guardExecution.killAt then
                    ply.guardExecution = nil
                end
                timer.Remove("Surrender_GuardNPC" .. ply:UserID())
                return
            end

            npcGuard:SetMaxLookDistance(6000) -- 每 tick 恢复，防止外部 mod 修改

            local npcPos = npcGuard:GetPos()
            local plyPos = ply:GetPos()
            local dir = plyPos - npcPos
            local dist = dir:Length2D()

            -- 处决跪地阶段 NPC 站远一点（150-200），普通守卫贴脸（90-130）
            local isExecutionPhase = ply.guardExecution and ply.guardExecution.killAt
            local closeThreshold = isExecutionPhase and 150 or 90
            local farThreshold   = isExecutionPhase and 200 or 130

            -- 带滞后的远近判断
            if wasClose and dist > farThreshold then
                wasClose = false
            elseif not wasClose and dist < closeThreshold then
                wasClose = true
            end

            if not wasClose then
                -- 跑向玩家
                npcGuard:SetLastPosition(plyPos)
                if not wasRunning then
                    npcGuard:SetNPCState(NPC_STATE_ALERT)
                    npcGuard:SetSchedule(SCHED_FORCED_GO_RUN)
                    wasRunning = true
                end
            else
                -- 停下瞄准
                if wasRunning then
                    npcGuard:SetNPCState(NPC_STATE_ALERT)
                    npcGuard:SetSchedule(SCHED_IDLE_STAND)
                    wasRunning = false
                end

                -- 持续面向并瞄准玩家
                local ang = dir:Angle()
                npcGuard:SetAngles(Angle(0, ang.y, 0))

                local aimPos = ply:GetPos() + Vector(0, 0, 40)

                if npcGuard.SetEyeTarget then
                    npcGuard:SetEyeTarget(aimPos)
                end

                -- 设置敌人让武器指向玩家（AI保持在ALERT状态，不会攻击）
                if IsValid(ply.bull) then
                    npcGuard:SetEnemy(ply.bull)
                    npcGuard:UpdateEnemyMemory(ply.bull, aimPos)
                else
                    npcGuard:SetEnemy(ply)
                    npcGuard:UpdateEnemyMemory(ply, aimPos)
                end

                -- 攻击倒计时（已被处决过的玩家不再攻击）
                if NPC_ATTACK_ENABLED:GetBool() and not ply.guardExecution then
                    if not npcGuard.attackPrepared then
                        npcGuard.attackPrepared = CurTime() + NPC_ATTACK_DELAY:GetFloat()
                    elseif npcGuard.attackPrepared <= CurTime() then
                        if IsValid(ply) and ply:Alive() and not IsValid(ply.FakeRagdoll) and dist < NPC_ATTACK_RANGE:GetFloat() then
                            ExecuteNPCGuardAttack(npcGuard, ply)
                        end
                        npcGuard.attackPrepared = nil
                    end
                end
            end
        end)

        print("[Surrender Debug] NPC: " .. nearestNPC:GetClass() .. " 走向玩家 " .. ply:Nick())
    end

    print("[Surrender Debug] 共清除了 " .. clearedCount .. " 个 NPC 的敌意")
end

-- 恢复 NPC 的原始敌意
local function RestoreNPCEnemies(ply)
    for npc, enemies in pairs(originalEnemies) do
        if IsValid(npc) then
            -- 如果这个 NPC 之前是守卫 NPC，恢复 AI 控制
            if npc.guardingPlayer == ply then
                npc.guardingPlayer = nil
                npc:SetNPCState(NPC_STATE_COMBAT)
            end

            -- 恢复敌对关系
            if IsValid(ply.bull) and npc.AddEntityRelationship then
                npc:AddEntityRelationship(ply.bull, D_HT, 99)
            end
            if npc.AddEntityRelationship then
                npc:AddEntityRelationship(ply, D_HT, 99)
            end

            for i, enemy in ipairs(enemies) do
                if IsValid(enemy) and enemy == ply then
                    -- 恢复敌意
                    npc:SetEnemy(enemy)
                    npc:UpdateEnemyMemory(enemy, enemy:GetPos())
                    npc:SetSchedule(SCHED_TARGET_CHASE)

                    -- 从记录中移除
                    table.remove(originalEnemies[npc], i)
                    break
                end
            end

            -- 如果没有敌人了，清理表
            if #originalEnemies[npc] == 0 then
                originalEnemies[npc] = nil
            end
        else
            -- NPC 不存在了，清理
            originalEnemies[npc] = nil
        end
    end
end

-- 投降玩家被守卫处决后起身 → 强制跪地 + 重建 NPC 守卫
hook.Add("Fake Up", "Surrender_GuardForceKneel", function(ply, ragdoll)
    if not ply.guardExecution then return end
    local execData = ply.guardExecution

    -- 守卫 NPC 已死/无效则跳过，玩家正常起身
    if not IsValid(execData.npc) then
        ply.guardExecution = nil
        return
    end

    -- 记录处决时间
    execData.killAt = CurTime() + NPC_EXECUTE_TIME:GetFloat()

    -- 瞬间恢复敌意再压制：先 Restore 让 NPC 重新认识玩家，再立即 Clear 让它们变中立
    RestoreNPCEnemies(ply)

    -- 立即设置投降保护 + 分配守卫
    ply:SetNWBool("Surrendering", true)
    ply:SetNWBool("Kneeling", true)
    surrenderedPlayers[ply] = true
    ClearNPCEnemies(ply)

    -- 发送强制跪地消息给客户端（客户端执行动画）
    net.Start("hg_surrender_force_kneel")
    net.Send(ply)

    print("[Surrender] " .. ply:Nick() .. " 被守卫处决后起身，强制跪地，" .. NPC_EXECUTE_TIME:GetFloat() .. "秒后处决")
end)


-- 定期检查状态变化（每0.5秒检查一次）
timer.Create("Surrender_StateCheck", 0.5, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) then
            surrenderedPlayers[ply] = nil
            continue
        end

        local isSurrendered = isPlayerSurrendered(ply)

        if isSurrendered then
            if not surrenderedPlayers[ply] then
                -- 刚进入投降状态，记录并清除敌意（只执行一次）
                surrenderedPlayers[ply] = true
                ClearNPCEnemies(ply)
                print("[Surrender] " .. ply:Nick() .. " 已投降，NPC 停止攻击")
            end

            -- 处决倒计时检查：时间到则 0.5s 后 NPC 开枪处决
            if ply.guardExecution and ply.guardExecution.killAt and ply.guardExecution.killAt <= CurTime() then
                ply.guardExecution.killAt = nil -- 防止重复触发
                -- 优先用当前守卫 NPC（可能和肘击时的不同），fallback 到原始 NPC
                local killNpc = ply.guardExecution.npc
                for _, npc in ipairs(ents.FindByClass("npc_*")) do
                    if IsValid(npc) and npc.guardingPlayer == ply then
                        killNpc = npc
                        break
                    end
                end
                if IsValid(killNpc) then
                    killNpc:EmitSound("weapons/pistol/pistol_fire2.wav", 90, 100)
                end
                timer.Simple(0.5, function()
                    if IsValid(ply) and ply:Alive() then
                        print("[Surrender] " .. ply:Nick() .. " 被 NPC 处决")
                        ply:Kill()
                    end
                    ply.guardExecution = nil
                end)
            end
        else
            if surrenderedPlayers[ply] then
                -- 停止守卫
                surrenderedPlayers[ply] = nil
                timer.Remove("Surrender_GuardNPC" .. ply:UserID())
                -- 已被守卫处决的玩家不恢复敌意（ragdoll 期间防止其他 NPC 攻击）
                if not ply.guardExecution then
                    RestoreNPCEnemies(ply)
                    print("[Surrender] " .. ply:Nick() .. " 取消投降，NPC 恢复攻击")
                end
            end
        end
    end
end)

-- 清理
hook.Add("PlayerDisconnected", "Surrender_Cleanup", function(ply)
    surrenderedPlayers[ply] = nil
    ply.guardExecution = nil
    -- 清理该玩家的原始敌人记录
    for npc, enemies in pairs(originalEnemies) do
        for i, enemy in ipairs(enemies) do
            if enemy == ply then
                table.remove(originalEnemies[npc], i)
                break
            end
        end
        if #originalEnemies[npc] == 0 then
            originalEnemies[npc] = nil
        end
    end
end)

hook.Add("PlayerDeath", "Surrender_OnDeath", function(ply)
    -- 先恢复 NPC 敌意（D_NU → D_HT），再清理状态
    RestoreNPCEnemies(ply)
    timer.Remove("Surrender_GuardNPC" .. ply:UserID())
    surrenderedPlayers[ply] = nil
    ply.guardExecution = nil
end)

hook.Add("PlayerSpawn", "Surrender_OnSpawn", function(ply)
    ply.guardExecution = nil
end)

-- 调试命令
concommand.Add("surrender_npc_debug", function(ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    local count = 0
    for _ in pairs(surrenderedPlayers) do count = count + 1 end
    ply:PrintMessage(HUD_PRINTCONSOLE, "当前投降的玩家数: " .. count)
    for p, _ in pairs(surrenderedPlayers) do
        ply:PrintMessage(HUD_PRINTCONSOLE, "  - " .. p:Nick())
    end

    local enemyCount = 0
    for _ in pairs(originalEnemies) do enemyCount = enemyCount + 1 end
    ply:PrintMessage(HUD_PRINTCONSOLE, "记录的原始敌对 NPC 数: " .. enemyCount)
end)

print("[Surrender NPC] NPC 投降反应系统已加载 - 监听 Surrendering/Kneeling 网络变量")
