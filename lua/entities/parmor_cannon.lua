AddCSLuaFile()
DEFINE_BASECLASS("base_wire_entity")

ENT.PrintName = "Cannon"
ENT.WireDebugName = "Cannon"

if CLIENT then return end

local MODEL = "models/props_phx/box_amraam.mdl"
util.PrecacheModel(MODEL)

function ENT:Initialize()
	BaseClass.Initialize(self)

	self:SetModel(MODEL)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.Inputs = WireLib.CreateSpecialInputs(self, {"Fire", "AmmoBox"}, {"NORMAL", "ENTITY"}, {"Input to fire a shell out of the cannon", "Input that should be wired to a ammunition box"})

	self:SetOverlayText("Cannon\nMuzzle Velocity: 563 m/s")
	self.AmmoBox = nil
end

function ENT:FireCannon()
	if IsValid(self.AmmoBox) then
		local shellInfo = self.AmmoBox:TakeAmmo()
		if not shellInfo then
			-- Out of ammo.
			return
		end

		PArmor.SpawnShell(self:GetPos() + self:GetForward() * 20, self:GetForward(), 563, shellInfo)
	end
end

function ENT:TriggerInput(name, value)
	if name == "AmmoBox" then
		if value:GetClass() == "parmor_ammobox" then
			self.AmmoBox = value
		end
	end

	if name == "Fire" and value == 1 then
		-- Fire!!
		self:FireCannon()
	end
end

duplicator.Allow("parmor_cannon")