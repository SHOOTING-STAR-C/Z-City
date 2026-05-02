
if SERVER then return end
local fd_firstperson= CreateClientConVar("fd_firstperson", "0", true, false, "Enter the ragdolls point of view when dead")
CreateClientConVar("fd_firstperson_nearclip", "1", true, false, "Higher values work better with masks", 0.01, 5)
CreateClientConVar("fd_firstperson_force", "0", true, false, "Always go into first person even when the model isn't supported")
--local Fed_Death_cam=CreateConVar("special_cam","1",bit.bor(FCVAR_ARCHIVE), "Fedhoria_death Cam Type")
local Death_cam=CreateConVar("special_cam","1",bit.bor(FCVAR_ARCHIVE), "Fedhoria_death Cam Type")
local Death_Camera_Distance=CreateClientConVar("fed_camera_distance","50",{FCVAR_ARCHIVE}, "Fedhoria death damera distance")
local Fed_znear=CreateClientConVar("fed_z_near","0.3",{FCVAR_ARCHIVE}, "Fedhoria death damera znear")
local xtt = nil
local changepos = nil
local function PopulateSBXToolMenu(pnl)
    pnl:CheckBox("Enabled", "fedhoria_enabled")
    pnl:ControlHelp("Enable or disable the addon.")

    pnl:CheckBox("Players", "fedhoria_players")
    pnl:ControlHelp("Enable or disable effect for players.")

    pnl:CheckBox("NPCs", "fedhoria_npcs")
    pnl:ControlHelp("Enable or disable effect for NPCs.")
    
	pnl:CheckBox("Facial Effect", "sv_fedhoria_facial")
    pnl:ControlHelp("Enable or disable effect for Facial.")
	
	pnl:CheckBox("fd_firstperson", "fd_firstperson")
    pnl:ControlHelp("First Person Death.")
	
	pnl:NumSlider("Facial Time", "sv_fedhoria_facial_duaration",0,30,3)
    pnl:ControlHelp("表情变化的持续时间，注意要小于die time.")
	
	pnl:NumSlider("Eyeclose_trend", "sv_fedhoria_eyelid_trend", 0, 1, 3)
    pnl:ControlHelp("眼睛闭上的倾向，这个值越大，最后眼皮闭合的程度越接近最大值，减少半睁着眼睛的概率。")
	pnl:ControlHelp("The trend of eye closing to max value")
	
	
	pnl:NumSlider("Mouth_Twitch_Random_scale", "sv_fedhoria_facial_random", 0, 1, 3)
    pnl:ControlHelp("嘴部开合的随机性大小，会让嘴部抽动（The mouth will twitch）")
	
	-- pnl:NumSlider("Death_FOV", "fed_fov",0,100,3)
    -- pnl:ControlHelp("渐进式死亡视角的镜头FOV，如果不改变就调成0，注意不要调的太小")
	
	-- pnl:NumSlider("Death_FOV_time", "fed_fov_duration",0,10,3)
    -- pnl:ControlHelp("渐进式死亡视角拉近所需要的时间，以防过大的fov变化导致您的视力出现问题")
	
	
	pnl:NumSlider("fed_camera_distance", "fed_camera_distance",-100,100,3)
    pnl:ControlHelp("非渐进式死亡视角的镜头距离，如果不改变就调成0，注意不要调的太大")
	
	pnl:NumSlider("Znear", "fed_z_near",0,30,3)
    pnl:ControlHelp("非渐进式死亡视角的贴地程度，如果不改变就调成0，注意不要调的太大")
	
	pnl:CheckBox("RagdollsCollideWithPlayers", "sv_playerragdolls_collide_players")
    pnl:ControlHelp("Enable or disable Ragdoll Collide With Players.")
	
	pnl:CheckBox("Ragdolls More Than 1", "sv_playerragdolls_complex")
    pnl:ControlHelp("Enable or disable Player Ragdoll more than one.")
	
	pnl:NumSlider("Remove Timer", "sv_playerragdoll_remove",0,300,3)
    pnl:ControlHelp("Enable or disable Ragdoll Remove.")
	
    pnl:NumSlider("Stumble time", "fedhoria_stumble_time", 0, 10, 3)
    pnl:ControlHelp("How long the ragdoll should stumble for.")
	pnl:ControlHelp("Note: Recommended value 7")

    pnl:NumSlider("Die time", "fedhoria_dietime", 0, 100, 3)
    pnl:ControlHelp("How long before the ragdoll dies after drowning/being still for too long.")
	pnl:ControlHelp("Note: Recommended value 7")

    pnl:NumSlider("Wound grab chance", "fedhoria_woundgrab_chance", 0, 1, 3)
    pnl:ControlHelp("The chance the ragdoll will grab it's wound when shot.")

    pnl:NumSlider("Wound grab time", "fedhoria_woundgrab_time", 0, 10, 3)
    pnl:ControlHelp("How long the ragdoll should hold its wound.")
	
	pnl:NumSlider("Citizen overkill hit", "fedhoria_overkill_citizen_hit", 0, 10, 0)
	pnl:ControlHelp("How many hits to overkill an npc_citizen. 0 = do not spawn dummy target.")
	pnl:ControlHelp("Note: Upon taken this hit number, the overkill still lasts for at least 1 secound for 6 hit or 1.8 secound.")
	
	pnl:NumSlider("Combine overkill hit", "fedhoria_overkill_combine_hit", 0, 10, 0)
	pnl:ControlHelp("How many hits to overkill an npc_combine_s.")
	
	pnl:NumSlider("Player overkill hit", "fedhoria_overkill_player_hit", 0, 10, 0)
	pnl:ControlHelp("How many hits to overkill an player.")
	


	pnl:CheckBox("Ragdoll no collide", "fedhoria_ragdoll_nocollide")
    pnl:ControlHelp("Ragdolls only collide to world and bullets.")
	
	
	
