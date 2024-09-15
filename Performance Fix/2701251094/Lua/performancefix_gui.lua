-- I'm sorry for the eyes of anyone looking at the GUI code.

local MultiLineTextBox = dofile(PerformanceFix.Path .. "/Lua/MultiLineTextBox.lua")
local easySettings = dofile(PerformanceFix.Path .. "/Lua/easysettings.lua")

Game.AddCommand("performancefix", "opens performance fix gui", function ()
    PerformanceFix.ToggleGUI()
end)

local GUIComponent = LuaUserData.CreateStatic("Barotrauma.GUIComponent")

local function CommaStringToTable(str)
    local tbl = {}

    for word in string.gmatch(str, '([^,]+)') do
        table.insert(tbl, word)
    end

    return tbl
end

local function ClearElements(guicomponent, removeItself)
    local toRemove = {}

    for value in guicomponent.GetAllChildren() do
        table.insert(toRemove, value)
    end

    for index, value in pairs(toRemove) do
        value.RemoveChild(value)
    end

    if guicomponent.Parent and removeItself then
        guicomponent.Parent.RemoveChild(guicomponent)
    end
end

local function GetAmountOfPrefab(prefabs)
    local amount = 0
    for key, value in prefabs do
        amount = amount + 1
    end

    return amount
end

Hook.Add("stop", "PerformanceFix.CleanupGUI", function ()
    if selectedGUIText then
        selectedGUIText.Parent.RemoveChild(selectedGUIText)
    end

    if PerformanceFix.GUIFrame then
        ClearElements(PerformanceFix.GUIFrame, true)
    end
end)

