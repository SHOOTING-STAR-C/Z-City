include("shared.lua")

SWEP.PrintName = "'Bugbait' Pheropod"
SWEP.Instructions =
[[信息素囊是天然存在于蚁狮守卫体内的器官，使它们能够控制低等蚁狮。它们可以被提取并由个体以类似方式用来指挥蚁狮。]]
SWEP.Category = "Weapons - Other"
SWEP.WorldModelReal = "models/mmod/weapons/c_bugbait.mdl"
SWEP.WorldModelExchange = false
SWEP.setlh = false
SWEP.WepSelectIcon = Material("entities/zcity/bugbait.png")
SWEP.IconOverride = "entities/zcity/bugbait.png"
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

function SWEP:Reload()
	local time = CurTime()
	if self.SqueezeCD > time then return end

	self:PlayAnim("special", 0.6)
	self:EmitSound("weapons/mmod/bugbait/bugbait_squeeze1.wav",75)
	self.SqueezeCD = time + 2
end