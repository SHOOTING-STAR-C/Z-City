local max, min, Round, Lerp, halfValue2 = math.max, math.min, math.Round, Lerp, util.halfValue2
--local Organism = hg.organism
hg.organism.module.lungs = {}
local module = hg.organism.module.lungs
module[1] = function(org)
	org.lungsL = {
		0, --состояние,пневмотаракс
		0
	}

	org.lungsR = {0, 0}
	org.trachea = 0
	org.pneumothorax = 0
	org.needle = 0
	org.nextCough = nil
	org.o2 = {
		range = 30,
		regen = 4,
		k = 0.5,
	}

	org.lungsfunction = true

	org.o2.curregen = org.o2.regen
	
	org.o2[1] = org.o2.range
	org.CO = 0
	org.COregen = 0
	org.lastCOBreathe = nil

	org.mannitol = 0
end

function hg.organism.OxygenateBlood(org)
	return (math.max(((1 - org.lungsL[1]) + (1 - org.lungsR[1])) / 2, 0.5) * (1 - org.trachea)) * org.o2.regen / 4 * (org.owner:WaterLevel() < 3 and 1 or 0)// * (1 - org.pneumothorax)
end

function hg.organism.CanBreath(org)
	return org.o2 and org.o2.curregen >= org.losing_oxy
end

local function insta_send_holdingbreath(org)
	net.Start("organism_send") // отправляем только дизориентацию (чтобы не нагружать нет), и сразу
	
	local tbl = {}
	tbl.holdingbreath = org.holdingbreath
	tbl.owner = org.owner

	net.WriteTable(tbl)
	net.WriteBool(true)
	net.WriteBool(false)
	net.WriteBool(false)
	net.WriteBool(true) // вот эта шняга отвечает за то чтобы оно просто мерджнуло и всё
	net.Send(org.owner)
end

local function togglebreath(ply, toggle)
	local org = ply.organism
	
	if isbool(toggle) then
		if toggle then
			if not ply.organism.holdingbreath then
				ply.organism.holdingbreath = true
				ply:EmitSound(ThatPlyIsFemale(ply) and "breathing/inhale/female/inhale_0"..math.random(5)..".wav" or "breathing/inhale/male/inhale_0"..math.random(4)..".wav",65)	
				insta_send_holdingbreath(ply.organism)
			end
		else
			if ply.organism.holdingbreath then
				ply:EmitSound(ThatPlyIsFemale(ply) and "breathing/exhale/female/exhale_0"..math.random(5)..".wav" or "breathing/exhale/male/exhale_0"..math.random(5)..".wav",65)
				ply.organism.holdingbreath = false
				ply.releasebreathe = nil
				insta_send_holdingbreath(ply.organism)
			end
		end
	else
		if ply.organism.holdingbreath then
			ply:EmitSound(ThatPlyIsFemale(ply) and "breathing/exhale/female/exhale_0"..math.random(5)..".wav" or "breathing/exhale/male/exhale_0"..math.random(5)..".wav",65)
			ply.organism.holdingbreath = false
			ply.releasebreathe = nil
			insta_send_holdingbreath(ply.organism)
		else
			ply.organism.holdingbreath = true
			ply:EmitSound(ThatPlyIsFemale(ply) and "breathing/inhale/female/inhale_0"..math.random(5)..".wav" or "breathing/inhale/male/inhale_0"..math.random(4)..".wav",65)	
			insta_send_holdingbreath(ply.organism)
		end
	end

	local ent = hg.GetCurrentCharacter(ply)
	ent:StopSound(ply.lastPhr or "")
	ply.phrCld = 0
end

concommand.Add("hmcd_holdbreath",function(ply)
	if not ply.organism then return end
	if not ply:Alive() then return end
	if ply.organism.stamina[1] < 90 then return end
	if ply.organism.o2.curregen == 0 then return end

	if (ply.cooldownbreathe or 0) > CurTime() then return end
	ply.cooldownbreathe = CurTime() + 0.5

	togglebreath(ply)
end)

