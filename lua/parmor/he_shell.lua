-- Ballistic event for the HE shell

PArmor.RegisterBallisticEvent(PArmor.WorldEvents.SHELL_HIT, function(data)
	if data.type == "he" then
		local fxData = EffectData()
		fxData:SetOrigin(data.pos)
		
		util.Effect("Explosion", fxData)

		util.BlastDamage(game.GetWorld(), game.GetWorld(), data.pos, PArmor.MetersToHU(2), 45)

		---@type table<number, GEntity>
		local propsNear = ents.FindInSphere(data.pos, PArmor.MetersToHU(2))

		for _, ent in pairs(propsNear) do
			local physObj = ent:GetPhysicsObject()

			if IsValid(physObj) then
				physObj:EnableMotion(true)
				constraint.RemoveAll(ent)

				local direction = (ent:GetPos() - data.pos):GetNormalized()
				local force = direction * PArmor.MetersToHU(300) --Force of a shock front hitting the object (shock front velocity is at 300 m/s)

				physObj:ApplyForceOffset(force, ent:GetPos() + VectorRand(-1, 1))
			end
		end
	end
end)