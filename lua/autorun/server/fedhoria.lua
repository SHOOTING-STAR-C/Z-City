AddCSLuaFile('autorun/client/ragdoll_death_expression_menu.lua')
AddCSLuaFile('autorun/client/fedh_menu.lua')
include("fedhoria/modules.lua")
--include("firstperson_death.lua")
local enabled 	= CreateConVar("fedhoria_enabled", 1, bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local players 	= CreateConVar("fedhoria_players", 1, bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local npcs 		= CreateConVar("fedhoria_npcs", 1, bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local noc 		= CreateConVar("fedhoria_ragdoll_nocollide", 1, bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local Removetime=CreateConVar("sv_playerragdoll_remove","20",{FCVAR_REPLICATED, FCVAR_ARCHIVE}, "RAG REMOVE")
local RagdollsCollideWithPlayers = CreateConVar("sv_playerragdolls_collide_players", "0", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Whether player corpses should collide with players or not.")
local RagdollComplex=CreateConVar("sv_playerragdolls_complex", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Corpses more than 1")
local RagdollBloodPool=CreateConVar("sv_playerragdolls_bloodpool", "0", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Corpses Blood Pool")
local RagdollUrine=CreateConVar("sv_playerragdolls_urine", "0", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Corpses Urine")
local fd_firstperson= CreateClientConVar("fd_firstperson", "0", true, false, "Enter the ragdolls point of view when dead")
local Death_FOV=CreateConVar("fed_fov","50",{FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Fedhoria death FOV")
local Death_FOV_duration=CreateConVar("fed_fov_duration","2",{FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Fedhoria_death FOV time")
local Death_cam=CreateConVar("special_cam","1",bit.bor(FCVAR_REPLICATED, FCVAR_ARCHIVE), "Fedhoria_death Cam Type")
local AllowBloodVar = CreateConVar("fd_blood", "0", FCVAR_ARCHIVE,"")
local BloodThresholdVar = CreateConVar("fd_blood_threshold", "500", FCVAR_ARCHIVE,"")


local citizen_hit	= CreateConVar("fedhoria_overkill_citizen_hit", 4, bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local player_hit	= CreateConVar("fedhoria_overkill_player_hit", 4, bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local combine_hit	= CreateConVar("fedhoria_overkill_combine_hit", 4, bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))
local grab_time 	= CreateConVar("fedhoria_woundgrab_time", 5, bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED))

util.AddNetworkString("Fedhoria_Ragdoll")
util.AddNetworkString("ragdeath_client")
local function OnPlyRagdollCollide(collider, colData )	
	if AllowBloodVar:GetBool() then
		if colData.Speed < BloodThresholdVar:GetFloat() then return end
		local pos = colData.HitPos
		local norm = colData.OurOldVelocity:GetNormalized()
		util.Decal("Blood",pos,pos + colData.HitNormal * 20)
	end
end


function printnpctype(mdlpath)
	local npcs = list.GetForEdit( "NPC")
	
	for k, v in pairs( npcs ) do
		if v["Class"]=="npc_citizen" and v["Model"]==mdlpath then print(k) end
	end
end


hook.Add("OnEntityCreated", "Fedhoria", function(ent)
if(IsValid(ent) and ent:IsNPC()) then
	for k, v in ipairs( ents.FindByClass("dummy_info_target") ) do
		if IsValid(v)then
		   ent:AddEntityRelationship(v,D_NU,0)
		end
	end
end
end
)


local last_dmgpos = {}

hook.Add("CreateEntityRagdoll", "Fedhoria", function(ent, ragdoll)
	if (!enabled:GetBool() or !npcs:GetBool()) then return end
	
	local class = ent:GetClass()
	if(class=="npc_citizen") then 
		ragdoll.citizen = 1 
		--printnpctype(ent:GetModel())
	end
	if(class=="npc_metropolice") then ragdoll.combine = 1 end
	if(class=="npc_combine_s") then ragdoll.combine = 1 end
	
	ragdoll.hatelist = {}
	for k, v in ipairs( ents.FindByClass("npc_*") ) do
		if v:IsNPC() and v:Disposition(ent)==D_HT then
			table.insert(ragdoll.hatelist, v)
		end
	end
	
	--print(ent:GetBloodColor())
	
	if ent:GetBloodColor()==0 then
	   --printnpctype(ent:GetModel())
	   ragdoll.UsesRealisticBlood = true
	   ent.UsesRealisticBlood = true
	end
	local dmgpos = last_dmgpos[ent]
	
	--print("dmgpos",dmgpos)

	local phys_bone, lpos

	if dmgpos then
		phys_bone = ragdoll:GetClosestPhysBone(dmgpos)
		if phys_bone then
			local phys = ragdoll:GetPhysicsObjectNum(phys_bone)
			lpos = phys:WorldToLocal(dmgpos)
		end
	end
	
	if noc:GetBool() then
		ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	end
    //finger
	
		for ii= 0 , ragdoll:GetBoneCount() do
		    if ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_L_Finger0' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,3-math.Rand(0,3),0))  
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_L_Finger0' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,10-math.Rand(0,2),0))   
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_L_Finger01' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,20-math.Rand(0,2),0))    
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_L_Finger02' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,25-math.Rand(0,3),0))    
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_L_Finger1' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(math.Rand(-5,5),-25-math.Rand(0,4),0))   
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_L_Finger11' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,-35-math.Rand(0,4),0))    
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_L_Finger12' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,-25-math.Rand(0,4),0))
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_L_Finger2' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(math.Rand(-5,5),-26-math.Rand(0,4),0))   
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_L_Finger21' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,-35-math.Rand(0,40),0))    
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_L_Finger22' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,-25-math.Rand(0,40),0))  
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_L_Finger3' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(math.Rand(-5,5),-25-math.Rand(0,4),0))   
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_L_Finger31' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,-35-math.Rand(0,40),0))    
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_L_Finger32' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,-25-math.Rand(0,40),0))
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_L_Finger4' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(math.Rand(-5,5),-25-math.Rand(0,30),0))   
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_L_Finger41' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,-20-math.Rand(0,20),0))    
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_L_Finger42' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,-20-math.Rand(0,3),0))  

			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_R_Finger0' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,3-math.Rand(0,2),0))   
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_R_Finger01' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,10-math.Rand(0,3),0))    
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_R_Finger02' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,20-math.Rand(0,3),0))    
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_R_Finger1' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(math.Rand(-5,5),-25-math.Rand(0,4),0))   
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_R_Finger11' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,-35-math.Rand(0,4),0))    
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_R_Finger12' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,-25-math.Rand(0,4),0))
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_R_Finger2' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(math.Rand(-5,5),-27-math.Rand(0,4),0))   
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_R_Finger21' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,-35-math.Rand(0,4),0))    
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_R_Finger22' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,-25-math.Rand(0,4),0))  
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_R_Finger3' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(math.Rand(-5,5),-25-math.Rand(0,4),0))   
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_R_Finger31' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,-32-math.Rand(0,4),0))    
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_R_Finger32' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,-20-math.Rand(0,40),0))
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_R_Finger4' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(math.Rand(-5,5),-20-math.Rand(0,30),0))   
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_R_Finger41' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,-25-math.Rand(0,20),0))    
			elseif ragdoll:GetBoneName(ii)=='ValveBiped.Bip01_R_Finger42' then
			   ragdoll:ManipulateBoneAngles(ii,Angle(0,-25-math.Rand(0,3),0))    
			end
			
		end
	-- //hentai
	-- if RagdollUrine:GetInt()== 765493316 then
	-- boneid2=ragdoll:LookupBone( 'ValveBiped.Bip01_L_Thigh' )
	-- boneid3=ragdoll:LookupBone( 'ValveBiped.Bip01_R_Thigh' )
	-- pos3=(ragdoll:GetBonePosition(boneid2)+ragdoll:GetBonePosition(boneid3))
	-- timer.Simple(5,function()
	   -- boneid1=ragdoll:LookupBone('ValveBiped.Bip01_Pelvis')
       -- CreateUrineForRagdoll(ragdoll, boneid1, boneid2,boneid3,BLOOD_COLOR_YELLOW, 1)
	   -- end) 
	-- end
	--print(ent.bloodpool_lastdmgbone)
	if ent.bloodpool_lastdmgbone then
	--print(ragdoll:GetBoneName(ent.bloodpool_lastdmgbone))
	if ragdoll:GetBoneName(ent.bloodpool_lastdmgbone)=='ValveBiped.Bip01_Head1' then //判定是否死于爆头击杀
	   --print(114)
	   ragdoll.HeadShotToDeath=1
	end
	end
	timer.Simple(0, function()
		if !IsValid(ragdoll) then return end	
		fedhoria.StartModule(ragdoll, "stumble_legs", phys_bone, lpos)
		last_dmgpos[ent] = nil		
	end)
end)

hook.Add("EntityTakeDamage", "Fedhoria", function(ent, dmginfo)
    if (ent:IsNPC() or ent:IsPlayer()) and ent:GetBloodColor()==0 then
	   ent.UsesRealisticBlood = true
	end
	if (!enabled:GetBool() or !npcs:GetBool()) then return end
	if (ent:IsRagdoll() and ent.infotarget) then
	
		if ent.overkilled then ent.overkilled=ent.overkilled+1 end
	
		if !IsValid(ent.infotarget) then
			--ent.infotarget = nil
			ent.overkilled = ent.overkilled or 1
		elseif dmginfo:IsBulletDamage() then
    		local dmginfo1= DamageInfo()
			      dmginfo1:SetDamage(1)
			ent.infotarget:TakeDamageInfo(dmginfo1)
			if ent.infotarget:Health()<=0 then 
				--ent.infotarget = nil
				ent.overkilled = ent.overkilled or 1
			end
		end
	end
	--print(dmginfo:GetDamagePosition())
	if ((ent:IsNPC() or ent:IsPlayer())  and dmginfo:GetDamage() >= ent:Health()) then
		--print("recorded dmg pos",ent,dmginfo:GetDamagePosition())
		last_dmgpos[ent] = dmginfo:GetDamagePosition()
	end
	--print(1)
	if ent:IsRagdoll() and ent.player==1 and ent.bleeding!=1 then //为玩家的尸体添加血液效果

	   if ent.bloodpool_lastdmgbone and RagdollBloodPool:GetBool() then 

		local bone = ent.bloodpool_lastdmgbone

		local lpos = ent.bloodpool_lastdmglpos
		local lang = ent.bloodstream_lastdmglang	
		ent.bleeding=1			     	
		--theres proably a better way to do this D:
		local meme = ents.Create("prop_dynamic")
		meme:SetModel("models/error.mdl")				
		meme:Spawn()
		meme:SetModelScale(0)
		meme:SetNotSolid(true)
		meme:DrawShadow(false)
        --print(1)
		

		meme:FollowBone(ent, bone)

		meme:SetLocalPos(lpos)
		
		meme:SetLocalAngles(Angle(lpos)-lang*(-4))
        PrecacheParticleSystem("blood_fluid_UBTM_bleeding1")
		ParticleEffectAttach("blood_fluid_UBTM_bleeding1", PATTACH_ABSORIGIN_FOLLOW, meme, 0)
		-- local effectdata = EffectData()
        -- effectdata:SetEntity(meme)
		-- effectdata:SetFlags(0)
        -- util.Effect("bloodstreameffectzippy", effectdata)
		   if dmginfo:GetDamage()>=70 then
		      --print(dmginfo:GetDamage())
		      CreateBloodPoolForRagdoll(ent, bone ,BLOOD_COLOR_RED,0)	
		   end
		ent.bloodpool_lastdmgbone = nil  
		timer.Simple(5,function()
		   ent.bleeding=0
		end)   
	   end
	end
end)

local once = true

--RagMod/TTT support
hook.Add("OnEntityCreated", "Fedhoria", function(ent)
	--If RagMod isn't installed remove this hook
	if once then
		once = nil
		if (!RMA_Ragdolize and !CORPSE) then
			hook.Remove("OnEntityCreated", "Fedhoria")
			return
		end
		--these hooks fucks shit up
		if RMA_Ragdolize then
			hook.Remove( "PlayerDeath", "RM_PlayerDies")
			hook.Add( "PostPlayerDeath", "RemoveRagdoll", function(ply)
				if IsValid(ply.RM_Ragdoll) then
					SafeRemoveEntity(ply:GetNWEntity("RagdollDeath"))
					ply:SpectateEntity(ply.RM_Ragdoll)
				end
			end)
		end
	end
	if (!enabled:GetBool() or !players:GetBool() or !ent:IsRagdoll()) then return end

	timer.Simple(0, function()
		if !IsValid(ent) then return end
		if CORPSE then
			local ply = ent:GetDTEntity(CORPSE.dti.ENT_PLAYER)
			if (IsValid(ply) and ply:IsPlayer()) then
			
				local dmgpos = last_dmgpos[ply]
				local phys_bone, lpos

				if dmgpos then
					phys_bone = ent:GetClosestPhysBone(dmgpos)
					if phys_bone then
						local phys = ent:GetPhysicsObjectNum(phys_bone)
						lpos = phys:WorldToLocal(dmgpos)
					end
				end
				
				ent.hatelist = {}
				for k, v in ipairs( ents.FindByClass("npc_*") ) do
					if v:IsNPC() and v:Disposition(ply)==D_HT then
						table.insert(ent.hatelist, v)
					end
				end
				
				--print("aaa1",dmgpos,phys_bone, lpos)
				fedhoria.StartModule(ent, "stumble_legs", phys_bone, lpos)
				return
			end
		end
		for _, ply in ipairs(player.GetAll()) do
			if (ply.RM_IsRagdoll and ply.RM_Ragdoll == ent) then
			
				local dmgpos = last_dmgpos[ply]
				local phys_bone, lpos

				if dmgpos then
					phys_bone = ent:GetClosestPhysBone(dmgpos)
					if phys_bone then
						local phys = ent:GetPhysicsObjectNum(phys_bone)
						lpos = phys:WorldToLocal(dmgpos)
					end
				end
			
				ent.hatelist = {}
				for k, v in ipairs( ents.FindByClass("npc_*") ) do
					if v:IsNPC() and v:Disposition(ply)==D_HT then
						table.insert(ent.hatelist, v)
					end
				end
				--print("aaa2",dmgpos,phys_bone, lpos)
			
				fedhoria.StartModule(ent, "stumble_legs", phys_bone, lpos)
				return
			end
		end
	end)
end)

hook.Add("EntityTakeDamage", "BloodPool_&Gib_TakeDamageedit", function(self, dmginfo)
			if ((self:IsPlayer() or self:IsNPC()) ) or self.player==1 then 
           -- print(1)
			local phys_bone = dmginfo:GetHitPhysBone_FDP(self)
            --print(phys_bone)
			if phys_bone then
				local bone = self:TranslatePhysBoneToBone(phys_bone)
                self.ZippyGoreMod3_LastDMGINFO = dmginfo
				self.bloodpool_lastdmgbone = bone
                self.bloodpool_physicbone = phys_bone
				self.bloodpool_lastdmglpos,self.bloodstream_lastdmglang = WorldToLocal(dmginfo:GetDamagePosition(), angle_zero, self:GetBonePosition(bone))
				--`print(self:GetBoneName(self.bloodpool_lastdmgbone))
			end
		
			end
	end)
local DMGINFO = FindMetaTable("CTakeDamageInfo")//from GibSplat

local COLL_CACHE = {}

local vec_max = Vector(1, 1, 1)
local vec_min = -vec_max

function DMGINFO:GetHitPhysBone_FDP(ent)
	local mdl = ent:GetModel()

	local colls = COLL_CACHE[mdl]
	if !colls then
		colls = CreatePhysCollidesFromModel(mdl)
		COLL_CACHE[mdl] = colls
	end
    --print(colls)
	local dmgpos = self:GetDamagePosition()

	local dmgdir = self:GetDamageForce()
	dmgdir:Normalize()

	local ray_start = dmgpos - dmgdir * 50
	local ray_end = dmgpos + dmgdir * 50
    if colls then
	for phys_bone, coll in pairs(colls) do
		phys_bone = phys_bone - 1
		local bone = ent:TranslatePhysBoneToBone(phys_bone)
		local pos, ang = ent:GetBonePosition(bone)
		if pos && ang && coll && IsValid(coll)then
		--print(1)
		 if coll:TraceBox(pos, ang, ray_start, ray_end, vec_min, vec_max) then
			return phys_bone
		 end
		end
	end
	end
end

local ppas={}
hook.Add("PlayerSpawn", "FPDM_Spawn", function(ply)
   self=ply
   --SafeRemoveEntity(pps[self]) -- pps was removed in Z-City merge
   ply:SetViewEntity(ply)
 --  ply:SetShouldServerRagdoll(enabled:GetBool())
   if enabled:GetBool() and not players:GetBool() then
      ply:SetShouldServerRagdoll(false)
   end

end) 


local Feddmginfo={}

hook.Add("PostPlayerDeath", "Fedhoria", function(ply)
    --print(PLAYER.CreateRagdoll)
	if (!enabled:GetBool()) then return end
	timer.Simple(0.001,function ()
	  local ent = ply:GetNWEntity("RagdollDeath")
	  if(IsValid(ent) and player_hit:GetFloat()>0.5) then
		timer.Simple(GetConVar("sv_fedhoria_facial_duaration"):GetFloat()/8,function()--GetConVar("sv_fedhoria_facial_duaration"):GetFloat()/5
		local hole = ents.Create("dummy_info_target")
		hole:SetBody(ent)
		for k, v in ipairs( ents.FindByClass("npc_*") ) do
			if IsValid(v) and v:IsNPC() then
				v:AddEntityRelationship(hole,D_NU,0)
			end
		end
			ent.hatelist = {}
			for k, v in ipairs( ents.FindByClass("npc_*") ) do
				if v:IsNPC() and v:Disposition(ply)==D_HT then
					table.insert(ent.hatelist, v)
				end
			end
		
		for k, v in ipairs( ent.hatelist ) do
			if IsValid(v) then
				v:AddEntityRelationship(hole,D_HT,math.floor(math.random()*2)-1)
			end
		end
		hole:Spawn()
		
		hole:SetHealth(player_hit:GetFloat())
		ent.infotarget = hole
		SafeRemoveEntityDelayed(hole, grab_time:GetFloat())
		end)
	  end
	end)
	
	
	if (!enabled:GetBool() or !players:GetBool()) then return end
	
	
	
	
	timer.Simple(0, function()
		if !IsValid(ply) then return end
		local ragdoll = ply:GetNWEntity("RagdollDeath")
		if (IsValid(ragdoll) and ragdoll:IsRagdoll()) then
		
			local dmgpos = last_dmgpos[ply]
			local phys_bone, lpos

			if dmgpos then
				phys_bone = ragdoll:GetClosestPhysBone(dmgpos)
				if phys_bone then
					local phys = ragdoll:GetPhysicsObjectNum(phys_bone)
					lpos = phys:WorldToLocal(dmgpos)
				end
			end
			
			ragdoll.hatelist = {}
			for k, v in ipairs( ents.FindByClass("npc_*") ) do
				if v:IsNPC() and v:Disposition(ply)==D_HT then
					table.insert(ragdoll.hatelist, v)
				end
			end
		
			--print("aaa3",dmgpos,phys_bone, lpos)
			fedhoria.StartModule(ragdoll, "stumble_legs", phys_bone, lpos)

		end
	end)
end)




-- hook.Add("CreateEntityRagdoll_FED","RagDeath_Ragdoll",function(owner, rag)
    -- --print(owner)
	-- if type(owner) != "Player" then return end
	-- -- Send the ragdolls entity index to its owner player
	-- local index = rag:EntIndex()
	-- net.Start("ragdeath_client")
		-- net.WriteInt(rag:EntIndex(),32)
		-- net.WriteInt(owner:EntIndex(),32)
	-- net.Broadcast()


	




	-- -- Remove owner (Otherwise owning player won't collide with the ragdoll)
    -- rag:SetOwner(NULL )

	-- -- Enable tool interactions
	-- rag.CanConstrain = true
	-- rag.GravGunPunt = true
	-- rag.PhysgunDisabled = false

	-- -- Add callback for blood decals
	-- rag:AddCallback( "PhysicsCollide", OnRagdollCollide)

-- end)
local NPC =
{
	Name = "Npc Info Target",
	Class = "npc_info_target",
	Health = "10",
	KeyValues = { citizentype = 4 },
	Model = "",
	Category = "Dummy"
}
list.Set( "NPC", "npc_info_target", NPC )

local NPC =
{
	Name = "Npc Info Target",
	Class = "npc_info_target",
	Health = "10",
	KeyValues = { citizentype = 4 },
	Model = "",
	Category = "Dummy"
}
list.Set( "NPC", "dummy_info_target", NPC )

local NPC =
{
	Name = "Npc Info Target Enemy",
	Class = "npc_info_target_e",
	Health = "10",
	Model = "",
	KeyValues = { citizentype = 4 },
	Category = "Dummy"
}
list.Set( "NPC", "npc_info_target_e", NPC )



