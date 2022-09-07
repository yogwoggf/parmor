-- Basic ballistics for a shell.
AddCSLuaFile()

---@class ShellInfo Information for a shell
---@field Type string Type of shell
---@field Weight number Weight of shell in kilograms
---@field Caliber number Caliber of shell in millimeters

---@class Shell A ballistics object for a tank shell.
---@field pos GVector Point in the map
---@field velocity GVector Current velocity
---@field info ShellInfo Shell information
---@field dead boolean If the shell is dead (hit and already sent out events)
local Shell = {}
Shell.__index = Shell

function Shell.new(origin, velocity, info)
	local self = {
		pos = origin,
		velocity = velocity,
		info = info,
		dead = false,
	}

	--self.model = ClientsideModel("models/props/pa/shells/m61_shell.mdl")

	return setmetatable(self, Shell)
end

function Shell:Simulate(dt)
	if self.dead then
		return
	end

	local filter = ents.FindByClass("parmor_*")
	local trace = util.TraceLine({
		start = self.pos,
		endpos = self.pos + self.velocity * dt,
		filter = filter,
	})

	if trace then
		--self.model:SetAngles((trace.HitPos - self.pos):Angle())

		self.pos = trace.HitPos
		local fxData = EffectData()
		fxData:SetOrigin(self.pos)
		fxData:SetAngles((trace.HitPos - self.pos):Angle() + Angle(90, 0, 0))
		util.Effect("MuzzleEffect", fxData)
		--self.model:SetPos(self.pos)
		if trace.Hit then
			-- Basic penetration calculations for now
			if IsValid(trace.Entity) then
				PArmor.SendBallisticEvent(PArmor.WorldEvents.SHELL_HIT, {pos = self.pos, info = self.info, ent = trace.Entity, tr = trace})
			else
				PArmor.SendBallisticEvent(PArmor.WorldEvents.SHELL_HIT, {pos = self.pos, info = self.info, tr = trace})
			end
			self.dead = true
			--self.model:Remove()
			ParticleEffect("shell_nopen", self.pos, trace.HitNormal:Angle())
		end
	end

	self.velocity = self.velocity - Vector(0, 0, PArmor.MetersToHU(9.8) * dt)
end

PArmor.Shell = Shell