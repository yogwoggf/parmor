-- Basic unguided rocket launcher
-- actual rocket is a ballistics object

AddCSLuaFile()
DEFINE_BASECLASS("base_wire_entity")

ENT.PrintName = "Rocket launcher"
ENT.WireDebugName = "Rocket_Launcher"

if CLIENT then return end

local MODEL = "models/props_phx/box_amraam.mdl"
util.PrecacheModel(MODEL)

function ENT:Initialize()
	BaseClass.Initialize(self)

	self:SetModel(MODEL)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.Inputs = Wire_CreateInputs(self, {"Fire"})

	self:SetOverlayText("Rocket Launcher\nPropellant Time: 0.5 seconds\nWarhead: 5 kg fragmentation blast")
end

function ENT:FireRocket()
	PArmor.SpawnRocket(self:GetPos() + self:GetForward() * 80, self:GetForward(), 0.5)
end

function ENT:TriggerInput(name, value)
	if name == "Fire" and value == 1 then
		-- Fire!!
		self:FireRocket()
	end
end

duplicator.Allow("parmor_rocket")