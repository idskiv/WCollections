C_AurasJournal = C_AurasJournal or { };

local _aurasIDs = { };
local _collectedAurasID = { };
local _filteredAurasIDs = { };
local _showCollected = nil;
local _showUncollected = nil;
local _search = nil;


local function PrepareFilter()
    _search = WCollections:PrepareSearchQuery(_search);
end


local function MatchesFilter(auraID)
    local name, spellID = C_AurasJournal.GetAuraInfoByID(auraID);

    if(name == "") then
        return false;
    end

    if not WCollections:TextMatchesSearch(name, _search) then
        return false;
    end

    return true;
end

function C_AurasJournal.RefreshAuras() 
    local oldAuras;
    if next(_collectedAurasID) then
        oldAuras = CopyTable(_collectedAurasID);
    end

    table.wipe(_aurasIDs);
    table.wipe(_collectedAurasID);
    table.wipe(_filteredAurasIDs);

    PrepareFilter();
    C_AurasJournal.GetAurasList();
    C_AurasJournal.UpdateActiveAura();
    
    local index = 1;
    for auraID, models in pairs(WCollections.AurasTemplate) do
        if models then
            table.insert(_aurasIDs, auraID);

            if(WCollections:HasAura(auraID)) then
                _collectedAurasID[auraID] = index;
            end
            if oldAuras and not oldAuras[auraID] then
                WCollections:GetAurasNeedFanfareContainer()[auraID] = true;
            end
            index = index + 1;
        end
    end

    for _, auraID in ipairs(_aurasIDs) do
        if MatchesFilter(auraID) then
            table.insert(_filteredAurasIDs, auraID);
        end
    end

    table.sort(_filteredAurasIDs, function(a, b)
        local nameA, _, _, _, _, isFavoriteA, _, isCollectedA = C_AurasJournal.GetAuraInfoByID(a);
        local nameB, _, _, _, _, isFavoriteB, _, isCollectedB = C_AurasJournal.GetAuraInfoByID(b);

        if isFavoriteA ~= isFavoriteB then
            return isFavoriteA;
        end

        if isCollectedA ~= isCollectedB then
            return isCollectedA;
        end

        return nameA < nameB;
    end);
end

function C_AurasJournal.GetCollectedFilterSetting(filterIndex)
    return not WCollections:GetCVarBitfield("aurasJournalGeneralFilters", filterIndex);
end

function C_AurasJournal.GetDisplayedAuraInfo(displayIndex)
    local auraID = _filteredAurasIDs[displayIndex];
    if auraID then
        return C_AurasJournal.GetAuraInfoByID(auraID);
    end
end

function C_AurasJournal.GetIsFavorite(aurasIndex)
    local aurasID = _filteredAurasIDs[aurasIndex];
    local isFavorite = aurasID and WCollections:GetAurasFavoritesContainer()[aurasID] and true or false;
    local canSetFavorite = true;
    return isFavorite, canSetFavorite;
end

function C_AurasJournal.GetAuraIDs()
    return _aurasIDs;
end

function C_AurasJournal.GetAuraInfoByID(auraID)
    local _, name, icon, modelPath, isActive, isFavorite, source, isCollected;

    name, _, icon = GetSpellInfo(auraID);
    if(name) then
        if(icon == '' or icon == nil) then
            icon = "Interface\Icons\Trade_Engineering";
        end

        isFavorite = WCollections:GetAurasFavoritesContainer()[auraID] and true or false;
        source = WCollections.AurasTemplate[auraID][2];
        modelPath = WCollections.AurasTemplate[auraID][1];

        if _collectedAurasID[auraID] then
            isCollected = true;
        else
            isCollected = false;
        end

        local activeAura = tonumber(WCollections:GetActiveVisualAura());
        if (auraID == activeAura) then
            isActive = true;
        else
            isActive = false;
        end

        return name or "", auraID, icon, modelPath, isActive, isFavorite, source, isCollected;
    end
    return "Unnamed aura", 0, icon, modelPath, isActive, isFavorite, source, isCollected;
end

function C_AurasJournal.GetNumDisplayedAuras()
    return #_filteredAurasIDs;
end

function C_AurasJournal.GetNumAuras()
    return #_aurasIDs;
end

function C_AurasJournal.ClearFanfare(auraID)
    WCollections:GetAurasNeedFanfareContainer()[auraID] = nil;
end

function C_AurasJournal.NeedsFanfare(auraID)
    return WCollections:GetAurasNeedFanfareContainer()[auraID];
end

local function SearchUpdated()
    WCollections:RaiseEvent("AURAS_JOURNAL_SEARCH_UPDATED");
end

function C_AurasJournal.SetAllSourceFilters(isChecked)
    for filterIndex = 1, C_PetJournal.GetNumPetSources() do
        WCollections:SetCVarBitfield("aurasJournalSourcesFilter", filterIndex, not isChecked);
    end
    SearchUpdated();
end

function C_AurasJournal.SetIsFavorite(aurasIndex, isFavorite)
    local aurasID = _filteredAurasIDs[aurasIndex];
    if aurasID then
        WCollections:GetAurasFavoritesContainer()[aurasID] = isFavorite and true or nil;
    end
    SearchUpdated();
end

function C_AurasJournal.SetSearch(searchValue)
    _search = searchValue;
    SearchUpdated();
end

function C_AurasJournal.ClearRecentFanfares()
    table.wipe(WCollections:GetAurasNeedFanfareContainer());
end

function C_AurasJournal.UpdateActiveAura()
    WCollections:SendAddonMessage("AURAS:ACTIVE");
end

function C_AurasJournal.GetAurasList()
    WCollections:SendAddonMessage("LIST:AURAS");
end