concommand.Add("+hmcd_holdbreath",function(ply)
	if not ply.organism then return end
	if not ply:Alive() then return end
	if ply.organism.stamina[1] < 90 then return end
	if ply.organism.o2.curregen == 0 then return end

	if (ply.cooldownbreathe or 0) > CurTime() then return end
	ply.cooldownbreathe = CurTime() + 0.5

	togglebreath(ply,true)
end)

concommand.Add("-hmcd_holdbreath",function(ply)
	if not ply.organism then return end
	if ply.organism.stamina[1] < 90 then return end
	if ply.organism.o2.curregen == 0 then return end

	if (ply.cooldownbreathe or 0) > CurTime() then ply.releasebreathe = ply.cooldownbreathe return end

	togglebreath(ply,false)
end)

local lowoxy = {
	"我要晕了……氧气不够了……",
	"氧气不够了……撑不了多久了……",
	"真的得吸点新鲜空气……",
	"我喘不上气了……",
	"得呼吸……不然就要在这晕倒了……"
}

local not_enough_intake = {
	//"I have to breathe...",
	//"I gotta take a break...",
	//"Need a break from this... to breathe...",
	//"Resting sounds like a nice idea.",
	"我得喘口气……",
	"我呼吸不上来了……",
}

local drop_mask = {
	"戴着这玩意儿没法呼吸……得摘了。",
	"把面具扔了吧，不值当……",
	"真他妈恶心……戴着这玩意根本喘不上气……",
	"太他妈臭了……得把这面具摘了……",
}

local drugged = {
	"噢噢噢噢噢我好喜翻这个.....",
	"操他妈滴太爽了.....感jio好好好好..",
	"这才素那玩意儿啊兄deeee",
	"我贼拉喜翻我现在滴感jio....",
	"噢耶耶耶这也太爽了！",
	"我想余生都保持这个样子",
	"我为嘛在这儿啊？..无所谓了嘿嘿",
	"你似谁啊？滚滚滚滚出去...",
	"啥都不要了...这简直太完喵了！..",
}

local bit_band,util_PointContents = bit.band,util.PointContents

