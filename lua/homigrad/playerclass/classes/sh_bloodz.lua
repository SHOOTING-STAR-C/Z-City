local CLASS = player.RegClass("bloodz")

function CLASS.Off(self)
    if CLIENT then return end
end

local models = {
    "models/gang_ballas_chem/gang_ballas_chem.mdl",
    "models/gang_ballas/gang_ballas_2.mdl",
    "models/gang_ballas/gang_ballas_1.mdl"
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
    self:SetPlayerColor(Color(165, 0, 0):ToVector())
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