
local allowedchars = {
	"ah",
	"AH",
	"ghh",
	"GH",
	"AHHH",
}

local audible_pain = {
	"啊...操...好痛...",
	"我再也受不了了！",
    "让它停下来 让它停下来 让它停下来",
    "为什么它不停下来",
    "让我昏过去吧。求你了",
    "为什么我要出生来承受这个...",
    "我愿意做任何事让它停下来...任何事。",
    "这不是活着 这是被折磨",
    "我不在乎了 只要停止疼痛",
    "什么都不重要 除了让它停下来...",
    "每一秒都是永恒的火焰。",
    "死亡现在将是仁慈...",
    "只要有一刻没有疼痛..",
	"我现在希望有一些止痛药。操。",
}

local sharp_pain = {
	"AAAHH",
	"AAAH",
	"AAaaAH",
	"AAaaAH",
	"AAaaAAAGH",
	"AAaaAH",
	"AAaAaaH",
	"AAAAAaaH",
	"AAaaAHHHH",
	"AAaAA",
	"AAAAAa",
	"AAAAaAAAaaaaghh",
	"AAAaaAa",
	"AaaAAaghf",
	"aaAaaAaff",
	"aaahhh",
	"AAAaaGHHH",
	"AAAaaAAHH",
	"AAAaaAAAAAaGHHHH",
	"AAAaaAAAAAaGHAAAHHH",
	"AAAaaAAAAAaGHHAAAAAAHH",
	"AAAaaAAAAAaGHHHH",
	"AAAaaAAAaaAAAaGHHHH",
	"AAAaaAAAaaAAAaAAAAAAAGHHHH",
	"AAAaaAAAAAaGHHHH",
	"AAAaaAAAAAAAAAHHH",
	"AAAaaAAAAAaGHAaaaHH",
	"AAAaaAAAAAaAaaaaaAAAAHH",
	"AAAaaAAAAAaAAAAAAAADGHHHH",
	"AAAaaAAAaaAAAaAAAAAAAAAAAAGGGGGGAGHHHH",
	"AAAaaAAAaaAAAaAAAAAAAAAAAAAAAAAAH",
}

hg.sharp_pain = sharp_pain

local random_phrase = {
	"这里有点冷...",
	"一切似乎都太安静了...",
	"呼吸现在感觉出奇地满足。",
	"如果这种安静永远持续下去呢？",
	"为什么什么都没发生？",
}

local fear_hurt_ironic = {
	"我敢打赌这其中有教训...如果我活下来。",
	"我未来的传记作者不会相信这部分。",
	"好吧，这是一种愚蠢的死法。",
	"至少我的生活不无聊。",
	"提醒自己：再也不要这样做了。",
	"这不是最糟糕的死亡之日。",
}

local fear_phrases = {
	"没那么糟...对吧？",
	"我不想这样死去。",
	"这真的是结局吗？",
	"这不好。",
	"这真的是结局吗？",
	"我不想这样死去。",
	"我希望有出路。",
	"我后悔很多事情。",
	"不可能就这样。",
	"我不敢相信这发生在我身上。",
	"我应该更认真对待这件事。",
	"如果我没挺过去呢..？",
	"这比我想象的还要糟。",
	"这太不公平了。",
	"我还不能放弃。",
	"我从没想过会这样。",
	"我应该听从自己的直觉。",
	"呼吸。只是呼吸。",
	"冰冷的手。稳定的手。",
}

local is_aimed_at_phrases = {
    "哦上帝。这就是了。",
    "别。动。",
    "我真的会这样死去吗？",
    "我应该跑的。为什么我没跑？",
    "请不要扣动扳机。求你了。",
    "我可以看到他们的手指在扳机上。",
    "I don't want to die. Not like this.",
    "如果我求饶，会让情况更糟吗？",
    "这不可能是真的。这不可能是真的。",
    "谁来帮帮我。求你了。有人吗。",
    "我不想死在这样的地方。",
    "我不想我最后的念头是恐惧。",
    "我不想死。",
}

local near_death_poetic = {
	"试着站起来...但我就是做不到...",
	"呼吸只是浅浅地吸着虚无...",
	"分不清我的眼睛是睁着还是闭着...",
	"我最后尝到的将是我自己的血和铜腥味。",
	"眼睛总是从东西上滑开。",
	"不记得怎么站着了。",
	"一切在我头骨内回响。",
	"眨眼后太久才能恢复。",
	"手指无法握住任何东西。",
	"肺拒绝充满空气。",
	"后悔现在毫无意义。",
}

local near_death_positive = {
	"我不想死。",
	"我必须活下来。",
	"还有机会。",
	"我不能让恐惧获胜。",
	"再试一次。",
	"我拒绝死在这里。",
	"好吧...仔细想想。",
	"保持静止。移动会让情况更糟。",
	"慢慢呼吸。恐慌没有帮助。",
	"直到结束才算结束。",
	"疼痛只是信号。忽略它。",
	"如果这就是结局...至少会很快的。",
	"我经历过更糟的。大概。",
	"这不是我想象的那样。",
}

