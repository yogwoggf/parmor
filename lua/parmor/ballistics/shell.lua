-- Basic ballistics for a shell.
AddCSLuaFile()

---@class Shell A ballistics object for a tank shell.
---@field pos GVector Point in the map
---@field velocity GVector Current velocity
---@field type string Type of shell
---@field dead boolean If the shell is dead (hit and already sent out events)
local Shell = {}
Shell.__index = Shell

function Shell.new(origin, velocity, type)
	local self = {
		pos = origin,
		velocity = velocity,
		type = type,
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
				PArmor.SendBallisticEvent(PArmor.WorldEvents.SHELL_HIT, {pos = self.pos, type = self.type, ent = trace.Entity})
			else
				PArmor.SendBallisticEvent(PArmor.WorldEvents.SHELL_HIT, {pos = self.pos, type = self.type})
			end
			self.dead = true
			--self.model:Remove()
			ParticleEffect("shell_nopen", self.pos, trace.HitNormal:Angle())
		end
	end

	self.velocity = self.velocity - Vector(0, 0, PArmor.MetersToHU(9.8) * dt)
end

PArmor.Shell = Shell