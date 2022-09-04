-- Ballistic event for the rocket
local FRAGMENTATION_COUNT = 55
PArmor.RegisterBallisticEvent(PArmor.WorldEvents.ROCKET_EXPLODE, function(data)
	util.BlastDamage(game.GetWorld(), game.GetWorld(), data.pos, PArmor.MetersToHU(15), 80)

	---@type table<number, GEntity>
	local propsNear = ents.FindInSphere(data.pos, PArmor.MetersToHU(15))

	for _, ent in pairs(propsNear) do
		local physObj = ent:GetPhysicsObject()
		ent:Ignite(15, 1)
		if IsValid(physObj) then
			physObj:EnableMotion(true)
			constraint.RemoveAll(ent)
			
			local randomDir = VectorRand(-0.1, 0.1)
			local direction = (ent:GetPos() - data.pos + randomDir):GetNormalized()
			local force = direction * PArmor.MetersToHU(1100) -- Force of a shock front hitting the object (shock front velocity is at 1100 m/s)

			physObj:ApplyForceCenter(force)
			physObj:AddAngleVelocity(VectorRand(-100, 100))
		end
	end

	for i = 1, FRAGMENTATION_COUNT do
		local frag = ents.Create("prop_physics")
		frag:SetPos(data.pos + VectorRand(-9, 9) + Vector(0, 0, 5))
		frag:SetAngles(AngleRand(0, 360))
		frag:SetModel("models/hunter/plates/plate125.mdl")
		frag:SetMaterial("phoenix_storms/cube")
		frag:Spawn()
		frag:Activate()

		frag:Ignite(15, 0.1)
		local physObj = frag:GetPhysicsObject()
		if IsValid(physObj) then
			local dir = (frag:GetPos() - data.pos):GetNormalized()
			local force = dir * PArmor.MetersToHU(1300) -- Slightly higher for more ripping and shearing

			physObj:SetDragCoefficient(0.08)
			physObj:ApplyForceCenter(force)
			physObj:AddGameFlag(FVPHYSICS_HEAVY_OBJECT)
			physObj:SetMass(0.75) -- 0.75kg
		end

		SafeRemoveEntityDelayed(frag, 15)
	end
end)