AddCSLuaFile()

PArmor = PArmor or {}
--- Contains all of the virtual ballistics
PArmor.World = {}
PArmor.WorldEvents = {
	SHELL_PEN = 0,
	SHELL_HIT = 1,
	SHELL_RICOCHET = 2,

	ROCKET_EXPLODE = 3,
}
PArmor.WorldEventsCallback = {}

function PArmor.RegisterBallisticEvent(eventTarget, cb)
	table.insert(PArmor.WorldEventsCallback, {ev = eventTarget, cb = cb})
end

function PArmor.SendBallisticEvent(type, data)
	data = data or {}

	for _, eventData in pairs(PArmor.WorldEventsCallback) do
		if eventData.ev == type then
			eventData.cb(data)
		end
	end
end

function PArmor.MetersToHU(meter)
	return (meter / 0.75) / 0.0254
end

function PArmor.HUToMeters(hu)
	return (hu * 0.75) * 0.0254 -- Entity to architectural scale
end

include("ballistics/shell.lua")
function PArmor.SpawnShell(origin, dir, vel, info)
	local shell = PArmor.Shell.new(origin, dir * PArmor.MetersToHU(vel), info)
	PArmor.World[#PArmor.World+1] = shell
end

include("ballistics/rocket.lua")
function PArmor.SpawnRocket(origin, dir, propellantLength)
	local rocket = PArmor.Rocket.new(origin, dir, propellantLength)
	PArmor.World[#PArmor.World+1] = rocket
end

-- Ballistic events
if SERVER then
	include("he_shell.lua")
	include("rocket.lua")
	include("ap_shell.lua")
end

local lastTime = os.clock()
hook.Add("Think", "PArmor.BallisticsUpdate", function()
	local dt = os.clock() - lastTime
	lastTime = os.clock()

	for idx, object in pairs(PArmor.World) do
		object:Simulate(dt)
		debugoverlay.Sphere(object.pos, 3, 0.05, color_white, true)
		if object.dead then
			PArmor.World[idx] = nil
		end
	end
end)
