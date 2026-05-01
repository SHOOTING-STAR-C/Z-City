include("shared.lua")

SWEP.PrintName = "雪球"
SWEP.Instructions =
[[雪球是用雪做成的球形物体，通常通过用手捧雪并挤压成球来制作。]]
SWEP.Category = "Weapons - Other"
SWEP.WorldModelReal = "models/mmod/weapons/c_bugbait.mdl"
SWEP.WorldModelExchange = "models/zerochain/props_christmas/snowballswep/zck_w_snowballswep.mdl"
SWEP.basebone = 39
SWEP.weaponPos = Vector(0,-0.5,0)
SWEP.modelscale = 1.1
SWEP.setlh = false
SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_snowball")
SWEP.IconOverride = "vgui/wep_jack_hmcd_snowball"
SWEP.BounceWeaponIcon = false
SWEP.AnimsEvents = {
	["draw"] = {
		[0.1] = function(self)
			self:EmitSound("weapons/m67/handling/m67_armdraw.wav",70)
		end,
	},
	["drawback"] = {
		[0.1] = function(self)
			self:EmitSound("weapons/m67/handling/m67_armdraw.wav",65)
		end,
	}
}