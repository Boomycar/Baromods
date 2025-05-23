
Hook.Add("item.applyTreatment", "emptysymbiosissyringe", function(item, usingCharacter, targetCharacter, limb)
	
	if targetCharacter==nil or targetCharacter.CharacterHealth==nil then return false end
	if item.Prefab.Identifier.Value ~= "emptysymbiosissyringe" then return false end
    local aff = targetCharacter.CharacterHealth.GetAffliction("husksymbiosis")
	local huskinfectionAff = targetCharacter.CharacterHealth.GetAffliction("husksymbiosis")
	
	if aff then
		local spawnItem = ItemPrefab.GetItemPrefab("symbiosisextract") -- sex tract lol
		Entity.Spawner.AddItemToSpawnQueue(spawnItem, usingCharacter.Inventory, nil, nil, function(itemspawnItem)
			
		end)
	--[[elseif huskinfectionAff and tonumber(huskinfectionAff.Strength) >= 40 then 
		local spawnItem = ItemPrefab.GetItemPrefab("huskeggs") -- calyx extract
		Entity.Spawner.AddItemToSpawnQueue(spawnItem, usingCharacter.Inventory, nil, nil, function(itemspawnItem)
			
		end)]] -- nvm this busted as FUCK lmao
	else
		local spawnItem = ItemPrefab.GetItemPrefab("emptysymbiosissyringe") -- return the syringe if the patient doesnt have husk symbiosis
		Entity.Spawner.AddItemToSpawnQueue(spawnItem, usingCharacter.Inventory, nil, nil, function(itemspawnItem)
			
		end)
	end
end)