local color_white, color_red, color_red2, color_red3 = Color(255, 255, 255), Color(255, 0, 0), Color(200, 55, 55), Color(255, 100, 100)
module[2] = function(owner, org, timeValue)
	local o2 = org.o2
	local losing_oxy = timeValue * 1 * math.Clamp(org.o2[1] / 30, 0.25, 1)
	org.losing_oxy = losing_oxy
	o2[1] = max(o2[1] - losing_oxy, 0)
	local ent = hg.GetCurrentCharacter(owner)
	local bone = ent:LookupBone("ValveBiped.Bip01_Head1")

	if (not bone) or (bone < 0) then bone = 6 end

	local head = ent:GetBonePosition(bone)
	
	if not head then
		head = ent:GetBonePosition(0)
	end

	if org.o2.curregen == 0 and org.holdingbreath then
		togglebreath(owner, false)
	end

	if org.holdingbreath then
		//org.stamina[1] = max(org.stamina[1] - timeValue * 15,0)
		if org.stamina[1] < 90 or org.o2[1] <= 10 then
			togglebreath(owner, false)
		end
		
		if owner.releasebreathe and owner.releasebreathe < CurTime() then
			togglebreath(owner, false)
			owner.releasebreathe = nil
		end
	end

	if not head then head = owner:GetPos() end
	
	local inwater = bit_band(util_PointContents(head),CONTENTS_WATER) == CONTENTS_WATER
	-- test
	local success = owner:IsBerserk() or (not org.heartstop and org.alive and not (org.brain >= 0.4 and math.random(10 - (org.brain * 10)) < 4) and org.lungsfunction)
	if success and owner:IsPlayer() and inwater then success = false end
	if success and org.choking then org.needfake = true success = false end
	if success and org.vomitInThroat then success = false end
	org.choking = false
	local pneumothorax = (org.lungsR[2] == 1 or org.lungsL[2] == 1) and org.needle == 0
	
	org.needle = math.Approach(org.needle, 0, timeValue / 1200)

	org.pneumothorax = pneumothorax and min(org.pneumothorax + timeValue / 180 * (org.lungsL[2] + org.lungsR[2]), (org.lungsL[2] + org.lungsR[2]) / 2) or max(org.pneumothorax - timeValue / 10, 0)
	
	if org.lastCOBreathe and org.lastCOBreathe + 1 > CurTime() then
		org.COregen = math.Approach(org.COregen, 30, timeValue * 1)
	else
		org.COregen = math.Approach(org.COregen, 0, timeValue * 0.5)
	end

	org.CO = max(org.CO - timeValue, 0)
	if success then
		local oxygenate = hg.organism.OxygenateBlood(org) * 0.5
		local lerp = min(max(org.pulse - 20, 0) / 20, 1)
		local regen = Lerp(lerp, 0, o2.regen * oxygenate * math.Rand(0.95, 1.05))

		org.CO = min(org.CO + (org.COregen > 0 and timeValue * 1.5 or 0), 30)

		org.consciousness = math.min(org.consciousness, (30 - org.CO) / 30)

		local mask_blevota = owner:GetNetVar("zableval_masku", false)

		local sprayed = org.is_sprayed_at
		org.is_sprayed_at = nil

		local regenerate = regen * timeValue * 4 * (org.stamina[1] / org.stamina.max) * (mask_blevota and 0 or 1) * ((org.temperature > 38) and math.Clamp(math.Remap(org.temperature, 38, 41, 1, 0.1), 0.1, 1) or 1)
		o2[1] = min(o2[1] + regenerate * math.Clamp(org.o2[1] / 30, 0.25, 1) * (org.holdingbreath and 0 or 1) * (sprayed and 0 or 1) * min((10 / max(org.CO,1)),1), o2.range * math.max(1 - org.pneumothorax * org.pneumothorax, 0.1) * math.min(org.blood / 4500, 1) * math.max(1 - (org.lungsL[1] + org.lungsR[1]) / 2, 0.5))

		o2.curregen = regenerate

		o2[1] = max(o2[1] - (org.CO > 0 and o2.curregen * 1.1 * (org.CO / 30) or 0),0)

		//org.owner:ResetNotification("oxygen_cantbreathe")
		//org.owner:ResetNotification("oxygen_cantbreathe2")
	else
		o2.curregen = 0
	end

	if owner:IsBerserk() then
		o2[1] = math.max(5, o2[1])
	end
	
	if org.isPly and not org.otrub and o2.curregen < losing_oxy and org.analgesia <= 1.5 and !org.heartstop then
		if mask_blevota then
			if o2[1] < 10 then
				org.owner:Notify("赶紧把这破面具摘了！", 25, "take_gasmask2", 0, nil, color_red2)
			else
				org.owner:Notify(drop_mask[math.random(#drop_mask)], 15, "take_gasmask", 0)
			end
		else
			if o2[1] < 20 and o2[1] > 8 then
				org.owner:Notify(not_enough_intake[math.random(#not_enough_intake)], 61, "oxygen_lowintake", 0)
			end
		end

		if o2[1] < 8 then
			org.owner:Notify(lowoxy[math.random(#lowoxy)], 30, "lowoxy", 0, nil, color_red3)

			if o2[1] < 4 then
				org.owner:Notify("氧气……求你了……", 30, "lowoxy2", 0, nil, color_red)
			end
		end
	end

	if org.analgesia > 1.5 then
		org.owner:Notify(drugged[math.random(#drugged)], 30, "drugged", 0, nil, color_white)
	end

	if org.analgesia > 1.5 or org.painkiller > 2.4 then
		if math.Rand(0, 500) < (org.analgesia + org.painkiller) then
			//org.lungsfunction = false
		end
	end

	if o2[1] == 0 and org.needle == 0 then
		if math.random(50) == 1 then
			org.lungsfunction = false
		end
	else
		if math.random(50) == 1 or org.needle > 0 then
			org.lungsfunction = true
		end
	end

	if org.needle > 0 then
		if org.heartstop and org.alive and org.brain < 0.6 then
			org.heartstop = false
		end
	end

	if (org.lungsL[1] == 1 and org.lungsR[1] == 1) and org.needle == 0 then
		org.lungsfunction = false
	end

	--[[if (pneumothorax or org.trachea >= 0.6 or org.lungsR[1] >= 0.6 or org.lungsL[1] >= 0.6) and org.alive and o2[1] > 0 then
		local timeSub = org.pneumothorax + org.trachea + org.lungsR[1] + org.lungsL[1]
		org.nextCough = org.nextCough and org.nextCough or (CurTime() + 5)
		
		if org.nextCough < CurTime() then
			org.nextCough = CurTime() + math.random(15,30 - timeSub + math.max(10 - o2[1],0))
			owner:EmitSound("homigrad/player/male/male_cough"..math.random(5)..".wav",50 + Round(timeSub * 2.5))
		end
	end--]]

	if org.isPly then
		if org.pneumothorax > 0 then
			org.owner:Notify("好像有什么东西灌进肺里了。", true, "pneumothorax1",10) // delay of 10 seconds before typing that
		else
			org.owner:ResetNotification("pneumothorax1")
		end

		if org.pneumothorax > 0.3 then
			org.owner:Notify("呼吸越来越费劲了。", true, "pneumothorax2", 5)
		else
			org.owner:ResetNotification("pneumothorax2")
		end

		if org.pneumothorax > 0.5 then
			org.owner:Notify("我快喘不上气了……", true, "pneumothorax3", 5)
		else
			org.owner:ResetNotification("pneumothorax3")
		end
	end

	local k = halfValue2(o2[1], o2.range, o2.k)

	if o2[1] < 3 then
		if org.isPly then
			hg.StunPlayer(owner, 3)
		end
	end

	if o2[1] < 5 then
		org.needfake = true

		if org.isPly then
			hg.LightStunPlayer(owner, 3)
		end
	end

	if o2[1] < 1 then
		org.needotrub = true
	end

	if org.lungsR[1] < 0.5 then
		org.lungsR[1] = max(org.lungsR[1] - timeValue / (org.needle > 0 and 120 or 600), 0)
	end

	if org.lungsL[1] < 0.5 then
		org.lungsL[1] = max(org.lungsL[1] - timeValue / (org.needle > 0 and 120 or 600), 0)
	end

	if owner:IsBerserk() then
		org.brain = math.min(0.5, org.brain)
	end

	if org.skull >= 0.6 then k = 0 end
	if org.brain >= 0.6 then k = 0 end

	if org.skull < 1 and org.skull >= 0.5 and org.bandagedskull then
		org.skull = math.Approach(org.skull, 0, timeValue / 600)
	end

	if org.brain >= 0.3 then
		if org.brain >= 0.5 then
			if math.random(60) == 1 then
				org.heartstop = true
			end
		end

		if org.brain > 0.35 and !org.heartstop then
			if math.random(60) == 1 then
				org.lungsfunction = true
			end
		end

		org.needotrub = true
	end

	local death_from_braindamage = false
	if org.brain >= 0.7 and org.alive then
		death_from_braindamage = true
		org.alive = false
	end

	if org.skull == 1 then org.brain = min(org.brain + timeValue / (org.isPly and 10000 or 1000), 1) end

	if org.isPly then
		if org.brain > 0.1 and org.brain < 0.3 then
			org.owner:Notify(math.random(2) == 1 and "我头好疼……" or "我这是在哪……？", true, "brain", 5)
		else
			org.owner:ResetNotification("brain") 
		end
	end

	org.brain = max(org.brain - timeValue / 400 * ((org.mannitol > 0 and org.brain < 0.6) and 1 or (org.brain > 0.1 and 0.1 or 0)), 0)
	org.mannitol = math.Approach(org.mannitol, 0, timeValue / 200)
	
	if k < 0.25 then
		if not org.alive and owner:IsPlayer() and death_from_braindamage and org.o2[1] == 0 then
			hg.achievements.AddPlayerAchievement(owner,"brain",1)
			if org.analgesia > 1 then
				hg.achievements.AddPlayerAchievement(owner,"drugs",1)
			end
		end
		
		org.brain = min(org.brain + timeValue / (org.brain < 0.3 and (org.isPly and 3000 or 300) or (org.isPly and 1200 or 120)) * math.min(((org.o2[1] < 0.25 and 1 or 0) + org.skull), 1), 1)
	end --~120 seconds to fully die (0.3 of 300 and 0.4 of 60 seconds after)
end