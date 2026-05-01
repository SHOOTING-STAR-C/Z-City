SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.PrintName = "SLUGCAT"
SWEP.Author = "john rainworld"
SWEP.Instructions = [[以「五卵石」为口径的手枪

是「雨世界」中最安静的猫咪之一

...你能听到我吗？

一个小动物，在我房间的地板上。我想我知道你在找什么。

你困在一个循环中，一个重复的模式。你想要一条出路。

要知道这并不使你特别——每个生物都有同样的挫折感。从处理层中的微生物到我，如果你不介意我这么说，与之相比我是神一般的存在。

先说说好消息。从某种意义上说，我就是你在寻找的东西。我和我的同类存在的目的，就是为了解决你和无数其他人胸腔中那种反复出现的幽闭恐惧症。一种奇怪的慈善——你，不知情的接受者；我，不情愿的礼物。高贵的捐助者？早已不在了。

坏消息是，至今没有找到确定的解决方案。每一刻，设备都在向新的衰败状态侵蚀。我无法帮助你们集体或个人。我甚至无法帮助自己。

不过对你来说，还有另一条路。古老的道路。向西穿过农场阵列，然后深入地下，到达地面裂缝的最深处，那里是古人建造庙宇和跳他们愚蠢仪式的地方。我给你的印记会让你通过。

虽然这只能解决你一个人的问题。]]
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/salat_port/slugcat_figure.mdl"
//SWEP.WorldModelFake = "models/salat_port/slugcat_figure.mdl"

SWEP.FakePos = Vector(1, 1.005, -1.21)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(-1.6,-0.1,0)
SWEP.AttachmentAng = Angle(0,0,0)


SWEP.DOZVUK = true

SWEP.FakeReloadSounds = {
	[0.4] = "zcitysnd/sound/weapons/m9/handling/m9_magout.wav",

	[0.70] = "zcitysnd/sound/weapons/m9/handling/m9_magin.wav",
	[0.9] = "zcitysnd/sound/weapons/m9/handling/m9_maghit.wav",

}

SWEP.FakeEmptyReloadSounds = {
	[0.4] = "zcitysnd/sound/weapons/m9/handling/m9_magout.wav",

	[0.70] = "zcitysnd/sound/weapons/m9/handling/m9_magin.wav",
	[0.9] = "zcitysnd/sound/weapons/m9/handling/m9_maghit.wav",
	[1.05] = "zcitysnd/sound/weapons/m9/handling/m9_boltrelease.wav",
}
SWEP.MagModel = "models/weapons/upgrades/w_magazine_m45_8.mdl"
local vector_full = Vector(1,1,1)

SWEP.lmagpos = Vector(0,0,0)
SWEP.lmagang = Angle(0,0,0)
SWEP.lmagpos2 = Vector(0,-1,0)
SWEP.lmagang2 = Angle(0,0,0)

SWEP.FakeReloadEvents = {
	[0.2] = function( self, timeMul ) 
		if CLIENT and self:Clip1() < 1 then
			self:GetWM():SetBodygroup(1,1)
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 1.5 * timeMul)
		end 
	end,
	[0.43] = function( self ) 
		if CLIENT and self:Clip1() < 1 then
			hg.CreateMag( self, Vector(0,55,-55) )
			self:GetWM():ManipulateBoneScale(92, vector_origin)
		end 
	end,
	[0.55] = function( self ) 
		if CLIENT and self:Clip1() < 1 then
			self:GetWM():SetBodygroup(1,0)
			self:GetWM():ManipulateBoneScale(92, vector_full)
		end 
	end,
}

SWEP.AnimList = {
	["idle"] = "base_idle",
	["reload"] = "base_reload",
	["reload_empty"] = "base_reloadempty",
}

SWEP.WepSelectIcon2 = Material("vgui/wep_jack_hmcd_suppressed.png")
SWEP.IconOverride = "vgui/wep_jack_hmcd_suppressed.png"

SWEP.weaponInvCategory = 4

SWEP.weight = 1
SWEP.punchmul = 0
SWEP.punchspeed = 1
SWEP.CustomShell = "9x19"
SWEP.norecoil = true
SWEP.NoWINCHESTERFIRE = true


SWEP.ScrappersSlot = "Secondary"

