C_NewsJournal = C_NewsJournal or { };

local _NewsIDs = { };
local _filteredNewsIDs = { };
local _search = nil;
local _showRegular = nil;
local _showMaintenance = nil;
local _showUpdates = nil;
local _showCustom = nil;
local _showFeature = nil;

C_NewsJournal.News = C_NewsJournal.News or { };

local function PrepareFilter()
    _search = WCollections:PrepareSearchQuery(_search);
    _showRegular = C_NewsJournal.IsTypeChecked(1);
    _showMaintenance = C_NewsJournal.IsTypeChecked(2);
    _showUpdates = C_NewsJournal.IsTypeChecked(3);
    _showCustom = C_NewsJournal.IsTypeChecked(4);
    _showFeature = C_NewsJournal.IsTypeChecked(5);
end


local function MatchesFilter(NewsID)
    local Date, Title, newsID, Text, icon, Type, isPublic= C_NewsJournal.GetNewsInfoByID(NewsID);

    if(Title == "") then
        return false;
    end

    if not WCollections:TextMatchesSearch(Title, _search) then
        return false;
    end

    if(Type == 1 and not _showRegular ) then
        return false;
    end

    if(Type == 2 and not _showMaintenance ) then
        return false;
    end

    if(Type == 3 and not _showUpdates ) then
        return false;
    end

    if(Type == 4 and not _showCustom ) then
        return false;
    end

    if(Type == 5 and not _showFeature ) then
        return false;
    end

    return true;
end

function C_NewsJournal.RefreshNews() 
    local oldNews;
    if next(C_NewsJournal.News) then
        oldNews = CopyTable(C_NewsJournal.News);
    end

    table.wipe(_NewsIDs);
    table.wipe(_filteredNewsIDs);
    table.wipe(C_NewsJournal.News);

    PrepareFilter();

    for NewsID, info in pairs(WCollections.Cache.News) do
        local news_time, title, text, newsType, isPublic = unpack(info);
        if (#title > 0)  then
            C_NewsJournal.News[NewsID] = info;
        end
    end
    
    for NewsID, info in pairs(C_NewsJournal.News) do
        local _, title, _, _, isPublic = unpack(info);
        if #title > 0 then
            if not tContains(_NewsIDs, NewsID) then
                table.insert(_NewsIDs, NewsID);
            end

            if (oldNews and not oldNews[NewsID]) then
                if(isPublic == 1) then
                    WCollections:GetNewsNeedFanfareContainer()[NewsID] = true;
                end
            end
            local needFanFare = C_NewsJournal.NeedsFanfare(NewsID);
            if(needFanFare) then
                WCollections:SetAnnounce(NewsID);
            end
        end
    end


    for _, NewsID in ipairs(_NewsIDs) do
        if MatchesFilter(NewsID) then
            table.insert(_filteredNewsIDs, NewsID);
        end
    end

    table.sort(_filteredNewsIDs, function(a, b)
        local Date_A, _, _, _, _, _ = C_NewsJournal.GetNewsInfoByID(a);
        local Date_B, _, _, _, _, _ = C_NewsJournal.GetNewsInfoByID(b);
        Date_A = tonumber(Date_A);
        Date_B = tonumber(Date_B);
        return Date_A > Date_B;
    end);
end

function C_NewsJournal.GetDisplayedNewsInfo(displayIndex)
    local NewsID = _filteredNewsIDs[displayIndex];
    if NewsID then
        return C_NewsJournal.GetNewsInfoByID(NewsID);
    end
end

function C_NewsJournal.GetNewsIDs()
    return _NewsIDs;
end

function C_NewsJournal.GetNewsInfoByID(NewsID)
    local Date, Title, Text, Type, icon, isPublic;

    if(C_NewsJournal.News[NewsID]) then
        Date     = C_NewsJournal.News[NewsID][1];
        Title    = C_NewsJournal.News[NewsID][2];
        Text     = C_NewsJournal.News[NewsID][3];
        Type     = C_NewsJournal.News[NewsID][4];
        isPublic = C_NewsJournal.News[NewsID][5];

        if Type == 1 then -- Regular news
            icon = [[Interface\Icons\inv_scroll_08]];
        elseif Type == 2 then -- Maintenance
            icon = [[Interface\Icons\INV_Gizmo_RocketLauncher]];
        elseif Type == 3 then -- Updates
            icon = [[Interface\AddOns\WCollections\Interface\Icons\ui_mission_itemupgrade]];
        elseif Type == 4 then -- Custom
            icon = [[Interface\Icons\INV_Helmet_06]];
        elseif Type == 5 then -- Feature
            icon = [[Interface\AddOns\WCollections\Interface\Icons\inv_letter_02]];
        end
    end

    return Date, Title, NewsID, Text, icon, Type, isPublic;
end

function C_NewsJournal.GetNumDisplayedNews()
    return #_filteredNewsIDs;
end

function C_NewsJournal.GetNumNews()
    return #_NewsIDs;
end

local function SearchUpdated()
    WCollections:RaiseEvent("NEWS_JOURNAL_SEARCH_UPDATED");
end

function C_NewsJournal.SetSearch(searchValue)
    _search = searchValue;
    SearchUpdated();
end

function C_NewsJournal.SetTypeFilter(filterIndex, isChecked)
    WCollections:SetCVarBitfield("newsJournalTypeFilter", filterIndex, not isChecked);
    SearchUpdated();
end

function C_NewsJournal.SetDefaultFilters()
    WCollections:SetCVar("newsJournalTypeFilter", 0);
    SearchUpdated();
end

function C_NewsJournal.IsUsingDefaultFilters()
    return WCollections:GetCVar("newsJournalTypeFilter") == 0;
end

function C_NewsJournal.IsTypeChecked(filterIndex)
    return not WCollections:GetCVarBitfield("newsJournalTypeFilter", filterIndex);
end

function C_NewsJournal.SynchronizationNews()
    local msg = "NEWS:SYNC";
    for NewsID, info in pairs(WCollections.Cache.News) do
        local  time_news, title, _, _, isPublic = unpack(info);
        time_news = tostring(time_news);
        msg = msg..":"..NewsID..":"..time_news;
    end
    msg = msg .. ":END";
    WCollections:SendAddonMessage(msg);
end

function C_NewsJournal.ClearRecentFanfares()
    table.wipe(WCollections:GetNewsNeedFanfareContainer());
end

function C_NewsJournal.ClearFanfare(newsID)
    if(WCollections:GetNewsNeedFanfareContainer()[newsID]) then
        WCollections:GetNewsNeedFanfareContainer()[newsID] = nil;
    end
end

function C_NewsJournal.NeedsFanfare(newsId)
    return WCollections:GetNewsNeedFanfareContainer()[newsId];
end

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' 
-- encoding
function enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- decoding
function dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end
