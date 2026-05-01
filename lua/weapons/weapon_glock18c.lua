SWEP.Base = "weapon_glock17"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Glock 18C"
SWEP.Author = "Glock GmbH"
SWEP.Instructions = "格洛克是奥地利制造商格洛克有限公司设计生产的聚合物框架、短后座操作、击针式闭锁半自动手枪品牌。此型号为格洛克18C，使用9x19mm弹药，具有全自动模式。"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10

SWEP.FakeBodyGroups = "00030"
SWEP.FakeBodyGroupsPresets = {
	"00030",
	"10030",
	"00030",
	"10030",
	"00030",
	"10030",
	"00030",
	"10030",
	"00030",
	"10030",
	"00030",
	"10030",
}

function SWEP:InitializePost()
	local Skin = math.random(0,2)
	if math.random(0,100) > 99 then
		Skin = 3
	end
	self:SetGlockSkin(Skin)
	self:SetRandomBodygroups(self.FakeBodyGroupsPresets[math.random(#self.FakeBodyGroupsPresets)] or "00030")
end

SWEP.WepSelectIcon2 = Material("vgui/hud/tfa_ins2_glock_p80.png")
SWEP.IconOverride = "entities/weapon_pwb_glock17.png"

SWEP.Primary.Automatic = true
SWEP.Primary.Wait = 0.05
SWEP.AnimShootHandMul = 0.01

SWEP.punchmul = 0.5
SWEP.punchspeed = 3

SWEP.podkid = 0.5