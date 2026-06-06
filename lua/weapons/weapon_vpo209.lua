SWEP.Base = "weapon_akm"
SWEP.Primary.Automatic = false

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.PrintName = "VPO-209"
SWEP.Author = "Vyatskiye Polyany Machine-Building Plant"
SWEP.Instructions = ".366 TKM口径半自动步枪\n\nAKM的民用狩猎版，使用.366 TKM滑膛弹药，取消了全自动功能。"
SWEP.Category = "Weapons - Carbines"
SWEP.ShockMultiplier = 1.5
SWEP.Penetration = 3
SWEP.Primary.Ammo = ".366 TKM"
SWEP.Primary.Force = 30

SWEP.CustomShell = "366tkm"

SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.FakeBodyGroups = "00000000010000"

SWEP.WepSelectIcon2 = Material("pwb/sprites/akm.png")
SWEP.IconOverride = "entities/arc9_eft_vpo209.png"

SWEP.Primary.Sound = {"weapons/ak74/ak74_tp.wav", 85, 90, 100}
SWEP.Primary.SoundFP = {"zcitysnd/sound/weapons/ak47/ak47_fp.wav", 85, 90, 100}

local mat = "models/weapons/tfa_ins2/ak_pack/ak74n/ak74n_stock"
--function SWEP:ModelCreated(model)
--	local wep = self:GetWeaponEntity()
--	--self:SetSubMaterial(1, mat)
--	--wep:SetSubMaterial(1, mat)
--end
