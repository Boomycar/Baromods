if SERVER then return end

local SSOSprite -- Making this seperate, Sprite() hates being in a table.
local SonarReplacer = {} -- all our local stuff.
local SSOconfig = {} -- Table for our save-able variables.
local firstLoad = true
SonarReplacer.Path = table.pack(...)[1] -- nicking this from Storage Icons mod
SonarReplacer.Config = SonarReplacer.Path .. "/config.json"
SonarReplacer.Variants = {
	[0] = "Off",
	[1] = "Default", 
	[2] = "oClock", 
	[3] = "oClockNumbers", 
	[4] = "Degree", 
	[5] = "DegreeSideless",
	[6] = "ImmersiveGreen",
	[7] = "ImmersiveBlue",
	[8] = "ImmersiveOrange",
	[9] = "ImmersivePurple"
}
SonarReplacer.Variants.Descriptions = {
	[0] = "Disables the mod to go back to another XML over-ride mod",
	[1] = "Barotrauma default sonar overlay", 
	[2] = "oClockRadar by Triiodine with time clock positions", 
	[3] = "oClockRadar by Triiodine with only the Numbers (by Pyrii)", 
	[4] = "DegreeRadar by Triiodine with bearings and ship side names", 
	[5] = "DegreeRadar by Triiodine with the side terms removed (by Pyrii)",
	[6] = "Immersive Sonar UI Overlay by _]|M|[_ Green/Nav Terminal variant",
	[7] = "Immersive Sonar UI Overlay by _]|M|[_ Blue/Shuttle variant",
	[8] = "Immersive Sonar UI Overlay by _]|M|[_ Orange/Monitor variant",
	[9] = "Immersive Sonar UI Overlay by _]|M|[_ Purple edit (by Pyrii)"

}
SonarReplacer.Paths = {
	[0] = "Content/Items/Command/sonarOverlay.png",
	[1] = "Content/Items/Command/sonarOverlay.png"
}
for int,variant in ipairs(SonarReplacer.Variants) do 
	if int > 1 then -- hacky method for not being able to start int at 2 in the for constructor with ipairs
		SonarReplacer.Paths[int] = SonarReplacer.Path .. "/Items/Command/sonarOverlay." .. variant .. ".png"
		SonarReplacer.Variants.maxn = int -- Might aswell get out maxn while were here since table.maxn got removed in lua 5.3
	end
end

-- Thanks to Storage Icons mod for a good example of config code. Although I only have one variable to store for now.
if File.Exists(SonarReplacer.Config) then
	local filetable = json.parse(File.Read(SonarReplacer.Config))
	if filetable.Variant != nil and filetable.Variant >= 0 and filetable.Variant <= SonarReplacer.Variants.maxn then
		SSOconfig.Variant = filetable.Variant
	else
		SSOconfig.Variant = 3 -- My favourite as a default, Yay nepotism
		File.Write(SonarReplacer.Config, json.serialize(SSOconfig))
	end
else
	SSOconfig.Variant = 3
	File.Write(SonarReplacer.Config, json.serialize(SSOconfig))
end

local function updateVariant(option)
	if option < 0 or option > SonarReplacer.Variants.maxn then option = 1 end -- Dunno how this was called with an bad option but let's default.
	if option != SSOconfig.Variant then 
		SSOconfig.Variant = option 
		File.Write(SonarReplacer.Config, json.serialize(SSOconfig))
	end
	SonarReplacer.Texture = SonarReplacer.Paths[SSOconfig.Variant]
end

updateVariant(SSOconfig.Variant)

-- I'm leaving this hellish construct here for all the problems it caused me
--[[
Hook.Patch("Barotrauma.Items.Components.Sonar", "CreateGUI", {}, 
function(instance, ptable)
	--print("Patching Sonar Construct...Fingers crossed")
	if SSOconfig.Variant > 0 then 
		if firstload then
			instance.screenOverlay.Remove()
			SSOSprite = Sprite(SonarReplacer.Texture, Vector2(0.5,0.5)) 
			firstLoad = false
		end
		if SSOSprite == nil or not SSOSprite.Loaded then
			print("[SSO] Overlay Sprite ("..type(SSOSprite)..") got murdered, remaking")
			SSOSprite = Sprite(SonarReplacer.Texture, Vector2(0.5,0.5))
		end
		instance.screenOverlay = SSOSprite
	 end
end, Hook.HookMethodType.Before)
--]]

-- My new hook after 2 days of scratching my head at ContentXElement
Hook.Patch("Barotrauma.Items.Components.Sonar", "InitProjSpecific", { 'Barotrauma.ContentXElement' }, 
function(instance, ptable)
	if SSOconfig.Variant > 0 then 
		local elements = ptable["element"]
		--parent = elements.Parent.GetAttributeString("identifier")
		--print(parent) -- Future Stuff
		for parts in elements.Elements() do
			name = string.lower(parts.Name.ToString())
			if name == "screenoverlay" then
				parts.SetAttributeValue("texture", SonarReplacer.Texture)
				return
			end
		end
	end
end, Hook.HookMethodType.Before)


-- Holy hell this is a mess.
Game.AddCommand("sonaroverlay", "Choose a sonar overlay. Use \"list\" to list options", function (args)
	if args[1] != nil then -- We're just going to ignore any extra arguments. No need to be pedantic
		local option = tonumber(args[1])
		if option == nil then
			option = -1 -- something
			local inputVariant = string.lower(args[1])
			if inputVariant == "list" then
				print("Enter 'sonaroverlay <number or name>' (case-insensitive) to choose what sonar overlay to use.")
				if Game.RoundStarted then print("Changes won't be seen till next the next round/mission.") end
				for int=0, SonarReplacer.Variants.maxn do
					print(string.format("%4i / %s\n    %s",int, SonarReplacer.Variants[int], SonarReplacer.Variants.Descriptions[int]))
				end
				return
			else
				for int=0, SonarReplacer.Variants.maxn do 
					if string.lower(SonarReplacer.Variants[int]) == inputVariant then 
						option = int
						break
					end 
				end
			end
		end
		if option >= 0 and option <= SonarReplacer.Variants.maxn then
			updateVariant(option)
			print("Sonar overlay changed to " .. SonarReplacer.Variants[option])
			if Game.RoundStarted then print("Changes won't be seen till next the next round/mission.") end
			return
		end
	end
	print("Please pick a valid option between 0 or " .. SonarReplacer.Variants.maxn .. " or type \"sonaroverlay list\" to see a list of options")
end)