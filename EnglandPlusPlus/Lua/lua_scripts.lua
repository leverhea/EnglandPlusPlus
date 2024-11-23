-- lua_scripts
-- Author: leverhea
-- DateCreated: 11/18/2024 7:50:38 PM
--------------------------------------------------------------

local leaderType = "LEADER_VICTORIA"
local civilizationType = "CIVILIZATION_ENGLAND"


function IsStringInTable(targetString, table)
    for _, value in ipairs(table) do
        if value == targetString then
            return true
        end
    end
    return false
end


function GetLeaderTraits(leaderType)
    local traits = {}
    -- Iterate through the LeaderTraits table
    for row in GameInfo.LeaderTraits() do
        if row.LeaderType == leaderType then
            table.insert(traits, row.TraitType)
        end
    end
    return traits
end

local leaderTraits = GetLeaderTraits(leaderType)

-- print("Traits for leader:", leaderType)
-- for _, trait in ipairs(leaderTraits) do
--     print("- " .. trait)
-- end


function GetCivilizationTraits(civilizationType)
    local traits = {}
    -- Iterate through the CivilizationTraits table
    for row in GameInfo.CivilizationTraits() do
        if row.CivilizationType == civilizationType then
            table.insert(traits, row.TraitType)
        end
    end
    return traits
end

local civTraits = GetCivilizationTraits(civilizationType)

-- print("Traits for civilization:", civilizationType)
-- for _, trait in ipairs(civTraits) do
--     print("- " .. trait)
-- end


function GetUniqueUnits()
    local uniqueUnits = {}
    for unit in GameInfo.Units() do
        -- print("EnglandPlusPlus: type=" .. tostring(unit.UnitType))
        if IsStringInTable(unit.TraitType, leaderTraits) or IsStringInTable(unit.TraitType, civTraits) then
            -- print("EnglandPlusPlus: It's our unique unit!")
            table.insert(uniqueUnits, unit.UnitType)
        end
    end
    return uniqueUnits
end

local uniqueUnits = GetUniqueUnits()

-- print("EnglandPlusPlus: unique units")
-- for _, unitType in ipairs(uniqueUnits) do
--     print(tostring(unitType))
-- end
-- print("--------------------------")


function GetReplacedUnits()
    local replacedUnits = {}
    for unit in GameInfo.UnitReplaces() do
        -- print("EnglandPlusPlus: CivUniqueUnitType=" .. unit.CivUniqueUnitType .. ", ReplacesUnitType=" .. unit.ReplacesUnitType)
        if IsStringInTable(unit.CivUniqueUnitType, uniqueUnits) then
            -- print("added to list")
            table.insert(replacedUnits, unit.ReplacesUnitType)
        end
    end
    return replacedUnits
end

local replacedUnits = GetReplacedUnits()

-- print("EnglandPlusPlus: replaced units")
-- for _, unitType in ipairs(replacedUnits) do
--     print(tostring(unitType))
-- end
-- print("--------------------------")


function GetSortedMeleeUnits()
    local meleeUnits = {}
    -- Iterate through all units in the database
    for unit in GameInfo.Units() do
        -- print("EnglandPlusPlus: UnitType=" .. unit.UnitType .. ", combat=" .. tostring(unit.Combat) .. ", domain=" .. tostring(unit.Domain) .. ", class=" .. tostring(unit.PromotionClass) .. ", trait=" .. tostring(unit.TraitType) .. ", tech=" ..tostring(unit.PrereqTech) .. ", civic=" .. tostring(unit.PrereqCivic))
        if unit.Combat > 0 and unit.Domain == "DOMAIN_LAND" and unit.PromotionClass == "PROMOTION_CLASS_MELEE" then
            -- print("EnglandPlusPlus: UnitType=" .. unit.UnitType .. ", combat=" .. tostring(unit.Combat) .. ", domain=" .. tostring(unit.Domain) .. ", class=" .. tostring(unit.PromotionClass) .. ", trait=" .. tostring(unit.TraitType) .. ", tech=" ..tostring(unit.PrereqTech) .. ", civic=" .. tostring(unit.PrereqCivic))
            -- print("EnglandPlusPlus: is it replaced unit?" .. tostring(IsStringInTable(unit.UnitType, replacedUnits)))

            -- Check if unit is replaced by unique unit
            if not IsStringInTable(unit.UnitType, replacedUnits) then
                -- print("EnglandPlusPlus: this is not a replaced unit")
                if unit.TraitType ~= nil then
                    if IsStringInTable(unit.TraitType, leaderTraits) or IsStringInTable(unit.TraitType, civTraits) then
                        -- Add to the meleeUnits table, key is combat strength
                        meleeUnits[#meleeUnits + 1] = {
                            CombatStrength = unit.Combat,
                            UnitType = unit.UnitType,
                            PrereqTech = unit.PrereqTech,
                            PrereqCivic = unit.PrereqCivic,
                            Index = unit.Index
                        }
                    end
                else
                    -- Add to the meleeUnits table, key is combat strength
                    meleeUnits[#meleeUnits + 1] = {
                        CombatStrength = unit.Combat,
                        UnitType = unit.UnitType,
                        PrereqTech = unit.PrereqTech,
                        PrereqCivic = unit.PrereqCivic,
                        Index = unit.Index
                    }
                end
            end
        end
    end
    -- Sort the table by CombatStrength in descending order
    table.sort(meleeUnits, function(a, b)
        return a.CombatStrength > b.CombatStrength
    end)
    return meleeUnits