SWEP.LocalMuzzlePos = Vector(5.767,0.001,2.28)
SWEP.LocalMuzzleAng = Angle(0.7,-0.1,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Primary.ClipSize = 352525
SWEP.Primary.DefaultClip = 352525
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "14.5x114mm B32"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 555555
SWEP.Primary.Sound = {"zcity/voice/slugcat_1/waw_1.mp3", 0, 100, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/makarov/handling/makarov_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 555555
SWEP.Primary.Wait = 0.01
SWEP.ReloadTime = 0
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor4", Vector(0,0,0), {}},
		[2] = {"supressor6", Vector(0,0,0), {}},
		--[3] = {"supressor3", Vector(0,0.2,0), {}},
		["mount"] = Vector(-0.1,0.4,0.03),
	},
	underbarrel = {
		["mount"] = Vector(13, -1.4, -1),
		["mountAngle"] = Angle(0, -0.75, 90),
		["mountType"] = "picatinny_small"
	},
}

SWEP.ReloadTime = 4
SWEP.ReloadSoundes = {
	"none",
	"none",
	"zcity/voice/slugcat_1/waw_2.mp3",
	"zcity/voice/slugcat_1/waw_1.mp3",
	"none",
	"zcity/voice/slugcat_1/waw_1.mp3",
	"none",
	"none",
	"none"
}

SWEP.PPSMuzzleEffect = "pcf_jack_mf_tpistol" -- shared in sh_effects.lua

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(-3, -0.0136, 2.9594)
SWEP.RHandPos = Vector(-2, 0, 0)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0.00, -0.01, 0), Angle(-0.01, 0.01, 0)}
SWEP.Ergonomics = 1
SWEP.AnimShootMul = 2
SWEP.AnimShootHandMul = 0.1
SWEP.addSprayMul = 0.25
SWEP.Penetration = 6.5
SWEP.WorldPos = Vector(4,-1.5,-2)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(-0.1,-0.9,0)
SWEP.lengthSub = 25
SWEP.DistSound = "zcity/voice/slugcat_1/waw_1.mp3"

SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, -2, 1)
SWEP.holsteredAng = Angle(0, 20, 30)
SWEP.shouldntDrawHolstered = true

SWEP.ShockMultiplier = 0.8
SWEP.HurtMultiplier = 1
SWEP.PainMultiplier = 1

--local to head
SWEP.RHPos = Vector(12,-4.5,3.5)
SWEP.RHAng = Angle(0,-5,90)
--local to rh
SWEP.LHPos = Vector(-1.2,-1.4,-2.8)
SWEP.LHAng = Angle(5,9,-100)

local finger1 = Angle(-65,50,-70)
local finger2 = Angle(-10,-10,-0)
local finger3 = Angle(31,1,-25)
local finger4 = Angle(-10,-5,-5)
local finger5 = Angle(0,-65,-15)
local finger6 = Angle(15,-5,-15)

function SWEP:AnimHoldPost()
	--self:BoneSet("r_finger0", vector_zero, finger6)
	--self:BoneSet("l_finger0", vector_zero, finger1)
    --self:BoneSet("l_finger02", vector_zero, finger2)
	--self:BoneSet("l_finger1", vector_zero, finger3)
	--self:BoneSet("r_finger1", vector_zero, finger4)
	--self:BoneSet("r_finger11", vector_zero, finger5)
	
end

SWEP.podkid = 1

SWEP.ShootAnimMul = 5
SWEP.SightSlideOffset = 1.2

function SWEP:DrawPost()
	
end

function SWEP:ModelCreated(model)
	local wep = self:GetWeaponEntity()
	if IsValid(wep) then
		wep:SetBodygroup(0, math.Round(util.SharedRandom("asdslug"..self:EntIndex(), 0, 6)))
	end
end

--RELOAD ANIMS PISTOL

SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(0,0,4),
	Vector(0,0,4),
	Vector(0,0,4),
	Vector(0,0,4),
	Vector(0,0,4),
	Vector(0,0,4),
	Vector(0,0,4),
	Vector(0,0,4),
	Vector(0,0,0),
	"fastreload",
	Vector(0,0,0),
	"reloadend",
	"reloadend",
}
SWEP.ReloadAnimLHAng = {
	Angle(0,0,40),
	Angle(0,0,40),
	Angle(0,0,90),
	Angle(0,0,40),
	Angle(0,0,90),
	Angle(0,0,40),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(-2,0,2),
	Vector(0,0,0),
	Vector(0,0,0)
}
SWEP.ReloadAnimRHAng = {
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(15,2,20),
	Angle(15,2,20),
	Angle(0,0,0)
}
SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
}


-- Inspect Assault

SWEP.InspectAnimWepAng = {
	Angle(0,0,0),
	Angle(4,4,15),
	Angle(10,15,25),
	Angle(10,15,25),
	Angle(10,15,25),
	Angle(-6,-15,-15),
	Angle(1,15,-45),
	Angle(15,25,-55),
	Angle(15,25,-55),
	Angle(15,25,-55),
	Angle(0,0,0),
	Angle(0,0,0)
}