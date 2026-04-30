include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:Initialize()
	self.HudHintMarkup = markup.Parse("<font=ZCity_Tiny>手雷\n<colour=200,0,0>快跑!</colour></font>",450)
end