AddCSLuaFile()
DEFINE_BASECLASS("base_wire_entity")

ENT.PrintName = "Ammunition Box"
ENT.WireDebugName = "AmmoBox"

local MODEL = "models/hunter/blocks/cube1x150x1.mdl"

if CLIENT then return end

function ENT:Initialize()
	self:SetModel(MODEL)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.AmmoDescription = self.AmmoDescription or {
		Type = "AP",
		Caliber = 75,
		Weight = 6.63,
	}

	self.AmmoCount = self.AmmoCount or 100

	self:UpdateWeight()
	self:UpdateOverlay()
end

function ENT:UpdateWeight()
	local physObj = self:GetPhysicsObject()

	if IsValid(physObj) then
		physObj:SetMass(self.AmmoCount * self.AmmoDescription.Weight)
	end
end

function ENT:UpdateOverlay()
	local mass = 0
	local physObj = self:GetPhysicsObject()

	if IsValid(physObj) then
		mass = physObj:GetMass()
	end

	self:SetOverlayText(("Ammunition Box\nType: %s\nCaliber: %dmm\nWeight: %.2fkg\nAmount left: %d\nTotal Weight: %dkg"):format(
		self.AmmoDescription.Type, self.AmmoDescription.Caliber, 
		self.AmmoDescription.Weight, self.AmmoCount,
		mass
	))
end

function ENT:TakeAmmo()
	if self.AmmoCount > 0 then
		self.AmmoCount = self.AmmoCount - 1
		self:UpdateWeight()
		self:UpdateOverlay()

		return self.AmmoDescription
	end

	return nil
end