end

local sortedMeleeUnits = GetSortedMeleeUnits()

-- -- Check if there are units to print
-- if sortedMeleeUnits == nil then
--     print("No melee unites found")
--     return
-- end;

-- if #sortedMeleeUnits == 0 then
--     print("No melee units found.")
--     return
-- end

-- for _, unit in ipairs(sortedMeleeUnits) do
--     print("Combat Strength: " .. unit.CombatStrength)
--     print("Unit Type: " .. unit.UnitType)
--     print("Prerequisite Technology: " .. (unit.PrereqTech or "None"))
--     print("Prerequisite Civic: " .. (unit.PrereqCivic or "None"))
--     print("--------------------------")
-- end


function GetSortedNavalUnits()
    local navalUnits = {}
    -- Iterate through all units in the database
    for unit in GameInfo.Units() do
        local combinedCombat = unit.Combat
        if unit.RangedCombat > 0 then
            combinedCombat = unit.RangedCombat
        end

        if unit.TraitType ~= nil then -- unique unit tie breaker
            combinedCombat = combinedCombat + 2
        end

        if unit.PromotionClass == "PROMOTION_CLASS_NAVAL_RAIDER" then
            combinedCombat = combinedCombat + 1
        end

        if unit.PromotionClass == "PROMOTION_CLASS_NAVAL_RANGED" then
            combinedCombat = combinedCombat + 2
        end

        -- print("EnglandPlusPlus: UnitType=" .. unit.UnitType .. ", combat=" .. tostring(unit.Combat) .. ", domain=" .. tostring(unit.Domain) .. ", class=" .. tostring(unit.PromotionClass) .. ", trait=" .. tostring(unit.TraitType) .. ", tech=" ..tostring(unit.PrereqTech) .. ", civic=" .. tostring(unit.PrereqCivic))
        if combinedCombat > 0 and unit.Domain == "DOMAIN_SEA" then
            -- print("EnglandPlusPlus: UnitType=" .. unit.UnitType .. ", combat=" .. tostring(unit.Combat) .. ", domain=" .. tostring(unit.Domain) .. ", class=" .. tostring(unit.PromotionClass) .. ", trait=" .. tostring(unit.TraitType) .. ", tech=" ..tostring(unit.PrereqTech) .. ", civic=" .. tostring(unit.PrereqCivic))
            -- print("EnglandPlusPlus: is it replaced unit?" .. tostring(IsStringInTable(unit.UnitType, replacedUnits)))
            -- Check if unit is replaced by unique unit
            if not IsStringInTable(unit.UnitType, replacedUnits) then -- exclude units that are replaced by unique units
                -- print("EnglandPlusPlus: this is not a replaced unit")
                if unit.TraitType ~= nil then
                    if IsStringInTable(unit.TraitType, leaderTraits) or IsStringInTable(unit.TraitType, civTraits) then -- these are unique units
                        -- Add to the navalUnits table, key is combat strength
                        navalUnits[#navalUnits + 1] = {
                            CombatStrength = combinedCombat,
                            UnitType = unit.UnitType,
                            PrereqTech = unit.PrereqTech,
                            PrereqCivic = unit.PrereqCivic,
                            Index = unit.Index
                        }
                    end
                else
                    -- Add to the navalUnits table, key is combat strength
                    navalUnits[#navalUnits + 1] = {
                        CombatStrength = combinedCombat,
                        UnitType = unit.UnitType,
                        PrereqTech = unit.PrereqTech,
                        PrereqCivic = unit.PrereqCivic,
                        Index = unit.Index
                    }
                end
            end
        end
    end
    -- Sort the table by CombatStrength in descending order
    table.sort(navalUnits, function(a, b)
        return a.CombatStrength > b.CombatStrength
    end)
    return navalUnits
end

local sortedNavalUnits = GetSortedNavalUnits()
-- -- Check if there are units to print
-- if sortedNavalUnits == nil then
--     print("No naval unites found")
--     return
-- end;

