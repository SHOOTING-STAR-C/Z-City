local CLASS = player.RegClass("groove")

function CLASS.Off(self)
    if CLIENT then return end
end

local models = {
    "models/gang_groove/gang_1.mdl",
    "models/gang_groove/gang_2.mdl",
    "models/gang_chem/gang_groove_chem.mdl"
}

local subnames = {
	"Big ",
	"Lil ",
	"OG "
}

function CLASS.On(self)
    if CLIENT then return end
    local name = hg.Appearance.GenerateRandomName(math.random(1, 2))
    self:SetNWString("PlayerName", subnames[math.random(#subnames)] .. name)
    self:SetPlayerColor(Color(0, 165, 0):ToVector())
    self:SetModel(models[math.random(#models)])
    self:SetNetVar("Accessories", "")
    for _, bg in ipairs(self:GetBodyGroups()) do
        self:SetBodygroup(bg.id, math.random(0, bg.num))
    end

    local inv = self:GetNetVar("Inventory", {})
    inv["Weapons"] = inv["Weapons"] or {}
    inv["Weapons"]["hg_sling"] = true
    self:SetNetVar("Inventory", inv)

    self:SetSubMaterial()
end