-- sv_random_event.lua -- 随机播放目录下的音频
--
-- 配置：
--   hg_random_sound_dir - 音频目录（相对于 GAME 根目录），默认 "sound"
--   hg_random_sound_refresh - 手动刷新缓存
--
-- 使用：
--   1. 在 sound/ 下放入 .wav/.ogg 文件
--   2. 运行 hg_random_sound_refresh 刷新
--   3. 玩家存活时每隔 120~320 秒随机播放一个

hg.organism.module.random_events = {}
local module = hg.organism.module.random_events

local soundCache = {}
local soundDirConVar = CreateConVar("hg_random_sound_dir", "sound/zcity/rnd", FCVAR_ARCHIVE, "音频目录（相对于 GAME 根目录）")

local function RefreshSoundCache()
    local dir = soundDirConVar:GetString()
    local files = file.Find(dir .. "/*", "GAME")
    soundCache = {}

    local emitPrefix = dir ~= "sound" and dir:match("^sound/(.+)$") or ""

    for _, f in ipairs(files or {}) do
        local ext = f:lower():match("%.([%w]+)$")
        if ext == "wav" or ext == "ogg" then
            local path = emitPrefix and emitPrefix ~= "" and emitPrefix .. "/" .. f or f
            soundCache[#soundCache + 1] = path
            resource.AddFile("sound/" .. path)
        end
    end
end

local function InitCache()
    if file and file.Find then
        RefreshSoundCache()
    else
        timer.Simple(1, InitCache)
    end
end
InitCache()

module[1] = function(org)
    org.timeToRandom = CurTime() + math.random(120, 320)
end

module[2] = function(owner, org, timeValue)
    if org.timeToRandom and org.timeToRandom < CurTime() and owner:IsPlayer() and owner:Alive() then
        if owner:GetPlayerClass() and owner:GetPlayerClass().CanEmitRNDSound ~= nil and not owner:GetPlayerClass().CanEmitRNDSound then
            return
        end

        if not org.otrub and #soundCache > 0 then
            local snd = soundCache[math.random(#soundCache)]
            owner:EmitSound(snd)
            print("[随机事件] 播放:", snd)
        end

        org.timeToRandom = CurTime() + math.random(120, 320)
    end
end

concommand.Add("hg_random_sound_refresh", function()
    RefreshSoundCache()
    print("[随机事件] 已刷新音频缓存，找到 " .. #soundCache .. " 个文件")
end)
