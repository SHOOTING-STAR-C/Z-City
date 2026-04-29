--local Organism = hg.organism
hg.organism.module.random_events = {}
local module = hg.organism.module.random_events
module[1] = function(org)
	org.timeToRandom = CurTime() + math.random(120,320)
end

local RandomEvents = {} 

function module.TriggerRandomEvent(owner, eventName)
    if RandomEvents[eventName] then
        if owner:IsRagdoll() then return end
        RandomEvents[eventName](owner, owner.organism)
    end
end

module[2] = function(owner, org, timeValue)
    --print("huy")
    if org.timeToRandom < CurTime() and owner:IsPlayer() and owner:Alive() then
		if owner:GetPlayerClass() and owner:GetPlayerClass().CanEmitRNDSound ~= nil and not owner:GetPlayerClass().CanEmitRNDSound then
			return
		end

        --if not org.otrub then
        --    table.Random(RandomEvents)(owner,org)
        --end

        org.timeToRandom = CurTime() + math.random(120,320)
    end
end

hook.Add("Org Think", "VirusRandomEvents", function(owner, org, timeValue)
    if not owner:IsPlayer() or not owner:Alive() then return end
    if owner:IsPlayer() and owner.Virus and owner.Virus.Infected and (owner.Virus.Stage == 1 or owner.Virus.Stage == 2) then
        if not owner.NextVirusRandomEventTime or CurTime() >= owner.NextVirusRandomEventTime then
            local event = math.random(1, 2) == 1 and "Cough" or "Sneeze"
            module.TriggerRandomEvent(owner, event)
            owner.NextVirusRandomEventTime = CurTime() + math.random(10, 15)
        end
    end
end)

hook.Add("Org Think", "TemperatureSounds", function(owner, org, timeValue) -- добавил звуки при низкой температуре Ж))
    if not owner:IsPlayer() or not owner:Alive() or org.otrub then return end
    if owner:IsPlayer() and org.temperature > 24 and org.temperature < 35 then
        if not owner.ColdRandomEventTime or CurTime() >= owner.ColdRandomEventTime then
            local event = math.random(1, 2) == 1 and "Cough" or "Sneeze"
            module.TriggerRandomEvent(owner, event)
            owner.ColdRandomEventTime = CurTime() + math.random(math.Remap(org.temperature, 35, 24, 60, 15), math.Remap(org.temperature, 35, 24, 120, 30))
        end
    end
end)