include("shared.lua")
SWEP.Category = "Weapons - Other"
SWEP.PrintName = "\"Deer Hunter\" Bow"
SWEP.Instructions = "这是一把现代铝-玻璃纤维复合弓，拉力为290牛顿，用于（与猎箭一起）猎取北美中型猎物。\n\n右键瞄准。\n瞄准时左键射击。\n未瞄准时左键击打。"
SWEP.WorldModelReal = "models/z_city/nmrih/weapons/bow/v_bow_deerhunter.mdl"
SWEP.WorldModelExchange = false
SWEP.setlh = true
SWEP.setrh = true
SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.WepSelectIcon = Material("entities/zcity/deerhunterbow.png")
SWEP.IconOverride = "entities/zcity/deerhunterbow.png"
SWEP.BounceWeaponIcon = false

SWEP.HoldPos = Vector(0,0,0)
SWEP.HoldAng = Angle(0,0,0)

--SWEP.LerpHoldPos = Vector(0,0,0)
--SWEP.LerpHoldAng = Angle(0,0,0)

function SWEP:PostSetHandPos()
    self.LerpHoldPos = self.LerpHoldPos or Vector(0,0,0)
    self.LerpHoldAng = self.LerpHoldAng or Angle(0,0,0)

    self.HoldPos = LerpVectorFT(0.03,self.HoldPos,self.LerpHoldPos)
    self.HoldAng = LerpAngleFT(0.02,self.HoldAng,self.LerpHoldAng)


    if self.AnimArHoldtypes[self.seq] then
        self.LerpHoldPos.x = self:IsLocal() and 13 or 15.5
        self.LerpHoldPos.y = self:IsLocal() and 0.65 or 0
        self.LerpHoldAng[3] = 2
        self.HoldType = "ar2"
    else
        self.HoldType = "slam"
        self.LerpHoldPos.x = 0
        self.LerpHoldAng[3] = 0
    end
end