-- if #sortedNavalUnits == 0 then
--     print("No naval units found.")
--     return
-- end

-- for _, unit in ipairs(sortedNavalUnits) do
--     print("Combat Strength: " .. unit.CombatStrength)
--     print("Unit Type: " .. unit.UnitType)
--     print("Prerequisite Technology: " .. (unit.PrereqTech or "None"))
--     print("Prerequisite Civic: " .. (unit.PrereqCivic or "None"))
--     print("--------------------------")
-- end


function GetResearchedTechnologies(playerID)
    local player = Players[playerID]
    if not player then
        print("Invalid player ID")
        return {}
    end

    local playerTechs = player:GetTechs()  -- Access the player's technology tree
    local researchedTechs = {}

    -- Iterate through all technologies
    for tech in GameInfo.Technologies() do
        if playerTechs:HasTech(tech.Index) then
            table.insert(researchedTechs, tech.TechnologyType)
        end
    end

    return researchedTechs
end


function GetResearchedCivics(playerID)
    local player = Players[playerID]
    if not player then
        print("Invalid player ID")
        return {}
    end

    local playerCulture = player:GetCulture()  -- Access the player's civic tree
    local researchedCivics = {}

    -- Iterate through all civics
    for civic in GameInfo.Civics() do
        if playerCulture:HasCivic(civic.Index) then
            table.insert(researchedCivics, civic.CivicType)
        end
    end

    return researchedCivics
end


function GetStrongestUnitByClass(sortedUnitsByClass, techs, civics, landOrSea)
    for _, unit in ipairs(sortedUnitsByClass) do
        -- print("Combat Strength: " .. unit.CombatStrength)
        -- print("Unit Type: " .. unit.UnitType)
        -- print("Prerequisite Technology: " .. (unit.PrereqTech or "None"))
        -- print("Prerequisite Civic: " .. (unit.PrereqCivic or "None"))
        -- print("--------------------------")

        local techReq = unit.PrereqTech or "None"

        local techReqMet = false
        if techReq == "None" or IsStringInTable(techReq, techs) then
            -- print("EnglandPlusPlus: Tech requirement met")
            techReqMet = true
        end

        local civicReq = unit.PrereqCivic or "None"

        local civicReqMet = false
        if civicReq == "None" or IsStringInTable(civicReq, civics) then
            -- print("EnglandPlusPlus: Civic requirement met")
            civicReqMet = true
        end

        if techReqMet and civicReqMet then
            -- print("EnglandPlusPlus: WE HAVE A WINNER! " .. unit.UnitType)
            return unit
        end
    end


    local default_unit = nil
    if landOrSea == "LAND" then
        default_unit = GameInfo.Units["UNIT_WARRIOR"]
    else
        default_unit = GameInfo.Units["UNIT_GALLEY"]
    end

    local default_return_value = {
        CombatStrength = default_unit.Combat,
        UnitType = default_unit.UnitType,
        PrereqTech = default_unit.PrereqTech,
        PrereqCivic = default_unit.PrereqCivic,
        Index = default_unit.Index
    }
    return default_return_value
end


function ApplyUnitAbility(unit, unitAbilityType)
    local currentStrength = unit:GetCombat()
    local pUnitAbility = unit:GetAbility();
    local iCurrentCount = pUnitAbility:GetAbilityCount(unitAbilityType);

    pUnitAbility:ChangeAbilityCount(unitAbilityType, -iCurrentCount+1);
    iCurrentCount = pUnitAbility:GetAbilityCount(unitAbilityType);
end







