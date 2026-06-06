
	local allowedchars = {
		"ah",
		"AH",
		"ghh",
		"GH",
		"AHHH",
	}

	local audible_pain = {
		"啊……操……疼死了……",
		"我受不了了！！",
	    "让它停下、让它停下、让它停下",
	    "为什么不消停",
	    "让我晕过去吧。求你了。",
	    "我为什么要遭这种罪……",
	    "我愿意做任何事让它停下……任何事。",
	    "这不是活着，是在受折磨。",
	    "我什么都不在乎了，只要别再疼了。",
	    "什么都不重要了……让它停下就好……",
	    "每一秒都像在烈火里烧。",
	    "现在死掉反而是一种解脱……",
	    "哪怕只有一秒钟不疼……",
		"现在要是有止痛药多好。操。",
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
		"这地方有点冷……",
		"一切都安静得过头了……",
		"呼吸现在出奇地顺畅。",
		"要是这安静永远持续下去呢？",
		"为什么什么都没发生？",
	}

	local fear_hurt_ironic = {
		"这里头肯定有教训……如果我活下来的话。",
		"我未来的传记作者肯定不会信这段。",
		"好吧，这可真是蠢到家了的死法。",
		"至少我这辈子不无聊。",
		"记住了：下不为例。",
		"这不是最糟糕的死亡之日。",
	}

	local fear_phrases = {
		"没那么糟……对吧？",
		"我不想这样死去。",
		"这真的是结局吗？",
		"不太妙。",
		"这真的是结局吗？",
		"我不想这样死去。",
		"我希望有出路。",
		"我有好多事都后悔了。",
		"不可能就这么完了。",
		"我不敢相信这事落我头上了。",
		"我该认真对待这件事的。",
		"要是我没撑过去呢……？",
		"这比我想象的还要糟。",
		"这太不公平了。",
		"我还不能放弃。",
		"我从没想过会这样。",
		"早该听直觉的。",
		"呼吸。只管呼吸。",
		"手是冷的。手要稳。",
	}

	local is_aimed_at_phrases = {
	    "老天。就是现在了。",
	    "别。动。",
	    "我真的要这么死了吗？",
	    "我应该跑的。为什么我没跑？",
	    "请不要扣动扳机。求你了。",
	    "我能看见他的手指扣在扳机上。",
	    "我不想死。不想以这种方式。",
	    "如果我求饶，会让情况更糟吗？",
	    "这不可能是真的。这不可能。",
	    "谁来救救我。求你了。有人吗。",
	    "我不想死在这样的地方。",
	    "我不想临死前脑子里全是恐惧。",
	    "我不想死。",
	}

	local near_death_poetic = {
		"想站起来……但就是做不到……",
		"呼吸只是在浅浅地啜饮虚空……",
		"分不清眼睛是睁着还是闭着……",
		"最后尝到的会是我自己的血和铜腥味。",
		"视线老是从东西上滑开。",
		"不记得怎么站着了。",
		"一切都在脑壳里回响。",
		"眨完眼要好半天才回过神来。",
		"手指握不住任何东西。",
		"肺不肯吸进气。",
		"现在后悔毫无意义。",
	}

	local near_death_positive = {
		"我不想死。",
		"我必须活下来。",
		"还有机会。",
		"不能让恐惧赢了。",
		"再试一次。",
		"我拒绝死在这里。",
		"好吧……仔细想想。",
		"别动。乱动只会更糟。",
		"慢慢呼吸。慌了也没用。",
		"直到结束才算结束。",
		"疼痛只是信号。别理它。",
		"如果这就是结局……至少会很快。",
		"我经历过更糟的。大概。",
		"这不是我想象的那样。",
	}

	local broken_limb = {
		"操。操。肯定断了！",
		"我能感觉到骨头碎片在动！",
		"操他妈的断了。我觉得……",
		"光是想想就疼。肯定断了。",
		"这地方不应该弯的。",
		"哦操。它断了。",
		"没看到开放骨折，但肯定有什么断了。",
	}

	local dislocated_limb = {
		"对，不该那么弯的。",
		"得把这骨头掰回去。",
		"不……得把它复位。",
		"那地方疼得不行。得看看。",
		"我脱臼了。",
	}

	local hungry_a_bit = {
	    "嗯，有点饿了……",
	    "来点吃的就好了……",
	    "饿了……",
	    "得吃点东西了。",
	}

	local very_hungry = {
	    "胃……呃……",
	    "再不吃东西，只会更难受……",
	    "胃……妈的……有点想吐",
	}

	local after_unconscious = {
	    "发生了什么？好疼……",
		"我在哪？为什么这么疼……",
		"我……我以为自己要死了……",
		"头……发生什么了？",
		"我刚才差点死了？",
		"感觉跟死了一回似的。",
		"老天没收我？",
		"哦操……头好疼……",
		"现在想站起来很难……但必须起来……",
		"完全认不出这地方……还是其实我认识？",
		"我再也不想经历这个了！",
	}

	local slight_braindamage_phraselist = {
		"我不明白……",
		"这说不通……",
		"我在哪里？",
		"嗯？这是什么……？",
		"不知道发生了什么……",
		"有人吗？",
		"呃……哦……      嗯……",
		"什么……发生了什么？",
	}

	local braindamage_phraselist = {
		"博……威……嗯？！",
		"嗯……嗯……",
		"嗯--嗯。嗯？",
		"嗯……嗯……",
		"啊……嗯？",
		"嗯……嗯-嗯。",
		"嗯……嗯！",
		"救……命……",
		"嗯……嗯？",
		"嗯……嗯..",
		"嗯……嗯。",
	}

	local cold_phraselist = {
		"越来越冷了……",
		"对我来说太冷了。",
		"冻得发抖，操。",
		"外面冷得要命……",
		"得找东西取暖……",
		"冷得不行……",
		"冷得我想吐，操。"
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
		"一身都是汗……",
		"热得不行了……",
		"衣服都被汗水浸透了，操。",
		"汗臭得要命。真得凉快一下……",
		"有点太热了，操。",
		"真的热得受不了……",
		"这里为什么这么热？",
	}

	local heatstroke_phraselist = {
		"我需要水！！",
		"求你了……水……",
		"头晕……操——",
		"我的头！……好痛……",
		"头像要炸了……",
	}

	local heatvomit_phraselist = {
		"太热了……要吐了——",
		"呃……要吐了——",
		"操……呃……快不——"
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
