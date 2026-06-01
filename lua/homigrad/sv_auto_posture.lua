-- Auto-switch posture based on weapon type
-- Pistol → High Ready (3)
-- Rifle/Other → Regular Hold (0)
-- If player manually changed posture, keep that posture for all weapons

hook.Add("PlayerSwitchWeapon", "auto_posture_by_weapon", function(ply, oldWep, newWep)
    -- 延迟一帧执行，确保武器已经完全切换
    timer.Simple(0, function()
        if not IsValid(ply) or not IsValid(newWep) then return end

        -- 检查是否是 hg 武器
        if not ishgweapon(newWep) then return end

        -- 如果玩家手动设置过姿势，保持不变
        if ply.customPosture then return end

        -- 根据武器类型自动设置姿势
        local targetPosture = newWep:IsPistolHoldType() and 3 or 0

        if ply.posture ~= targetPosture then
            ply.posture = targetPosture
            net.Start("change_posture")
            net.WriteEntity(ply)
            net.WriteInt(ply.posture, 9)
            net.Broadcast()
        end
    end)
end)