function Trait_City_Melee_Unit_Foreign(PlayerID, CityID, CityX, CityY)
    local playerConfig = PlayerConfigurations[PlayerID]
    local localLeaderType = playerConfig:GetLeaderTypeName()
    local localCivType = playerConfig:GetCivilizationTypeName()

    -- only continue if this is for the correct leader and civilizationType
	if localLeaderType ~= leaderType or localCivType ~= civilizationType then return end
	local pPlayer = Players[PlayerID]

    local techs = GetResearchedTechnologies(PlayerID)
    -- print("Technologies researched by player " .. PlayerID .. ":")
    -- for _, tech in ipairs(techs) do
    --     print("- " .. tech)
    -- end

    local civics = GetResearchedCivics(PlayerID)
    -- print("Civics researched by player " .. PlayerID .. ":")
    -- for _, civic in ipairs(civics) do
    --     print("- " .. civic)
    -- end

    local strongestMeleeUnit = GetStrongestUnitByClass(sortedMeleeUnits, techs, civics, "LAND")
    -- print("EnglandPlusPlus: strongest unit=" .. strongestMeleeUnit.UnitType)

	local pCity = pPlayer:GetCities():FindID(CityID)

	local sCity_LOC = pCity:GetName()
	local cPlayerCapital = pPlayer:GetCities():GetCapitalCity()

	-- print("EnglandPlusPlus: Player # " .. PlayerID .. " has a city at X" .. CityX .. ", Y" .. CityY .. " called " .. Locale.Lookup(sCity_LOC))

    if cPlayerCapital == nil then
        -- print("EnglandPlusPlus: NO CAPITAL EXISTS!!!")
        return
    end

	local pNewCityPlot = Map.GetPlot(CityX, CityY)
	local pNewCityContinent = pNewCityPlot:GetContinentType()

	local pCapitalPlot = Map.GetPlot(cPlayerCapital:GetX(), cPlayerCapital:GetY())

	local pCapitalContinent = pCapitalPlot:GetContinentType()

    if pCapitalContinent == pNewCityContinent then return end

    -- print("EnglandPlusPlus: DIFFERENT CONTINENT!!!")
	local newUnit = pPlayer:GetUnits():Create(strongestMeleeUnit.Index, CityX, CityY)
    if newUnit then
        -- print("Spawned unit:", newUnit:GetType(), "at location:", CityX, CityY)
        -- Apply a custom modifier to the unit
        ApplyUnitAbility(newUnit, "ABILITY_LINCOLN_MELEE_UNITS")
    else
        -- print("Failed to create unit.")
    end

end
GameEvents.CityBuilt.Add(Trait_City_Melee_Unit_Foreign)





function DockyardBuildingEvent(iX, iY, iBuildingIndex, iPlayer, iCityId, iPercentCompleted)
    -- print("EnglandPlusPlus: *************************")
    -- print("EnglandPlusPlus: DockyardBuildingEvent")
    -- print("EnglandPlusPlus: *************************")
    -- print("EnglandPlusPlus: iX=", iX)
    -- print("EnglandPlusPlus: iY=", iY)
    -- print("EnglandPlusPlus: iBuildingIndex=", iBuildingIndex)
    -- print("EnglandPlusPlus: iPlayer=", iPlayer)
    -- print("EnglandPlusPlus: iCityId=", iCityId)
    -- print("EnglandPlusPlus: iPercentCompleted=", iPercentCompleted)

	if iPercentCompleted < 100 then return end

    local playerConfig = PlayerConfigurations[iPlayer]
    local localLeaderType = playerConfig:GetLeaderTypeName()
    local localCivType = playerConfig:GetCivilizationTypeName()

    -- only continue if this is for the correct leader and civilizationType
	if localLeaderType ~= leaderType or localCivType ~= civilizationType then return end

    local buildingTypeEntry = nil
    -- Search for the district entry by index
    for row in GameInfo.Buildings() do
        if row.Index == iBuildingIndex then
            buildingTypeEntry = row
            break
        end
    end

	local pPlayer = Players[iPlayer]

    local pCity = pPlayer:GetCities():FindID(iCityId)
    local sCity_LOC = pCity:GetName()

    -- print("EnglandPlusPlus: sCity_LOC=" .. tostring(sCity_LOC))
    -- print("EnglandPlusPlus: buildings Type=" .. tostring(buildingTypeEntry.BuildingType))
    -- print("EnglandPlusPlus: buildings prereq distict=" .. tostring(buildingTypeEntry.PrereqDistrict))

    if buildingTypeEntry.PrereqDistrict ~= "DISTRICT_HARBOR" then return end


    local techs = GetResearchedTechnologies(iPlayer)
    -- -- print("Technologies researched by player " .. iPlayer .. ":")
    -- -- for _, tech in ipairs(techs) do
    -- --     print("- " .. tech)
    -- -- end

    local civics = GetResearchedCivics(iPlayer)
    -- -- print("Civics researched by player " .. iPlayer .. ":")
    -- -- for _, civic in ipairs(civics) do
    -- --     print("- " .. civic)
    -- -- end


    local strongestNavalUnit = GetStrongestUnitByClass(sortedNavalUnits, techs, civics, "SEA")
    -- print("EnglandPlusPlus: strongest unit=" .. strongestNavalUnit.UnitType)

    -- If the district type entry is found, proceed
    if buildingTypeEntry then
        local newUnit = pPlayer:GetUnits():Create(strongestNavalUnit.Index, iX, iY)
        ApplyUnitAbility(newUnit, "ABILITY_ROYAL_NAVY_DOCKYARD_MOVEMENT_BONUS")
    else
        print("Building type not found for index:", iBuildingIndex)
    end
end

-- Add the event listener
Events.BuildingChanged.Add(DockyardBuildingEvent)

















