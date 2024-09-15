if SERVER then return end -- we don't want server to run GUI code.

LuaUserData.MakeFieldAccessible(Descriptors["Barotrauma.Items.Components.Controller"], "targetRotation")

-- our main frame where we will put our custom GUI
local frame = GUI.Frame(GUI.RectTransform(Vector2(1, 1)), nil)
frame.CanBeFocused = false

local textBlock = GUI.TextBlock(GUI.RectTransform(Vector2(0.5, 0.045), frame.RectTransform, GUI.Anchor.BottomCenter), "Aiming at: 0°", nil, nil, GUI.Alignment.Center)
textBlock.TextColor = Color(0, 0, 0, 255)
local function normalizeRotation(degrees)
    return (degrees % 360 + 360) % 360
 end
Hook.Patch("Barotrauma.GameScreen", "AddToGUIUpdateList", function()
    if Character.Controlled and not Character.Controlled.IsDead then
        local periscope = Character.Controlled.SelectedItem
        if periscope and periscope.Prefab.Identifier == "periscope" then
            local controller = periscope.GetComponentString("Controller")

            local rotation = controller.targetRotation
            rotation = math.deg(rotation)
            rotation = math.floor(rotation) -- convert from radians to degrees
            rotation = normalizeRotation(rotation + 90)
            textBlock.Text = "Aiming at: " .. rotation .. "°",

            frame.AddToGUIUpdateList()
        end
    end
end)