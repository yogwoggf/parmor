-- Basic ballistics for a dumb-fire rocket
AddCSLuaFile()

---@class Rocket A ballistics object for a tank Rocket.
---@field pos GVector Point in the map
---@field velocity GVector Current velocity
---@field propellantTime number Seconds left of propellant
---@field dead boolean If the Rocket is dead (hit and already sent out events)

local Rocket = {}
Rocket.__index = Rocket

function Rocket.new(origin, direction, propellantLength)
	local self = {
		pos = origin,
		velocity = Vector(0, 0, 0),
		dir = direction,
		dead = false,

		propellantTime = propellantLength 
	}

	--self.model = ClientsideModel("models/props/pa/Rockets/m61_Rocket.mdl")

	return setmetatable(self, Rocket)
end

function Rocket:Simulate(dt)
	if self.dead then
		return
	end

	local filter = ents.FindByClass("parmor_*")
	local trace = util.TraceLine({
		start = self.pos,
		endpos = self.pos + self.velocity * dt,
		filter = filter,
	})

	self.propellantTime = self.propellantTime - dt
	if self.propellantTime > 0 then
		self.velocity = self.velocity + self.dir * PArmor.MetersToHU(250) * dt
	end
	
	if trace then
		self.pos = trace.HitPos
		
		local fxData = EffectData()
		fxData:SetOrigin(self.pos)
		fxData:SetAngles((trace.HitPos - self.pos):Angle() + Angle(90, 0, 0))
		util.Effect("MuzzleEffect", fxData)
		
		if trace.Hit then
			PArmor.SendBallisticEvent(PArmor.WorldEvents.ROCKET_EXPLODE, {pos = self.pos})
			self.dead = true
			--self.model:Remove()
			ParticleEffect("explosion_huge", self.pos, trace.HitNormal:Angle())
		end
	end

	self.velocity = self.velocity - Vector(0, 0, PArmor.MetersToHU(9.8) * dt)
end

PArmor.Rocket = Rocket