local broken_limb = {
	"操。操。肯定断了！",
	"我能感觉到骨头碎片在动！",
	"操他妈的断了。我想..",
	"光是想想就疼。肯定断了。",
	"我觉得这里不应该弯曲。",
	"哦操。它断了。",
	"我没看到开放性骨折，但我感觉我断了什么",
}

local dislocated_limb = {
	"是啊，那不应该那样弯曲。",
	"我得把这根骨头复位。",
	"不...我得把它移回原位。",
	"那里太疼了。我可能需要检查一下。",
	"我的肢体脱臼了。",
}

local hungry_a_bit = {
    "嗯，我饿了...",
    "来点食物就好了...",
    "我饿了...",
    "我应该吃点东西。",
}

local very_hungry = {
    "我的胃...呃...",
    "如果我不吃东西，我会感觉更糟...",
    "胃...该死...我感觉恶心",
}

local after_unconscious = {
    "发生了什么？好痛...",
	"我在哪里？为什么会痛...",
	"我-我以为我要死了...",
	"我的头...发生了什么？",
	"我刚才差点死了吗？",
	"感觉就像我死了一样。",
	"天堂没有带走我？",
	"哦-操...我的头好痛...",
	"哦现在站起来会很困难...但我必须...",
	"我完全不认识这个地方...还是我认识？",
	"我再也不想经历这个了！",
}

local slight_braindamage_phraselist = {
	"我不明白...",
	"这没有意义...",
	"我在哪里？",
	"嗯？这是什么..？",
	"我不知道发生了什么...",
	"有人吗？",
	"呃...哦...      嗯...",
	"什么...发生了？",
}

local braindamage_phraselist = {
	"博...威...嗯？！",
	"嗯...嗯...",
	"嗯--嗯。嗯？",
	"嗯...嗯...",
	"啊...嗯？",
	"嗯...嗯-嗯。",
	"嗯...嗯！",
	"救...命...",
	"嗯...嗯？",
	"嗯...嗯..",
	"嗯...嗯。",
}

local cold_phraselist = {
	"变得非常冷..",
	"对我来说太冷了。",
	"我在发抖，该死的。",
	"外面极其寒冷..",
	"需要一些东西来取暖...",
	"我感觉很冷...",
	"那寒冷让我感到恶心，操。"
}

local freezing_phraselist = {
	"我..感..感觉不到我-我的身-身体..",
	"我..感..感觉不到我的腿...",
	"我-我-他妈的冻-冻僵了..",
	"我-我想-想我的脸麻-麻木了..",
	"冷-冷..",
	"我..感-感觉不到任-任何东西..",
}

local numb_phraselist = {
	"不..再冷了..",
	"为什么...感觉温暖..？",
	"我想我没事...我想...",
	"终于有点温暖了...",
	"我又暖和了...不知怎的...",
	"我刚才还在冻僵...这热量是从哪里来的..？",
}

local hot_phraselist = {
	"我出了很多汗..",
	"这热度要杀死我了..",
	"我的衣服都被汗水浸透了，操。",
	"我的汗真他妈臭。我真的应该凉快一下...",
	"有点太热了，操。",
	"我真的热得很厉害...",
	"这里为什么这么热？",
}

local heatstroke_phraselist = {
	"我需要水！！",
	"求你了...水...",
	"我感觉头晕...操-",
	"我的头！- 好痛..",
	"我的头在痛..",
}

local heatvomit_phraselist = {
	"那热度..-我要吐了-",
	"呃...我要吐了-",
	"操..呃..我感觉不-"
}

local hg_showthoughts = ConVarExists("hg_showthoughts") and GetConVar("hg_showthoughts") or CreateClientConVar("hg_showthoughts", "1", true, true, "Toggle thoughts of your character", 0, 1)

