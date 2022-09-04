TOOL.Category = "PArmor"
TOOL.Name = "Menu"
TOOL.Command = nil
TOOL.Tab = "PArmor"

if CLIENT then
	language.Add("Tool.parmor_menu.name", "PArmor Tool")
	language.Add("Tool.parmor_menu.desc", "Spawns any PArmor equipment")
	language.Add("Tool.parmor_menu.left", "Spawn equipment")

	TOOL.Information = {"left"}
end

TOOL.ClientConVar["spawn_class"] = ""

function TOOL:LeftClick(trace)
	if CLIENT then
		return
	end

	local posToSpawn = trace.HitPos + trace.HitNormal * 20
	local class = self:GetClientInfo("spawn_class")

	if class:sub(1, #("parmor")) ~= "parmor" then
		-- Dont spawn it.
		return
	end

	local ent = ents.Create(class)
	if not ent then
		return
	end

	ent:SetPos(posToSpawn)
	ent:SetAngles(Angle())
	ent:Spawn()
	ent:Activate()

	undo.Create("PArmor Spawn")
		undo.AddEntity(ent)
		undo.SetPlayer(self:GetOwner())
	undo.Finish()
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", {
		Text = "#Tool.parmor_menu.name",
		Description = "#TOOL.parmor_menu.desc",
	})

	---@type GPanel
	local listView = vgui.Create("DListView")
	listView:AddColumn("Equipment")
	listView:SetMinimumSize(300, 400)

	for _, info in pairs(scripted_ents.GetList()) do
		if info.t.ClassName:sub(1, #("parmor")) == "parmor" then
			listView:AddLine(info.t.ClassName)
		end
	end

	listView.OnRowSelected = function(_, _a, panel)
		GetConVar("parmor_menu_spawn_class"):SetString(panel:GetColumnText(1))
	end

	panel:AddItem(listView)
end