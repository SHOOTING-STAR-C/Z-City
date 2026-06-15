-- Spectator / Ghost Mode
-- When enabled, NPCs will ignore the player completely (won't target, attack, or react to them)

local IsValid = IsValid
local CurTime = CurTime
local hook = hook
local ipairs = ipairs
local pairs = pairs

-- ConVar to toggle spectator mode
local hg_spectator_mode = CreateConVar("hg_spectator_mode", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_NOTIFY, "Toggle spectator mode - NPCs will ignore you completely", 0, 1)

-- Table to track which players are in spectator mode
local spectatorPlayers = {}

-- Function to make an NPC ignore a specific player
local function MakeNpcIgnorePlayer(npc, ply)
    if not IsValid(npc) or not IsValid(ply) then return end

    -- D_NU = Disposition Neutral (NPC won't care about this entity)
    -- Priority 0 means lowest priority
    npc:AddEntityRelationship(ply, D_NU, 0)
end

-- Function to restore NPC's normal behavior towards a player
local function RestoreNpcBehavior(npc, ply)
    if not IsValid(npc) or not IsValid(ply) then return end

    -- D_HT = Disposition Hate (NPC will hate/attack this entity)
    -- Reset to default hate relationship for players
    npc:AddEntityRelationship(ply, D_HT, 999)
end

-- Apply spectator mode to a player
local function ApplySpectatorMode(ply)
    if not IsValid(ply) then return end

    spectatorPlayers[ply] = true

    -- Make all existing NPCs ignore this player
    for _, npc in ipairs(ents.FindByClass("npc_*")) do
        if IsValid(npc) and npc:IsNPC() then
            MakeNpcIgnorePlayer(npc, ply)
        end
    end

    -- Also handle scripted NPCs (like swarm entities)
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and (ent:IsNPC() or ent:GetClass():find("swarm")) then
            MakeNpcIgnorePlayer(ent, ply)
        end
    end
end

-- Remove spectator mode from a player
local function RemoveSpectatorMode(ply)
    if not IsValid(ply) then return end

    spectatorPlayers[ply] = nil

    -- Restore normal NPC behavior towards this player
    for _, npc in ipairs(ents.FindByClass("npc_*")) do
        if IsValid(npc) and npc:IsNPC() then
            RestoreNpcBehavior(npc, ply)
        end
    end
end

-- Hook: When an NPC is created, make it ignore all spectator players
hook.Add("OnEntityCreated", "SpectatorMode_NpcIgnore", function(ent)
    -- Delay slightly to ensure the entity is fully initialized
    timer.Simple(0.1, function()
        if not IsValid(ent) then return end
        if not ent:IsNPC() and not ent:GetClass():find("swarm") then return end

        -- Make this new NPC ignore all current spectator players
        for ply, _ in pairs(spectatorPlayers) do
            if IsValid(ply) then
                MakeNpcIgnorePlayer(ent, ply)
            else
                spectatorPlayers[ply] = nil
            end
        end
    end)
end)

-- Hook: Prevent NPCs from targeting spectator players (runs periodically to ensure consistency)
hook.Add("Think", "SpectatorMode_EnforceIgnore", function()
    -- Only run every 0.5 seconds to avoid performance issues
    if (SpectatorMode_NextThink or 0) > CurTime() then return end
    SpectatorMode_NextThink = CurTime() + 0.5

    -- Check if any players are in spectator mode
    if not next(spectatorPlayers) then return end

    -- Enforce NPC ignoring for all spectator players
    for ply, _ in pairs(spectatorPlayers) do
        if not IsValid(ply) then
            spectatorPlayers[ply] = nil
            continue
        end

        -- Check if player still has spectator mode enabled via ConVar
        if not ply:GetInfoNum("hg_spectator_mode", 0) then
            RemoveSpectatorMode(ply)
            continue
        end

        -- Enforce relationship for all NPCs
        for _, npc in ipairs(ents.FindByClass("npc_*")) do
            if IsValid(npc) and npc:IsNPC() then
                MakeNpcIgnorePlayer(npc, ply)
            end
        end
    end
end)

-- Command: Toggle spectator mode for the player
concommand.Add("hg_spectator", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local current = ply:GetInfoNum("hg_spectator_mode", 0)

    if current == 0 then
        -- Enable spectator mode
        ply:ConCommand("hg_spectator_mode 1")
        ApplySpectatorMode(ply)
        ply:ChatPrint("透明模式已开启，NPC 将完全忽略你。")
        ply:ChatPrint("再次输入 hg_spectator 关闭。")
    else
        -- Disable spectator mode
        ply:ConCommand("hg_spectator_mode 0")
        RemoveSpectatorMode(ply)
        ply:ChatPrint("透明模式已关闭，NPC 将正常攻击你。")
    end
end, nil, "切换透明模式 - NPC 将完全忽略你")

-- When a player spawns, check if they have spectator mode enabled
hook.Add("PlayerSpawn", "SpectatorMode_PlayerSpawn", function(ply)
    timer.Simple(0.5, function()
        if not IsValid(ply) then return end
        if ply:GetInfoNum("hg_spectator_mode", 0) then
            ApplySpectatorMode(ply)
        end
    end)
end)

-- When a player disconnects, clean up
hook.Add("PlayerDisconnected", "SpectatorMode_Cleanup", function(ply)
    spectatorPlayers[ply] = nil
end)

-- Utility: Force all players out of spectator mode (for round resets, etc.)
function SpectatorMode_ResetAll()
    for ply, _ in pairs(spectatorPlayers) do
        if IsValid(ply) then
            ply:ConCommand("hg_spectator_mode 0")
        end
    end
    spectatorPlayers = {}
end

-- Hook: Reset spectator mode on round start (if using round system)
hook.Add("RoundStart", "SpectatorMode_RoundReset", function()
    -- Optional: Uncomment to auto-reset spectator mode on round start
    -- SpectatorMode_ResetAll()
end)

-- Debug command to check spectator mode status
concommand.Add("hg_spectator_status", function(ply)
    if not IsValid(ply) then return end

    local count = 0
    for p, _ in pairs(spectatorPlayers) do
        if IsValid(p) then
            count = count + 1
            ply:ChatPrint("透明模式玩家: " .. p:Nick())
        end
    end

    if count == 0 then
        ply:ChatPrint("当前没有玩家开启透明模式。")
    else
        ply:ChatPrint("共 " .. count .. " 名玩家开启了透明模式。")
    end
end, nil, "查看谁开启了透明模式")
