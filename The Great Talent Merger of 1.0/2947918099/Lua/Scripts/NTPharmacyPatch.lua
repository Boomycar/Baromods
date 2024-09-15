Timer.wait(function()

    -- Add selfcare and buff to pills
    NT.ItemStartsWithMethods.custompill = function(item, usingCharacter, targetCharacter, limb)

        local hasselfcare = HF.BoolToNum(HF.HasTalent(usingCharacter,"selfcare"))
        local hasbuff = HF.BoolToNum(HF.HasTalent(targetCharacter,"buff"))
        local hasfirstaidtraining = HF.BoolToNum(HF.HasTalent(targetCharacter,"firstaidtraining"))
        local config = NTP.TagsToPillconfig(HF.SplitString(item.Tags,","))

        if targetCharacter == usingCharacter then
            for identifier,strength in pairs(config.fx) do
                if hasbuff == 1 then
                    local buffcheck = string.find("afmannitol analgesia afantibiotics adrenaline haste strengthen afstreptokinase afthiamine afimmunosuppressant durationincrease combatstimulant pressurestabilized",identifier)
                    if buffcheck ~= nil and strength > 0 then strength = strength*1.5 end
                end
                HF.AddAffliction(targetCharacter,identifier,strength*(1+(0.2*hasselfcare)+(0.35*hasfirstaidtraining)),usingCharacter)
            end
        else
            for identifier,strength in pairs(config.fx) do
                if hasbuff == 1 then
                    local buffcheck = string.find("afmannitol analgesia afantibiotics adrenaline haste strengthen afstreptokinase afthiamine afimmunosuppressant durationincrease combatstimulant pressurestabilized",identifier)
                    if buffcheck ~= nil and strength > 0 then strength = strength*1.5 end
                end
                HF.AddAffliction(targetCharacter,identifier,strength*(1+(0.35*hasfirstaidtraining)),usingCharacter)
            end
        end

        HF.RemoveItem(item)
        HF.GiveItem(targetCharacter,"ntsfx_pills")
    end

    function NTP.PillConfigFromItems(components,skill,descriptionOverride,user)
        skill = skill or 30

        local res = {fx={},capacity=0,yield=2,tags={},
        ingredients={},color=nil,description=nil,
        sprite=nil}

        local sscheck = HF.BoolToNum(user.HasTalent("supersoldiers"))
            if sscheck == 0 then 
            sscheck = HF.BoolToNum(user.HasTalent("supersoldiersnew"))
        end
        local mdcheck = HF.BoolToNum(user.HasTalent("macrodosing"))
        local dsmcheck = HF.BoolToNum(user.HasTalent("drsubmarine"))

        local potencymult = 1*(1+(0.25*dsmcheck))
        local basepotencymult = 1
        local binderpotencymult = 1
        local activepotencymult = 1
        local fillerpotencymult = 1
        local yieldmult = 1
        local yield = 2
        local capacity=0
        local color = nil

        -- build ingredients
        for id in components do
            res.ingredients[id] = (res.ingredients[id] or 0) + 1
        end

        -- fetch item success
        local success = {}
        for i, itemidentifier in ipairs(components) do
            local s = true
            if NTP.PillData.items[itemidentifier] ~= nil then
                s = math.random() < 
                    skill/(NTP.PillData.items[itemidentifier].skillrequirement or 30)
            end
            success[i] = s
        end

        -- fetch multipliers
        for i, itemidentifier in ipairs(components) do
            if NTP.PillData.items[itemidentifier] ~= nil then
                local effects = NTP.PillData.items[itemidentifier].effects or {}
                if not success[i] then effects = NTP.PillData.items[itemidentifier].faileffects or effects end
            
                for effect in effects do
                    if effect.type == "potencymult" then potencymult=potencymult*effect.value
                    elseif effect.type == "basepotencymult" then basepotencymult=basepotencymult*effect.value
                    elseif effect.type == "binderpotencymult" then binderpotencymult=binderpotencymult*effect.value
                    elseif effect.type == "activepotencymult" then activepotencymult=activepotencymult*effect.value
                    elseif effect.type == "fillerpotencymult" then fillerpotencymult=fillerpotencymult*effect.value
                    elseif effect.type == "yieldmult" then yieldmult=yieldmult*effect.value
                    elseif effect.type == "yield" then yield=yield+effect.value
                    elseif effect.type == "capacity" then capacity=capacity+effect.value
                    elseif effect.type == "sprite" then res.sprite=effect.value
                    end
                end
            end
        end

        res.capacity = capacity

        -- check for combos
        local activecombo = nil
        for comboidentifier, combo in pairs(NTP.PillData.combos) do
            local viable = true
            -- required items
            if combo.requireditems~=nil then
                for requirement in combo.requireditems do
                    if
                        res.ingredients[requirement.id] == nil or
                        res.ingredients[requirement.id] < (requirement.amount or 1)
                    then
                        viable=false
                        break
                    end
                end
            end
            -- forbidden items
            if viable and combo.forbiddenitems~=nil then
                for forbidden in combo.forbiddenitems do
                    if res.ingredients[forbidden] ~= nil then
                        viable=false
                        break
                    end
                end
            end

            if viable then activecombo = combo break end
        end

        -- apply effects
        if activecombo ~= nil and activecombo.effectoverride ~= nil then
            local s = math.random() < 
                skill/(activecombo.effectoverride.skillrequirement or 30)
            local effects = nil
            if s or activecombo.effectoverride.faileffects == nil then
                effects = activecombo.effectoverride.effects
            else effects = activecombo.effectoverride.faileffects end

            if effects ~= nil then
                for effect in effects do
                    if effect.type == "addeffect" and (effect.chance == nil or HF.Chance(effect.chance)) then

                        local strength = effect.amount * potencymult

                        if effect.identifier == "huskinfectionresistance" then strength = strength * (1+(0.25*sscheck)+(0.25*mdcheck)) end

                        -- add strength to existing effect
                        if res.fx[effect.identifier]~=nil then strength=strength+res.fx[effect.identifier] end
                        -- set effect
                        res.fx[effect.identifier] = strength
                    elseif effect.type=="addtag" then
                        table.insert(res.tags,effect.tag)
                    end
                end
            end
        else
            for i, itemidentifier in ipairs(components) do
                if NTP.PillData.items[itemidentifier] ~= nil then
                    local effects = NTP.PillData.items[itemidentifier].effects or {}
                    if not success[i] then effects = NTP.PillData.items[itemidentifier].faileffects or effects end
                
                    local itemType = NTP.PillData.items[itemidentifier].types[1] or ""
        
                    for effect in effects do
                        if effect.type == "addeffect" and (effect.chance == nil or HF.Chance(effect.chance)) then
                            local strengthmult=1

                            if itemType == "base" then strengthmult=basepotencymult
                            elseif itemType == "binder" then strengthmult=binderpotencymult
                            elseif itemType == "active" then strengthmult=activepotencymult
                            elseif itemType == "filler" then strengthmult=fillerpotencymult
                            end
                            
                            local buffcheck = string.find("afmannitol analgesia afantibiotics adrenaline haste strengthen afstreptokinase afthiamine afimmunosuppressant durationincrease combatstimulant pressurestabilized",effect.identifier)
                            if buffcheck ~= nil and effect.amount > 0 then strengthmult=strengthmult*(1+(0.25*sscheck)+(0.25*mdcheck)) end
        
                            local strength = effect.amount * strengthmult * potencymult
                            -- add strength to existing effect
                            if res.fx[effect.identifier]~=nil then strength=strength+res.fx[effect.identifier] end
                            -- set effect
                            res.fx[effect.identifier] = strength
                        elseif effect.type=="addtag" then
                            table.insert(res.tags,effect.tag)
                        elseif effect.type=="color" then
                            if color == nil then
                                color = {effect.r,effect.g,effect.b}
                            else
                                color = {
                                    HF.Lerp(color[1],effect.r,0.5),
                                    HF.Lerp(color[2],effect.g,0.5),
                                    HF.Lerp(color[3],effect.b,0.5)
                                }
                            end
                        end
                    end
                end
            end
        end

        -- combo stuff
        if activecombo ~= nil then
            if activecombo.coloroverride~=nil then 
                color = {activecombo.coloroverride[1],activecombo.coloroverride[2],activecombo.coloroverride[3]}
            end
            if activecombo.descriptionoverride~=nil then 
                descriptionOverride =
                    TextManager.Get("pillcombo."..activecombo.descriptionoverride).Value
                    ..(descriptionOverride or "")
            end
        end

        res.color = color
        res.yield = HF.Round(yield*yieldmult)
        res.description = descriptionOverride

        return res
    end

end,1)