-- Armor piercing shell ballistics

local SPACE_AMOUNT = 2 -- 48 HUs
local EPSILON = Vector(0.001, 0.001, 0.001)

local function estimateDepth(tr)
    -- Algorithm:
    -- 1. Initialize the start point (SP)
    -- 2. From the SP, loop and terminate if a point evenly spaced to the rest is outside of the medium.
    -- 3. Return the distance of SP and the last point before it went outside.
    
    local sp = tr.HitPos
    local lastPoint = sp
    local traces = 0
    for i = 1, 500 do
        -- Limit of 500
        local newPoint = sp + tr.Normal * (SPACE_AMOUNT * i)
        local trace = util.TraceLine({
			start = newPoint,
			endpos = newPoint + EPSILON,
		})

        traces = traces + 1
        
        if (not trace.Hit) or trace.HitWorld then
            -- We've found the point!
            local pointToUse = (lastPoint + newPoint) / 2
            return pointToUse:Distance(sp), traces      
        end
        
        lastPoint = newPoint
    end
    
    return nil
end

-- Penetration formula
local RHA_TENSILE_STRENGTH = 1170 -- MPa
local SPALLING_AMOUNT = 15

local function calculatePen(strikingVelocity, mass, diameter)
	-- This is the Patel-Gillingham formula for shear plug penetration
	-- IDA Paper P-5032: Method of Estimating the Principal Characteristics of an Infantry Fighting Vehicle from Basic Performance Requirements
	local numerator = mass * strikingVelocity ^ 2
	local denominator = 0.7 * RHA_TENSILE_STRENGTH * math.pi * diameter

	return math.sqrt((numerator / denominator))
end

PArmor.RegisterBallisticEvent(PArmor.WorldEvents.SHELL_HIT, function(data)
	if data.info.Type == "AP" then
		local tr = data.tr

		if tr.Hit and not tr.HitWorld then
			-- Stats from the amazing 75mm M61 shell
			local velocity = 563
			local weight = data.info.Weight
			local diameter = data.info.Caliber / 1000 -- Convert this into meters

			local maxPen = calculatePen(velocity, weight, diameter)
			local totalDepth = estimateDepth(tr)
			local mmDepth = PArmor.HUToMeters(totalDepth) * 1000

			print(("Penetration at 0 degrees: %.1fmm\nDepth at angle: %.1fmm\nHammer unit depth: %1.fhu\nWeight: %.2fkg\nDiameter: %.2fmm"):format(maxPen, mmDepth, totalDepth, weight, diameter))
			if mmDepth < maxPen then
				local inside = tr.HitPos + tr.Normal * (totalDepth + 5)

				local fxData = EffectData()
				fxData:SetOrigin(tr.HitPos + tr.Normal * totalDepth)
				util.Effect("Explosion", fxData)

				for i = 1, SPALLING_AMOUNT do
					---@type GEntity
					local ent = ents.Create("prop_physics")
					ent:SetModel("models/hunter/plates/plate.mdl")
					ent:SetPos(inside + VectorRand(-0.05, 0.05))
					ent:SetAngles(AngleRand(0, 360))
					ent:Spawn()
					ent:Ignite(5, 3)

					util.SpriteTrail(ent, 0, Color(100, 100, 100, 255), false, 1, 0, 0.1, 1 / (1 + 0) * 0.5, "trails/smoke")

					local physObj = ent:GetPhysicsObject()

					if IsValid(physObj) then
						local magnitude = PArmor.MetersToHU(velocity * 2) * physObj:GetMass()
						local direction = (tr.Normal + VectorRand(-0.05, 0.05)):GetNormalized()

						local impulse = direction * magnitude * engine.TickInterval()

						physObj:ApplyForceCenter(impulse)
						physObj:AddGameFlag(FVPHYSICS_DMG_SLICE)
						physObj:AddGameFlag(FVPHYSICS_HEAVY_OBJECT)
					end

					SafeRemoveEntityDelayed(ent, 10)
				end
			end
		end
	end
end)