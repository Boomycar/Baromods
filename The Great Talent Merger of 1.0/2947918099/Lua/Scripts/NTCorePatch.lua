Timer.wait(function()

    --new wrench types work with dislocations
    NT.ItemMethods.advwrench = NT.ItemStartsWithMethods.wrench
    NT.ItemMethods.advwrenchhardened = NT.ItemStartsWithMethods.wrench
    NT.ItemMethods.advwrenchdementonite = NT.ItemStartsWithMethods.wrench
    NT.ItemMethods.advheavywrench = NT.ItemStartsWithMethods.wrench

    --DR submarine, medical expertise, & self care effects added to bandages
    NT.ItemMethods.antibleeding1 = function(item, usingCharacter, targetCharacter, limb) 
        local limbtype = limb.type
        local success = HF.BoolToNum(HF.GetSkillRequirementMet(usingCharacter,"medical",10),1)
        local hasmedexp = HF.BoolToNum(HF.HasTalent(usingCharacter,"medicalexpertise"))
        local dsmcheck = HF.BoolToNum(usingCharacter.HasTalent("drsubmarine"))
        local hasselfcare = HF.BoolToNum(HF.HasTalent(usingCharacter,"selfcare"))

        if targetCharacter == usingCharacter then
            HF.AddAfflictionLimb(targetCharacter,"dirtybandage",limbtype,-100,usingCharacter)
            HF.AddAfflictionLimb(targetCharacter,"bandaged",limbtype,(36+success*12+hasmedexp*12)*(1+(0.25*dsmcheck))*(1+(0.2*hasselfcare)),usingCharacter)
            HF.AddAfflictionLimb(targetCharacter,"bleeding",limbtype,(-18-success*6-hasmedexp*6)*(1+(0.25*dsmcheck))*(1+(0.2*hasselfcare)),usingCharacter)
            HF.AddAfflictionLimb(targetCharacter,"bleedingnonstop",limbtype,(-18-success*6-hasmedexp*6)*(1+(0.25*dsmcheck))*(1+(0.2*hasselfcare)),usingCharacter)
            HF.RemoveItem(item)
            HF.GiveItem(targetCharacter,"ntsfx_bandage")
        else
            HF.AddAfflictionLimb(targetCharacter,"dirtybandage",limbtype,-100,usingCharacter)
            HF.AddAfflictionLimb(targetCharacter,"bandaged",limbtype,(36+success*12+hasmedexp*12)*(1+(0.25*dsmcheck)),usingCharacter)
            HF.AddAfflictionLimb(targetCharacter,"bleeding",limbtype,(-18-success*6-hasmedexp*6)*(1+(0.25*dsmcheck)),usingCharacter)
            HF.AddAfflictionLimb(targetCharacter,"bleedingnonstop",limbtype,(-18-success*6-hasmedexp*6)*(1+(0.25*dsmcheck)),usingCharacter)
            HF.RemoveItem(item)
            HF.GiveItem(targetCharacter,"ntsfx_bandage")
        end
    end

    local function limbHasThirdDegreeBurns(char,limbtype)
        return HF.GetAfflictionStrengthLimb(char,limbtype,"burn",0) > 50
    end

    --Dr submarine & self care effects added to ointment
    NT.ItemMethods.ointment = function(item, usingCharacter, targetCharacter, limb) 
        local dsmcheck = HF.BoolToNum(usingCharacter.HasTalent("drsubmarine"))
        local hasselfcare = HF.BoolToNum(HF.HasTalent(usingCharacter,"selfcare"))
        local limbtype = limb.type
        local success = HF.BoolToNum(HF.GetSkillRequirementMet(usingCharacter,"medical",10),1)

        if targetCharacter == usingCharacter then
            HF.AddAfflictionLimb(targetCharacter,"ointmented",limbtype,(60*(success+1))*(1+(0.25*dsmcheck))*(1+(0.2*hasselfcare)),usingCharacter)
            if not limbHasThirdDegreeBurns(targetCharacter,limbtype) then
                HF.AddAfflictionLimb(targetCharacter,"burn",limbtype,(-7.2-success*4.8)*(1+(0.25*dsmcheck))*(1+(0.2*hasselfcare)),usingCharacter)
            end
            HF.AddAfflictionLimb(targetCharacter,"infectedwound",limbtype,(-24-success*48)*(1+(0.25*dsmcheck))*(1+(0.2*hasselfcare)),usingCharacter)
        
            --HF.RemoveItem(item)
            item.Condition = item.Condition - 12.5
            HF.GiveItem(targetCharacter,"ntsfx_ointment")
        else
            HF.AddAfflictionLimb(targetCharacter,"ointmented",limbtype,(60*(success+1))*(1+(0.25*dsmcheck)),usingCharacter)
            if not limbHasThirdDegreeBurns(targetCharacter,limbtype) then
                HF.AddAfflictionLimb(targetCharacter,"burn",limbtype,(-7.2-success*4.8)*(1+(0.25*dsmcheck)),usingCharacter)
            end
            HF.AddAfflictionLimb(targetCharacter,"infectedwound",limbtype,(-24-success*48)*(1+(0.25*dsmcheck)),usingCharacter)
        
            --HF.RemoveItem(item)
            item.Condition = item.Condition - 12.5
            HF.GiveItem(targetCharacter,"ntsfx_ointment")
        end
    end

    --Dr submarine, super soldier, macrodosing, & self care effects added to adrenaline
    NT.ItemMethods.adrenaline = function(item, usingCharacter, targetCharacter, limb) 
        local sscheck = HF.BoolToNum(usingCharacter.HasTalent("supersoldiers"))
        if sscheck == 0 then 
            sscheck = HF.BoolToNum(usingCharacter.HasTalent("supersoldiersnew"))
        end
        local mdcheck = HF.BoolToNum(usingCharacter.HasTalent("macrodosing"))
        local dsmcheck = HF.BoolToNum(usingCharacter.HasTalent("drsubmarine"))
        local hasselfcare = HF.BoolToNum(HF.HasTalent(usingCharacter,"selfcare"))

        if targetCharacter == usingCharacter then
            HF.AddAffliction(targetCharacter,"afadrenaline",55*(1+(0.25*sscheck)+(0.25*mdcheck))*(1+(0.25*dsmcheck))*(1+(0.2*hasselfcare)),usingCharacter)
            if HF.HasAffliction(targetCharacter,"cardiacarrest",0.1) then
                HF.AddAffliction(targetCharacter,"cardiacarrest",-100,usingCharacter)
                HF.AddAffliction(targetCharacter,"fibrillation",20,usingCharacter)
            end
            HF.RemoveItem(item)
            HF.GiveItem(targetCharacter,"ntsfx_syringe")
        else
            HF.AddAffliction(targetCharacter,"afadrenaline",55*(1+(0.25*sscheck)+(0.25*mdcheck))*(1+(0.25*dsmcheck)),usingCharacter)
            if HF.HasAffliction(targetCharacter,"cardiacarrest",0.1) then
                HF.AddAffliction(targetCharacter,"cardiacarrest",-100,usingCharacter)
                HF.AddAffliction(targetCharacter,"fibrillation",20,usingCharacter)
            end
            HF.RemoveItem(item)
            HF.GiveItem(targetCharacter,"ntsfx_syringe")
        end
    end

    --DR submarine & self care effects added to sutures
    NT.ItemMethods.suture = function(item, usingCharacter, targetCharacter, limb) 
        local limbtype = HF.NormalizeLimbType(limb.type)
        local dsmcheck = HF.BoolToNum(usingCharacter.HasTalent("drsubmarine"))
        local hasselfcare = HF.BoolToNum(HF.HasTalent(usingCharacter,"selfcare"))

        if(HF.GetSkillRequirementMet(usingCharacter,"medical",30)) then
            -- in field use
            local healeddamage = 0
            healeddamage = healeddamage + HF.Clamp(HF.GetAfflictionStrengthLimb(targetCharacter,limbtype,"lacerations",0),0,20)
            healeddamage = healeddamage + HF.Clamp(HF.GetAfflictionStrengthLimb(targetCharacter,limbtype,"bitewounds",0),0,20)
            healeddamage = healeddamage + HF.Clamp(HF.GetAfflictionStrengthLimb(targetCharacter,limbtype,"explosiondamage",0),0,20)
            healeddamage = healeddamage + HF.Clamp(HF.GetAfflictionStrengthLimb(targetCharacter,limbtype,"gunshotwound",0),0,20)
            healeddamage = healeddamage + HF.Clamp(HF.GetAfflictionStrengthLimb(targetCharacter,limbtype,"bleeding",0)/10,0,4)

            if targetCharacter == usingCharacter then
                HF.AddAfflictionLimb(targetCharacter,"lacerations",limbtype,-20*(1+(0.25*dsmcheck)+(0.2*hasselfcare)),usingCharacter)
                HF.AddAfflictionLimb(targetCharacter,"bitewounds",limbtype,-20*(1+(0.25*dsmcheck)+(0.2*hasselfcare)),usingCharacter)
                HF.AddAfflictionLimb(targetCharacter,"explosiondamage",limbtype,-20*(1+(0.25*dsmcheck)+(0.2*hasselfcare)),usingCharacter)
                HF.AddAfflictionLimb(targetCharacter,"gunshotwound",limbtype,-20*(1+(0.25*dsmcheck)+(0.2*hasselfcare)),usingCharacter)
                HF.AddAfflictionLimb(targetCharacter,"bleeding",limbtype,-40*(1+(0.25*dsmcheck)+(0.2*hasselfcare)),usingCharacter)
                HF.AddAfflictionLimb(targetCharacter,"bleedingnonstop",limbtype,-40*(1+(0.25*dsmcheck)+(0.2*hasselfcare)),usingCharacter)
                HF.AddAfflictionLimb(targetCharacter,"suturedw",limbtype,healeddamage)
        
                HF.GiveSkillScaled(usingCharacter,"medical",healeddamage) 
            else
                HF.AddAfflictionLimb(targetCharacter,"lacerations",limbtype,-20*(1+(0.25*dsmcheck)),usingCharacter)
                HF.AddAfflictionLimb(targetCharacter,"bitewounds",limbtype,-20*(1+(0.25*dsmcheck)),usingCharacter)
                HF.AddAfflictionLimb(targetCharacter,"explosiondamage",limbtype,-20*(1+(0.25*dsmcheck)),usingCharacter)
                HF.AddAfflictionLimb(targetCharacter,"gunshotwound",limbtype,-20*(1+(0.25*dsmcheck)),usingCharacter)
                HF.AddAfflictionLimb(targetCharacter,"bleeding",limbtype,-40*(1+(0.25*dsmcheck)),usingCharacter)
                HF.AddAfflictionLimb(targetCharacter,"bleedingnonstop",limbtype,-40*(1+(0.25*dsmcheck)),usingCharacter)
                HF.AddAfflictionLimb(targetCharacter,"suturedw",limbtype,healeddamage)
        
                HF.GiveSkillScaled(usingCharacter,"medical",healeddamage)
            end

            -- terminating surgeries
            -- amputations
            if HF.HasAfflictionLimb(targetCharacter,"bonecut",limbtype,1) then
                local droplimb =
                    not NT.LimbIsAmputated(targetCharacter,limbtype)
                    and not HF.HasAfflictionLimb(targetCharacter,"gangrene",limbtype,15)
                NT.SurgicallyAmputateLimb(targetCharacter,limbtype)
                if (droplimb) then
                    local limbtoitem = {}
                    limbtoitem[LimbType.RightLeg] = "rleg"
                    limbtoitem[LimbType.LeftLeg] = "lleg"
                    limbtoitem[LimbType.RightArm] = "rarm"
                    limbtoitem[LimbType.LeftArm] = "larm"
                    if limbtoitem[limbtype] ~= nil then
                        HF.GiveItem(usingCharacter,limbtoitem[limbtype])
                    end
                    if NTSP ~= nil and NT.Config.NTSPenableSurgerySkill then HF.GiveSkill(usingCharacter,"surgery",0.5) end
                end
            end

            -- the other stuff
            local function removeAfflictionPlusGainSkill(affidentifier,skillgain)
                if HF.HasAfflictionLimb(targetCharacter,affidentifier,limbtype) then
                    HF.SetAfflictionLimb(targetCharacter,affidentifier,limbtype,0,usingCharacter)

                    if NTSP ~= nil and NT.Config.NTSPenableSurgerySkill then 
                        HF.GiveSkill(usingCharacter,"surgery",skillgain)
                    else 
                        HF.GiveSkill(usingCharacter,"medical",skillgain/4)
                    end
                end
            end
            local function removeAfflictionNonLimbSpecificPlusGainSkill(affidentifier,skillgain)
                if HF.HasAffliction(targetCharacter,affidentifier) then
                    HF.SetAffliction(targetCharacter,affidentifier,0,usingCharacter)

                    if NTSP ~= nil and NT.Config.NTSPenableSurgerySkill then 
                        HF.GiveSkill(usingCharacter,"surgery",skillgain)
                    else 
                        HF.GiveSkill(usingCharacter,"medical",skillgain/4)
                    end
                end
            end

            for key, value in pairs(NT.SutureAfflictions) do
                local prefab = AfflictionPrefab.Prefabs[key]
                if prefab ~= nil and (value.case == nil or HF.HasAfflictionLimb(targetCharacter,value.case,limbtype)) then
                    if value.func ~= nil then
                        value.func(item, usingCharacter, targetCharacter, limb)
                    else
                        local skillgain = value.xpgain or 0
                        if prefab.LimbSpecific then
                            removeAfflictionPlusGainSkill(key,skillgain)
                        elseif prefab.IndicatorLimb == limbtype then
                            removeAfflictionNonLimbSpecificPlusGainSkill(key,skillgain)
                        end
                    end
                end
            end
            
        else
            HF.AddAfflictionLimb(targetCharacter,"internaldamage",limbtype,6)
        end
    end

    --Don't die on me patch
    Hook.Add("human.CPRSuccess", "NT.CPRSuccess", function(animcontroller)
        if animcontroller==nil or animcontroller.Character==nil or animcontroller.Character.SelectedCharacter==nil then return end
        local character = animcontroller.Character.SelectedCharacter
        local ddom = HF.BoolToNum(animcontroller.Character.HasTalent("dontdieonme"))
        
        HF.AddAffliction(character,"cpr_buff",2)
        HF.AddAffliction(character,"cpr_fracturebuff",2) -- prevent fractures during CPR (fuck baro physics)
        HF.AddAffliction(character,"cprddom",ddom*2)
    end)

end,1)