function string.Random(length)
	local length = tonumber(length)

    if length < 1 then return end

    local result = {}

    for i = 1, length do
        result[i] = allowedchars[math.random(#allowedchars)]
    end

    return table.concat(result)
end

function hg.nothing_happening(ply)
	if not IsValid(ply) then return end

	return ply.organism and ply.organism.fear < -0.6
end

function hg.fearful(ply)
	if not IsValid(ply) then return end

	return ply.organism and ply.organism.fear > 0.5
end

function hg.likely_to_phrase(ply)
	local org = ply.organism

	local pain = org.pain
	local brain = org.brain
	local blood = org.blood
	local fear = org.fear
	local temperature = org.temperature
	local broken_dislocated = org.just_damaged_bone and ((org.just_damaged_bone - CurTime()) < -3)

	return (broken_dislocated) and 5
		or (pain > 65) and 5
		or (temperature < 31 and 0.5)
		or (temperature > 38 and 0.5)
		or (blood < 3000 and 0.3)
		--or (fear > 0.5 and 0.7)
		or (brain > 0.1 and brain * 5)
		or (fear < -0.5 and 0.05)
		or -0.1
end

function IsAimedAt(ply)
    return ply.aimed_at or 0
end

local function get_status_message(ply)
	if not IsValid(ply) then
		if CLIENT then
			ply = lply
		else
			return
		end
	end

	local nomessage = hook.Run("HG_CanThoughts", ply) --ply.PlayerClassName == "Gordon" || ply.PlayerClassName == "Combine"
	if nomessage ~= nil and nomessage == false then return "" end

    if ply:GetInfoNum("hg_showthoughts", 1) == 0 then return "" end

	local org = ply.organism
	
	if not org or not org.brain then return "" end

	local pain = org.pain
	local brain = org.brain
	local temperature = org.temperature
	local blood = org.blood
	local hungry = org.hungry
	local broken_dislocated = org.just_damaged_bone and ((org.just_damaged_bone + 3 - CurTime()) < -3)

	if broken_dislocated and org.just_damaged_bone then
		org.just_damaged_bone = nil
	end
	
	local broken_notify = (org.rarm == 1) or (org.larm == 1) or (org.rleg == 1) or (org.lleg == 1)
	local dislocated_notify = (org.rarm == 0.5) or (org.larm == 0.5) or (org.rleg == 0.5) or (org.lleg == 0.5)
	local after_unconscious_notify = org.after_otrub

	if not isnumber(pain) then return "" end

	local str = ""

	local most_wanted_phraselist
	
	if temperature < 35 then
		most_wanted_phraselist = temperature > 31 and cold_phraselist or (temperature < 28 and numb_phraselist or freezing_phraselist)
	elseif temperature > 38 then
		most_wanted_phraselist = temperature < 40 and hot_phraselist or heatstroke_phraselist
	end

	if not most_wanted_phraselist and hungry and hungry > 25 and math.random(3) == 1 then
		most_wanted_phraselist = hungry > 45 and very_hungry or hungry_a_bit
	end

	if (blood < 3100) or (pain > 75) or (broken_dislocated) or (broken_notify) or (dislocated_notify) then
		if pain > 75 and (broken_dislocated) then
			most_wanted_phraselist = math.random(2) == 1 and audible_pain or (broken_notify and broken_limb or dislocated_limb)
		elseif pain > 75 then
			most_wanted_phraselist = audible_pain
		elseif broken_dislocated then
			most_wanted_phraselist = (broken_notify and broken_limb or dislocated_limb)
		end

		if pain > 100 then
			most_wanted_phraselist = sharp_pain
		end

		if not most_wanted_phraselist then
			if (broken_dislocated_notify) and (blood < 3100) then
				most_wanted_phraselist = blood < 2900 and (near_death_poetic) or (math.random(2) == 1 and (broken_notify and broken_limb or dislocated_limb) or near_death_poetic)
			--elseif(broken_dislocated_notify)then
				--most_wanted_phraselist = (broken_notify and broken_limb or dislocated_limb)
			elseif(blood < 3100)then
				most_wanted_phraselist = near_death_poetic
			end
		end
	elseif after_unconscious_notify then
		most_wanted_phraselist = after_unconscious
	elseif hg.nothing_happening(ply) then
		most_wanted_phraselist = random_phrase

		if hungry and hungry > 25 and math.random(5) == 1 then
			most_wanted_phraselist = hungry > 45 and very_hungry or hungry_a_bit
		end
	elseif hg.fearful(ply) then
		most_wanted_phraselist = ((IsAimedAt(ply) > 0.9) and is_aimed_at_phrases or (math.random(10) == 1 and fear_hurt_ironic or fear_phrases))
	end

	if brain > 0.1 then
		most_wanted_phraselist = brain < 0.2 and slight_braindamage_phraselist or braindamage_phraselist
	end
	
	if most_wanted_phraselist then
		str = most_wanted_phraselist[math.random(#most_wanted_phraselist)]

		return str
	else
		return ""
	end
end

local allowedlist_types = {
	heatvomit = heatvomit_phraselist,
}

function hg.get_phraselist(ply, type)
	if not IsValid(ply) then
		if CLIENT then
			ply = lply
		else
			return
		end
	end
	
	local nomessage = ply.PlayerClassName == "Gordon" || ply.PlayerClassName == "Combine"

	if nomessage then return "" end
    if ply:GetInfoNum("hg_showthoughts", 1) == 0 then return "" end

	local org = ply.organism	
	if not org or not org.brain then return "" end

	if not isstring(type) or not allowedlist_types[type] then return "" end

	local needed_list = allowedlist_types[type]

	local str = needed_list[math.random(#needed_list)]
	return str
end

function hg.get_status_message(ply)
	local txt = get_status_message(ply)

	return txt
end