PerformanceFix.ShowGUI = function (frame)
    PerformanceFix.GUIFrame = frame

    local config = easySettings.BasicList(frame)

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "Active Items: " .. tostring(#Item.ItemList), nil, nil)

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "Active Characters: " .. tostring(#Character.CharacterList), nil, nil)

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "Active Walls: " .. tostring(#Structure.WallList), nil, nil)

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "Active Submarines: " .. tostring(#Submarine.Loaded), nil, nil)

    local shadowCastingLights = 0
    local drawBehindSubLights = 0
    for key, value in pairs(Item.ItemList) do
        local light = value.GetComponentString("LightComponent")

        if light and light.IsOn then
            if light.CastShadows then shadowCastingLights = shadowCastingLights + 1 end
            if light.DrawBehindSubs then drawBehindSubLights = drawBehindSubLights + 1 end
        end
    end

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "Draw Behind Sub Lights: " .. tostring(shadowCastingLights), nil, nil)

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "Shadow Casting Lights: " .. tostring(drawBehindSubLights), nil, nil)

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "", nil, nil)

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "Item Prefabs Loaded: " .. tostring(GetAmountOfPrefab(ItemPrefab.Prefabs)), nil, nil)

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "Character Prefabs Loaded: " .. tostring(GetAmountOfPrefab(CharacterPrefab.Prefabs)), nil, nil)


    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "Submarines Loaded In Memory: " .. tostring(#SubmarineInfo.SavedSubmarines), nil, nil)


    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.1), config.Content.RectTransform), "Performance Fix Config", nil, nil, GUI.Alignment.Center)

    local btn = GUI.Button(GUI.RectTransform(Vector2(1, 0.2), config.Content.RectTransform), "Save Config and Reload Client-Side Performance Fix", GUI.Alignment.Center, "GUIButtonSmall")
    btn.OnClicked = function ()
        File.Write(PerformanceFix.Path .. "/config.json", json.serialize(PerformanceFix.Config))

        dofile(PerformanceFix.Path .. "/Lua/performancefix.lua")
    end

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.1), config.Content.RectTransform), "Note: Server configurations require you to either restart or use the command reloadlua to change it. For dedicated servers you need to edit the file config.json, this GUI wont work.", nil, nil, GUI.Alignment.Center, true)

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "Timing Accumulator Max", nil, nil, GUI.Alignment.Center, true)

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.1), config.Content.RectTransform), "Lower values of Timing Accumulator Max means the game will more aggressively skip ticks, thus it can improve performance when your game is running really slowly. The games default is 250.", nil, nil, GUI.Alignment.Center, true)

    local accumulatorMax = GUI.NumberInput(GUI.RectTransform(Vector2(1, 0.1), config.Content.RectTransform), NumberType.Int)

    accumulatorMax.MinValueInt = 1
    accumulatorMax.MaxValueInt = 1000
    accumulatorMax.valueStep = 10

    if PerformanceFix.Config.accumulatorMax == nil then
        accumulatorMax.IntValue = 250
    else
        accumulatorMax.IntValue = PerformanceFix.Config.accumulatorMax
    end

    accumulatorMax.OnValueChanged = function ()
        PerformanceFix.Config.accumulatorMax = accumulatorMax.IntValue
    end


    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "Client Map Entity Interval", nil, nil, GUI.Alignment.Center, true)

    local clientMapEntityUpdateInterval = GUI.NumberInput(GUI.RectTransform(Vector2(1, 0.1), config.Content.RectTransform), NumberType.Int)

    clientMapEntityUpdateInterval.MinValueInt = 1
    clientMapEntityUpdateInterval.MaxValueInt = 60

    clientMapEntityUpdateInterval.IntValue = PerformanceFix.Config.clientMapEntityUpdateInterval
    
    clientMapEntityUpdateInterval.OnValueChanged = function ()
        PerformanceFix.Config.clientMapEntityUpdateInterval = clientMapEntityUpdateInterval.IntValue
    end

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "Server Map Entity Interval", nil, nil, GUI.Alignment.Center, true)

    local serverMapEntityUpdateInterval = GUI.NumberInput(GUI.RectTransform(Vector2(1, 0.1), config.Content.RectTransform), NumberType.Int)

    serverMapEntityUpdateInterval.MinValueInt = 1
    serverMapEntityUpdateInterval.MaxValueInt = 60

    serverMapEntityUpdateInterval.IntValue = PerformanceFix.Config.serverMapEntityUpdateInterval
    
    serverMapEntityUpdateInterval.OnValueChanged = function ()
        PerformanceFix.Config.serverMapEntityUpdateInterval = serverMapEntityUpdateInterval.IntValue
    end

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "Powered Update Interval (Client-Side only and only works on multiplayer)", nil, nil, GUI.Alignment.Center, true)

    local poweredUpdateInterval = GUI.NumberInput(GUI.RectTransform(Vector2(1, 0.1), config.Content.RectTransform), NumberType.Int)

    poweredUpdateInterval.MinValueInt = 1
    poweredUpdateInterval.MaxValueInt = 60

    poweredUpdateInterval.IntValue = PerformanceFix.Config.poweredUpdateInterval or 1
    
    poweredUpdateInterval.OnValueChanged = function ()
        PerformanceFix.Config.poweredUpdateInterval = poweredUpdateInterval.IntValue
    end


    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "Client High Priority Items", nil, nil, GUI.Alignment.Center, true)

    local clientHighPriorityItems = MultiLineTextBox(config.Content.RectTransform, "", 0.2)

    clientHighPriorityItems.Text = table.concat(PerformanceFix.Config.clientItemHighPriority, ",")

    clientHighPriorityItems.OnTextChangedDelegate = function (textBox)
        PerformanceFix.Config.clientItemHighPriority = CommaStringToTable(textBox.Text)
    end

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "Server High Priority Items", nil, nil, GUI.Alignment.Center, true)

    local serverHighPriorityItems = MultiLineTextBox(config.Content.RectTransform, "", 0.2)

    serverHighPriorityItems.Text = table.concat(PerformanceFix.Config.serverItemHighPriority, ",")

    serverHighPriorityItems.OnTextChangedDelegate = function (textBox)
        PerformanceFix.Config.serverItemHighPriority = CommaStringToTable(textBox.Text)
    end

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "Client High Priority Components", nil, nil, GUI.Alignment.Center, true)

    local clientHighPriorityComponents = MultiLineTextBox(config.Content.RectTransform, "", 0.2)

    clientHighPriorityComponents.Text = table.concat(PerformanceFix.Config.clientComponentPriority, ",")

    clientHighPriorityComponents.OnTextChangedDelegate = function (textBox)
        PerformanceFix.Config.clientComponentPriority = CommaStringToTable(textBox.Text)
    end

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "Server High Priority Components", nil, nil, GUI.Alignment.Center, true)

    local serverHighPriorityComponents = MultiLineTextBox(config.Content.RectTransform, "", 0.2)

    serverHighPriorityComponents.Text = table.concat(PerformanceFix.Config.serverComponentPriority, ",")

    serverHighPriorityComponents.OnTextChangedDelegate = function (textBox)
        PerformanceFix.Config.serverComponentPriority = CommaStringToTable(textBox.Text)
    end

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.1), config.Content.RectTransform), "Character Update Config (Extra Experimental)", nil, nil, GUI.Alignment.Center, true)

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "Client Character Update Interval", nil, nil, GUI.Alignment.Center, true)
    
    local clientCharacterUpdateInterval = GUI.NumberInput(GUI.RectTransform(Vector2(1, 0.1), config.Content.RectTransform), NumberType.Int)

    clientCharacterUpdateInterval.MinValueInt = 1
    clientCharacterUpdateInterval.MaxValueInt = 60

    clientCharacterUpdateInterval.IntValue = PerformanceFix.Config.clientCharacterUpdateInterval
    
    clientCharacterUpdateInterval.OnValueChanged = function ()
        PerformanceFix.Config.clientCharacterUpdateInterval = clientCharacterUpdateInterval.IntValue
    end


    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "Server Character Update Interval", nil, nil, GUI.Alignment.Center, true)

    local serverCharacterUpdateInterval = GUI.NumberInput(GUI.RectTransform(Vector2(1, 0.1), config.Content.RectTransform), NumberType.Int)

    serverCharacterUpdateInterval.MinValueInt = 1
    serverCharacterUpdateInterval.MaxValueInt = 60

    serverCharacterUpdateInterval.IntValue = PerformanceFix.Config.serverCharacterUpdateInterval

    serverCharacterUpdateInterval.OnValueChanged = function ()
        PerformanceFix.Config.serverCharacterUpdateInterval = serverCharacterUpdateInterval.IntValue
    end


    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.05), config.Content.RectTransform), "High Priority Characters", nil, nil, GUI.Alignment.Center, true)

    local highPriorityCharacters = MultiLineTextBox(config.Content.RectTransform, "", 0.2)

    highPriorityCharacters.Text = table.concat(PerformanceFix.Config.highPriorityCharacters, ",")

    highPriorityCharacters.OnTextChangedDelegate = function (textBox)
        PerformanceFix.Config.highPriorityCharacters = CommaStringToTable(textBox.Text)
    end

    GUI.TextBlock(GUI.RectTransform(Vector2(1, 0.1), config.Content.RectTransform), "WARNING: THE BELOW CONFIGS ARE PERMANENT FOR SINGLEPLAYER AND IN MULTIPLAYER ARE REVERSIBLE BY RESTARTING THE ROUND.", nil, nil, GUI.Alignment.Center, true)


    local singleplayerPermanent = GUI.TickBox(GUI.RectTransform(Vector2(1, 0.2), config.Content.RectTransform), "Allow Permanent Configs In Singleplayer")

    singleplayerPermanent.Selected = PerformanceFix.Config.allowSingleplayerPermanentConfigs or false

    singleplayerPermanent.OnSelected = function ()
        PerformanceFix.Config.allowSingleplayerPermanentConfigs = singleplayerPermanent.State == GUIComponent.ComponentState.Selected
    end


    local shadowCasting = GUI.TickBox(GUI.RectTransform(Vector2(1, 0.2), config.Content.RectTransform), "Disable Shadow Casting Lights")

    shadowCasting.Selected = PerformanceFix.Config.disableShadowCastingLights

    shadowCasting.OnSelected = function ()
        PerformanceFix.Config.disableShadowCastingLights = shadowCasting.State == GUIComponent.ComponentState.Selected
    end

    local drawBehindSub = GUI.TickBox(GUI.RectTransform(Vector2(1, 0.2), config.Content.RectTransform), "Disable Draw Behind Subs Lights")

    drawBehindSub.Selected = PerformanceFix.Config.disableDrawBehindSubsLights

    drawBehindSub.OnSelected = function ()
        PerformanceFix.Config.disableDrawBehindSubsLights = drawBehindSub.State == GUIComponent.ComponentState.Selected
    end

    local hideInGameWires = GUI.TickBox(GUI.RectTransform(Vector2(1, 0.2), config.Content.RectTransform), "Hide In Game Wires")

    hideInGameWires.Selected = PerformanceFix.Config.hideInGameWires

    hideInGameWires.OnSelected = function ()
        PerformanceFix.Config.hideInGameWires = hideInGameWires.State == GUIComponent.ComponentState.Selected
    end

    local hideInGameComponents = GUI.TickBox(GUI.RectTransform(Vector2(1, 0.2), config.Content.RectTransform), "Hide In Game Components")

    hideInGameComponents.Selected = PerformanceFix.Config.hideInGameComponents

    hideInGameComponents.OnSelected = function ()
        PerformanceFix.Config.hideInGameComponents = hideInGameComponents.State == GUIComponent.ComponentState.Selected
    end
end


easySettings.AddMenu("Performance Fix", PerformanceFix.ShowGUI)

PerformanceFix.ToggleGUI = function ()
    GUI.GUI.TogglePauseMenu()

    if GUI.GUI.PauseMenuOpen then
        easySettings.Open("Performance Fix")
    end
end