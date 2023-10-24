C_NewsJournal = C_NewsJournal or { };

local _NewsIDs = { };
local _filteredNewsIDs = { };
local _search = nil;


local function PrepareFilter()
    _search = WCollections:PrepareSearchQuery(_search);
end


local function MatchesFilter(NewsID)
    local name, spellID = C_NewsJournal.GetNewsInfoByID(NewsID);

    if(name == "") then
        return false;
    end

    if not WCollections:TextMatchesSearch(name, _search) then
        return false;
    end

    return true;
end

function C_NewsJournal.RefreshNews() 
    table.wipe(_NewsIDs);
    table.wipe(_filteredNewsIDs);

    PrepareFilter();
    C_NewsJournal.GetNewsList();

    C_NewsJournal.NewsList =
    {
        [1] = {"[Legion] Открытие Аргуса", "Уважаемые игроки! Рады сообщить, что 22.10.2023 в 17:00 по МСК на WoWCircle Legion x11 в рамках патча 7.3 «Тени Аргуса», станет доступен следующий контент: |n|n"..
        "- Анторус, Пылающий Трон в обычной и героической сложности (эпохальная и поиск рейда через 1-2 недели).|n"..
        "- Новое Подземелье на пять человек - Престол Триумвирата.|n"..
        "- Три Новых зоны и активности - Мак`кари, Крокуун, Пустоши Анторуса.|n"..
        "- Новая Активность - Точки Вторжения."..
        "- Подземелье Собор Вечной Ночи станет доступен в эпохальном+ режиме (в ключах)|n"..
        "https://www.youtube.com/watch?v=D-3Z0_5xKX4", 1, 1},
        [2] = {"Техработы", "Bla-bla Bla-bla Bla-bla Bla-bla Bla-bla Bla-bla Bla-bla Bla-bla Bla-bla Bla-bla", 2, 1},
        [3] = {"[Wotlk] Апдейтпак", "Bla-bla Bla-bla Bla-bla Bla-bla Bla-bla Bla-bla Bla-bla Bla-bla Bla-bla Bla-bla", 3, 1},
        [4] = {"[Wotlk] Арена Хаоса 1х1", "В недавнем обновлении, мы добавили в игру новый режим дуэлей 1х1, с рабочим названием Арена Хаоса.|n|n"..
        "Главной особенностью Арены Хаоса является ее непредсказуемость, когда вы принимаете вызов и попадаете на арену с оппонентом, формат сражения может меняться, например, во время боя могут случайным образом активироваться различные бафы, дебафы и заклинания, которые могут повлиять на ход сражения."..
        "По умолчанию для данного режима установлена карта Арена Награнда, а также все стандартные правила арены, помимо этого применен весь наш кастом для турнирной арены, длительность боя не более 15 минут, также со временем появляется тикающий бафф на + урон.|n|n"..
        "|c000fFFFFЧтобы вызвать игрока на бой, нужно прописать команду в чат:|r|n"..
        "|cffffffff.challenge ИМЯ ИГРОКА|r|n|n"..
        "|c000fFFFFВключать и выключать возможность вызывать вас в такой формат дуэлей (по умолчанию включено):|r|n"..
        "|cffffffff.challenge on/off|r|n|n"..
        "Данный режим работает только внутри вашего игрового мира, это означает что играя на х5, вы не сможете позвать на дуэль игрока с х1.|n"..
        "В первую очередь это фановый мод, наград за него НЕ предусмотрено.|n"..
        "Данный режим работает в виде открытого теста, со временем будет больше разного рода фишек, часть из которых можете предложить Вы https://forum.wowcircle.com/showthread.php?t=1230652", 4, 1},
        [5] = {"Особенности проекта", "Bla-bla Bla-bla Bla-bla Bla-bla Bla-bla Bla-bla Bla-bla Bla-bla Bla-bla Bla-bla", 5, 0},
    };
    
    local index = 1;
    for NewsID, info in pairs(C_NewsJournal.NewsList) do
        local _, _, _, isPublic = unpack(info);
        if isPublic == 1 then
            table.insert(_NewsIDs, NewsID);
            index = index + 1;
        end
    end

    for _, NewsID in ipairs(_NewsIDs) do
        if MatchesFilter(NewsID) then
            table.insert(_filteredNewsIDs, NewsID);
        end
    end

    table.sort(_filteredNewsIDs, function(a, b)
        return a < b;
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
    local Title, Text, Type, icon, isPublic;

    Title    = C_NewsJournal.NewsList[NewsID][1];
    Text     = C_NewsJournal.NewsList[NewsID][2];
    Type     = C_NewsJournal.NewsList[NewsID][3];
    isPublic = C_NewsJournal.NewsList[NewsID][4];

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

    return Title, NewsID, Text, icon, isPublic;
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

function C_NewsJournal.SetAllSourceFilters(isChecked)
    for filterIndex = 1, C_PetJournal.GetNumPetSources() do
        WCollections:SetCVarBitfield("AurasJournalSourcesFilter", filterIndex, not isChecked);
    end
    SearchUpdated();
end

function C_NewsJournal.SetSearch(searchValue)
    _search = searchValue;
    SearchUpdated();
end

function C_NewsJournal.GetNewsList()
    WCollections:SendAddonMessage("LIST:AURAS");
end