end

hook.Add("AddToolMenuCategories", "FedhoriaCategory", function()
    spawnmenu.AddToolCategory("Utilities", "Fedhoria_aquila", "Fedhoria_aquila")
end)

hook.Add("PopulateToolMenu", "FedhoriaMenuSettings", function()
    spawnmenu.AddToolMenuOption("Utilities", "Fedhoria_aquila", "FedhoriaSettings", "Settings", "", "", function(pnl)
        pnl:ClearControls()
        PopulateSBXToolMenu(pnl)
    end)
end)


--util.AddNetworkString("RagdollVariable")
local CamState = false

-- 创建一个自定义命令
concommand.Add("toggle_FedCamState", function()
    -- 切换命令状态
    CamState = not CamState

    -- 在这里根据命令状态执行相应的操作
    if CamState then
        print("CamState is now enabled")
        -- 执行启用命令时的操作
    else
        print("CamState is now disabled")
        -- 执行禁用命令时的操作
    end
end)

-- 监听按键事件



hook.Add( "CalcView", "Fedhoria_edited", function( ply, pos, angles, fov )
    --print(ply:Nick())
	if not GetConVar("special_cam"):GetBool() then return end

	net.Receive("Fedhoria_Ragdoll", function()
    local  countt = net.ReadInt(32)
	local  owner = net.ReadEntity()
	       countn=countt
		   ownerp=owner
	       --print(countn)
    end)


	
	
    if (ply:Alive() ) or not Death_cam:GetBool() then xtt=0  return end
	
	local ragdoll
	allragdoll=ents.FindByClass("prop_ragdoll")
	for dir,x in pairs (allragdoll) do
	--print(countn)--and (x:GetOwner() == ply)
	    if  (countn==x:EntIndex() and ownerp == ply) then --&& x.DeathInfo == ply:Nick()  x:EntIndex() == countt and 
		
		ragdoll=x
		break
	    end
	end
	
	--local rd = util.TraceLine({start=ragdoll:GetPos(),endpos=ragdoll:GetPos()-angles:Forward()*105,filter={ragdoll,LocalPlayer()}})
	
	
--    net.Start("RagdollVariable")
    
	--ragdoll=ply:GetObserverTarget()
     if not IsValid(ragdoll) then  return end
     if fd_firstperson:GetBool()  then --and ragdoll.DeathInfo == ply:GetName().."'s ragdoll" 
	 local head={
	       Pos = ragdoll:EyePos(),
           Ang = ragdoll:EyeAngles()
	       }
	      
	       head = ragdoll:GetAttachment( ragdoll:LookupAttachment( "eyes" ) )
		   
	      -- headPos = ragdoll:GetBonePosition(ragdoll:LookupBone("ValveBiped.Bip01_Head"))
          -- headAng = ragdoll:GetBoneMatrix(ragdoll:LookupBone("ValveBiped.Bip01_Head")):GetAngles()
        --PrintMessage(HUD_PRINTTALK)
        -- 设置玩家的位置和角度
        local view = {
              
              angles = head.Ang,
			  origin = head.Pos +head.Ang:Forward()*1 ,--微调摄像头的位置
              fov = fov,
              drawviewer = true,
			  znear = GetConVar("fd_firstperson_nearclip"):GetFloat(),
			  --zfar=3000
              }
			  
	        return view
	 else
	   
	   local aimVector = ply:GetAimVector()
	   --print(input.WasKeyTyped(KEY_P))
       if xtt == nil then
	      xtt = 0
	   end
	   --print(Angle(aimVector))
	   if CamState  then
          
		  --print(xtt)
		 if xtt == 0  then 
		  changepos = ragdoll:EyePos()+Vector(0,0,20)
		  --print(changepos)
          xxt = 1
		  else
		  if input.IsKeyDown(KEY_LSHIFT) && input.IsKeyDown(KEY_W)  then 
		     changepos = changepos + aimVector*2.5
		  end
		  if input.IsKeyDown(KEY_W) then
		     changepos = changepos + aimVector
		  end
		  if input.IsKeyDown(KEY_S) then
		     changepos = changepos - aimVector
		  end
		  if input.IsKeyDown(KEY_LSHIFT) && input.IsKeyDown(KEY_S) then
		     changepos = changepos - aimVector*2.5
		  end		  
		  if input.IsKeyDown(KEY_S) && input.IsKeyDown(KEY_LSHIFT) then
		     changepos = changepos - aimVector*2.5
		  end
		  if input.IsKeyDown(KEY_A) then
		     changepos = changepos - aimVector:Cross(Vector(0, 0, 1))
		  end
		  
		  if input.IsKeyDown(KEY_A) && input.IsKeyDown(KEY_LSHIFT)  then
		     changepos = changepos - aimVector:Cross(Vector(0, 0, 1))*1.5
		  end
		  if input.IsKeyDown(KEY_D) then
		     changepos = changepos + aimVector:Cross(Vector(0, 0, 1))
		  end
		  if input.IsKeyDown(KEY_D) && input.IsKeyDown(KEY_LSHIFT)  then
		     changepos = changepos + aimVector:Cross(Vector(0, 0, 1))*1.5
		  end
		  changepos = changepos
		 end
		  xtt = 1
	      local view={origin=changepos,angles=angles,fov=fov,znear=Fed_znear} 
		  --print (xtt)
	      return view
		  
	   else
	      xtt = 0
		  
	      local rd = util.TraceLine({start=ragdoll:GetPos(),endpos=ragdoll:GetPos()-angles:Forward()*45,filter={ragdoll,LocalPlayer()}})
          
		  local view={origin=ragdoll:GetPos()-angles:Forward()*(100*rd.Fraction)+angles:Forward()*Death_Camera_Distance:GetFloat()-Vector(0,0,0.1)*Fed_znear:GetFloat(),angles=angles,fov=fov,znear=Fed_znear} 
	      return view
		  
	   end
     end  
	 
end)
