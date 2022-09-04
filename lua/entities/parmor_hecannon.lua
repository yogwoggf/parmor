AddCSLuaFile()
DEFINE_BASECLASS("base_wire_entity")

ENT.PrintName = "HE Cannon"
ENT.WireDebugName = "HE_Cannon"

if CLIENT then return end

local MODEL = "models/props_phx/box_amraam.mdl"
util.PrecacheModel(MODEL)

function ENT:Initialize()
	BaseClass.Initialize(self)

	self:SetModel(MODEL)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.Inputs = Wire_CreateInputs(self, {"Fire", "LoadShell"})

	self:SetOverlayText("HE Cannon\nMuzzle Velocity: 350 m/s")
end

function ENT:FireCannon()
	PArmor.SpawnShell(self:GetPos() + self:GetForward() * 20, self:GetForward(), 350)
end

function ENT:TriggerInput(name, value)
	if name == "Fire" and value == 1 then
		-- Fire!!
		self:FireCannon()
	end
end

duplicator.Allow("parmor_hecannon")