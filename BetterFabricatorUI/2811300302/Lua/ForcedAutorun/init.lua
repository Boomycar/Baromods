if not CLIENT then return end

local tblx = require 'BetterFabricatorUI.tblx'

local descriptor = Descriptors["Barotrauma.Items.Components.Fabricator"]
LuaUserData.MakeMethodAccessible(descriptor, "FilterEntities")
LuaUserData.MakeMethodAccessible(descriptor, "HideEmptyItemListCategories")
LuaUserData.MakeFieldAccessible(descriptor, "fabricationRecipes")
LuaUserData.MakeFieldAccessible(descriptor, "itemCategoryButtons")
LuaUserData.MakeFieldAccessible(descriptor, "itemFilterBox")
LuaUserData.MakeFieldAccessible(descriptor, "itemList")
LuaUserData.MakeFieldAccessible(descriptor, "selectedItemCategory")

---@type { [Barotrauma.Items.Components.Fabricator]:Barotrauma.ContentPackage[] }
local selectedPackages = {}

---@param fabricator Barotrauma.Items.Components.Fabricator
---@return integer
local function getCategoriesMask(fabricator)
    local categoriesMask = 0
    local anyPackageSelected = tblx.any(selectedPackages[fabricator])
    for _, recipe in pairs(fabricator.fabricationRecipes) do
        local itemPrefab = recipe.TargetItem
        if not anyPackageSelected or tblx.include(selectedPackages[fabricator], itemPrefab.ContentPackage) then
            categoriesMask = bit32.bor(categoriesMask, itemPrefab.Category)
        end
    end
    return categoriesMask
end

---@param fabricator Barotrauma.Items.Components.Fabricator
local function furtherFilterByPackage(fabricator)
    if not tblx.any(selectedPackages[fabricator]) then return end
    for child in fabricator.itemList.Content.Children do
        if type(child.UserData) == "userdata"
            and child.Visible
            and not tblx.include(selectedPackages[fabricator], child.UserData.TargetItem.ContentPackage)
        then
            child.Visible = false
        end
    end
    fabricator.HideEmptyItemListCategories()
end

---@param fabricator Barotrauma.Items.Components.Fabricator
local function patch(fabricator)
    selectedPackages[fabricator] = {}

    ---@type Barotrauma.ContentPackage[]
    local relatedPackages = {}
    for _, recipe in pairs(fabricator.fabricationRecipes) do
        local package = recipe.TargetItem.ContentPackage
        if not tblx.include(relatedPackages, package) then
            table.insert(relatedPackages, package)
        end
    end

    for _, categoryButton in pairs(fabricator.itemCategoryButtons) do
        categoryButton.SelectedColor = Color.Yellow
    end

    fabricator.GuiFrame.RectTransform.RelativeSize = fabricator.GuiFrame.RectTransform.RelativeSize + Vector2(0, 0.1)

    ---@type Barotrauma.GUILayoutGroup
    local innerArea = fabricator.itemList
        .Parent -- paddedItemFrame
        .Parent -- itemListFrame
        .Parent -- topFrame
        .Parent -- mainFrame
        .Parent
    innerArea.RectTransform.RelativeSize = innerArea.RectTransform.RelativeSize - Vector2(0, 0.075)

    ---@type Barotrauma.GUILayoutGroup
    local paddedFrame = innerArea.Parent

    local overlapFrame = GUI.Frame(GUI.RectTransform(Vector2(0.975, 0.075), paddedFrame.RectTransform, GUI.Anchor.Center))
    overlapFrame.AutoDraw = false

    local watermark = GUI.TextBlock(
        GUI.RectTransform(Vector2.One, overlapFrame.RectTransform, GUI.Anchor.Center),
        TextManager.Get("settingstab.mods"),
        Color.LightGray,
        GUI.GUIStyle.Font,
        GUI.Alignment.CenterLeft)
    watermark.AutoScaleVertical = true

    local packageSelector = GUI.DropDown(GUI.RectTransform(Vector2.One, overlapFrame.RectTransform, GUI.Anchor.Center), nil, 4, nil, true, true)
    packageSelector.ListBox.RectTransform.RelativeSize = packageSelector.ListBox.RectTransform.RelativeSize - Vector2(0.05, 0)
    packageSelector.ListBox.RectTransform.Pivot = GUI.Pivot.BottomRight
    packageSelector.ListBox.RectTransform.Anchor = GUI.Anchor.TopRight
    packageSelector.ListBox.Padding = Vector4(10, 15, 10, 15) * GUI.Scale
    for _, package in pairs(relatedPackages) do packageSelector.AddItem(package.Name, package) end
    packageSelector.OnSelected = function()
        tblx.clear(selectedPackages[fabricator])
        for _, data in pairs(packageSelector.SelectedDataMultiple) do
            table.insert(selectedPackages[fabricator], data)
        end

        watermark.Visible = not tblx.any(selectedPackages[fabricator])

        local categoriesMask = getCategoriesMask(fabricator)
        for _, categoryButton in pairs(fabricator.itemCategoryButtons) do
            local category = categoryButton.UserData
            categoryButton.Enabled = category == nil
                or bit32.band(categoriesMask, category) == category
            if not categoryButton.Enabled and categoryButton.Selected then
                categoryButton.OnClicked.Invoke(categoryButton, categoryButton.UserData)
            end
        end

        fabricator.FilterEntities(fabricator.selectedItemCategory, fabricator.itemFilterBox.Text)
    end
end

Hook.Add("roundEnd", "BetterFabricatorUI", function()
    tblx.clear(selectedPackages)
end)

Hook.Patch(
    "BetterFabricatorUI",
    "Barotrauma.Items.Components.Fabricator",
    "CreateGUI",
    ---@param fabricator Barotrauma.Items.Components.Fabricator
    ---@param ptable? Barotrauma.LuaCsHook.ParameterTable
    function(fabricator, ptable)
        patch(fabricator)
    end,
    Hook.HookMethodType.After
)

Hook.Patch(
    "BetterFabricatorUI",
    "Barotrauma.Items.Components.Fabricator",
    "FilterEntities",
    ---@param fabricator Barotrauma.Items.Components.Fabricator
    ---@param ptable? Barotrauma.LuaCsHook.ParameterTable
    function(fabricator, ptable)
        furtherFilterByPackage(fabricator)
    end,
    Hook.HookMethodType.After
)
