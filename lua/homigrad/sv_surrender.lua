--[[
    NPC 投降反应系统 - 服务端脚本
    监听玩家的投降/跪下状态（由其他mod设置的网络变量）
    当玩家处于投降状态时，NPC 将停止攻击并失去敌意
    取消投降后，恢复NPC的原始敌意
]]

local surrenderedPlayers = {}
local originalEnemies = {}  -- 记录NPC的原始敌人 {npc = {ply1, ply2, ...}}

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

    local attacker = dmginfo:GetAttacker()
    if IsValid(attacker) and attacker:IsNPC() then
        return true -- 阻止伤害
    end
end)

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
                timer.Remove("Surrender_GuardNPC" .. ply:UserID())
                return
            end

            local npcPos = npcGuard:GetPos()
            local plyPos = ply:GetPos()
            local dir = plyPos - npcPos
            local dist = dir:Length2D()

            -- 带滞后的远近判断：close→far 需要 dist>130，far→close 需要 dist<90
            if wasClose and dist > 130 then
                wasClose = false
            elseif not wasClose and dist < 90 then
                wasClose = true
            end

            if not wasClose then
                -- 跑向玩家：持续更新目标位置，但只在切换时设 schedule（避免每 tick 重启碎步）
                npcGuard:SetLastPosition(plyPos)
                if not wasRunning then
                    npcGuard:SetNPCState(NPC_STATE_ALERT)
                    npcGuard:SetSchedule(SCHED_FORCED_GO_RUN)
                    wasRunning = true
                end
            else
                -- 靠近了：停下瞄准
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
        else
            if surrenderedPlayers[ply] then
                -- 取消投降，恢复原始敌意
                surrenderedPlayers[ply] = nil
                timer.Remove("Surrender_GuardNPC" .. ply:UserID())  -- 停止守护
                RestoreNPCEnemies(ply)
                print("[Surrender] " .. ply:Nick() .. " 取消投降，NPC 恢复攻击")
            end
        end
    end
end)

-- 清理
hook.Add("PlayerDisconnected", "Surrender_Cleanup", function(ply)
    surrenderedPlayers[ply] = nil
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
    surrenderedPlayers[ply] = nil
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
