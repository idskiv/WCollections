local ADDON_NAME = ...;
local ADDON_VERSION = GetAddOnMetadata(ADDON_NAME, "Version");

local ADDON_PREFIX = "WCollections";
local ENCHANT_HIDDEN = 88;
local ITEM_HIDDEN = 15;
local ITEM_BACK = 16;
TRANSMOGRIFY_FONT_COLOR = { r = 1, g = 0.5, b = 1 };
TRANSMOGRIFY_FONT_COLOR_CODE = "|cFFFF80FF";

local TRANSMOGRIFIABLE_SLOTS =
{
    [1] = "HeadSlot",
    -- [2] = "NeckSlot",
    [3] = "ShoulderSlot",
    [4] = "ShirtSlot",
    [5] = "ChestSlot",
    [6] = "WaistSlot",
    [7] = "LegsSlot",
    [8] = "FeetSlot",
    [9] = "WristSlot",
    [10] = "HandsSlot",
    -- [11] = "Finger0Slot",
    -- [12] = "Finger1Slot",
    -- [13] = "Trinket0Slot",
    -- [14] = "Trinket1Slot",
    [15] = "BackSlot",
    [16] = "MainHandSlot",
    [17] = "SecondaryHandSlot",
    [18] = "RangedSlot",
    [19] = "TabardSlot",
};

local INVTYPE_ENUM_TO_NAME =
{
    [0] = "INVTYPE_NON_EQUIP",
    [1] = "INVTYPE_HEAD",
    [2] = "INVTYPE_NECK",
    [3] = "INVTYPE_SHOULDER",
    [4] = "INVTYPE_BODY",
    [5] = "INVTYPE_CHEST",
    [6] = "INVTYPE_WAIST",
    [7] = "INVTYPE_LEGS",
    [8] = "INVTYPE_FEET",
    [9] = "INVTYPE_WRIST",
    [10] = "INVTYPE_HAND",
    [11] = "INVTYPE_FINGER",
    [12] = "INVTYPE_TRINKET",
    [13] = "INVTYPE_WEAPON",
    [14] = "INVTYPE_SHIELD",
    [15] = "INVTYPE_RANGED",
    [16] = "INVTYPE_CLOAK",
    [17] = "INVTYPE_2HWEAPON",
    [18] = "INVTYPE_BAG",
    [19] = "INVTYPE_TABARD",
    [20] = "INVTYPE_ROBE",
    [21] = "INVTYPE_WEAPONMAINHAND",
    [22] = "INVTYPE_WEAPONOFFHAND",
    [23] = "INVTYPE_HOLDABLE",
    [24] = "INVTYPE_AMMO",
    [25] = "INVTYPE_THROWN",
    [26] = "INVTYPE_RANGEDRIGHT",
    [27] = "INVTYPE_QUIVER",
    [28] = "INVTYPE_RELIC",
};

local CLASS_ID_TO_NAME =
{
    "WARRIOR",
    "PALADIN",
    "HUNTER",
    "ROGUE",
    "PRIEST",
    "DEATHKNIGHT",
    "SHAMAN",
    "MAGE",
    "WARLOCK",
    "MONK",
    "DRUID",
    "DEMONHUNTER",
    "ANY",
};

local RACE_ID_TO_NAME =
{
    "HUMAN",
    "ORC",
    "DWARF",
    "NIGHTELF",
    "UNDEAD",
    "TAUREN",
    "GNOME",
    "TROLL",
    "GOBLIN",
    "BLOODELF",
    "DRAENEI",
    "ANY",
};

local ACTIONBUTTON_UPDATE_STATE = 1;
local ACTIONBUTTON_UPDATE_USABLE = 2;
local ACTIONBUTTON_UPDATE_COOLDOWN = 3;

local oGetInventoryItemID = GetInventoryItemID;

-- ---------
-- Ace Addon
-- ---------
local addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceEvent-3.0", "AceTimer-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME);

function addon:OnInitialize()
    BINDING_HEADER_WCOLLECTIONS                    = L["Binding.Header"];
    BINDING_NAME_WCOLLECTIONS_UNLOCK_SKIN          = L["Binding.UnlockSkin"];
    BINDING_NAME_WCOLLECTIONS_MENU_WOWCIRCLE       = L["Binding.Menu.Wowcircle"];
    BINDING_NAME_WCOLLECTIONS_MENU_TRANSMOG        = L["Binding.Menu.Transmog"];
    BINDING_NAME_WCOLLECTIONS_MENU_TRANSMOG_SETS   = L["Binding.Menu.Transmog.Sets"];
    BINDING_NAME_WCOLLECTIONS_MENU_COLLECTIONS     = L["Binding.Menu.Collections"];
    BINDING_NAME_WCOLLECTIONS_MENU_DAILY           = L["Binding.Menu.Daily"];

    self:RegisterEvent("CHAT_MSG_ADDON");
    self:RegisterEvent("PLAYER_LOGIN");
    self:RegisterEvent("PLAYER_LOGOUT");
    self:RegisterEvent("INSPECT_TALENT_READY");
    self:RegisterEvent("UNIT_INVENTORY_CHANGED");
    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
    self:RegisterEvent("BANKFRAME_OPENED");
    self:RegisterEvent("BAG_UPDATE");
    self:RegisterEvent("PLAYERBANKSLOTS_CHANGED");
    self:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED");
    self:RegisterEvent("ADDON_LOADED");
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("COMPANION_LEARNED");
    self:RegisterEvent("COMPANION_UNLEARNED");
    self:RegisterEvent("SPELL_UPDATE_USABLE");
    self:RegisterEvent("ACTIONBAR_UPDATE_USABLE");
    self:RegisterEvent("UNIT_SPELLCAST_START");
    self:RegisterEvent("UNIT_SPELLCAST_FAILED");
    self:RegisterEvent("PLAYER_REGEN_ENABLED");
    self:RegisterEvent("PLAYER_REGEN_DISABLED");

    local function MakePresetColor(order, name, hex, r, g, b, a)
        if not r then
            a, r, g, b = hex:match("|c(%x%x)(%x%x)(%x%x)(%x%x)");
            a = (tonumber(a or "FF", 16) or 255) / 255;
            r = (tonumber(r or "FF", 16) or 255) / 255;
            g = (tonumber(g or "FF", 16) or 255) / 255;
            b = (tonumber(b or "FF", 16) or 255) / 255;
        end
        return { Name = hex..name..FONT_COLOR_CODE_CLOSE, r = r, g = g, b = b, a = a, code = hex, key = format("%08x:%s", order, name) };
    end
    local PRESET_COLORS =
    {
        red         = MakePresetColor( 50, L["Color.Red"],      "|cFFFF0000"),
        orange      = MakePresetColor(100, L["Color.Orange"],   "|cFFF89133"),
        gold        = MakePresetColor(200, L["Color.Gold"],     "|cFFFFD200"),
        yellow      = MakePresetColor(300, L["Color.Yellow"],   "|cFFFFFF00"),
        dandelion   = MakePresetColor(350, L["Color.Dandelion"],"|cFFEBE140"),
        green       = MakePresetColor(400, L["Color.Green"],    "|cFF6BCC45"),
        teal        = MakePresetColor(450, L["Color.Teal"],     "|cFF009C70"),
        cyan        = MakePresetColor(500, L["Color.Cyan"],     "|cFF15A9F8"),
        blue        = MakePresetColor(600, L["Color.Blue"],     "|cFF88AAFF"),
        pink        = MakePresetColor(700, L["Color.Pink"],     TRANSMOGRIFY_FONT_COLOR_CODE, TRANSMOGRIFY_FONT_COLOR.r, TRANSMOGRIFY_FONT_COLOR.g, TRANSMOGRIFY_FONT_COLOR.b),
        white       = MakePresetColor(800, L["Color.White"],    "|cFFFFFFFF"),
        gray        = MakePresetColor(850, L["Color.Gray"],     "|cFF808080"),
        black       = MakePresetColor(900, L["Color.Black"],    "|cFF000000"),
    };

    local defaultsConfig =
    {
        profile =
        {
            NewVersion =
            {
                HideRetiredPopup = false,
                SkipVersionPopup = nil,
            },
            ChatLinks =
            {
                OutfitIcon =
                {
                    Enable = true,
                    Size = 17,
                    Offset = -2,
                },
            },
            Alerts =
            {
                AddSkin =
                {
                    Enable = true,
                    Color = { Custom = false, r = PRESET_COLORS["pink"].r, g = PRESET_COLORS["pink"].g, b = PRESET_COLORS["pink"].b, a = PRESET_COLORS["pink"].a },
                    FullRowColor = false,
                },
                AddToy =
                {
                    Enable = true,
                    Color = { Custom = false, r = PRESET_COLORS["yellow"].r, g = PRESET_COLORS["yellow"].g, b = PRESET_COLORS["yellow"].b, a = PRESET_COLORS["yellow"].a },
                },
            },
            TooltipFlags =
            {
                Enable = true,
                Color = { Custom = false, r = PRESET_COLORS["pink"].r, g = PRESET_COLORS["pink"].g, b = PRESET_COLORS["pink"].b, a = PRESET_COLORS["pink"].a },
            },
            TooltipTransmog =
            {
                Enable = true,
                IconEntry =
                {
                    Enable = false,
                    Size = 0,
                    Crop = true,
                },
                IconEnchant =
                {
                    Enable = false,
                    Size = 0,
                    Crop = true,
                },
                Color = { Custom = false, r = PRESET_COLORS["pink"].r, g = PRESET_COLORS["pink"].g, b = PRESET_COLORS["pink"].b, a = PRESET_COLORS["pink"].a },
                NewHideVisualIcon = true,
            },
            TooltipCollection =
            {
                OwnedItems = false,
                Skins = true,
                SkinUnlock = true,
                TakenQuests = false,
                RewardedQuests = false,
                Toys = true,
                ToyUnlock = true,
                ToyUnlockEmbed = true,
                Color = { Custom = false, r = PRESET_COLORS["blue"].r, g = PRESET_COLORS["blue"].g, b = PRESET_COLORS["blue"].b, a = PRESET_COLORS["blue"].a },
                Separator = true,
            },
            TooltipSets =
            {
                Collected = true,
                Uncollected = true,
                Color = { Custom = false, r = PRESET_COLORS["blue"].r, g = PRESET_COLORS["blue"].g, b = PRESET_COLORS["blue"].b, a = PRESET_COLORS["blue"].a },
                Separator = true,
                SlotStateStyle = 2,
            },
            RestoreItemIcons =
            {
                Equipment = true,
                Inspect = true,
                EquipmentManager = true,
                Global = false,
            },
            RestoreItemSets =
            {
                Equipment = true,
                Inspect = true,
            },
            Misc =
            {
                WintergraspButton = true,
                CFBGFactionIcons = true,
                CompressCache = true,
            },
            ActionButtons =
            {
                Mounts = true,
                MountsPerf = true,
                Toys = true,
                Addons =
                {
                    Bartender = true,
                    ButtonForge = true,
                    Dominos = true,
                    KActionBars = true,
                    LibActionButton = true,
                },
            },
            IconOverlays =
            {
                Enable = true,
                Cosmetic =
                {
                    Enable = true,
                },
                Junk =
                {
                    Enable = true,
                    Merchant = true,
                },
                ShowRecipes = true,
                Known =
                {
                    Enable = true,
                    Texture = "Known",
                    Style = "Shadow",
                    Color = { Custom = false, r = PRESET_COLORS["green"].r, g = PRESET_COLORS["green"].g, b = PRESET_COLORS["green"].b, a = PRESET_COLORS["green"].a },
                    Anchor = "TOPRIGHT",
                    Offset = 2,
                    Size = 13,
                },
                Unknown =
                {
                    Enable = true,
                    Texture = "Unknown",
                    Style = "Shadow",
                    Color = { Custom = false, r = PRESET_COLORS["orange"].r, g = PRESET_COLORS["orange"].g, b = PRESET_COLORS["orange"].b, a = PRESET_COLORS["orange"].a },
                    Anchor = "TOPRIGHT",
                    Offset = 2,
                    Size = 13,
                },
                Unowned =
                {
                    Enable = false,
                    Texture = "Unowned",
                    Style = "Shadow",
                    Color = { Custom = false, r = PRESET_COLORS["pink"].r, g = PRESET_COLORS["pink"].g, b = PRESET_COLORS["pink"].b, a = PRESET_COLORS["pink"].a },
                    Anchor = "TOPRIGHT",
                    Offset = 0,
                    Size = 13,
                },
                Addons =
                {
                    ["*"] = true,
                },
                AddonConfig = (function()
                    local result =
                    {
                        ["*"] = { },
                    };
                    for addon, module in pairs(WCollections.IconOverlays:GetAddons()) do
                        if module.GetDefaults then
                            result[addon] = module.GetDefaults();
                        end
                    end
                    return result;
                end)(),
            },
            Windows =
            {
                UpgradedConfig244 = false,
                ["**"] =
                {
                    Strata = "HIGH",
                    Layout = true,
                    Lock = false,
                    Clamp = true,
                    Escape = true,
                },
                DressUpFrame =
                {
                    Strata = "MEDIUM",
                    Blizzard = false,
                },
            },
            Wardrobe =
            {
                CameraOption = WCollections.CameraOptions[1],
                CameraOptionSetup = false,
                CameraZoomSpeed = 0.5,
                CameraZoomSmooth = true,
                CameraZoomSmoothSpeed = 0.5,
                CameraPanLimit = true,
                MicroButtonsOption = nil,
                MicroButtonsTransmogrify = nil, -- Obsolete
                MicroButtonsRMB = nil, -- Obsolete
                MicroButtonsActionLMB = nil,
                MicroButtonsActionRMB = nil,
                MicroButtonsIcon = nil,
                MinimapButtonCollections = { minimapPos = 205 },
                MinimapButtonCollectionsRMB = false,
                MinimapButtonTransmogrify = { minimapPos = 225 },
                MinimapButtonTransmogrifyRMB = false,
                OutfitsSort = 1,
                OutfitsPrepaidSheen = true,
                OutfitsSelectLastUsed = false,
                PerCharacterFavorites = false,
                HideExtraSlotsOnSetSelect = false,
                ShowWowheadSetIcon = true,
                ShowSetID = false,
                ShowItemID = false,
                ShowCollectedVisualSourceText = false,
                ShowCollectedVisualSources = false,
                WindowsCloseWithEscape = true,
                WindowsStrata = "HIGH",
                WindowsClampToScreen = true,
                WindowsLockTransmogrify = true,
                WindowsLayoutTransmogrify = true,
                WindowsLockCollections = true,
                WindowsLayoutCollections = true,
                EtherealWindowSound = true,
                DressUpClassBackground = false,
                DressUpGnomeTrollBackground = true,
                DressUpDesaturateBackground = false,
                DressUpSkipDressOnShow = false,
                PortraitButton = false,
                MountsUnusableInZone = false,
                MountsShowHidden = false,
                PetsShowHidden = false,
                ToysShowHidden = false,
                ShowCollectedToySourceText = false,
                TooltipCycleKeyboard = false,
                TooltipCycleMouseWheel = true,
                MountsDoubleClickIcon = false,
                MountsDoubleClickName = true,
                PetsDoubleClickIcon = false,
                PetsDoubleClickName = true,
                SearchClientside = true,
                SearchCacheNames = true,
                SearchSetsBySources = true,
                ElvUIDressUpFirstLaunch = false,
                ShowSetsInAppearances = true,
            },
            TransmogCollection =
            {
                PerCharacter =
                {
                    ["*"] =
                    {
                        Favorites = { },
                        SetFavorites = { },
                    },
                },
                Favorites = { },
                NewAppearances = { },
                LatestAppearanceID = nil,
                LatestAppearanceCategoryID = nil,
                SetFavorites = { },
                NewSetSources = { },
                LatestSetSource = nil,
            },
            MountJournal =
            {
                PerCharacter =
                {
                    ["*"] =
                    {
                        Favorites = { },
                        NeedFanfare = { },
                    },
                },
            },
            PetJournal =
            {
                PerCharacter =
                {
                    ["*"] =
                    {
                        Favorites = { },
                        NeedFanfare = { },
                    },
                },
            },
            ToyBox =
            {
                PerCharacter =
                {
                    ["*"] =
                    {
                        Favorites = { },
                        NeedFanfare = { },
                    },
                },
            },
            CVar =
            {
                ["*"] =
                {
                    closedInfoFrames = 0, -- Bitfield for which help frames have been acknowledged by the user
                    transmogrifySourceFilters = 0, -- Bitfield for which source filters are applied in the  wardrobe at the transmogrifier
                    wardrobeSourceFilters = 0, -- Bitfield for which source filters are applied in the wardrobe in the collection journal
                    wardrobeSetsFilters = 0, -- Bitfield for which transmog sets filters are applied in the wardrobe in the collection journal
                    transmogrifyShowCollected = true, -- Whether to show collected transmogs in the at the transmogrifier
                    transmogrifyShowUncollected = true, -- Whether to show uncollected transmogs in the at the transmogrifier
                    wardrobeShowCollected = true, -- Whether to show collected transmogs in the wardrobe
                    wardrobeShowUncollected = true, -- Whether to show uncollected transmogs in the wardrobe
                    missingTransmogSourceInItemTooltips = false, -- Whether to show if you have collected the appearance of an item but not from that item itself
                    lastTransmogOutfitIDSpec1 = "", -- SetID of the last applied transmog outfit for the 1st spec
                    lastTransmogOutfitIDSpec2 = "", -- SetID of the last applied transmog outfit for the 2nd spec
                    lastTransmogOutfitIDSpec3 = "", -- SetID of the last applied transmog outfit for the 3rd spec
                    lastTransmogOutfitIDSpec4 = "", -- SetID of the last applied transmog outfit for the 4th spec
                    -- latestTransmogSetSource, -- itemModifiedAppearanceID of the latest collected source belonging to a set
                    transmogCurrentSpecOnly = false, -- Stores whether transmogs apply to current spec instead of all specs
                    miniDressUpFrame = false,
                    mountJournalGeneralFilters = 0, -- Bitfield for which collected filters are applied in the mount journal
                    mountJournalSourcesFilter = 0, -- Bitfield for which source filters are applied in the mount journal
                    mountJournalTypeFilter = 0, -- Bitfield for which type filters are applied in the mount journal
                    petJournalFilters = 0, -- Bitfield for which collected filters are applied in the pet journal
                    petJournalSort = 1, -- Sorting value for the pet journal
                    petJournalSourceFilters = 0, -- Bitfield for which source filters are applied in the pet journal
                    petJournalTab = 5, -- Stores the last tab the pet journal was opened to
                    petJournalTypeFilters = 0, -- Bitfield for which type filters are applied in the pet journal
                    toyBoxCollectedFilters = 0, -- Bitfield for which collected filters are applied in the toybox
                    toyBoxExpansionFilters = 0, -- Bitfield for which expansion filters are applied in the toybox
                    toyBoxSourceFilters = 0, -- Bitfield for which source filters are applied in the toybox
                    showOutfitDetails = true, -- dressing room is opened in maximized mode, default on
                    -- Custom
                    transmogrifyShowClaimable = true,
                    transmogrifyShowPurchasable = true,
                    transmogrifyShowObtainable = true,
                    transmogrifyShowUnobtainable = false,
                    transmogrifyArmorFilters = 0,
                    transmogrifyClassFilters = 0,
                    transmogrifyRaceFilters = 0,
                    transmogrifyExpansionFilters = 0,
                    wardrobeArmorFilters = 0,
                    wardrobeClassFilters = 0,
                    wardrobeRaceFilters = 0,
                    wardrobeExpansionFilters = 0,
                    wardrobeSetsClassFilters = 0,
                    wardrobeSetsRaceFilters = 0,
                    wardrobeSetsExpansionFilters = 0,
                    transmogrifySetsSlotMask = 0,
                },
            }
        },
    };
    local defaultsCache =
    {
        realm =
        {
            Version = 0,
            AddonVersion = nil,
            All = { },
            Slot =
            {
                ["HEAD"]            = { },
                ["SHOULDER"]        = { },
                ["BACK"]            = { },
                ["CHEST"]           = { },
                ["TABARD"]          = { },
                ["SHIRT"]           = { },
                ["WRIST"]           = { },
                ["HANDS"]           = { },
                ["WAIST"]           = { },
                ["LEGS"]            = { },
                ["FEET"]            = { },
                ["WAND"]            = { },
                ["1H_AXE"]          = { },
                ["1H_SWORD"]        = { },
                ["1H_MACE"]         = { },
                ["DAGGER"]          = { },
                ["FIST"]            = { },
                ["SHIELD"]          = { },
                ["HOLDABLE"]        = { },
                ["2H_AXE"]          = { },
                ["2H_SWORD"]        = { },
                ["2H_MACE"]         = { },
                ["STAFF"]           = { },
                ["POLEARM"]         = { },
                ["BOW"]             = { },
                ["GUN"]             = { },
                ["CROSSBOW"]        = { },
                ["THROWN"]          = { },
                ["FISHING_POLE"]    = { },
                ["MISC"]            = { },
                ["ENCHANT"]         = { },
            },
            ScrollToEnchant = { },
            EnchantToScroll = { },
            RecipeToDressable = { },
            Sets = { },
            Cameras = { },
            Toys = { },
        },
    };

    local config = LibStub("AceDB-3.0"):New(ADDON_NAME.."Config", defaultsConfig, true);
    WCollections.Config = config.profile;
    local cache = LibStub("AceDB-3.0"):New(ADDON_NAME.."Cache", defaultsCache, true);
    WCollections.Cache = cache.realm;

    WCollections.ClearCache = function(self)
        cache:ResetDB(nil);
        self.Cache = cache.realm;
    end;

    do
        for slot, db in pairs(WCollections.Cache.Slot) do
            if db.Packed then
                for id in db.Packed:gmatch("[^,]+") do
                    table.insert(db, tonumber(id));
                end
                db.Packed = nil;
            end
        end
        for id, info in pairs(WCollections.Cache.All) do
            if type(id) == "number" and type(info) == "string" then
                WCollections.Cache.All[id] = WCollections.UnpackSkin(info);
            end
        end
        local setsUnpacked = false;
        for id, info in pairs(WCollections.Cache.Sets) do
            if  type(id) == "number" and type(info) == "string" then
                WCollections.Cache.Sets[id] = WCollections.UnpackSet(id, info);
                setsUnpacked = true;
            end
        end
        if setsUnpacked then
            WCollections:PostprocessSetsAfterLoading();
        end
    end

    -- General
    local panels = { };
    local showAdvancedOptions = false;
    local bigButtonCounter = 1;
    local mediumButtonCounter = 1;
    local chatFontTextCounter = 1;
    local settingsButtonCounter = 1;
    LibStub("AceGUI-3.0"):RegisterWidgetType("WCollectionsOptionsBigButtonTemplate", function()
        local self =
        {
            type = "WCollectionsOptionsBigButtonTemplate",
            frame = CreateFrame("Button", "WCollectionsOptionsBigButton"..bigButtonCounter, nil, "WCollectionsOptionsBigButtonTemplate"),
        };
        self.frame.obj = self;
        bigButtonCounter = bigButtonCounter + 1;
        function self:OnAcquire()
        end
        function self:OnRelease()
        end
        function self:SetLabel(text)
            self.frame.ContentsFrame.Header:SetText(text);
        end
        function self:SetText(text)
            self.frame.ContentsFrame.Text:SetText(text);
        end
        LibStub("AceGUI-3.0"):RegisterAsWidget(self);
        return self;
    end, 1);
    LibStub("AceGUI-3.0"):RegisterWidgetType("WCollectionsOptionsMediumButtonTemplate", function()
        local self =
        {
            type = "WCollectionsOptionsMediumButtonTemplate",
            frame = CreateFrame("Button", "WCollectionsOptionsMediumButton"..mediumButtonCounter, nil, "WCollectionsOptionsMediumButtonTemplate"),
        };
        self.frame.obj = self;
        mediumButtonCounter = mediumButtonCounter + 1;
        function self:OnAcquire()
        end
        function self:OnRelease()
        end
        function self:SetLabel(text)
            self.frame.ContentsFrame.Header:SetText(text);
        end
        function self:SetText(text)
            self.frame.ContentsFrame.Text:SetText(text);
        end
        LibStub("AceGUI-3.0"):RegisterAsWidget(self);
        return self;
    end, 1);
    LibStub("AceGUI-3.0"):RegisterWidgetType("WCollectionsOptionsMicroButtonIconTemplate", function()
        local self =
        {
            type = "WCollectionsOptionsMicroButtonIconTemplate",
            frame = CreateFrame("CheckButton", nil, nil, "WCollectionsOptionsMicroButtonIconTemplate"),
        };
        self.frame.obj = self;
        Mixin(self.frame, SetEnabledMixin);
        function self:OnAcquire()
        end
        function self:OnRelease()
        end
        function self:SetLabel(text)
            self.frame:GetNormalTexture():SetTexture(format("%s-Up", text));
            self.frame:GetPushedTexture():SetTexture(format("%s-Down", text));
            self.frame:GetCheckedTexture():SetTexture(format("%s-Down", text));
        end
        function self:SetText(text)
        end
        function self:SetDisabled(disabled)
            self.frame:SetEnabled(not disabled);
            self.frame:GetNormalTexture():SetDesaturated(disabled);
            self.frame:GetPushedTexture():SetDesaturated(disabled);
            self.frame:GetCheckedTexture():SetDesaturated(disabled);
        end
        function self:OnWidthSet(width)
            if width ~= 28 then
                self:SetWidth(28);
                self:SetHeight(37);
            end
        end
        LibStub("AceGUI-3.0"):RegisterAsWidget(self);
        return self;
    end, 1);
    LibStub("AceGUI-3.0"):RegisterWidgetType("WCollectionsOptionsChatFontTextTemplate", function()
        local self =
        {
            type = "WCollectionsOptionsChatFontTextTemplate",
            frame = CreateFrame("Frame", "WCollectionsOptionsChatFontText"..chatFontTextCounter, nil, "WCollectionsOptionsChatFontTextTemplate"),
        };
        self.frame.obj = self;
        chatFontTextCounter = chatFontTextCounter + 1;
        function self:OnAcquire()
        end
        function self:OnRelease()
        end
        function self:SetLabel(text)
            self.frame.Text:SetFont(DEFAULT_CHAT_FRAME:GetFont());
            self.frame.Text:SetText(text);
            self.frame:SetHeight(math.max(30, self.frame.Text:GetStringHeight()));
        end
        function self:SetText(text)
        end
        LibStub("AceGUI-3.0"):RegisterAsWidget(self);
        return self;
    end, 1);
    LibStub("AceGUI-3.0"):RegisterWidgetType("WCollectionsOptionsCheckBoxWithSettingsTemplate", function()
        local self = LibStub("AceGUI-3.0"):Create("CheckBox");
        self.settingsButton = CreateFrame("CheckButton", "WCollectionsCheckBoxWithSettings"..settingsButtonCounter, self.frame, "WCollectionsOptionsCheckBoxWithSettingsTemplate");
        self.settingsButton.obj = self;
        settingsButtonCounter = settingsButtonCounter + 1;
        function self.settingsButton:GetArg()
            return self.obj:GetUserDataTable().option.arg;
        end
        return self;
    end, 1);
    hooksecurefunc("FCF_SetChatWindowFontSize", function()
        for i = 1, chatFontTextCounter do
            local frame = _G["WCollectionsOptionsChatFontText"..i];
            if frame then
                frame.Text:SetFont(DEFAULT_CHAT_FRAME:GetFont());
            end
        end
    end);

    -- Wardrobe
    local function updateSpecButton()
        if WCollections.Config.Wardrobe.OutfitsSelectLastUsed then
            WardrobeTransmogFrame.SpecButton:Enable();
            WardrobeTransmogFrame.SpecButton:EnableMouse(true);
            WardrobeTransmogFrame.SpecButton.Icon:SetDesaturated(false);
        else
            WardrobeTransmogFrame.SpecButton:Disable();
            WardrobeTransmogFrame.SpecButton:EnableMouse(false);
            WardrobeTransmogFrame.SpecButton.Icon:SetDesaturated(true);
            WardrobeTransmogFrame.SpecHelpBox:Hide();
        end
    end
    updateSpecButton();

    -- Windows
    local getWindows;
    local windowStratas;
    local updateWindows;
    do
        if not WCollections.Config.Windows.UpgradedConfig244 and WCollections.Cache and WCollections.Cache.AddonVersion and WCollections.Cache.AddonVersion < ADDON_VERSION then
            WCollections.Config.Windows["WardrobeFrame"     ].Strata = WCollections.Config.Wardrobe.WindowsStrata;
            WCollections.Config.Windows["WardrobeFrame"     ].Layout = WCollections.Config.Wardrobe.WindowsLayoutTransmogrify and WCollections.Config.Wardrobe.WindowsLockTransmogrify;
            WCollections.Config.Windows["WardrobeFrame"     ].Lock   = WCollections.Config.Wardrobe.WindowsLockTransmogrify;
            WCollections.Config.Windows["WardrobeFrame"     ].Clamp  = WCollections.Config.Wardrobe.WindowsClampToScreen;
            WCollections.Config.Windows["WardrobeFrame"     ].Escape = WCollections.Config.Wardrobe.WindowsCloseWithEscape;
            WCollections.Config.Windows["CollectionsJournal"].Strata = WCollections.Config.Wardrobe.WindowsStrata;
            WCollections.Config.Windows["CollectionsJournal"].Layout = WCollections.Config.Wardrobe.WindowsLayoutCollections and WCollections.Config.Wardrobe.WindowsLockCollections;
            WCollections.Config.Windows["CollectionsJournal"].Lock   = WCollections.Config.Wardrobe.WindowsLockCollections;
            WCollections.Config.Windows["CollectionsJournal"].Clamp  = WCollections.Config.Wardrobe.WindowsClampToScreen;
            WCollections.Config.Windows["CollectionsJournal"].Escape = WCollections.Config.Wardrobe.WindowsCloseWithEscape;
        end
        WCollections.Config.Windows.UpgradedConfig244 = true;
        getWindows = function() return { "CollectionsJournal", "WardrobeFrame", "DressUpFrame" }; end;
        windowStratas =
        {
            "BACKGROUND",
            "LOW",
            "MEDIUM",
            "HIGH",
            "DIALOG",
        };
        updateWindows = function(togglingLayout)
            local dressUpAddon = IsAddOnLoaded("WCollectionsDressUp");
            for _, windowName in ipairs(getWindows()) do
                local window = _G[windowName];
                local config = WCollections.Config.Windows[windowName];
                if windowName == "DressUpFrame" then
                    if not config.Blizzard and not dressUpAddon then break; end
                    GetUIPanelWidth(window); -- Trigger GetUIPanelWindowInfo so that it creates the attributes UIPanelLayout-defined and UIPanelLayout-enabled
                end

                if not config.Layout and config.Escape then
                    if not tContains(UISpecialFrames, windowName) then
                        table.insert(UISpecialFrames, windowName);
                    end
                else
                    tDeleteItem(UISpecialFrames, windowName);
                end
                window:SetMovable(not config.Layout);
                window:SetFrameStrata(config.Strata);
                window:SetClampedToScreen(not config.Layout and config.Clamp);
                local wasOpen;
                if togglingLayout then
                    wasOpen = window:IsShown();
                    HideUIPanel(window);
                end
                window:SetAttribute("UIPanelLayout-enabled", config.Layout);
                UpdateUIPanelPositions(window);
                if wasOpen then
                    ShowUIPanel(window);
                end

                if windowName == "DressUpFrame" then
                    if not window.MovingHeader and not config.Layout and not config.Lock then
                        window.MovingHeader = CreateFrame("Button", nil, window, "WCollectionsMovingHeaderTemplate");
                    end
                    if window.MovingHeader then
                        local elvuiSkin = ElvUI and WCollections:DelveInto(ElvUI[1], "private", "skins", "blizzard", "enable") and WCollections:DelveInto(ElvUI[1], "private", "skins", "blizzard", "dressingroom");
                        local elvuiEnh = ElvUI and WCollections:DelveInto(ElvUI[1], "db", "enhanced", "blizzard", "dressUpFrame", "enable");
                        window.MovingHeader:SetPoint("LEFT", elvuiSkin and (dressUpAddon and 0 or 12) or (dressUpAddon and 55 or 68), 0);
                        window.MovingHeader:SetPoint("RIGHT", (dressUpAddon and -23 or -58) - (dressUpAddon and 22 or elvuiEnh and 20 or 0), 0);
                        window.MovingHeader:SetPoint("TOP", 0, dressUpAddon and 0 or -13);
                    end
                end
            end
        end
        C_Timer.After(0, updateWindows); -- Let WCollectionsDressUp load
    end
    updateWindows();

    -- Micro Buttons
    local microButtonActions;
    local microButtonIcons;
    local microButtonOptions;
    local setupCollectionsMicroButton;
    do
        -- Upgrade settings from version <2.2
        if not WCollections.Config.Wardrobe.MicroButtonsActionLMB then
            WCollections.Config.Wardrobe.MicroButtonsActionLMB = WCollections.Config.Wardrobe.MicroButtonsTransmogrify and 6 or 0;
        end
        if not WCollections.Config.Wardrobe.MicroButtonsActionRMB then
            if WCollections.Config.Wardrobe.MicroButtonsRMB then
                WCollections.Config.Wardrobe.MicroButtonsActionRMB = WCollections.Config.Wardrobe.MicroButtonsTransmogrify and 0 or 6;
            else
                WCollections.Config.Wardrobe.MicroButtonsActionRMB = 0;
            end
        end
        if not WCollections.Config.Wardrobe.MicroButtonsIcon then
            WCollections.Config.Wardrobe.MicroButtonsIcon = WCollections.Config.Wardrobe.MicroButtonsTransmogrify and 6 or 5;
        end

        CreateFrame("Button", "CollectionsMicroButton", MainMenuBarArtFrame, "MainMenuBarMicroButton");
        CreateFrame("Button", "CollectionsMicroButtonAlert", CollectionsMicroButton, "MicroButtonAlertTemplate");
        LoadMicroButtonTextures(CollectionsMicroButton, "Help");
        local function getCoreMicroButtons()
            return
            {
                CharacterMicroButton,
                SpellbookMicroButton,
                TalentMicroButton,
                AchievementMicroButton,
                QuestLogMicroButton,
                SocialsMicroButton,
                PVPMicroButton,
                LFDMicroButton,
                MainMenuMicroButton,
                HelpMicroButton,
            };
        end
        local microButtonNames =
        {
            [CharacterMicroButton] = CHARACTER_BUTTON,
            [SpellbookMicroButton] = SPELLBOOK_ABILITIES_BUTTON,
            [TalentMicroButton] = TALENTS_BUTTON,
            [AchievementMicroButton] = ACHIEVEMENT_BUTTON,
            [QuestLogMicroButton] = QUESTLOG_BUTTON,
            [SocialsMicroButton] = SOCIAL_BUTTON,
            [PVPMicroButton] = PLAYER_V_PLAYER,
            [LFDMicroButton] = DUNGEONS_BUTTON,
            [MainMenuMicroButton] = MAINMENU_BUTTON,
            [HelpMicroButton] = HELP_BUTTON,
        };
        microButtonActions =
        {
            [0] = COLLECTIONS,
            [1] = MOUNTS,
            [2] = COMPANIONS,
            [3] = TOY_BOX,
            [4] = HEIRLOOMS,
            [5] = WARDROBE,
            [6] = TRANSMOGRIFY,
        };
        local microButtonBindings =
        {
            [0] = "TOGGLECOLLECTIONS",
            [1] = "TOGGLECOLLECTIONSMOUNTJOURNAL",
            [2] = "TOGGLECOLLECTIONSPETJOURNAL",
            [3] = "TOGGLECOLLECTIONSTOYBOX",
            [4] = "TOGGLECOLLECTIONSHEIRLOOM",
            [5] = "TOGGLECOLLECTIONSWARDROBE",
            [6] = "TOGGLETRANSMOGRIFY",
        };
        microButtonIcons =
        {
            [1] = [[Interface\AddOns\WCollections\Interface\Buttons\UI-MicroButton-Mounts]],
            [5] = [[Interface\AddOns\WCollections\Textures\UI-MicroButton-Collections]],
            [6] = [[Interface\AddOns\WCollections\Textures\UI-MicroButton-Transmogrify]],
        };
        local microButtonInserted;
        local function positionMicroButtons(buttons, inserted)
            if Dominos and Dominos.MenuBar then
                function Dominos.MenuBar:NumButtons()
                    return #buttons;
                end
                function Dominos.MenuBar:AddButton(i)
                    local b = buttons[i]
                    if b then
                        b:SetParent(self.header);
                        b:Show();
                        self.buttons[i] = b;
                    end
                end
                local menuBar = Dominos.Frame:Get("menu");
                if menuBar and not InCombatLockdown() then
                    local copy = { }; for k, v in ipairs(buttons) do copy[k] = v; end
                    menuBar.buttons = copy;
                    menuBar:LoadButtons();
                    menuBar:Layout();
                end
                return;
            end
            if Bartender4 and Bartender4:GetModule("MicroMenu") then
                local self = Bartender4:GetModule("MicroMenu");
                if self.bar then
                    local copy = { }; for k, v in ipairs(buttons) do copy[k] = v; end
                    self.bar.buttons = copy;
                    self.button_count = #buttons
                    for i,v in pairs(buttons) do
                        v:SetParent(self.bar)
                        v:Show()
                        v:SetFrameLevel(self.bar:GetFrameLevel() + 1)
                        v.ClearSetPoint = self.bar.ClearSetPoint
                    end
                end
                return;
            end
            if ElvUI then
                local E = unpack(ElvUI);
                local AB = E:GetModule("ActionBars");
                AB.WCollectionsMicroButtons = buttons;
                AB:UpdateMicroPositionDimensions();
                return;
            end
            microButtonInserted = inserted;
            if UnitHasVehicleUI("player") then
                return;
            end
            for i, button in ipairs(buttons) do
                if i == 1 then
                    button:SetPoint("BOTTOMLEFT", MainMenuBarArtFrame, "BOTTOMLEFT", inserted and 545 or 552, 2);
                else
                    button:SetPoint("BOTTOMLEFT", buttons[i-1], "BOTTOMRIGHT", inserted and -4 or -3, 0);
                end
                button:Show();
            end
        end
        microButtonOptions =
        {
            { L["Config.Wardrobe.MicroButtons.Option.None"], function() positionMicroButtons(getCoreMicroButtons()); CollectionsMicroButton:Hide(); end },
        };
        local function GetMicroButtonTexture(button)
            if button == CharacterMicroButton then
                return [[Interface\AddOns\WCollections\Textures\UI-MicroButton-Character]];
            elseif button == PVPMicroButton then
                return [[Interface\AddOns\WCollections\Textures\UI-MicroButton-PVP-]]..(UnitFactionGroup("player") or "FFA");
            else
                return button:GetNormalTexture():GetTexture();
            end
        end
        for i, button in ipairs(getCoreMicroButtons()) do
            if button == LFDMicroButton and not WCollections.Config.Wardrobe.MicroButtonsOption then
                WCollections.Config.Wardrobe.MicroButtonsOption = 1 + i;
            end
            table.insert(microButtonOptions, 1 + i,
            {
                format(L["Config.Wardrobe.MicroButtons.Option.Insert"], GetMicroButtonTexture(button), microButtonNames[button]),
                function()
                    local buttons = getCoreMicroButtons();
                    for i, b in ipairs(buttons) do
                        if b == button then
                            table.insert(buttons, i + 1, CollectionsMicroButton);
                            break;
                        end
                    end
                    positionMicroButtons(buttons, true);
                end,
            });
            if button ~= CharacterMicroButton then
                table.insert(microButtonOptions,
                {
                    format(L["Config.Wardrobe.MicroButtons.Option.Replace"], GetMicroButtonTexture(button), microButtonNames[button]),
                    function()
                        local buttons = getCoreMicroButtons();
                        for i, b in ipairs(buttons) do
                            if b == button then
                                if not UnitHasVehicleUI("player") then
                                    b:Hide();
                                end
                                buttons[i] = CollectionsMicroButton;
                                break;
                            end
                        end
                        positionMicroButtons(buttons);
                    end,
                });
            end
        end
        setupCollectionsMicroButton = function()
            microButtonOptions[WCollections.Config.Wardrobe.MicroButtonsOption][2]();
            local lmb = WCollections.Config.Wardrobe.MicroButtonsActionLMB or 0;
            local rmb = WCollections.Config.Wardrobe.MicroButtonsActionRMB or 0;
            local name = microButtonIcons[WCollections.Config.Wardrobe.MicroButtonsIcon or 1];
            LoadMicroButtonTextures(CollectionsMicroButton, "Help");
            CollectionsMicroButton:SetNormalTexture(name.."-Up");
            CollectionsMicroButton:SetPushedTexture(name.."-Down");
            CollectionsMicroButton.tooltipText = MicroButtonTooltipText(COLLECTIONS, "TOGGLECOLLECTIONS");
            CollectionsMicroButton.newbieText = format(L["Tooltip.MicroButton"],
                                                       (lmb ~= 0 or rmb ~= 0)
                                                       and format(L["Tooltip.MicroButton.Buttons"],
                                                                  lmb ~= 0 and format(L["Tooltip.MicroButton.LMB"], microButtonActions[lmb]) or "",
                                                                  rmb ~= 0 and format(L["Tooltip.MicroButton.RMB"], microButtonActions[rmb]) or "")
                                                       or "");
            UpdateMicroButtons();
        end
        hooksecurefunc("VehicleMenuBar_MoveMicroButtons", function(skinName)
            if Dominos and Dominos.MenuBar then
                setupCollectionsMicroButton();
                return;
            end
            if not skinName and not UnitHasVehicleUI("player") then
                setupCollectionsMicroButton();
            else
                local buttons = getCoreMicroButtons();
                for i, button in ipairs(buttons) do
                    if button ~= CharacterMicroButton and button ~= SocialsMicroButton then
                        button:SetPoint("BOTTOMLEFT", buttons[i-1], "BOTTOMRIGHT", -3, 0);
                    end
                    button:Show();
                end
            end
        end);
        hooksecurefunc("UpdateMicroButtons", function()
            if CollectionsJournal:IsShown() or WardrobeFrame:IsShown() then
                CollectionsMicroButton:SetButtonState("PUSHED", 1);
            else
                CollectionsMicroButton:SetButtonState("NORMAL");
            end
        end);
        function WCollectionsDominosHook()
            if Dominos and not Dominos.MenuBar then
                setupCollectionsMicroButton();
            end
        end
        function WCollectionsBartender4Hook()
            if Bartender4 and Bartender4:GetModule("MicroMenu") then
                hooksecurefunc(Bartender4:GetModule("MicroMenu"), "OnEnable", setupCollectionsMicroButton);
            end
        end
        CollectionsMicroButton:SetScript("OnEvent", function(self, event)
            if event == "UPDATE_BINDINGS" then
                setupCollectionsMicroButton();
            end
        end)
        CollectionsMicroButton:SetScript("OnClick", function(self, button)
            local action = WCollections.Config.Wardrobe.MicroButtonsActionLMB or 0;
            if button == "RightButton" then
                action = WCollections.Config.Wardrobe.MicroButtonsActionRMB or 0;
            end
            if CollectionsJournal:IsShown() or WardrobeFrame:IsShown() then
                HideUIPanel(CollectionsJournal);
                HideUIPanel(WardrobeFrame);
            elseif action == 0 and WCollections:GetCVar("petJournalTab") ~= 6 then
                HideUIPanel(WardrobeFrame);
                ToggleCollectionsJournal();
            elseif action == 6 or (action == 0 and WCollections:GetCVar("petJournalTab") == 6) then
                HideUIPanel(CollectionsJournal);
                ShowUIPanel(WardrobeFrame);
            else
                HideUIPanel(WardrobeFrame);
                ToggleCollectionsJournal(action);
            end
        end);
        CollectionsMicroButton:Hide();
        CollectionsMicroButtonAlert:SetPoint("BOTTOM", CollectionsMicroButton, "TOP", 0, -8);
        CollectionsMicroButtonAlert:HookScript("OnUpdate", function(self)
            self:SetFrameStrata("DIALOG");
        end);
        MicroButtonAlert_OnLoad(CollectionsMicroButtonAlert);
        C_Timer.After(1, function()
            if not CollectionsMicroButton:IsVisible() or KMicroMenuArt or ElvUI then
                if not WCollections:GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WCOLLECTIONS_MICRO_BUTTON) then
                    local button = _G["LibDBIcon10_WCollections - Collections"];
                    if button and button:IsShown() and button:IsVisible() then
                        local x = button:GetCenter();
                        local left = x < GetScreenWidth() / 2;
                        WCollectionsMinimapHelpBox:SetParent(button);
                        WCollectionsMinimapHelpBox:ClearAllPoints();
                        WCollectionsMinimapHelpBox:SetLeft(left);
                        WCollectionsMinimapHelpBox:SetPoint(left and "LEFT" or "RIGHT", button, "CENTER", left and 30 or -30, 0);
                        WCollectionsMinimapHelpBox:Show();
                    end
                end
            else
                if pUiMicroMenu then -- pretty_actionbar
                    CollectionsMicroButtonAlert.Arrow:SetPoint("TOP", CollectionsMicroButtonAlert, "BOTTOM", 40, 4);
                    CollectionsMicroButtonAlert:SetPoint("BOTTOM", CollectionsMicroButton, "TOP", -40, 20);
                    CollectionsMicroButtonAlert:SetScale(UIParent:GetEffectiveScale() / CollectionsMicroButton:GetEffectiveScale());
                end
                MainMenuMicroButton_ShowAlert(CollectionsMicroButtonAlert, L["Tutorial.MicroButton"], LE_FRAME_TUTORIAL_WCOLLECTIONS_MICRO_BUTTON);
            end
        end);
        setupCollectionsMicroButton();
    end

    -- Minimap Button
    local setupMinimapButtons;
    do
        LibStub("LibDBIcon-1.0"):Register("WCollections - Collections", LibStub("LibDataBroker-1.1"):NewDataObject("WCollections - Collections",
        {
            type = "launcher",
            text = L["Minimap.Collections"],
            icon = [[Interface\Icons\INV_Chest_Cloth_17]],
            OnClick = function(ldb, button)
                if button == "LeftButton" or button == "RightButton" then
                    local window = CollectionsJournal;
                    if button == "RightButton" then
                        if WCollections.Config.Wardrobe.MinimapButtonCollectionsRMB then
                            window = WardrobeFrame;
                        else
                            InterfaceOptionsFrame_Show();
                            InterfaceOptionsFrame_OpenToCategory(panels["general"]);
                            return;
                        end
                    end
                    if window:IsShown() then
                        HideUIPanel(window);
                    elseif window == CollectionsJournal then
                        HideUIPanel(WardrobeFrame);
                        ToggleCollectionsJournal(COLLECTIONS_JOURNAL_TAB_INDEX_APPEARANCES);
                    elseif window == WardrobeFrame then
                        HideUIPanel(CollectionsJournal);
                        ShowUIPanel(WardrobeFrame);
                    end
                end
            end,
            OnTooltipShow = function(tooltip)
                tooltip:SetText(L["Minimap.Collections"]);
                if WCollections.Config.Wardrobe.MinimapButtonCollectionsRMB then
                    tooltip:AddLine(L["Minimap.Collections.RMBTooltip"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1);
                end
            end,
        }), WCollections.Config.Wardrobe.MinimapButtonCollections);
        LibStub("LibDBIcon-1.0"):Register("WCollections - Transmogrify", LibStub("LibDataBroker-1.1"):NewDataObject("WCollections - Transmogrify",
        {
            type = "launcher",
            text = L["Minimap.Transmogrify"],
            icon = [[Interface\AddOns\WCollections\Interface\Icons\INV_Arcane_Orb]],
            OnClick = function(ldb, button)
                if button == "LeftButton" or button == "RightButton" then
                    local window = WardrobeFrame;
                    if button == "RightButton" then
                        if WCollections.Config.Wardrobe.MinimapButtonTransmogrifyRMB then
                            window = CollectionsJournal;
                        else
                            InterfaceOptionsFrame_Show();
                            InterfaceOptionsFrame_OpenToCategory(panels["general"]);
                            return;
                        end
                    end
                    if window:IsShown() then
                        HideUIPanel(window);
                    elseif window == CollectionsJournal then
                        HideUIPanel(WardrobeFrame);
                        ToggleCollectionsJournal(COLLECTIONS_JOURNAL_TAB_INDEX_APPEARANCES);
                    elseif window == WardrobeFrame then
                        HideUIPanel(CollectionsJournal);
                        ShowUIPanel(WardrobeFrame);
                    end
                end
            end,
            OnTooltipShow = function(tooltip)
                tooltip:SetText(L["Minimap.Transmogrify"]);
                if WCollections.Config.Wardrobe.MinimapButtonTransmogrifyRMB then
                    tooltip:AddLine(L["Minimap.Transmogrify.RMBTooltip"], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1);
                end
            end,
        }), WCollections.Config.Wardrobe.MinimapButtonTransmogrify);
        setupMinimapButtons = function()
            if WCollections.Config.Wardrobe.MinimapButtonCollections.hide then
                LibStub("LibDBIcon-1.0"):Hide("WCollections - Collections");
            else
                LibStub("LibDBIcon-1.0"):Show("WCollections - Collections");
            end
            if WCollections.Config.Wardrobe.MinimapButtonTransmogrify.hide then
                LibStub("LibDBIcon-1.0"):Hide("WCollections - Transmogrify");
            else
                LibStub("LibDBIcon-1.0"):Show("WCollections - Transmogrify");
            end
        end;
        setupMinimapButtons();
    end

    local InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory_Fix or InterfaceOptionsFrame_OpenToCategory;
    WCollections.ConfigHandlers =
    {
        Color =
        {
            disabled = function(self, info) return not info.arg.Enable; end,
            values = function(self, info)
                local values = { custom = L["Color.Custom"] };
                for k, v in pairs(PRESET_COLORS) do
                    values[v.key] = v.Name;
                end
                return values;
            end,
            get = function(self, info)
                local color = info.arg.Color;
                if not color.Custom then
                    for k, v in pairs(PRESET_COLORS) do
                        if v.r == color.r and v.g == color.g and v.b == color.b and v.a == color.a then
                            return v.key;
                        end
                    end
                end
                return "custom";
            end,
            set = function(self, info, value)
                local color = info.arg.Color;
                if value == "custom" then
                    color.Custom = true;
                else
                    color.Custom = false;
                    for k, v in pairs(PRESET_COLORS) do
                        if v.key == value then
                            color.r, color.g, color.b, color.a = v.r, v.g, v.b, v.a;
                        end
                    end
                end
            end,
        },
        CustomColor =
        {
            get = function(self, info)             local color = info.arg.Color; return color.r,     color.g,     color.b,     color.a;     end,
            set = function(self, info, r, g, b, a) local color = info.arg.Color;        color.r = r; color.g = g; color.b = b; color.a = a; end,
            disabled = function(self, info) return not info.arg.Enable or self:disabled2(info); end,
            disabled2 = function(self, info) return not info.arg.Color.Custom; end,
        },
        Keybind =
        {
            Get = function(self, info)
                return table.concat({ GetBindingKey(info.arg) }, ", ");
            end,
            Set = function(self, info, value)
                if value == "" then value = nil; end

                if value and GetBindingAction(value) ~= "" and GetBindingAction(value) ~= info.arg then
                    self:Error(L["Binding.Error.AlreadyBound"]);
                    return;
                end

                if value then
                    if not SetBinding(value, info.arg) then
                        self:Error(L["Binding.Error.BindingFailed"]);
                        return;
                    end
                else
                    local keys = { GetBindingKey(info.arg) };
                    for _, key in pairs(keys) do
                        SetBinding(key);
                    end
                end

                if GetCurrentBindingSet()==1 or GetCurrentBindingSet()==2 then
                    SaveBindings(GetCurrentBindingSet());
                end
            end,
            Error = function(self, message)
                StaticPopupDialogs["WCOLLECTIONS_KEYBINDING_ERROR"].text = message;
                StaticPopup_Show("WCOLLECTIONS_KEYBINDING_ERROR");
            end,
        },
    };
    WCollections.ConfigHelpers = { };
    function WCollections.ConfigHelpers.IntegrationAddonName(name)
        return function(info)
            return format(L[info.option.disabled() and "Config.Integration.ActionButtons.Addons.NotFound" or "Config.Integration.ActionButtons.Addons.Found"], name);
        end;
    end
    local reloadUINeeded = false;
    local reloadUINeeded2 = false;
    local configTable =
    {
        type = "group",
        name = L["Addon.Color"],
        args =
        {
            general =
            {
                type = "group",
                name = L["Config.General"],
                args =
                {
                    info =
                    {
                        type = "description",
                        name = L["Config.General.Addon"],
                        order = 0,
                        hidden = true,
                    },
                    newVersion =
                    {
                        type = "group",
                        name = function() return WCollections.NewVersion == nil and "" or WCollections.NewVersion.Disabled and L["Config.NewVersion.Disabled"] or WCollections.NewVersion.Outdated and L["Config.NewVersion.Outdated"] or L["Config.NewVersion.Compatible"] end,
                        inline = true,
                        order = 100,
                        hidden = function() return WCollections.NewVersion == nil; end,
                        args =
                        {
                            desc =
                            {
                                type = "description",
                                name = L["Config.NewVersion.Desc"],
                                order = 0,
                                hidden = function() return WCollections.NewVersion and WCollections.NewVersion.Disabled; end,
                            },
                            url =
                            {
                                type = "input",
                                name = L["Config.NewVersion.URL"],
                                order = 1,
                                width = "full",
                                get = function(info) return WCollections.NewVersion.URL; end;
                                set = function(info, value) end;
                                hidden = function() return WCollections.NewVersion and WCollections.NewVersion.Disabled; end,
                            },
                            clientVersion =
                            {
                                type = "description",
                                name = function() return format(L["Config.NewVersion.ClientVersion"], ADDON_VERSION); end;
                                order = 2,
                                hidden = function() return WCollections.NewVersion and WCollections.NewVersion.Disabled; end,
                            },
                            serverVersion =
                            {
                                type = "description",
                                name = function() return format(L["Config.NewVersion.ServerVersion"], WCollections.NewVersion.Version); end;
                                order = 3,
                                hidden = function() return WCollections.NewVersion and WCollections.NewVersion.Disabled; end,
                            },
                            hideRetiredPopup =
                            {
                                type = "toggle",
                                name = L["Config.NewVersion.HideRetiredPopup"],
                                desc = L["Config.NewVersion.HideRetiredPopup.Desc"],
                                width = "full",
                                order = 100,
                                get = function(info) return WCollections.Config.NewVersion.HideRetiredPopup; end,
                                set = function(info, value) WCollections.Config.NewVersion.HideRetiredPopup = value; end,
                                hidden = function() return WCollections.NewVersion and not WCollections.NewVersion.Disabled; end,
                            },
                            SkipVersionPopup =
                            {
                                type = "toggle",
                                name = L["Config.NewVersion.SkipVersionPopup"],
                                width = "full",
                                order = 200,
                                get = function(info) return WCollections.NewVersion and WCollections.Config.NewVersion.SkipVersionPopup == WCollections.NewVersion.Version; end,
                                set = function(info, value)
                                    if value and WCollections.NewVersion then
                                        WCollections.Config.NewVersion.SkipVersionPopup = WCollections.NewVersion.Version;
                                    else
                                        WCollections.Config.NewVersion.SkipVersionPopup = nil;
                                    end
                                end,
                                hidden = function() return WCollections.NewVersion and WCollections.NewVersion.Disabled; end,
                            },
                        },
                    },
                    panelWardrobe =
                    {
                        type = "input",
                        name = L["Config.General.Panel.Wardrobe"],
                        width = "full",
                        order = 150,
                        get = function() return L["Config.General.Panel.Wardrobe.Desc"] end,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["wardrobe"]); end,
                        dialogControl = "WCollectionsOptionsBigButtonTemplate",
                    },
                    panelMounts =
                    {
                        type = "input",
                        name = format(L["Config.General.Panel.Tab"], MOUNTS),
                        order = 150.1,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["mounts"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelPets =
                    {
                        type = "input",
                        name = format(L["Config.General.Panel.Tab"], COMPANIONS),
                        order = 150.2,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["pets"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelToys =
                    {
                        type = "input",
                        name = format(L["Config.General.Panel.Tab"], TOY_BOX),
                        order = 150.3,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["toys"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                        hidden = function() return not _G["CollectionsJournalTab"..3] or _G["CollectionsJournalTab"..3].isDisabled; end,
                    },
                    panelHeirlooms =
                    {
                        type = "input",
                        name = format(L["Config.General.Panel.Tab"], HEIRLOOMS),
                        order = 150.4,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["heirlooms"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                        hidden = function() return not _G["CollectionsJournalTab"..4] or _G["CollectionsJournalTab"..4].isDisabled; end,
                    },
                    panelAppearances =
                    {
                        type = "input",
                        name = format(L["Config.General.Panel.Tab"], WARDROBE),
                        order = 150.5,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["appearances"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelTransmogrify =
                    {
                        type = "input",
                        name = format(L["Config.General.Panel.Tab"], TRANSMOGRIFY),
                        width = GetLocale() == "ruRU" and "double" or nil,
                        order = 150.9,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["transmogrify"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelIntegration =
                    {
                        type = "input",
                        name = L["Config.General.Panel.Integration"],
                        width = "full",
                        order = 155,
                        get = function() return L["Config.General.Panel.Integration.Desc"] end,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["integration"]); end,
                        dialogControl = "WCollectionsOptionsBigButtonTemplate",
                    },
                    panelChat =
                    {
                        type = "input",
                        name = L["Config.Integration.Chat"],
                        order = 155.1,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["chat"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelTooltips =
                    {
                        type = "input",
                        name = L["Config.Integration.Tooltips"],
                        order = 155.2,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["tooltips"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelMicroButtons =
                    {
                        type = "input",
                        name = L["Config.Integration.MicroButtons"],
                        order = 155.3,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["microButtons"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelMinimapButtons =
                    {
                        type = "input",
                        name = L["Config.Integration.MinimapButtons"],
                        order = 155.4,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["minimapButtons"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelActionButtons =
                    {
                        type = "input",
                        name = L["Config.Integration.ActionButtons"],
                        order = 155.5,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["actionButtons"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelItemButtons =
                    {
                        type = "input",
                        name = L["Config.Integration.ItemButtons"],
                        order = 155.6,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["itemButtons"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelWindows =
                    {
                        type = "input",
                        name = L["Config.Integration.Windows"],
                        order = 155.65,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["windows"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelDressUp =
                    {
                        type = "input",
                        name = L["Config.Integration.DressUp"],
                        order = 155.7,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["dressUp"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelBindings =
                    {
                        type = "input",
                        name = L["Config.General.Panel.Bindings"],
                        width = "full",
                        order = 160,
                        get = function() return L["Config.General.Panel.Bindings.Desc"] end,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["bindings"]); end,
                        dialogControl = "WCollectionsOptionsBigButtonTemplate",
                    },
                    showAdvancedOptions =
                    {
                        type = "toggle",
                        name = L["Config.General.Advanced"],
                        width = "full",
                        order = 199,
                        get = function(info) return showAdvancedOptions; end,
                        set = function(info, value) showAdvancedOptions = value; end,
                    },
                    cache =
                    {
                        type = "group",
                        name = L["Config.Cache"],
                        inline = true,
                        order = 200,
                        hidden = function() return not showAdvancedOptions; end,
                        args =
                        {
                            desc =
                            {
                                type = "description",
                                name = L["Config.Cache.Desc"],
                                order = 0,
                            },
                            clear =
                            {
                                type = "execute",
                                name = L["Config.Cache.Clear"],
                                desc = L["Config.Cache.Clear.Desc"],
                                width = "full",
                                order = 1,
                                func = function() StaticPopup_Show("WCOLLECTIONS_CONFIRM_CACHE_RESET"); end,
                            },
                        },
                    },
                    config =
                    {
                        type = "group",
                        name = L["Config.Config"],
                        inline = true,
                        order = 300,
                        hidden = function() return not showAdvancedOptions; end,
                        args =
                        {
                            desc =
                            {
                                type = "description",
                                name = L["Config.Config.Desc"],
                                order = 0,
                            },
                            reset =
                            {
                                type = "execute",
                                name = L["Config.Config.Reset"],
                                desc = L["Config.Config.Reset.Desc"],
                                width = "full",
                                order = 100,
                                func = function() StaticPopup_Show("WCOLLECTIONS_CONFIRM_CONFIG_RESET"); end,
                            },
                        },
                    },
                },
            },
            wardrobe =
            {
                type = "group",
                name = L["Config.Wardrobe"],
                args =
                {
                    panelMounts =
                    {
                        type = "input",
                        name = format(L["Config.General.Panel.Tab"], MOUNTS),
                        order = 0.1,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["mounts"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelPets =
                    {
                        type = "input",
                        name = format(L["Config.General.Panel.Tab"], COMPANIONS),
                        order = 0.2,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["pets"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelToys =
                    {
                        type = "input",
                        name = format(L["Config.General.Panel.Tab"], TOY_BOX),
                        order = 0.3,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["toys"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                        hidden = function() return not _G["CollectionsJournalTab"..3] or _G["CollectionsJournalTab"..3].isDisabled; end,
                    },
                    panelHeirlooms =
                    {
                        type = "input",
                        name = format(L["Config.General.Panel.Tab"], HEIRLOOMS),
                        order = 0.4,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["heirlooms"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                        hidden = function() return not _G["CollectionsJournalTab"..4] or _G["CollectionsJournalTab"..4].isDisabled; end,
                    },
                    panelAppearances =
                    {
                        type = "input",
                        name = format(L["Config.General.Panel.Tab"], WARDROBE),
                        order = 0.5,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["appearances"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelTransmogrify =
                    {
                        type = "input",
                        name = format(L["Config.General.Panel.Tab"], TRANSMOGRIFY),
                        width = GetLocale() == "ruRU" and "double" or nil,
                        order = 0.9,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["transmogrify"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    storage =
                    {
                        type = "group",
                        name = L["Config.Wardrobe.Misc.Storage"],
                        inline = true,
                        order = 50,
                        args =
                        {
                            CompressCache =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.CompressCache"],
                                desc = L["Config.Wardrobe.CompressCache.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 100,
                                get = function(info) return WCollections.Config.Misc.CompressCache; end,
                                set = function(info, value) WCollections.Config.Misc.CompressCache = value; end,
                            },
                            perCharacterFavorites =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.PerCharacterFavorites"],
                                desc = L["Config.Wardrobe.PerCharacterFavorites.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 125,
                                get = function(info) return WCollections.Config.Wardrobe.PerCharacterFavorites; end,
                                set = function(info, value)
                                    WCollections.Config.Wardrobe.PerCharacterFavorites = value;
                                    WCollections:RaiseEvent("TRANSMOG_COLLECTION_UPDATED");
                                    WCollections:RaiseEvent("TRANSMOG_SETS_UPDATE_FAVORITE");
                                    StaticPopup_Hide("WCOLLECTIONS_CONFIRM_FAVORITES_SPLIT");
                                    StaticPopup_Hide("WCOLLECTIONS_CONFIRM_FAVORITES_MERGE");
                                    StaticPopup_Show(WCollections.Config.Wardrobe.PerCharacterFavorites and "WCOLLECTIONS_CONFIRM_FAVORITES_SPLIT" or "WCOLLECTIONS_CONFIRM_FAVORITES_MERGE");
                                end,
                            },
                            favoritesMerge =
                            {
                                type = "execute",
                                name = L["Config.Wardrobe.FavoritesMerge"],
                                width = "full",
                                order = 126,
                                hidden = function() return WCollections.Config.Wardrobe.PerCharacterFavorites; end,
                                func = function()
                                    StaticPopup_Hide("WCOLLECTIONS_CONFIRM_FAVORITES_SPLIT");
                                    StaticPopup_Show("WCOLLECTIONS_CONFIRM_FAVORITES_MERGE");
                                end,
                            },
                            favoritesSplit =
                            {
                                type = "execute",
                                name = L["Config.Wardrobe.FavoritesSplit"],
                                width = "full",
                                order = 127,
                                hidden = function() return not WCollections.Config.Wardrobe.PerCharacterFavorites; end,
                                func = function()
                                    StaticPopup_Hide("WCOLLECTIONS_CONFIRM_FAVORITES_MERGE");
                                    StaticPopup_Show("WCOLLECTIONS_CONFIRM_FAVORITES_SPLIT");
                                end,
                            },
                        },
                    },
                    cameras =
                    {
                        type = "group",
                        name = L["Config.Wardrobe.Cameras"],
                        inline = true,
                        order = 100,
                        args =
                        {
                            desc =
                            {
                                type = "description",
                                name = L["Config.Wardrobe.Cameras.Desc"],
                                order = 0,
                            },
                            option =
                            {
                                type = "select",
                                name = L["Config.Wardrobe.Cameras.Option"],
                                order = 100,
                                values = function()
                                    local values = { };
                                    for index, option in ipairs(WCollections.CameraOptions) do
                                        values[option] = WCollections:GetCameraOptionName(option);
                                    end
                                    return values;
                                end,
                                get = function(info)
                                    return WCollections.Config.Wardrobe.CameraOption;
                                end,
                                set = function(info, value)
                                    WCollections.Config.Wardrobe.CameraOption = value;
                                    WCollections:RaiseEvent("TRANSMOG_COLLECTION_UPDATED");
                                end,
                            },
                            popup =
                            {
                                type = "execute",
                                name = L["Config.Wardrobe.Cameras.Popup"],
                                order = 200,
                                func = function()
                                    HideUIPanel(InterfaceOptionsFrame);
                                    HideUIPanel(GameMenuFrame);
                                    StaticPopupSpecial_Show(WCollectionsCameraPreviewPopup);
                                end,
                            },
                            panLimit =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.Cameras.PanLimit"],
                                width = "full",
                                order = 300,
                                get = function(info) return WCollections.Config.Wardrobe.CameraPanLimit; end,
                                set = function(info, value) WCollections.Config.Wardrobe.CameraPanLimit = value; end,
                            },
                            zoomSpeed =
                            {
                                type = "range",
                                name = L["Config.Wardrobe.Cameras.ZoomSpeed"],
                                width = "full",
                                order = 350,
                                min = 0.01,
                                max = 1,
                                step = 0.01,
                                isPercent = true,
                                get = function(info) return WCollections.Config.Wardrobe.CameraZoomSpeed; end,
                                set = function(info, value) WCollections.Config.Wardrobe.CameraZoomSpeed = value; end,
                            },
                            zoomSmooth =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.Cameras.ZoomSmooth"],
                                width = "full",
                                order = 400,
                                get = function(info) return WCollections.Config.Wardrobe.CameraZoomSmooth; end,
                                set = function(info, value) WCollections.Config.Wardrobe.CameraZoomSmooth = value; end,
                            },
                            zoomSmoothSpeed =
                            {
                                type = "range",
                                name = L["Config.Wardrobe.Cameras.ZoomSmoothSpeed"],
                                width = "full",
                                order = 450,
                                min = 0.01,
                                max = 1,
                                step = 0.01,
                                isPercent = true,
                                disabled = function(info) return not WCollections.Config.Wardrobe.CameraZoomSmooth; end,
                                get = function(info) return WCollections.Config.Wardrobe.CameraZoomSmoothSpeed; end,
                                set = function(info, value) WCollections.Config.Wardrobe.CameraZoomSmoothSpeed = value; end,
                            },
                        },
                    },
                },
            },
            mounts =
            {
                type = "group",
                name = L["Config.Mounts"],
                args =
                {
                    list =
                    {
                        type = "group",
                        name = L["Config.Mounts.List"],
                        inline = true,
                        order = 100,
                        args =
                        {
                            doubleClickIcon =
                            {
                                type = "toggle",
                                name = L["Config.Mounts.List.DoubleClick.Icon"],
                                width = "full",
                                order = 50,
                                get = function(info) return WCollections.Config.Wardrobe.MountsDoubleClickIcon; end,
                                set = function(info, value) WCollections.Config.Wardrobe.MountsDoubleClickIcon = value; end,
                            },
                            doubleClickName =
                            {
                                type = "toggle",
                                name = L["Config.Mounts.List.DoubleClick.Name"],
                                width = "full",
                                order = 51,
                                get = function(info) return WCollections.Config.Wardrobe.MountsDoubleClickName; end,
                                set = function(info, value) WCollections.Config.Wardrobe.MountsDoubleClickName = value; end,
                            },
                            lb1 = { type = "description", name = " ", order = 99 },
                            mountsUnusableInZone =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.MountsUnusableInZone"],
                                desc = L["Config.Wardrobe.MountsUnusableInZone.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 100,
                                get = function(info) return WCollections.Config.Wardrobe.MountsUnusableInZone; end,
                                set = function(info, value) WCollections.Config.Wardrobe.MountsUnusableInZone = value; WCollections.Callbacks.MountListUpdated(); end,
                            },
                            mountsShowHidden =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.MountsShowHidden"],
                                desc = L["Config.Wardrobe.MountsShowHidden.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 200,
                                get = function(info) return WCollections.Config.Wardrobe.MountsShowHidden; end,
                                set = function(info, value) WCollections.Config.Wardrobe.MountsShowHidden = value; WCollections.Callbacks.MountListUpdated(); end,
                            },
                        },
                    },
                },
            },
            pets =
            {
                type = "group",
                name = L["Config.Pets"],
                args =
                {
                    list =
                    {
                        type = "group",
                        name = L["Config.Pets.List"],
                        inline = true,
                        order = 100,
                        args =
                        {
                            doubleClickIcon =
                            {
                                type = "toggle",
                                name = L["Config.Pets.List.DoubleClick.Icon"],
                                width = "full",
                                order = 50,
                                get = function(info) return WCollections.Config.Wardrobe.PetsDoubleClickIcon; end,
                                set = function(info, value) WCollections.Config.Wardrobe.PetsDoubleClickIcon = value; end,
                            },
                            doubleClickName =
                            {
                                type = "toggle",
                                name = L["Config.Pets.List.DoubleClick.Name"],
                                width = "full",
                                order = 51,
                                get = function(info) return WCollections.Config.Wardrobe.PetsDoubleClickName; end,
                                set = function(info, value) WCollections.Config.Wardrobe.PetsDoubleClickName = value; end,
                            },
                            lb1 = { type = "description", name = " ", order = 99 },
                            petsShowHidden =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.PetsShowHidden"],
                                desc = L["Config.Wardrobe.PetsShowHidden.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 100,
                                get = function(info) return WCollections.Config.Wardrobe.PetsShowHidden; end,
                                set = function(info, value) WCollections.Config.Wardrobe.PetsShowHidden = value; WCollections.Callbacks.PetListUpdated(); end,
                            },
                        },
                    },
                },
            },
            toys =
            {
                type = "group",
                name = L["Config.Toys"],
                args =
                {
                    list =
                    {
                        type = "group",
                        name = L["Config.Toys.List"],
                        inline = true,
                        order = 100,
                        args =
                        {
                            toysShowHidden =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.ToysShowHidden"],
                                desc = L["Config.Wardrobe.ToysShowHidden.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 100,
                                get = function(info) return WCollections.Config.Wardrobe.ToysShowHidden; end,
                                set = function(info, value) WCollections.Config.Wardrobe.ToysShowHidden = value; WCollections.Callbacks.ToyListUpdated(); end,
                            },
                            showCollectedToySourceText =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.ShowCollectedToySourceText"],
                                width = "full",
                                order = 200,
                                get = function(info) return WCollections.Config.Wardrobe.ShowCollectedToySourceText; end,
                                set = function(info, value) WCollections.Config.Wardrobe.ShowCollectedToySourceText = value; end,
                            },
                        },
                    },
                },
            },
            heirlooms =
            {
                type = "group",
                name = L["Config.Heirlooms"],
                args =
                {
                },
            },
            appearances =
            {
                type = "group",
                name = L["Config.Appearances"],
                args =
                {
                    sets =
                    {
                        type = "group",
                        name = L["Config.Appearances.Sets"],
                        inline = true,
                        order = 200,
                        args =
                        {
                            ShowSetsInAppearances =
                            {
                                type = "toggle",
                                name = L["Config.Appearances.Sets.ShowSetsInAppearances"],
                                desc = L["Config.Appearances.Sets.ShowSetsInAppearances.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 50,
                                get = function(info) return WCollections.Config.Wardrobe.ShowSetsInAppearances; end,
                                set = function(info, value) WCollections.Config.Wardrobe.ShowSetsInAppearances = value; end,
                            },
                            tooltipCycleKeyboard =
                            {
                                type = "toggle",
                                name = L["Config.Appearances.Sets.TooltipCycle.Keyboard"],
                                desc = L["Config.Appearances.Sets.TooltipCycle.Keyboard.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 100,
                                get = function(info) return WCollections.Config.Wardrobe.TooltipCycleKeyboard; end,
                                set = function(info, value) WCollections.Config.Wardrobe.TooltipCycleKeyboard = value; end,
                            },
                            tooltipCycleMouseWheel =
                            {
                                type = "toggle",
                                name = L["Config.Appearances.Sets.TooltipCycle.MouseWheel"],
                                width = "full",
                                order = 200,
                                get = function(info) return WCollections.Config.Wardrobe.TooltipCycleMouseWheel; end,
                                set = function(info, value) WCollections.Config.Wardrobe.TooltipCycleMouseWheel = value; end,
                            },
                            ShowWowheadSetIcon =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.ShowWowheadSetIcon"],
                                width = "full",
                                order = 300,
                                get = function(info) return WCollections.Config.Wardrobe.ShowWowheadSetIcon; end,
                                set = function(info, value) WCollections.Config.Wardrobe.ShowWowheadSetIcon = value; WCollections:RaiseEvent("TRANSMOG_COLLECTION_UPDATED"); end,
                            },
                        },
                    },
                    search =
                    {
                        type = "group",
                        name = L["Config.Appearances.Search"],
                        inline = true,
                        order = 900,
                        args =
                        {
                            clientside =
                            {
                                type = "toggle",
                                name = L["Config.Appearances.Search.Clientside"],
                                desc = L["Config.Appearances.Search.Clientside.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 100,
                                get = function(info) return WCollections.Config.Wardrobe.SearchClientside; end,
                                set = function(info, value) WCollections.Config.Wardrobe.SearchClientside = value; end,
                            },
                            cacheNames =
                            {
                                type = "toggle",
                                name = L["Config.Appearances.Search.CacheNames"],
                                desc = L["Config.Appearances.Search.CacheNames.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 200,
                                disabled = function(info) return not WCollections.Config.Wardrobe.SearchClientside; end,
                                get = function(info) return WCollections.Config.Wardrobe.SearchCacheNames and WCollections.Config.Wardrobe.SearchClientside; end,
                                set = function(info, value) WCollections.Config.Wardrobe.SearchCacheNames = value; table.wipe(WCollections.ItemNamesForSearch); table.wipe(WCollections.SetNamesForSearch); end,
                            },
                            setsBySources =
                            {
                                type = "toggle",
                                name = L["Config.Appearances.Search.SetsBySources"],
                                desc = L["Config.Appearances.Search.SetsBySources.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 300,
                                disabled = function(info) return not WCollections.Config.Wardrobe.SearchClientside or not WCollections.Config.Wardrobe.SearchCacheNames; end,
                                get = function(info) return WCollections.Config.Wardrobe.SearchSetsBySources and WCollections.Config.Wardrobe.SearchClientside and WCollections.Config.Wardrobe.SearchCacheNames; end,
                                set = function(info, value) WCollections.Config.Wardrobe.SearchSetsBySources = value; table.wipe(WCollections.SetNamesForSearch); end,
                            },
                        },
                    },
                    misc =
                    {
                        type = "group",
                        name = L["Config.Wardrobe.Misc.Misc"],
                        inline = true,
                        order = 1000,
                        args =
                        {
                            portraitButton =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.PortraitButton"],
                                desc = L["Config.Wardrobe.PortraitButton.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 190,
                                get = function(info) return WCollections.Config.Wardrobe.PortraitButton; end,
                                set = function(info, value) WCollections.Config.Wardrobe.PortraitButton = value; CollectionsJournalPortraitButton:UpdateVisibility(); WardrobeFramePortraitButton:UpdateVisibility(); end,
                            },
                            showSetID =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.ShowSetID"],
                                width = "full",
                                order = 300,
                                get = function(info) return WCollections.Config.Wardrobe.ShowSetID; end,
                                set = function(info, value) WCollections.Config.Wardrobe.ShowSetID = value; WCollections:RaiseEvent("TRANSMOG_COLLECTION_UPDATED"); end,
                            },
                            showItemID =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.ShowItemID"],
                                width = "full",
                                order = 400,
                                get = function(info) return WCollections.Config.Wardrobe.ShowItemID; end,
                                set = function(info, value) WCollections.Config.Wardrobe.ShowItemID = value; end,
                            },
                            showCollectedVisualSourceText =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.ShowCollectedVisualSourceText"],
                                width = "full",
                                order = 500,
                                get = function(info) return WCollections.Config.Wardrobe.ShowCollectedVisualSourceText; end,
                                set = function(info, value) WCollections.Config.Wardrobe.ShowCollectedVisualSourceText = value; end,
                            },
                            showCollectedVisualSources =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.ShowCollectedVisualSources"],
                                width = "full",
                                order = 600,
                                get = function(info) return WCollections.Config.Wardrobe.ShowCollectedVisualSources; end,
                                set = function(info, value) WCollections.Config.Wardrobe.ShowCollectedVisualSources = value; end,
                            },
                        },
                    },
                },
            },
            transmogrify =
            {
                type = "group",
                name = L["Config.Transmogrify"],
                args =
                {
                    sets =
                    {
                        type = "group",
                        name = L["Config.Transmogrify.Sets"],
                        inline = true,
                        order = 100,
                        args =
                        {
                            hideExtraSlotsOnSetSelect =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.HideExtraSlotsOnSetSelect"],
                                desc = L["Config.Wardrobe.HideExtraSlotsOnSetSelect.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 50,
                                get = function(info) return WCollections.Config.Wardrobe.HideExtraSlotsOnSetSelect; end,
                                set = function(info, value) WCollections.Config.Wardrobe.HideExtraSlotsOnSetSelect = value; WCollections:RaiseEvent("TRANSMOG_COLLECTION_UPDATED"); end,
                            },
                        },
                    },
                    outfits =
                    {
                        type = "group",
                        name = L["Config.Wardrobe.Misc.Outfits"],
                        inline = true,
                        order = 200,
                        args =
                        {
                            outfitsSort =
                            {
                                type = "select",
                                name = L["Config.Wardrobe.OutfitsSort"],
                                order = 100,
                                values =
                                {
                                    L["Config.Wardrobe.OutfitsSort.1"],
                                    L["Config.Wardrobe.OutfitsSort.2"],
                                },
                                get = function(info) return WCollections.Config.Wardrobe.OutfitsSort; end,
                                set = function(info, value) WCollections.Config.Wardrobe.OutfitsSort = value; WCollections:RaiseEvent("TRANSMOG_OUTFITS_CHANGED"); end,
                            },
                            lb1 = { type = "description", name = "", order = 109 },
                            outfitsSelectLastUsed =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.OutfitsSelectLastUsed"],
                                desc = L["Config.Wardrobe.OutfitsSelectLastUsed.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 110,
                                get = function(info) return WCollections.Config.Wardrobe.OutfitsSelectLastUsed; end,
                                set = function(info, value) WCollections.Config.Wardrobe.OutfitsSelectLastUsed = value; updateSpecButton(); end,
                            },
                            outfitsPrepaidSheen =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.OutfitsPrepaidSheen"],
                                desc = L["Config.Wardrobe.OutfitsPrepaidSheen.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 115,
                                get = function(info) return WCollections.Config.Wardrobe.OutfitsPrepaidSheen; end,
                                set = function(info, value) WCollections.Config.Wardrobe.OutfitsPrepaidSheen = value; WCollections:RaiseEvent("TRANSMOG_OUTFITS_CHANGED"); end,
                            },
                        },
                    },
                    search =
                    {
                        type = "group",
                        name = L["Config.Appearances.Search"],
                        inline = true,
                        order = 900,
                        args =
                        {
                            clientside =
                            {
                                type = "toggle",
                                name = L["Config.Appearances.Search.Clientside"],
                                desc = L["Config.Appearances.Search.Clientside.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 100,
                                get = function(info) return WCollections.Config.Wardrobe.SearchClientside; end,
                                set = function(info, value) WCollections.Config.Wardrobe.SearchClientside = value; end,
                            },
                            cacheNames =
                            {
                                type = "toggle",
                                name = L["Config.Appearances.Search.CacheNames"],
                                desc = L["Config.Appearances.Search.CacheNames.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 200,
                                disabled = function(info) return not WCollections.Config.Wardrobe.SearchClientside; end,
                                get = function(info) return WCollections.Config.Wardrobe.SearchCacheNames and WCollections.Config.Wardrobe.SearchClientside; end,
                                set = function(info, value) WCollections.Config.Wardrobe.SearchCacheNames = value; table.wipe(WCollections.ItemNamesForSearch); table.wipe(WCollections.SetNamesForSearch); end,
                            },
                            setsBySources =
                            {
                                type = "toggle",
                                name = L["Config.Appearances.Search.SetsBySources"],
                                desc = L["Config.Appearances.Search.SetsBySources.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 300,
                                disabled = function(info) return not WCollections.Config.Wardrobe.SearchClientside or not WCollections.Config.Wardrobe.SearchCacheNames; end,
                                get = function(info) return WCollections.Config.Wardrobe.SearchSetsBySources and WCollections.Config.Wardrobe.SearchClientside and WCollections.Config.Wardrobe.SearchCacheNames; end,
                                set = function(info, value) WCollections.Config.Wardrobe.SearchSetsBySources = value; table.wipe(WCollections.SetNamesForSearch); end,
                            },
                        },
                    },
                    misc =
                    {
                        type = "group",
                        name = L["Config.Wardrobe.Misc.Misc"],
                        inline = true,
                        order = 1000,
                        args =
                        {
                            portraitButton =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.PortraitButton"],
                                desc = L["Config.Wardrobe.PortraitButton.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 190,
                                get = function(info) return WCollections.Config.Wardrobe.PortraitButton; end,
                                set = function(info, value) WCollections.Config.Wardrobe.PortraitButton = value; CollectionsJournalPortraitButton:UpdateVisibility(); WardrobeFramePortraitButton:UpdateVisibility(); end,
                            },
                            showSetID =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.ShowSetID"],
                                width = "full",
                                order = 300,
                                get = function(info) return WCollections.Config.Wardrobe.ShowSetID; end,
                                set = function(info, value) WCollections.Config.Wardrobe.ShowSetID = value; WCollections:RaiseEvent("TRANSMOG_COLLECTION_UPDATED"); end,
                            },
                            showItemID =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.ShowItemID"],
                                width = "full",
                                order = 400,
                                get = function(info) return WCollections.Config.Wardrobe.ShowItemID; end,
                                set = function(info, value) WCollections.Config.Wardrobe.ShowItemID = value; end,
                            },
                            showCollectedVisualSourceText =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.ShowCollectedVisualSourceText"],
                                width = "full",
                                order = 500,
                                get = function(info) return WCollections.Config.Wardrobe.ShowCollectedVisualSourceText; end,
                                set = function(info, value) WCollections.Config.Wardrobe.ShowCollectedVisualSourceText = value; end,
                            },
                        },
                    },
                },
            },
            integration =
            {
                type = "group",
                name = L["Config.Integration"],
                args =
                {
                    panelChat =
                    {
                        type = "input",
                        name = L["Config.Integration.Chat"],
                        order = 0.1,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["chat"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelTooltips =
                    {
                        type = "input",
                        name = L["Config.Integration.Tooltips"],
                        order = 0.2,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["tooltips"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelMicroButtons =
                    {
                        type = "input",
                        name = L["Config.Integration.MicroButtons"],
                        order = 0.3,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["microButtons"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelMinimapButtons =
                    {
                        type = "input",
                        name = L["Config.Integration.MinimapButtons"],
                        order = 0.4,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["minimapButtons"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelActionButtons =
                    {
                        type = "input",
                        name = L["Config.Integration.ActionButtons"],
                        order = 0.5,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["actionButtons"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelItemButtons =
                    {
                        type = "input",
                        name = L["Config.Integration.ItemButtons"],
                        order = 0.6,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["itemButtons"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelWindows =
                    {
                        type = "input",
                        name = L["Config.Integration.Windows"],
                        order = 0.65,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["windows"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    panelDressUp =
                    {
                        type = "input",
                        name = L["Config.Integration.DressUp"],
                        order = 0.7,
                        func = function() InterfaceOptionsFrame_OpenToCategory(panels["dressUp"]); end,
                        dialogControl = "WCollectionsOptionsMediumButtonTemplate",
                    },
                    restoreItemIcons =
                    {
                        type = "group",
                        name = L["Config.RestoreItemIcons"],
                        inline = true,
                        order = 100,
                        hidden = function() return WCollections.NewVersion and WCollections.NewVersion.Disabled; end,
                        args =
                        {
                            desc =
                            {
                                type = "description",
                                name = L["Config.RestoreItemIcons.Desc"],
                                order = 0,
                            },
                            equipment =
                            {
                                type = "toggle",
                                name = L["Config.RestoreItemIcons.Equipment"],
                                desc = L["Config.RestoreItemIcons.Equipment.Desc"],
                                width = "full",
                                order = 100,
                                get = function(info) return WCollections.Config.RestoreItemIcons.Equipment; end,
                                set = function(info, value) WCollections.Config.RestoreItemIcons.Equipment = value; reloadUINeeded = true; end,
                            },
                            equipmentManager =
                            {
                                type = "toggle",
                                name = L["Config.RestoreItemIcons.EquipmentManager"],
                                desc = L["Config.RestoreItemIcons.EquipmentManager.Desc"],
                                width = "full",
                                order = 150,
                                disabled = function() return not WCollections.Config.RestoreItemIcons.Equipment; end,
                                get = function(info) return WCollections.Config.RestoreItemIcons.EquipmentManager; end,
                                set = function(info, value) WCollections.Config.RestoreItemIcons.EquipmentManager = value; reloadUINeeded = true; end,
                            },
                            inspect =
                            {
                                type = "toggle",
                                name = L["Config.RestoreItemIcons.Inspect"],
                                desc = L["Config.RestoreItemIcons.Inspect.Desc"],
                                width = "full",
                                order = 200,
                                get = function(info) return WCollections.Config.RestoreItemIcons.Inspect; end,
                                set = function(info, value) WCollections.Config.RestoreItemIcons.Inspect = value; reloadUINeeded = true; end,
                            },
                            global =
                            {
                                type = "toggle",
                                name = L["Config.RestoreItemIcons.Global"],
                                desc = L["Config.RestoreItemIcons.Global.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 900,
                                disabled = function() return not WCollections.Config.RestoreItemIcons.Equipment and not WCollections.Config.RestoreItemIcons.Inspect; end,
                                get = function(info) return WCollections.Config.RestoreItemIcons.Global; end,
                                set = function(info, value) WCollections.Config.RestoreItemIcons.Global = value; reloadUINeeded = true; end,
                            },
                            reload =
                            {
                                type = "execute",
                                name = L["Config.RestoreItemIcons.ReloadUI"],
                                desc = L["Config.RestoreItemIcons.ReloadUI.Desc"],
                                order = 1000,
                                hidden = function() return not reloadUINeeded; end,
                                func = function() ReloadUI(); end,
                            },
                        },
                    },
                    restoreItemSets =
                    {
                        type = "group",
                        name = L["Config.RestoreItemSets"],
                        inline = true,
                        order = 200,
                        hidden = function() return WCollections.NewVersion and WCollections.NewVersion.Disabled; end,
                        args =
                        {
                            desc =
                            {
                                type = "description",
                                name = L["Config.RestoreItemSets.Desc"],
                                order = 0,
                            },
                            equipment =
                            {
                                type = "toggle",
                                name = L["Config.RestoreItemSets.Equipment"],
                                desc = L["Config.RestoreItemSets.Equipment.Desc"],
                                width = "full",
                                order = 100,
                                get = function(info) return WCollections.Config.RestoreItemSets.Equipment; end,
                                set = function(info, value) WCollections.Config.RestoreItemSets.Equipment = value; end,
                            },
                            inspect =
                            {
                                type = "toggle",
                                name = L["Config.RestoreItemSets.Inspect"],
                                desc = L["Config.RestoreItemSets.Inspect.Desc"],
                                width = "full",
                                order = 200,
                                get = function(info) return WCollections.Config.RestoreItemSets.Inspect; end,
                                set = function(info, value) WCollections.Config.RestoreItemSets.Inspect = value; end,
                            },
                        },
                    },
                    misc =
                    {
                        type = "group",
                        name = L["Config.Integration.Misc"],
                        inline = true,
                        order = 1000,
                        hidden = function() return WCollections.NewVersion and WCollections.NewVersion.Disabled; end,
                        args =
                        {
                            wintergraspButton =
                            {
                                type = "toggle",
                                name = L["Config.Integration.Misc.WintergraspButton"],
                                desc = L["Config.Integration.Misc.WintergraspButton.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 100,
                                get = function(info) return WCollections.Config.Misc.WintergraspButton; end,
                                set = function(info, value) WCollections.Config.Misc.WintergraspButton = value; WCollections:SetWintergraspButton(value); end,
                            },
                            CFBGFactionIcons =
                            {
                                type = "toggle",
                                name = L["Config.Integration.Misc.CFBGFactionIcons"],
                                desc = L["Config.Integration.Misc.CFBGFactionIcons.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 200,
                                get = function(info) return WCollections.Config.Misc.CFBGFactionIcons; end,
                                set = function(info, value) WCollections.Config.Misc.CFBGFactionIcons = value; MiniMapBattlefieldFrame_isArena(); PlayerFrame_UpdatePvPStatus(); end,
                            },
                        },
                    },
                },
            },
            chat =
            {
                type = "group",
                name = format(L["Config.Integration.CategoryFormat"], L["Config.Integration.Chat"]),
                args =
                {
                    links =
                    {
                        type = "group",
                        name = L["Config.Integration.Chat.Links"],
                        inline = true,
                        order = 50,
                        args =
                        {
                            outfitIconEnable =
                            {
                                type = "toggle",
                                name = L["Config.Integration.Chat.Links.OutfitIcon"],
                                width = "full",
                                order = 100,
                                get = function(info) return WCollections.Config.ChatLinks.OutfitIcon.Enable; end,
                                set = function(info, value) WCollections.Config.ChatLinks.OutfitIcon.Enable = value; end,
                            },
                            outfitIconSize =
                            {
                                type = "range",
                                name = L["Config.Integration.Chat.Links.OutfitIcon.Size"],
                                desc = L["Config.Integration.Chat.Links.OutfitIcon.Size.Desc"],
                                min = 0,
                                max = 32,
                                softMin = 8,
                                bigStep = 1,
                                width = "half",
                                order = 101,
                                get = function(info) return WCollections.Config.ChatLinks.OutfitIcon.Size; end,
                                set = function(info, value) WCollections.Config.ChatLinks.OutfitIcon.Size = value; end,
                                disabled = function() return not WCollections.Config.ChatLinks.OutfitIcon.Enable; end,
                            },
                            outfitIconOffset =
                            {
                                type = "range",
                                name = L["Config.Integration.Chat.Links.OutfitIcon.Offset"],
                                desc = L["Config.Integration.Chat.Links.OutfitIcon.Offset.Desc"],
                                min = -10,
                                max = 10,
                                bigStep = 1,
                                width = "half",
                                order = 102,
                                get = function(info) return WCollections.Config.ChatLinks.OutfitIcon.Offset; end,
                                set = function(info, value) WCollections.Config.ChatLinks.OutfitIcon.Offset = value; end,
                                disabled = function() return not WCollections.Config.ChatLinks.OutfitIcon.Enable; end,
                            },
                            outfitIconExample =
                            {
                                type = "input",
                                name = function()
                                    local icon, text = TRANSMOG_OUTFIT_HYPERLINK_TEXT:match("^(|T.-|t)(.-)$");
                                    icon = icon and WCollections.Config.ChatLinks.OutfitIcon.Enable and icon:gsub("13:13:%-1:1", format("%1$d:%1$d:-1:%2$d", WCollections.Config.ChatLinks.OutfitIcon.Size or 13, WCollections.Config.ChatLinks.OutfitIcon.Offset or 1));
                                    return format(L["Config.Integration.Chat.Links.OutfitIcon.Example"], icon or "", text or "");
                                end,
                                order = 103,
                                dialogControl = "WCollectionsOptionsChatFontTextTemplate",
                            },
                        },
                    },
                    alerts =
                    {
                        type = "group",
                        name = L["Config.Alerts"],
                        inline = true,
                        order = 100,
                        hidden = function() return WCollections.NewVersion and WCollections.NewVersion.Disabled; end,
                        args =
                        {
                            desc =
                            {
                                type = "description",
                                name = L["Config.Alerts.Desc"],
                                order = 0,
                            },
                            enable =
                            {
                                type = "toggle",
                                name = L["Config.Alerts.AddSkin.Enable"],
                                desc = L["Config.Alerts.AddSkin.Enable.Desc"],
                                width = "full",
                                order = 100,
                                get = function(info) return WCollections.Config.Alerts.AddSkin.Enable; end,
                                set = function(info, value) WCollections.Config.Alerts.AddSkin.Enable = value; end,
                            },
                            color =
                            {
                                type = "select",
                                name = L["Config.Alerts.AddSkin.Color"],
                                desc = L["Config.Alerts.AddSkin.Color.Desc"],
                                order = 101,
                                handler = WCollections.ConfigHandlers.Color, values = "values", get = "get", set = "set", disabled = "disabled",
                                arg = WCollections.Config.Alerts.AddSkin,
                            },
                            customColor =
                            {
                                type = "color",
                                name = L["Config.Alerts.AddSkin.CustomColor"],
                                desc = L["Config.Alerts.AddSkin.CustomColor.Desc"],
                                width = "half",
                                order = 102,
                                handler = WCollections.ConfigHandlers.CustomColor, get = "get", set = "set", disabled = "disabled",
                                arg = WCollections.Config.Alerts.AddSkin,
                            },
                            fullRowColor =
                            {
                                type = "toggle",
                                name = L["Config.Alerts.AddSkin.FullRowColor"],
                                desc = L["Config.Alerts.AddSkin.FullRowColor.Desc"],
                                width = "half",
                                order = 103,
                                get = function(info) return WCollections.Config.Alerts.AddSkin.FullRowColor; end,
                                set = function(info, value) WCollections.Config.Alerts.AddSkin.FullRowColor = value; end,
                                disabled = function() return not WCollections.Config.Alerts.AddSkin.Enable; end,
                            },
                            lb1 = { type = "description", name = " ", order = 199 },
                            addToyEnable =
                            {
                                type = "toggle",
                                name = L["Config.Alerts.AddToy.Enable"],
                                desc = L["Config.Alerts.AddToy.Enable.Desc"],
                                width = "full",
                                order = 200,
                                get = function(info) return WCollections.Config.Alerts.AddToy.Enable; end,
                                set = function(info, value) WCollections.Config.Alerts.AddToy.Enable = value; end,
                            },
                            addToyColor =
                            {
                                type = "select",
                                name = L["Config.Alerts.AddToy.Color"],
                                desc = L["Config.Alerts.AddToy.Color.Desc"],
                                order = 201,
                                handler = WCollections.ConfigHandlers.Color, values = "values", get = "get", set = "set", disabled = "disabled",
                                arg = WCollections.Config.Alerts.AddToy,
                            },
                            addToyCustomColor =
                            {
                                type = "color",
                                name = L["Config.Alerts.AddToy.CustomColor"],
                                desc = L["Config.Alerts.AddToy.CustomColor.Desc"],
                                width = "half",
                                order = 202,
                                handler = WCollections.ConfigHandlers.CustomColor, get = "get", set = "set", disabled = "disabled",
                                arg = WCollections.Config.Alerts.AddToy,
                            },
                        },
                    },
                },
            },
            tooltips =
            {
                type = "group",
                name = format(L["Config.Integration.CategoryFormat"], L["Config.Integration.Tooltips"]),
                args =
                {
                    tooltipFlags =
                    {
                        type = "group",
                        name = L["Config.TooltipFlags"],
                        inline = true,
                        order = 100,
                        hidden = function() return WCollections.NewVersion and WCollections.NewVersion.Disabled; end,
                        args =
                        {
                            desc =
                            {
                                type = "description",
                                name = L["Config.TooltipFlags.Desc"],
                                order = 0,
                            },
                            enable =
                            {
                                type = "toggle",
                                name = L["Config.TooltipFlags.Enable"],
                                desc = L["Config.TooltipFlags.Enable.Desc"],
                                width = "full",
                                order = 1,
                                get = function(info) return WCollections.Config.TooltipFlags.Enable; end,
                                set = function(info, value) WCollections.Config.TooltipFlags.Enable = value; end,
                            },
                            color =
                            {
                                type = "select",
                                name = L["Config.TooltipFlags.Color"],
                                desc = L["Config.TooltipFlags.Color.Desc"],
                                order = 300,
                                handler = WCollections.ConfigHandlers.Color, values = "values", get = "get", set = "set", disabled = "disabled",
                                arg = WCollections.Config.TooltipFlags,
                            },
                            customColor =
                            {
                                type = "color",
                                name = L["Config.TooltipFlags.CustomColor"],
                                desc = L["Config.TooltipFlags.CustomColor.Desc"],
                                order = 301,
                                handler = WCollections.ConfigHandlers.CustomColor, get = "get", set = "set", disabled = "disabled",
                                arg = WCollections.Config.TooltipFlags,
                            },
                        },
                    },
                    tooltipTransmog =
                    {
                        type = "group",
                        name = L["Config.TooltipTransmog"],
                        inline = true,
                        order = 200,
                        hidden = function() return WCollections.NewVersion and WCollections.NewVersion.Disabled; end,
                        args =
                        {
                            desc =
                            {
                                type = "description",
                                name = L["Config.TooltipTransmog.Desc"],
                                order = 0,
                            },
                            enable =
                            {
                                type = "toggle",
                                name = L["Config.TooltipTransmog.Enable"],
                                desc = L["Config.TooltipTransmog.Enable.Desc"],
                                width = "full",
                                order = 1,
                                get = function(info) return WCollections.Config.TooltipTransmog.Enable; end,
                                set = function(info, value) WCollections.Config.TooltipTransmog.Enable = value; end,
                            },
                            iconEntry =
                            {
                                type = "toggle",
                                name = L["Config.TooltipTransmog.IconEntry"],
                                desc = L["Config.TooltipTransmog.IconEntry.Desc"],
                                width = "normal",
                                order = 100,
                                get = function(info) return WCollections.Config.TooltipTransmog.IconEntry.Enable; end,
                                set = function(info, value) WCollections.Config.TooltipTransmog.IconEntry.Enable = value; end,
                                disabled = function() return not WCollections.Config.TooltipTransmog.Enable; end,
                            },
                            iconEntrySize =
                            {
                                type = "range",
                                name = L["Config.TooltipTransmog.IconEntry.Size"],
                                desc = L["Config.TooltipTransmog.IconEntry.Size.Desc"],
                                min = 0,
                                max = 64,
                                softMin = 8,
                                bigStep = 1,
                                width = "half",
                                order = 101,
                                get = function(info) return WCollections.Config.TooltipTransmog.IconEntry.Size; end,
                                set = function(info, value) WCollections.Config.TooltipTransmog.IconEntry.Size = value; end,
                                disabled = function() return not WCollections.Config.TooltipTransmog.Enable or not WCollections.Config.TooltipTransmog.IconEntry.Enable or WCollections.Config.TooltipTransmog.IconEntry.Size == 0; end,
                            },
                            iconEntrySizeAuto =
                            {
                                type = "toggle",
                                name = L["Config.TooltipTransmog.IconEntry.Size.Auto"],
                                desc = L["Config.TooltipTransmog.IconEntry.Size.Auto.Desc"],
                                width = "half",
                                order = 102,
                                get = function(info) return WCollections.Config.TooltipTransmog.IconEntry.Size == 0; end,
                                set = function(info, value) WCollections.Config.TooltipTransmog.IconEntry.Size = value and 0 or 16; end,
                                disabled = function() return not WCollections.Config.TooltipTransmog.Enable or not WCollections.Config.TooltipTransmog.IconEntry.Enable; end,
                            },
                            lb1 = { type = "description", name = "", order = 102.5 },
                            iconEntryPadding1 =
                            {
                                type = "description",
                                name = "",
                                width = "normal",
                                order = 103,
                            },
                            iconEntryPadding2 =
                            {
                                type = "description",
                                name = "",
                                width = "half",
                                order = 104,
                            },
                            iconEntryCrop =
                            {
                                type = "toggle",
                                name = L["Config.TooltipTransmog.IconEntry.Crop"],
                                desc = L["Config.TooltipTransmog.IconEntry.Crop.Desc"],
                                width = "half",
                                order = 105,
                                get = function(info) return WCollections.Config.TooltipTransmog.IconEntry.Crop; end,
                                set = function(info, value) WCollections.Config.TooltipTransmog.IconEntry.Crop = value; end,
                                disabled = function() return not WCollections.Config.TooltipTransmog.Enable or not WCollections.Config.TooltipTransmog.IconEntry.Enable; end,
                            },
                            lb2 = { type = "description", name = "", order = 199 },
                            iconEnchant =
                            {
                                type = "toggle",
                                name = L["Config.TooltipTransmog.IconEnchant"],
                                desc = L["Config.TooltipTransmog.IconEnchant.Desc"],
                                width = "normal",
                                order = 200,
                                get = function(info) return WCollections.Config.TooltipTransmog.IconEnchant.Enable; end,
                                set = function(info, value) WCollections.Config.TooltipTransmog.IconEnchant.Enable = value; end,
                                disabled = function() return not WCollections.Config.TooltipTransmog.Enable; end,
                            },
                            iconEnchantSize =
                            {
                                type = "range",
                                name = L["Config.TooltipTransmog.IconEnchant.Size"],
                                desc = L["Config.TooltipTransmog.IconEnchant.Size.Desc"],
                                min = 0,
                                max = 64,
                                softMin = 8,
                                bigStep = 1,
                                width = "half",
                                order = 201,
                                get = function(info) return WCollections.Config.TooltipTransmog.IconEnchant.Size; end,
                                set = function(info, value) WCollections.Config.TooltipTransmog.IconEnchant.Size = value; end,
                                disabled = function() return not WCollections.Config.TooltipTransmog.Enable or not WCollections.Config.TooltipTransmog.IconEnchant.Enable or WCollections.Config.TooltipTransmog.IconEnchant.Size == 0; end,
                            },
                            iconEnchantSizeAuto =
                            {
                                type = "toggle",
                                name = L["Config.TooltipTransmog.IconEnchant.Size.Auto"],
                                desc = L["Config.TooltipTransmog.IconEnchant.Size.Auto.Desc"],
                                width = "half",
                                order = 202,
                                get = function(info) return WCollections.Config.TooltipTransmog.IconEnchant.Size == 0; end,
                                set = function(info, value) WCollections.Config.TooltipTransmog.IconEnchant.Size = value and 0 or 16; end,
                                disabled = function() return not WCollections.Config.TooltipTransmog.Enable or not WCollections.Config.TooltipTransmog.IconEnchant.Enable; end,
                            },
                            lb3 = { type = "description", name = "", order = 202.5 },
                            iconEnchantPadding1 =
                            {
                                type = "description",
                                name = "",
                                width = "normal",
                                order = 203,
                            },
                            iconEnchantPadding2 =
                            {
                                type = "description",
                                name = "",
                                width = "half",
                                order = 204,
                            },
                            iconEnchantCrop =
                            {
                                type = "toggle",
                                name = L["Config.TooltipTransmog.IconEnchant.Crop"],
                                desc = L["Config.TooltipTransmog.IconEnchant.Crop.Desc"],
                                width = "half",
                                order = 205,
                                get = function(info) return WCollections.Config.TooltipTransmog.IconEnchant.Crop; end,
                                set = function(info, value) WCollections.Config.TooltipTransmog.IconEnchant.Crop = value; end,
                                disabled = function() return not WCollections.Config.TooltipTransmog.Enable or not WCollections.Config.TooltipTransmog.IconEnchant.Enable; end,
                            },
                            lb4 = { type = "description", name = "", order = 249 },
                            newHideVisualIcon =
                            {
                                type = "toggle",
                                name = L["Config.TooltipTransmog.NewHideVisualIcon"],
                                desc = L["Config.TooltipTransmog.NewHideVisualIcon.Desc"],
                                width = "full",
                                order = 250,
                                get = function(info) return WCollections.Config.TooltipTransmog.NewHideVisualIcon; end,
                                set = function(info, value) WCollections.Config.TooltipTransmog.NewHideVisualIcon = value; end,
                                disabled = function() return not WCollections.Config.TooltipTransmog.Enable; end,
                            },
                            color =
                            {
                                type = "select",
                                name = L["Config.TooltipTransmog.Color"],
                                desc = L["Config.TooltipTransmog.Color.Desc"],
                                order = 300,
                                handler = WCollections.ConfigHandlers.Color, values = "values", get = "get", set = "set", disabled = "disabled",
                                arg = WCollections.Config.TooltipTransmog,
                            },
                            customColor =
                            {
                                type = "color",
                                name = L["Config.TooltipTransmog.CustomColor"],
                                desc = L["Config.TooltipTransmog.CustomColor.Desc"],
                                order = 301,
                                handler = WCollections.ConfigHandlers.CustomColor, get = "get", set = "set", disabled = "disabled",
                                arg = WCollections.Config.TooltipTransmog,
                            },
                        },
                    },
                    tooltipSets =
                    {
                        type = "group",
                        name = L["Config.TooltipSets"],
                        inline = true,
                        order = 300,
                        hidden = function() return WCollections.NewVersion and WCollections.NewVersion.Disabled; end,
                        args =
                        {
                            desc =
                            {
                                type = "description",
                                name = L["Config.TooltipSets.Desc"],
                                order = 0,
                            },
                            collected =
                            {
                                type = "toggle",
                                name = L["Config.TooltipSets.Collected"],
                                desc = L["Config.TooltipSets.Collected.Desc"],
                                width = "full",
                                order = 100,
                                get = function(info) return WCollections.Config.TooltipSets.Collected; end,
                                set = function(info, value) WCollections.Config.TooltipSets.Collected = value; end,
                            },
                            uncollected =
                            {
                                type = "toggle",
                                name = L["Config.TooltipSets.Uncollected"],
                                desc = L["Config.TooltipSets.Uncollected.Desc"],
                                width = "full",
                                order = 200,
                                get = function(info) return WCollections.Config.TooltipSets.Uncollected; end,
                                set = function(info, value) WCollections.Config.TooltipSets.Uncollected = value; end,
                            },
                            Appearances =
                            {
                                type = "toggle",
                                name = L["Config.TooltipSets.Appearances"],
                                desc = L["Config.TooltipSets.Appearances.Desc"],
                                width = "full",
                                order = 300,
                                get = function(info) return WCollections.Config.Wardrobe.ShowSetsInAppearances; end,
                                set = function(info, value) WCollections.Config.Wardrobe.ShowSetsInAppearances = value; end,
                            },
                            color =
                            {
                                type = "select",
                                name = L["Config.TooltipSets.Color"],
                                desc = L["Config.TooltipSets.Color.Desc"],
                                order = 1000,
                                handler = WCollections.ConfigHandlers.Color, values = "values", get = "get", set = "set",
                                arg = WCollections.Config.TooltipSets,
                            },
                            customColor =
                            {
                                type = "color",
                                name = L["Config.TooltipSets.CustomColor"],
                                desc = L["Config.TooltipSets.CustomColor.Desc"],
                                width = "half",
                                order = 1001,
                                handler = WCollections.ConfigHandlers.CustomColor, get = "get", set = "set", disabled = "disabled2",
                                arg = WCollections.Config.TooltipSets,
                            },
                            separator =
                            {
                                type = "toggle",
                                name = L["Config.TooltipSets.Separator"],
                                desc = L["Config.TooltipSets.Separator.Desc"],
                                width = "half",
                                order = 1002,
                                get = function(info) return WCollections.Config.TooltipSets.Separator; end,
                                set = function(info, value) WCollections.Config.TooltipSets.Separator = value; end,
                            },
                            SlotStateStyle =
                            {
                                type = "select",
                                name = L["Config.TooltipSets.SlotStateStyle"],
                                desc = L["Config.TooltipSets.SlotStateStyle.Desc"],
                                width = "full",
                                order = 1100,
                                values = function()
                                    local values = { };
                                    for i = 1, 4 do
                                        values[i] = L["TooltipSets.SlotStateStyle."..i];
                                    end
                                    return values;
                                end,
                                get = function(info) return WCollections.Config.TooltipSets.SlotStateStyle; end,
                                set = function(info, value) WCollections.Config.TooltipSets.SlotStateStyle = value; end,
                            },
                        },
                    },
                    tooltipCollection =
                    {
                        type = "group",
                        name = L["Config.TooltipCollection"],
                        inline = true,
                        order = 400,
                        hidden = function() return WCollections.NewVersion and WCollections.NewVersion.Disabled; end,
                        args =
                        {
                            desc =
                            {
                                type = "description",
                                name = L["Config.TooltipCollection.Desc"],
                                order = 0,
                            },
                            ownedItems =
                            {
                                type = "toggle",
                                name = L["Config.TooltipCollection.OwnedItems"],
                                desc = L["Config.TooltipCollection.OwnedItems.Desc"],
                                width = "full",
                                order = 100,
                                get = function(info) return WCollections.Config.TooltipCollection.OwnedItems; end,
                                set = function(info, value) WCollections.Config.TooltipCollection.OwnedItems = value; end,
                                hidden = function() return not WCollections.Collections.OwnedItems.Enabled; end,
                            },
                            skins =
                            {
                                type = "toggle",
                                name = L["Config.TooltipCollection.Skins"],
                                desc = L["Config.TooltipCollection.Skins.Desc"],
                                width = "full",
                                order = 200,
                                get = function(info) return WCollections.Config.TooltipCollection.Skins; end,
                                set = function(info, value) WCollections.Config.TooltipCollection.Skins = value; end,
                                hidden = function() return not WCollections.Collections.Skins.Enabled; end,
                            },
                            skinUnlock =
                            {
                                type = "toggle",
                                name = L["Config.TooltipCollection.SkinUnlock"],
                                desc = L["Config.TooltipCollection.SkinUnlock.Desc"],
                                order = 201,
                                get = function(info) return WCollections.Config.TooltipCollection.SkinUnlock; end,
                                set = function(info, value) WCollections.Config.TooltipCollection.SkinUnlock = value; end,
                                hidden = function() return not WCollections.Collections.Skins.Enabled; end,
                            },
                            skinUnlockBinding =
                            {
                                type = "keybinding",
                                name = L["Config.TooltipCollection.SkinUnlock.Binding"],
                                desc = L["Config.TooltipCollection.SkinUnlock.Binding.Desc"],
                                order = 202,
                                handler = WCollections.ConfigHandlers.Keybind,
                                arg = "WCOLLECTIONS_UNLOCK_SKIN",
                                get = "Get",
                                set = "Set",
                                hidden = function() return not WCollections.Collections.Skins.Enabled; end,
                            },
                            lb1 = { type = "description", name = "", order = 299 },
                            takenQuests =
                            {
                                type = "toggle",
                                name = L["Config.TooltipCollection.TakenQuests"],
                                desc = L["Config.TooltipCollection.TakenQuests.Desc"],
                                width = "full",
                                order = 300,
                                get = function(info) return WCollections.Config.TooltipCollection.TakenQuests; end,
                                set = function(info, value) WCollections.Config.TooltipCollection.TakenQuests = value; end,
                                hidden = function() return not WCollections.Collections.TakenQuests.Enabled; end,
                            },
                            rewardedQuests =
                            {
                                type = "toggle",
                                name = L["Config.TooltipCollection.RewardedQuests"],
                                desc = L["Config.TooltipCollection.RewardedQuests.Desc"],
                                width = "full",
                                order = 400,
                                get = function(info) return WCollections.Config.TooltipCollection.RewardedQuests; end,
                                set = function(info, value) WCollections.Config.TooltipCollection.RewardedQuests = value; end,
                                hidden = function() return not WCollections.Collections.RewardedQuests.Enabled; end,
                            },
                            toys =
                            {
                                type = "toggle",
                                name = L["Config.TooltipCollection.Toys"],
                                desc = L["Config.TooltipCollection.Toys.Desc"],
                                width = "full",
                                order = 500,
                                get = function(info) return WCollections.Config.TooltipCollection.Toys; end,
                                set = function(info, value) WCollections.Config.TooltipCollection.Toys = value; end,
                                hidden = function() return not WCollections.Collections.Toys.Enabled; end,
                            },
                            toyUnlock =
                            {
                                type = "toggle",
                                name = L["Config.TooltipCollection.ToyUnlock"],
                                desc = L["Config.TooltipCollection.ToyUnlock.Desc"],
                                order = 501,
                                get = function(info) return WCollections.Config.TooltipCollection.ToyUnlock; end,
                                set = function(info, value) WCollections.Config.TooltipCollection.ToyUnlock = value; end,
                                hidden = function() return not WCollections.Collections.Toys.Enabled; end,
                            },
                            toyUnlockEmbed =
                            {
                                type = "toggle",
                                name = L["Config.TooltipCollection.ToyUnlock.Embed"],
                                desc = L["Config.TooltipCollection.ToyUnlock.Embed.Desc"],
                                order = 502,
                                get = function(info) return WCollections.Config.TooltipCollection.ToyUnlockEmbed; end,
                                set = function(info, value) WCollections.Config.TooltipCollection.ToyUnlockEmbed = value; end,
                                disabled = function() return not WCollections.Config.TooltipCollection.ToyUnlock; end,
                                hidden = function() return not WCollections.Collections.Toys.Enabled; end,
                            },
                            lb2 = { type = "description", name = "", order = 999 },
                            color =
                            {
                                type = "select",
                                name = L["Config.TooltipCollection.Color"],
                                desc = L["Config.TooltipCollection.Color.Desc"],
                                order = 1000,
                                handler = WCollections.ConfigHandlers.Color, values = "values", get = "get", set = "set",
                                arg = WCollections.Config.TooltipCollection,
                            },
                            customColor =
                            {
                                type = "color",
                                name = L["Config.TooltipCollection.CustomColor"],
                                desc = L["Config.TooltipCollection.CustomColor.Desc"],
                                width = "half",
                                order = 1001,
                                handler = WCollections.ConfigHandlers.CustomColor, get = "get", set = "set", disabled = "disabled2",
                                arg = WCollections.Config.TooltipCollection,
                            },
                            separator =
                            {
                                type = "toggle",
                                name = L["Config.TooltipCollection.Separator"],
                                desc = L["Config.TooltipCollection.Separator.Desc"],
                                width = "half",
                                order = 1002,
                                get = function(info) return WCollections.Config.TooltipCollection.Separator; end,
                                set = function(info, value) WCollections.Config.TooltipCollection.Separator = value; end,
                            },
                        },
                    },
                },
            },
            microButtons =
            {
                type = "group",
                name = format(L["Config.Integration.CategoryFormat"], L["Config.Integration.MicroButtons"]),
                args =
                {
                    microButtons =
                    {
                        type = "group",
                        name = L["Config.Wardrobe.MicroButtons"],
                        inline = true,
                        order = 100,
                        args =
                        {
                            desc =
                            {
                                type = "description",
                                name = L["Config.Wardrobe.MicroButtons.Desc"],
                                order = 0,
                            },
                            option =
                            {
                                type = "select",
                                name = L["Config.Wardrobe.MicroButtons.Option"],
                                width = "full",
                                order = 100,
                                values = function()
                                    local values = { };
                                    for id, data in ipairs(microButtonOptions) do
                                        values[id] = data[1];
                                    end
                                    return values;
                                end,
                                get = function(info) return WCollections.Config.Wardrobe.MicroButtonsOption; end,
                                set = function(info, value) WCollections.Config.Wardrobe.MicroButtonsOption = value; setupCollectionsMicroButton(); end,
                            },
                            actionLMB =
                            {
                                type = "select",
                                name = L["Config.Wardrobe.MicroButtons.Action.LMB"],
                                order = 200,
                                disabled = function(info)
                                    return WCollections.Config.Wardrobe.MicroButtonsOption == 1;
                                end,
                                values = function()
                                    local values = { };
                                    for id, data in pairs(microButtonActions) do
                                        if id == 0 then
                                            values[id] = L["Config.Wardrobe.MicroButtons.Action.Last"];
                                        elseif _G["CollectionsJournalTab"..id] and not _G["CollectionsJournalTab"..id].isDisabled then
                                            values[id] = format(L["Config.Wardrobe.MicroButtons.Action.Tab"], data);
                                        end
                                    end
                                    return values;
                                end,
                                get = function(info) return WCollections.Config.Wardrobe.MicroButtonsActionLMB; end,
                                set = function(info, value) WCollections.Config.Wardrobe.MicroButtonsActionLMB = value; setupCollectionsMicroButton(); end,
                            },
                            actionRMB =
                            {
                                type = "select",
                                name = L["Config.Wardrobe.MicroButtons.Action.RMB"],
                                order = 201,
                                disabled = function(info)
                                    return WCollections.Config.Wardrobe.MicroButtonsOption == 1;
                                end,
                                values = function()
                                    local values = { };
                                    for id, data in pairs(microButtonActions) do
                                        if id == 0 then
                                            values[id] = L["Config.Wardrobe.MicroButtons.Action.Last"];
                                        elseif _G["CollectionsJournalTab"..id] and not _G["CollectionsJournalTab"..id].isDisabled then
                                            values[id] = format(L["Config.Wardrobe.MicroButtons.Action.Tab"], data);
                                        end
                                    end
                                    return values;
                                end,
                                get = function(info) return WCollections.Config.Wardrobe.MicroButtonsActionRMB; end,
                                set = function(info, value) WCollections.Config.Wardrobe.MicroButtonsActionRMB = value; setupCollectionsMicroButton(); end,
                            },
                            icon = (function()
                                local group =
                                {
                                    type = "group",
                                    name = L["Config.Wardrobe.MicroButtons.Icon"],
                                    inline = true,
                                    order = 300,
                                    disabled = function(info)
                                        return WCollections.Config.Wardrobe.MicroButtonsOption == 1;
                                    end,
                                    args = { },
                                };
                                for id, data in pairs(microButtonIcons) do
                                    group.args["icon"..id] =
                                    {
                                        type = "input",
                                        name = microButtonIcons[id],
                                        width = "half",
                                        order = id,
                                        func = function() WCollections.Config.Wardrobe.MicroButtonsIcon = id; setupCollectionsMicroButton(); end,
                                        dialogControl = "WCollectionsOptionsMicroButtonIconTemplate",
                                    };
                                end
                                return group;
                            end)(),
                        },
                    },
                },
            },
            minimapButtons =
            {
                type = "group",
                name = format(L["Config.Integration.CategoryFormat"], L["Config.Integration.MinimapButtons"]),
                args =
                {
                    minimapButtons =
                    {
                        type = "group",
                        name = L["Config.Wardrobe.MinimapButtons"],
                        inline = true,
                        order = 100,
                        args =
                        {
                            desc =
                            {
                                type = "description",
                                name = L["Config.Wardrobe.MinimapButtons.Desc"],
                                order = 0,
                            },
                            collections =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.MinimapButtons.Collections"],
                                width = "full",
                                order = 100,
                                get = function(info) return not WCollections.Config.Wardrobe.MinimapButtonCollections.hide; end,
                                set = function(info, value) WCollections.Config.Wardrobe.MinimapButtonCollections.hide = not value; setupMinimapButtons(); end,
                            },
                            collectionsRMB =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.MinimapButtons.Collections.RMB"],
                                width = "full",
                                order = 101,
                                get = function(info) return WCollections.Config.Wardrobe.MinimapButtonCollectionsRMB; end,
                                set = function(info, value) WCollections.Config.Wardrobe.MinimapButtonCollectionsRMB = value; end,
                            },
                            collectionsPos =
                            {
                                type = "range",
                                name = L["Config.Wardrobe.MinimapButtons.Collections.Pos"],
                                order = 102,
                                min = 0,
                                max = 360,
                                step = 1,
                                get = function(info) return WCollections.Config.Wardrobe.MinimapButtonCollections.minimapPos or 205; end,
                                set = function(info, value) WCollections.Config.Wardrobe.MinimapButtonCollections.minimapPos = value; setupMinimapButtons(); end,
                            },
                            lb1 = { type = "description", name = " ", order = 199 },
                            transmogrify =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.MinimapButtons.Transmogrify"],
                                width = "full",
                                order = 200,
                                get = function(info) return not WCollections.Config.Wardrobe.MinimapButtonTransmogrify.hide; end,
                                set = function(info, value) WCollections.Config.Wardrobe.MinimapButtonTransmogrify.hide = not value; setupMinimapButtons(); end,
                            },
                            transmogrifyRMB =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.MinimapButtons.Transmogrify.RMB"],
                                width = "full",
                                order = 201,
                                get = function(info) return WCollections.Config.Wardrobe.MinimapButtonTransmogrifyRMB; end,
                                set = function(info, value) WCollections.Config.Wardrobe.MinimapButtonTransmogrifyRMB = value; end,
                            },
                            transmogrifyPos =
                            {
                                type = "range",
                                name = L["Config.Wardrobe.MinimapButtons.Transmogrify.Pos"],
                                order = 202,
                                min = 0,
                                max = 360,
                                step = 1,
                                get = function(info) return WCollections.Config.Wardrobe.MinimapButtonTransmogrify.minimapPos or 225; end,
                                set = function(info, value) WCollections.Config.Wardrobe.MinimapButtonTransmogrify.minimapPos = value; setupMinimapButtons(); end,
                            },
                        },
                    },
                },
            },
            actionButtons =
            {
                type = "group",
                name = format(L["Config.Integration.CategoryFormat"], L["Config.Integration.ActionButtons"]),
                args =
                {
                    actionButtons =
                    {
                        type = "group",
                        name = L["Config.Integration.ActionButtons"],
                        inline = true,
                        order = 100,
                        hidden = function() return WCollections.NewVersion and WCollections.NewVersion.Disabled; end,
                        args =
                        {
                            desc =
                            {
                                type = "description",
                                name = L["Config.Integration.ActionButtons.Desc"],
                                order = 0,
                            },
                            mounts =
                            {
                                type = "toggle",
                                name = L["Config.Integration.ActionButtons.Mounts"],
                                desc = L["Config.Integration.ActionButtons.Mounts.Desc"],
                                order = 100,
                                get = function(info) return WCollections.Config.ActionButtons.Mounts; end,
                                set = function(info, value) WCollections.Config.ActionButtons.Mounts = value; reloadUINeeded2 = true; end,
                            },
                            mountsPerf =
                            {
                                type = "toggle",
                                name = L["Config.Integration.ActionButtons.MountsPerf"],
                                desc = L["Config.Integration.ActionButtons.MountsPerf.Desc"],
                                order = 101,
                                disabled = function() return not WCollections.Config.ActionButtons.Mounts; end,
                                get = function(info) return WCollections.Config.ActionButtons.MountsPerf; end,
                                set = function(info, value) WCollections.Config.ActionButtons.MountsPerf = value; end,
                            },
                            toys =
                            {
                                type = "toggle",
                                name = L["Config.Integration.ActionButtons.Toys"],
                                desc = L["Config.Integration.ActionButtons.Toys.Desc"],
                                width = "full",
                                order = 200,
                                get = function(info) return WCollections.Config.ActionButtons.Toys; end,
                                set = function(info, value) WCollections.Config.ActionButtons.Toys = value; reloadUINeeded2 = true; end,
                            },
                            addons =
                            {
                                type = "group",
                                name = L["Config.Integration.ActionButtons.Addons"],
                                inline = true,
                                order = 1000,
                                args =
                                {
                                    Bartender =
                                    {
                                        type = "toggle",
                                        name = WCollections.ConfigHelpers.IntegrationAddonName("Bartender4"),
                                        width = "full",
                                        order = 100,
                                        disabled = function() return not Bartender4; end,
                                        get = function(info) return WCollections.Config.ActionButtons.Addons.Bartender; end,
                                        set = function(info, value) WCollections.Config.ActionButtons.Addons.Bartender = value; reloadUINeeded2 = true; end,
                                    },
                                    ButtonForge =
                                    {
                                        type = "toggle",
                                        name = WCollections.ConfigHelpers.IntegrationAddonName("ButtonForge"),
                                        width = "full",
                                        order = 200,
                                        disabled = function() return not BFEventFrames; end,
                                        get = function(info) return WCollections.Config.ActionButtons.Addons.ButtonForge; end,
                                        set = function(info, value) WCollections.Config.ActionButtons.Addons.ButtonForge = value; reloadUINeeded2 = true; end,
                                    },
                                    Dominos =
                                    {
                                        type = "toggle",
                                        name = WCollections.ConfigHelpers.IntegrationAddonName("Dominos"),
                                        width = "full",
                                        order = 300,
                                        disabled = function() return not Dominos; end,
                                        get = function(info) return WCollections.Config.ActionButtons.Addons.Dominos; end,
                                        set = function(info, value) WCollections.Config.ActionButtons.Addons.Dominos = value; reloadUINeeded2 = true; end,
                                    },
                                    KActionBars =
                                    {
                                        type = "toggle",
                                        name = WCollections.ConfigHelpers.IntegrationAddonName("KActionBars"),
                                        width = "full",
                                        order = 400,
                                        disabled = function() return not KActionBars; end,
                                        get = function(info) return WCollections.Config.ActionButtons.Addons.KActionBars; end,
                                        set = function(info, value) WCollections.Config.ActionButtons.Addons.KActionBars = value; reloadUINeeded2 = true; end,
                                    },
                                    LibActionButton =
                                    {
                                        type = "toggle",
                                        name = WCollections.ConfigHelpers.IntegrationAddonName("LibActionButton (ElvUI)"),
                                        width = "full",
                                        order = 500,
                                        disabled = function() return not LibStub("LibActionButton-1.0", true) and not LibStub("LibActionButton-1.0-ElvUI", true); end,
                                        get = function(info) return WCollections.Config.ActionButtons.Addons.LibActionButton; end,
                                        set = function(info, value) WCollections.Config.ActionButtons.Addons.LibActionButton = value; reloadUINeeded2 = true; end,
                                    },
                                },
                            },
                            reload =
                            {
                                type = "execute",
                                name = L["Config.Integration.ActionButtons.ReloadUI"],
                                desc = L["Config.Integration.ActionButtons.ReloadUI.Desc"],
                                order = 2000,
                                hidden = function() return not reloadUINeeded2; end,
                                func = function() ReloadUI(); end,
                            },
                        },
                    },
                },
            },
            itemButtons =
            {
                type = "group",
                name = format(L["Config.Integration.CategoryFormat"], L["Config.Integration.ItemButtons"]),
                args =
                {
                    IconOverlays = WCollections.IconOverlays:MakeOptions(),
                },
            },
            windows =
            {
                type = "group",
                name = format(L["Config.Integration.CategoryFormat"], L["Config.Integration.Windows"]),
                childGroups = "tab",
                args = (function()
                    local result = { };
                    for i, windowName in ipairs(getWindows()) do
                        local config = WCollections.Config.Windows[windowName];
                        local disable = windowName == "DressUpFrame" and not config.Blizzard and not IsAddOnLoaded("WCollectionsDressUp");
                        local reloadUINeeded = false;
                        result[windowName] =
                        {
                            type = "group",
                            name = L["Config.Integration.Windows."..windowName],
                            order = i,
                            args =
                            {
                                strata =
                                {
                                    type = "select",
                                    name = L["Config.Wardrobe.Strata"],
                                    order = 100,
                                    values = windowStratas,
                                    disabled = function() return disable; end,
                                    get = function(info) for k, v in ipairs(windowStratas) do if v == config.Strata then return k; end end end,
                                    set = function(info, value) config.Strata = windowStratas[value]; updateWindows(); end,
                                },
                                layout =
                                {
                                    type = "toggle",
                                    name = L["Config.Wardrobe.Layout"],
                                    desc = L["Config.Wardrobe.Layout.Desc"],
                                    descStyle = "inline",
                                    width = "full",
                                    order = 200,
                                    disabled = function() return disable; end,
                                    get = function(info) return config.Layout; end,
                                    set = function(info, value) config.Layout = value; updateWindows(true); end,
                                },
                                lock =
                                {
                                    type = "toggle",
                                    name = L["Config.Wardrobe.Lock"],
                                    width = "full",
                                    order = 300,
                                    disabled = function() return config.Layout or disable; end,
                                    get = function(info) return config.Lock or info.option.disabled(); end,
                                    set = function(info, value) config.Lock = value; updateWindows(config.Layout); end,
                                },
                                clamp =
                                {
                                    type = "toggle",
                                    name = L["Config.Wardrobe.Clamp"],
                                    width = "full",
                                    order = 400,
                                    disabled = function() return config.Layout or disable; end,
                                    get = function(info) return config.Clamp or info.option.disabled(); end,
                                    set = function(info, value) config.Clamp = value; updateWindows(); end,
                                },
                                escape =
                                {
                                    type = "toggle",
                                    name = L["Config.Wardrobe.Escape"],
                                    width = "full",
                                    order = 500,
                                    disabled = function() return config.Layout or disable; end,
                                    get = function(info) return config.Escape or info.option.disabled(); end,
                                    set = function(info, value) config.Escape = value; updateWindows(); end,
                                },
                                resetPositions =
                                {
                                    type = "execute",
                                    name = L["Config.Wardrobe.ResetPositions"],
                                    order = 900,
                                    disabled = function() return config.Layout or disable; end,
                                    func = function()
                                        local window = _G[windowName];
                                        window:ClearAllPoints();
                                        window:SetPoint("CENTER", UIParent, "CENTER");
                                    end,
                                },
                                etherealWindowSound =
                                {
                                    type = "toggle",
                                    name = L["Config.Wardrobe.EtherealWindowSound"],
                                    desc = L["Config.Wardrobe.EtherealWindowSound.Desc"],
                                    descStyle = "inline",
                                    width = "full",
                                    order = 1000,
                                    hidden = function() return windowName ~= "WardrobeFrame"; end,
                                    get = function(info) return WCollections.Config.Wardrobe.EtherealWindowSound; end,
                                    set = function(info, value) WCollections.Config.Wardrobe.EtherealWindowSound = value; end,
                                },
                                dressUpBlizzard =
                                {
                                    type = "toggle",
                                    name = L["Config.Integration.Windows.DressUpBlizzard"],
                                    desc = L["Config.Integration.Windows.DressUpBlizzard.Desc"],
                                    descStyle = "inline",
                                    width = "full",
                                    order = 1100,
                                    hidden = function() return windowName ~= "DressUpFrame"; end,
                                    get = function(info) return config.Blizzard; end,
                                    set = function(info, value) config.Blizzard = value; reloadUINeeded = true; end,
                                },
                                reload =
                                {
                                    type = "execute",
                                    name = L["Config.RestoreItemIcons.ReloadUI"],
                                    desc = L["Config.RestoreItemIcons.ReloadUI.Desc"],
                                    order = 2000,
                                    hidden = function() return not reloadUINeeded; end,
                                    func = function() ReloadUI(); end,
                                },
                            },
                        };
                    end
                    return result;
                end)(),
            },
            dressUp =
            {
                type = "group",
                name = format(L["Config.Integration.CategoryFormat"], L["Config.Integration.DressUp"]),
                args =
                {
                    dressUp =
                    {
                        type = "group",
                        name = function() return L[IsAddOnLoaded("WCollectionsDressUp") and "Config.Wardrobe.Misc.DressUp" or "Config.Wardrobe.Misc.DressUp.Inactive"]; end,
                        inline = true,
                        order = 100,
                        disabled = function() return not IsAddOnLoaded("WCollectionsDressUp"); end,
                        args =
                        {
                            dressUpClassBackground =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.DressUp.ClassBackground"],
                                desc = L["Config.Wardrobe.DressUp.ClassBackground.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 100,
                                disabled = function() return not IsAddOnLoaded("WCollectionsDressUp"); end,
                                get = function(info) return WCollections.Config.Wardrobe.DressUpClassBackground; end,
                                set = function(info, value)
                                    WCollections.Config.Wardrobe.DressUpClassBackground = value;
                                    if value then
                                        SetDressUpBackground(DressUpFrame, nil, select(2, UnitClass("player")));
                                    else
                                        SetDressUpBackground(DressUpFrame, select(2, UnitRace("player")));
                                    end
                                end,
                            },
                            DressUpGnomeTrollBackground =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.DressUp.GnomeTrollBackground"],
                                desc = L["Config.Wardrobe.DressUp.GnomeTrollBackground.Desc"],
                                descStyle = "inline",
                                width = "full",
                                order = 150,
                                disabled = function() return not IsAddOnLoaded("WCollectionsDressUp") or WCollections.Config.Wardrobe.DressUpClassBackground; end,
                                get = function(info) return WCollections.Config.Wardrobe.DressUpGnomeTrollBackground; end,
                                set = function(info, value)
                                    WCollections.Config.Wardrobe.DressUpGnomeTrollBackground = value;
                                    SetDressUpBackground(DressUpFrame, select(2, UnitRace("player")));
                                    if SideDressUpFrame then
                                        SetDressUpBackground(SideDressUpFrame, select(2, UnitRace("player")));
                                    end
                                end,
                            },
                            dressUpDesaturateBackground =
                            {
                                type = "toggle",
                                name = L["Config.Wardrobe.DressUp.DesaturateBackground"],
                                width = "full",
                                order = 200,
                                disabled = function() return not IsAddOnLoaded("WCollectionsDressUp"); end,
                                get = function(info) return WCollections.Config.Wardrobe.DressUpDesaturateBackground; end,
                                set = function(info, value)
                                    WCollections.Config.Wardrobe.DressUpDesaturateBackground = value;
                                    if WCollections.Config.Wardrobe.DressUpClassBackground then
                                        SetDressUpBackground(DressUpFrame, nil, select(2, UnitClass("player")));
                                    else
                                        SetDressUpBackground(DressUpFrame, select(2, UnitRace("player")));
                                    end
                                    if SideDressUpFrame then
                                        SetDressUpBackground(SideDressUpFrame, select(2, UnitRace("player")));
                                    end
                                end,
                            },
                            DressUpSkipDressOnShow =
                            {
                                type = "toggle",
                                name = L["Config.Integration.DressUp.SkipDressOnShow"],
                                width = "full",
                                order = 300,
                                disabled = function() return not IsAddOnLoaded("WCollectionsDressUp"); end,
                                get = function(info) return WCollections.Config.Wardrobe.DressUpSkipDressOnShow; end,
                                set = function(info, value) WCollections.Config.Wardrobe.DressUpSkipDressOnShow = value; end,
                            },
                        },
                    },
                },
            },
            bindings =
            {
                type = "group",
                name = L["Config.Bindings"],
                args =
                {
                    bindings =
                    {
                        type = "group",
                        name = L["Config.Bindings"],
                        inline = true,
                        args =
                        {
                            desc =
                            {
                                type = "description",
                                name = L["Config.Bindings.Desc"],
                                order = 0,
                            },
                            skinUnlockDesc =
                            {
                                type = "description",
                                name = L["Binding.UnlockSkin"],
                                width = "normal",
                                order = 100,
                            },
                            skinUnlock =
                            {
                                type = "keybinding",
                                name = "",
                                order = 101,
                                handler = WCollections.ConfigHandlers.Keybind,
                                arg = "WCOLLECTIONS_UNLOCK_SKIN",
                                get = "Get",
                                set = "Set",
                            },
                            lb1 = { type = "description", name = "", order = 198 },
                            headerWowcircle = { type = "header", name = L["Binding.Header.Wowcircle"], order = 199 },
                            menuWowcircleDesc =
                            {
                                type = "description",
                                name = L["Binding.Menu.Wowcircle"],
                                width = "normal",
                                order = 200,
                            },
                            menuWowcircle =
                            {
                                type = "keybinding",
                                name = "",
                                order = 201,
                                handler = WCollections.ConfigHandlers.Keybind,
                                arg = "WCOLLECTIONS_MENU_WOWCIRCLE",
                                get = "Get",
                                set = "Set",
                            },
                            lb2 = { type = "description", name = "", order = 299 },
                            menuTransmogDesc =
                            {
                                type = "description",
                                name = L["Binding.Menu.Transmog"],
                                width = "normal",
                                order = 300,
                            },
                            menuTransmog =
                            {
                                type = "keybinding",
                                name = "",
                                order = 301,
                                handler = WCollections.ConfigHandlers.Keybind,
                                arg = "WCOLLECTIONS_MENU_TRANSMOG",
                                get = "Get",
                                set = "Set",
                            },
                            lb3 = { type = "description", name = "", order = 349 },
                            menuTransmogSetsDesc =
                            {
                                type = "description",
                                name = L["Binding.Menu.Transmog.Sets"],
                                width = "normal",
                                order = 350,
                            },
                            menuTransmogSets =
                            {
                                type = "keybinding",
                                name = "",
                                order = 351,
                                handler = WCollections.ConfigHandlers.Keybind,
                                arg = "WCOLLECTIONS_MENU_TRANSMOG_SETS",
                                get = "Get",
                                set = "Set",
                            },
                            lb4 = { type = "description", name = "", order = 399 },
                            menuCollectionsDesc =
                            {
                                type = "description",
                                name = L["Binding.Menu.Collections"],
                                width = "normal",
                                order = 400,
                            },
                            menuCollections =
                            {
                                type = "keybinding",
                                name = "",
                                order = 401,
                                handler = WCollections.ConfigHandlers.Keybind,
                                arg = "WCOLLECTIONS_MENU_COLLECTIONS",
                                get = "Get",
                                set = "Set",
                            },
                            lb5 = { type = "description", name = "", order = 499 },
                            menuDailyDesc =
                            {
                                type = "description",
                                name = L["Binding.Menu.Daily"],
                                width = "normal",
                                order = 500,
                            },
                            menuDaily =
                            {
                                type = "keybinding",
                                name = "",
                                order = 501,
                                handler = WCollections.ConfigHandlers.Keybind,
                                arg = "WCOLLECTIONS_MENU_DAILY",
                                get = "Get",
                                set = "Set",
                            },
                            lb6 = { type = "description", name = "", order = 598 },
                            headerWardrobe = { type = "header", name = L["Binding.Header.Wardrobe"], order = 599 },
                            collectionsDesc =
                            {
                                type = "description",
                                name = BINDING_NAME_TOGGLECOLLECTIONS,
                                width = "normal",
                                order = 600,
                            },
                            collections =
                            {
                                type = "keybinding",
                                name = "",
                                order = 601,
                                handler = WCollections.ConfigHandlers.Keybind,
                                arg = "TOGGLECOLLECTIONS",
                                get = "Get",
                                set = "Set",
                            },
                            lb7 = { type = "description", name = "", order = 699 },
                            mountsDesc =
                            {
                                type = "description",
                                name = BINDING_NAME_TOGGLECOLLECTIONSMOUNTJOURNAL,
                                width = "normal",
                                order = 700,
                            },
                            mounts =
                            {
                                type = "keybinding",
                                name = "",
                                order = 701,
                                handler = WCollections.ConfigHandlers.Keybind,
                                arg = "TOGGLECOLLECTIONSMOUNTJOURNAL",
                                get = "Get",
                                set = "Set",
                            },
                            lb8 = { type = "description", name = "", order = 799 },
                            petsDesc =
                            {
                                type = "description",
                                name = BINDING_NAME_TOGGLECOLLECTIONSPETJOURNAL,
                                width = "normal",
                                order = 800,
                            },
                            pets =
                            {
                                type = "keybinding",
                                name = "",
                                order = 801,
                                handler = WCollections.ConfigHandlers.Keybind,
                                arg = "TOGGLECOLLECTIONSPETJOURNAL",
                                get = "Get",
                                set = "Set",
                            },
                            lb9 = { type = "description", name = "", order = 899 },
                            toyboxDesc =
                            {
                                type = "description",
                                name = BINDING_NAME_TOGGLECOLLECTIONSTOYBOX,
                                width = "normal",
                                order = 900,
                            },
                            toybox =
                            {
                                type = "keybinding",
                                name = "",
                                order = 901,
                                handler = WCollections.ConfigHandlers.Keybind,
                                arg = "TOGGLECOLLECTIONSTOYBOX",
                                get = "Get",
                                set = "Set",
                            },
                            lb10 = { type = "description", name = "", order = 999 },
                            --[[
                            heirloomsDesc =
                            {
                                type = "description",
                                name = BINDING_NAME_TOGGLECOLLECTIONSHEIRLOOM,
                                width = "normal",
                                order = 1000,
                            },
                            heirlooms =
                            {
                                type = "keybinding",
                                name = "",
                                order = 1001,
                                handler = WCollections.ConfigHandlers.Keybind,
                                arg = "TOGGLECOLLECTIONSHEIRLOOM",
                                get = "Get",
                                set = "Set",
                            },
                            lb11 = { type = "description", name = "", order = 1099 },
                            ]]
                            appearancesDesc =
                            {
                                type = "description",
                                name = BINDING_NAME_TOGGLECOLLECTIONSWARDROBE,
                                width = "normal",
                                order = 1100,
                            },
                            appearances =
                            {
                                type = "keybinding",
                                name = "",
                                order = 1101,
                                handler = WCollections.ConfigHandlers.Keybind,
                                arg = "TOGGLECOLLECTIONSWARDROBE",
                                get = "Get",
                                set = "Set",
                            },
                            lb12 = { type = "description", name = "", order = 1199 },
                            transmogrifyDesc =
                            {
                                type = "description",
                                name = BINDING_NAME_TOGGLETRANSMOGRIFY,
                                width = "normal",
                                order = 1200,
                            },
                            transmogrify =
                            {
                                type = "keybinding",
                                name = "",
                                order = 1201,
                                handler = WCollections.ConfigHandlers.Keybind,
                                arg = "TOGGLETRANSMOGRIFY",
                                get = "Get",
                                set = "Set",
                            },
                        },
                    },
                },
            },
        },
    };
    LibStub("AceConfig-3.0"):RegisterOptionsTable(ADDON_NAME, configTable);
    local function AddPanel(name, root)
        panels[name] = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(ADDON_NAME, not root and configTable.args[name].name or nil, not root and ADDON_NAME or nil, name);
    end
    AddPanel("general", true);
    AddPanel("wardrobe");
    AddPanel("mounts");
    AddPanel("pets");
    if _G["CollectionsJournalTab"..3] and not _G["CollectionsJournalTab"..3].isDisabled then
        AddPanel("toys");
    end
    if _G["CollectionsJournalTab"..4] and not _G["CollectionsJournalTab"..4].isDisabled then
        AddPanel("heirlooms");
    end
    AddPanel("appearances");
    AddPanel("transmogrify");
    AddPanel("integration");
    AddPanel("chat");
    AddPanel("tooltips");
    AddPanel("microButtons");
    AddPanel("minimapButtons");
    AddPanel("actionButtons");
    AddPanel("itemButtons");
    AddPanel("windows");
    AddPanel("dressUp");
    AddPanel("bindings");

    StaticPopupDialogs["WCOLLECTIONS_ERROR"] =
    {
        text = L["Popup.Error"],
        button1 = OKAY,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        hideOnEnter = 1,
    };
    StaticPopupDialogs["WCOLLECTIONS_ERROR_RELOADUI"] =
    {
        text = L["Popup.Error"],
        button1 = L["Popup.Error.ReloadUI"],
        button2 = CLOSE,
        OnAccept = function(self)
            ReloadUI();
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        hideOnEnter = 1,
    };
    StaticPopupDialogs["WCOLLECTIONS_NEW_VERSION"] =
    {
        text = "",
        button1 = OKAY,
        hasEditBox = 1,
        OnShow = function(self)
            self.text:SetText(format(WCollections.NewVersion.Disabled and L["Popup.NewVersion.Disabled"] or WCollections.NewVersion.Outdated and L["Popup.NewVersion.Outdated"] or L["Popup.NewVersion.Compatible"], WCollections.NewVersion.Version));
            if WCollections.NewVersion.Disabled then
                self.editBox:Hide();
            else
                self.editBox:SetText(WCollections.NewVersion.URL);
                self.editBox:SetFocus();
                self.editBox:HighlightText();
            end
        end,
        EditBoxOnEnterPressed = function(self, data)
            self:GetParent():Hide();
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide();
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        hideOnEnter = 1,
        showAlert = 1,
    };
    StaticPopupDialogs["WCOLLECTIONS_CONFIRM_CACHE_RESET"] =
    {
        text = L["Popup.Confirm.CacheReset"],
        button1 = YES,
        button2 = NO,
        OnAccept = function(self)
            WCollections:ClearCache();
            ReloadUI();
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
    };
    StaticPopupDialogs["WCOLLECTIONS_CONFIRM_CONFIG_RESET"] =
    {
        text = L["Popup.Confirm.ConfigReset"],
        button1 = YES,
        button2 = NO,
        OnAccept = function(self)
            config:ResetProfile();
            WardrobeFrame:SetUserPlaced(false);
            CollectionsJournal:SetUserPlaced(false);
            ReloadUI();
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
    };
    StaticPopupDialogs["WCOLLECTIONS_CONFIRM_FAVORITES_MERGE"] =
    {
        text = L["Popup.Confirm.FavoritesMerge"],
        button1 = YES,
        button2 = NO,
        OnAccept = function(self)
            for key, container in pairs(WCollections.Config.TransmogCollection.PerCharacter) do
                if key ~= "*" then
                    for id, fav in pairs(container.Favorites) do
                        if fav then
                            WCollections.Config.TransmogCollection.Favorites[id] = true;
                        end
                    end
                    for id, fav in pairs(container.SetFavorites) do
                        if fav then
                            WCollections.Config.TransmogCollection.SetFavorites[id] = true;
                        end
                    end
                end
            end
            WCollections:RaiseEvent("TRANSMOG_COLLECTION_UPDATED");
            WCollections:RaiseEvent("TRANSMOG_SETS_UPDATE_FAVORITE");
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
    };
    StaticPopupDialogs["WCOLLECTIONS_CONFIRM_FAVORITES_SPLIT"] =
    {
        text = L["Popup.Confirm.FavoritesSplit"],
        button1 = YES,
        button2 = NO,
        OnAccept = function(self)
            for key, container in pairs(WCollections.Config.TransmogCollection.PerCharacter) do
                if key ~= "*" then
                    for id, fav in pairs(WCollections.Config.TransmogCollection.Favorites) do
                        if fav then
                            container.Favorites[id] = true;
                        end
                    end
                    for id, fav in pairs(WCollections.Config.TransmogCollection.SetFavorites) do
                        if fav then
                            container.SetFavorites[id] = true;
                        end
                    end
                end
            end
            WCollections:RaiseEvent("TRANSMOG_COLLECTION_UPDATED");
            WCollections:RaiseEvent("TRANSMOG_SETS_UPDATE_FAVORITE");
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
    };
    StaticPopupDialogs["WCOLLECTIONS_UNLOCK_SKIN"] =
    {
        text = "",
        button1 = YES,
        button2 = NO,
        OnShow = function(self)
            self.text:SetText(format(L["Popup.UnlockSkin"], StaticPopupDialogs["WCOLLECTIONS_UNLOCK_SKIN"].itemLink));
        end,
        OnAccept = function(self)
            WCollections:SendAddonMessage( "UNLOCKSKIN:"..StaticPopupDialogs["WCOLLECTIONS_UNLOCK_SKIN"].commandData);
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        itemLink = nil,
        commandData = nil,
    };
    StaticPopupDialogs["WCOLLECTIONS_KEYBINDING_ERROR"] =
    {
        text = "",
        button1 = OKAY,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
    };
    StaticPopupDialogs["WCOLLECTIONS_PRELOADING_ITEM_CACHE"] =
    {
        text = L["Popup.PreloadingItemCache"],
        OnShow = function(self)
            local bar = StaticPopupDialogs["WCOLLECTIONS_PRELOADING_ITEM_CACHE"].progressBar;
            bar:SetParent(self);
            bar:SetPoint("BOTTOM", self, "BOTTOM", 0, 22);
            bar:SetWidth(math.floor(self:GetWidth() * 0.75));
            bar:SetMinMaxValues(0, 1);
            bar:SetValue(0);
            bar:Show();
            bar:SetScript("OnUpdate", function() bar:SetWidth(math.floor(self:GetWidth() * 0.75)); end);
            bar:SetScript("OnEvent", function(self, event, current, total)
                self:SetMinMaxValues(0, total);
                self:SetValue(current);
                self.text:SetText(format("%d / %d", current, total));
                if current >= total then
                    StaticPopup_Hide("WCOLLECTIONS_PRELOADING_ITEM_CACHE");
                end
            end);
            WCollections:RegisterEvent(bar, "WCOLLECTIONS_PRELOAD_ITEM_CACHE_PROGRESS");
        end,
        OnHide = function(self)
            local bar = StaticPopupDialogs["WCOLLECTIONS_PRELOADING_ITEM_CACHE"].progressBar;
            bar:Hide();
            bar:SetParent(nil);
            WCollections:UnregisterEvent(bar, "WCOLLECTIONS_PRELOAD_ITEM_CACHE_PROGRESS");
        end,
        timeout = 0,
        whileDead = 1,
        progressBar = CreateFrame("StatusBar", "WCollectionsItemCacheProgressBar", nil, "WCollectionsProgressBarTemplate"),
    };
    StaticPopupDialogs["WCOLLECTIONS_PRELOADING_MOUNT_CACHE"] =
    {
        text = L["Popup.PreloadingMountCache"],
        OnShow = function(self)
            local bar = StaticPopupDialogs["WCOLLECTIONS_PRELOADING_MOUNT_CACHE"].progressBar;
            bar:SetParent(self);
            bar:SetPoint("BOTTOM", self, "BOTTOM", 0, 22);
            bar:SetWidth(math.floor(self:GetWidth() * 0.75));
            bar:SetMinMaxValues(0, 1);
            bar:SetValue(0);
            bar:Show();
            bar:SetScript("OnUpdate", function() bar:SetWidth(math.floor(self:GetWidth() * 0.75)); end);
            bar:SetScript("OnEvent", function(self, event, current, total)
                self:SetMinMaxValues(0, total);
                self:SetValue(current);
                self.text:SetText(format("%d / %d", current, total));
                if current >= total then
                    StaticPopup_Hide("WCOLLECTIONS_PRELOADING_MOUNT_CACHE");
                end
            end);
            WCollections:RegisterEvent(bar, "WCOLLECTIONS_PRELOAD_MOUNT_CACHE_PROGRESS");
        end,
        OnHide = function(self)
            local bar = StaticPopupDialogs["WCOLLECTIONS_PRELOADING_MOUNT_CACHE"].progressBar;
            bar:Hide();
            bar:SetParent(nil);
            WCollections:UnregisterEvent(bar, "WCOLLECTIONS_PRELOAD_MOUNT_CACHE_PROGRESS");
        end,
        timeout = 0,
        whileDead = 1,
        progressBar = CreateFrame("StatusBar", "WCollectionsMountCacheProgressBar", nil, "WCollectionsProgressBarTemplate"),
    };
    StaticPopupDialogs["WCOLLECTIONS_STORE_URL"] =
    {
        text = L["Popup.StoreURL"],
        button1 = OKAY,
        hasEditBox = 1,
        OnShow = function(self, data)
            self.editBox:SetText(data);
            self.editBox:SetFocus();
            self.editBox:HighlightText();
        end,
        EditBoxOnEnterPressed = function(self)
            self:GetParent():Hide();
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide();
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        hideOnEnter = 1,
    };
    StaticPopupDialogs["WCOLLECTIONS_COPY_OUTFIT_COMMAND"] =
    {
        text = L["Popup.CopyOutfitCommand"],
        button1 = OKAY,
        hasEditBox = 1,
        OnShow = function(self, data)
            self.editBox:SetText(data);
            self.editBox:SetFocus();
            self.editBox:HighlightText();
        end,
        EditBoxOnEnterPressed = function(self)
            self:GetParent():Hide();
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide();
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        hideOnEnter = 1,
    };
    StaticPopupDialogs["WCOLLECTIONS_MOUNT_MACRO_CREATE"] =
    {
        text = L["Popup.Mount.Macro.Create"],
        button1 = YES,
        button2 = NO,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
    };
    StaticPopupDialogs["WCOLLECTIONS_MOUNT_MACRO_PERCHARACTER"] =
    {
        text = L["Popup.Mount.Macro.PerCharacter"],
        button1 = OKAY,
        button2 = CANCEL,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
    };
    StaticPopupDialogs["WCOLLECTIONS_PET_MACRO_CREATE"] =
    {
        text = L["Popup.Pet.Macro.Create"],
        button1 = YES,
        button2 = NO,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
    };
    StaticPopupDialogs["WCOLLECTIONS_PET_MACRO_PERCHARACTER"] =
    {
        text = L["Popup.Pet.Macro.PerCharacter"],
        button1 = OKAY,
        button2 = CANCEL,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
    };
    StaticPopupDialogs["WCOLLECTIONS_COMPATIBILITY_DRESSUP"] =
    {
        text = "",
        button1 = "WCollections",
        button2 = CANCEL,
        button3 = "",
        OnShow = function(self)
            local info = StaticPopupDialogs[self.which];
            local addon = info.incompatibleAddons[1] or "<ERROR>";
            self.text:SetText(format(L["Popup.Error.Compatibility.DressUp"], addon));
            self.button3:SetText(addon);
        end,
        OnAccept = function(self)
            local info = StaticPopupDialogs[self.which];
            local addon = info.incompatibleAddons[1];
            if addon then
                DisableAddOn(addon);
                table.remove(info.incompatibleAddons, 1);
            end
            info:Next();
        end,
        OnAlt = function(self)
            local info = StaticPopupDialogs[self.which];
            DisableAddOn("WCollectionsDressUp");
            table.wipe(info.incompatibleAddons);
            info:Next();
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        incompatibleAddons = { },
        Start = function(self)
            local incompatibleAddons = { "CloseUp" };
            for _, addon in ipairs(incompatibleAddons) do
                if select(4, GetAddOnInfo(addon)) then
                    table.insert(self.incompatibleAddons, addon);
                end
            end
            if next(self.incompatibleAddons) then
                self:Next();
            end
        end,
        Next = function(self)
            C_Timer.After(0, function()
                if next(self.incompatibleAddons) then
                    StaticPopup_Show("WCOLLECTIONS_COMPATIBILITY_DRESSUP");
                else
                    StaticPopup_Show("WCOLLECTIONS_ERROR_RELOADUI", L["Popup.Error.Compatibility.ReloadUI"]);
                end
            end);
        end,
    };

    WCollections:InitDropDownMenus(); -- Taint avoidance

    if WCollections.Config.RestoreItemIcons.Equipment or WCollections.Config.RestoreItemIcons.Inspect then
        self:HookRestoreItemIcons();
    end
    if WCollections.Config.ActionButtons.Mounts or WCollections.Config.ActionButtons.Toys then
        self:HookActionBars();
    end

    -- Need to delay this, otherwise the addon gets enabled right during addon loading process and actually gets loaded, but something breaks
    C_Timer.After(1, function()
        if not WCollections.Config.Wardrobe.ElvUIDressUpFirstLaunch then
            WCollections.Config.Wardrobe.ElvUIDressUpFirstLaunch = true;
            if not select(4, GetAddOnInfo("WCollectionsDressUp")) and select(4, GetAddOnInfo("ElvUI")) then
                EnableAddOn("WCollectionsDressUp");
                StaticPopup_Show("WCOLLECTIONS_ERROR_RELOADUI", L["Popup.Error.Compatibility.ElvUI.DressUp"]);
            end
        end
    end);

    if select(4, GetAddOnInfo("WCollectionsDressUp")) then
        StaticPopupDialogs["WCOLLECTIONS_COMPATIBILITY_DRESSUP"]:Start();
    end

    PanelTemplates_SetTab(CollectionsJournal, tonumber(WCollections:GetCVar("petJournalTab")) or 5);
end

-- ----------------
-- Helper functions
-- ----------------
local function RGBPercToHex(r, g, b)
    r = r <= 1 and r >= 0 and r or 0
    g = g <= 1 and g >= 0 and g or 0
    b = b <= 1 and b >= 0 and b or 0
    return string.format("%02X%02X%02X", r*255, g*255, b*255)
end
local function IsSameColor(aR, aG, aB, bR, bG, bB)
    return abs(aR - bR) <= 0.01
       and abs(aG - bG) <= 0.01
       and abs(aB - bB) <= 0.01;
end
local function FormatToPattern(format)
    return (format:gsub("%d+%$", ""):gsub("%(", "%%("):gsub("%)", "%%)"):gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)"):gsub("|4(.+):%1.+:%1.+;", "%1.-"):gsub("|4(.+);", ".-"));
end
local function starts_with(str, start)
   return str:sub(1, #start) == start
end
local function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end
local function match(str, prefix, callback)
    if starts_with(str, prefix) then
        callback(str:sub(#prefix + 1));
        return true;
    end
    return false;
end
local function deepcopy(orig)
    if type(orig) == 'table' then
        local copy = { };
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
        return copy;
    else
        return orig;
    end
end
local function GetItemID(item)
    if type(item) == "number" then
        return item;
    else
        local _, link = GetItemInfo(item);
        local _, id, _ = strsplit(":", link);
        return tonumber(id);
    end
end
local function GetUnitName(unit)
    local name, server = UnitName(unit);
    if server and server ~= "" then
        return name.."-"..server;
    end
    return name;
end

-- -----------------
-- Main core and API
-- -----------------
WCollections =
{
    Name = ADDON_NAME,
    Version = ADDON_VERSION,
    AceAddon = addon,
    L = L,
    Config = nil,
    Cache = nil,
    ClearCache = nil,
    Allowed = false,
    Token = nil,
    HideVisualSlots = { },
    WeaponCompatibility = { },
    InvTypeEnumToName = INVTYPE_ENUM_TO_NAME,
    InvTypeNameToEnum = (function() local tbl = { }; for id, name in ipairs(INVTYPE_ENUM_TO_NAME) do tbl[name] = id; end return tbl; end)(),
    ClassIDToName = CLASS_ID_TO_NAME,
    ClassNameToID = (function() local tbl = { }; for id, name in ipairs(CLASS_ID_TO_NAME) do tbl[name] = id; end return tbl; end)(),
    RaceIDToName = RACE_ID_TO_NAME,
    RaceNameToID = (function() local tbl = { }; for id, name in ipairs(RACE_ID_TO_NAME) do tbl[name] = id; end return tbl; end)(),
    RaceNameToFaction = { HUMAN = FACTION_ALLIANCE, DWARF = FACTION_ALLIANCE, NIGHTELF = FACTION_ALLIANCE, GNOME = FACTION_ALLIANCE, DRAENEI = FACTION_ALLIANCE, ORC = FACTION_HORDE, UNDEAD = FACTION_HORDE, TAUREN = FACTION_HORDE, TROLL = FACTION_HORDE, BLOODELF = FACTION_HORDE, ANY = FACTION_OTHER },
    RaceSortOrder = { "HUMAN", "DWARF", "NIGHTELF", "GNOME", "DRAENEI", "ORC", "UNDEAD", "TAUREN", "TROLL", "BLOODELF" },
    RGBPercToHex = RGBPercToHex,
    TransmogrifiableSlots = TRANSMOGRIFIABLE_SLOTS,
    IsSameColor = IsSameColor,
    FormatToPattern = FormatToPattern,
    MenuItemBack = ITEM_BACK,
    GetItemID = GetItemID,
    GetUnitName = GetUnitName,

    -- Communications
    NewVersion = nil,
    SendAddonMessage = function(self, msg)
        SendAddonMessage(ADDON_PREFIX, msg, "WHISPER", UnitName("player"));
    end,
    SendAddonCommand = function(self, msg)
        SendAddonMessage(msg.." ", "", "WHISPER", UnitName("player"));
    end,
    Encode = function(self, str)
        return str:gsub(":", "\1"):gsub(",", "\2");
    end,
    Decode = function(self, str)
        return str:gsub("\1", ":"):gsub("\2", ",");
    end,

    -- Collections
    Collections =
    {
        OwnedItems = { },
        Skins = { },
        TakenQuests = { },
        RewardedQuests = { },
        Toys = { },
    },
    IsSkinSource     = function(self, item)  local db = self.Cache.All;                  if                   not db.Loaded then return nil; end return db[GetItemID(item)] and true or false; end,
    HasOwnedItem     = function(self, item)  local db = self.Collections.OwnedItems;     if not db.Enabled or not db.Loaded then return nil; end return db[GetItemID(item)] or false; end,
    HasSkin          = function(self, item)  local db = self.Collections.Skins;          if not db.Enabled or not db.Loaded then return nil; end return db[GetItemID(item)] or false; end,
    HasTakenQuest    = function(self, quest) local db = self.Collections.TakenQuests;    if not db.Enabled or not db.Loaded then return nil; end return db[quest] or false; end,
    HasRewardedQuest = function(self, quest) local db = self.Collections.RewardedQuests; if not db.Enabled or not db.Loaded then return nil; end return db[quest] or false; end,
    HasToy           = function(self, toy)   local db = self.Collections.Toys;           if not db.Enabled or not db.Loaded then return nil; end return db[toy]   or false; end,
    GetSlotByCategory = function(self, category)
            if category == LE_TRANSMOG_COLLECTION_TYPE_HEAD         then return "HEAD";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_SHOULDER     then return "SHOULDER";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_BACK         then return "BACK";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_CHEST        then return "CHEST";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_TABARD       then return "TABARD";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_SHIRT        then return "SHIRT";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_WRIST        then return "WRIST";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_HANDS        then return "HANDS";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_WAIST        then return "WAIST";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_LEGS         then return "LEGS";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_FEET         then return "FEET";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_WAND         then return "WAND";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_1H_AXE       then return "1H_AXE";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_1H_SWORD     then return "1H_SWORD";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_1H_MACE      then return "1H_MACE";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_DAGGER       then return "DAGGER";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_FIST         then return "FIST";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_SHIELD       then return "SHIELD";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_HOLDABLE     then return "HOLDABLE";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_2H_AXE       then return "2H_AXE";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_2H_SWORD     then return "2H_SWORD";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_2H_MACE      then return "2H_MACE";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_STAFF        then return "STAFF";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_POLEARM      then return "POLEARM";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_BOW          then return "BOW";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_GUN          then return "GUN";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_CROSSBOW     then return "CROSSBOW";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_THROWN       then return "THROWN";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_FISHING_POLE then return "FISHING_POLE";
        elseif category == LE_TRANSMOG_COLLECTION_TYPE_MISC         then return "MISC";
        elseif category == nil                                      then return "ENCHANT";
        end
        return nil;
    end,
    GetDBByCategory = function(self, category)
        return self.Cache.Slot[self:GetSlotByCategory(category)];
    end,
    GetSkinCategory = function(self, item)
        for slot, db in pairs(self.Cache.Slot) do
            if db.Loaded then
                for i, id in ipairs(db) do
                    if id == item then
                        for category = 1, NUM_LE_TRANSMOG_COLLECTION_TYPES do
                            if self:GetSlotByCategory(category) == slot then
                                return category;
                            end
                        end
                        return nil;
                    end
                end
            end
        end
        return nil;
    end,
    GetSkinInfo = function(self, id)
        return self.Cache.All[id];
    end,
    GetSkinIcon = function(self, id)
        local info = self:GetSkinInfo(id);
        if info and info.Icon then
            return [[Interface\Icons\]]..info.Icon;
        end
        return select(10, GetItemInfo(id));
    end,
    GetInstanceInfo = function(self, id)
        local data = self.Instances[id];
        if data then
            local type, tier, name, overrideDifficulty = strsplit(",", data, 4);
            return
            {
                Type = tonumber(type) or INSTANCE_TYPE_DUNGEON,
                Tier = L["InstanceTier."..((tonumber(tier) or 0) + 1)],
                Name = name,
                OverrideDifficulty = tonumber(overrideDifficulty),
            };
        end
    end,
    GetEncounterInfo = function(self, id, dynamicHeroic)
        local data = self.Encounters[id];
        if data then
            local map, difficulty, name = strsplit(",", data, 3);
            local instance = self:GetInstanceInfo(tonumber(map) or 0);
            return
            {
                Map = tonumber(map) or 0,
                Difficulty = L[format("Difficulty.%d.%d", instance and instance.Type or 1, instance.OverrideDifficulty or ((tonumber(difficulty) or 0) + 1 + (dynamicHeroic and 2 or 0)))];
                Name = name,
            };
        end
    end,
    GetEnchantFromScroll = function(self, scroll)
        return self.Cache.ScrollToEnchant[scroll];
    end,
    GetScrollFromEnchant = function(self, enchant)
        local scroll = self.Cache.EnchantToScroll[enchant];
        if type(scroll) == "table" then
            local availableVariant;
            for _, variant in ipairs(scroll) do
                if WCollections:HasAvailableSkin(variant) then
                    -- Prefer the first scroll variant the player owns
                    if WCollections:HasSkin(variant) then
                        return variant;
                    end
                    if not availableVariant then
                        availableVariant = variant;
                    end
                end
            end
            -- If the players doesn't own any scroll variant - fallback to the first scroll available from a subscription (if any), otherwise to the first variant
            return availableVariant or scroll[1];
        end
        return scroll;
    end,
    GetScrollVariantsFromEnchant = function(self, enchant)
        local scroll = self.Cache.EnchantToScroll[enchant];
        if type(scroll) == "table" then
            return scroll;
        end
    end,
    GetDressableFromRecipe = function(self, recipe)
        return self.Cache.RecipeToDressable[GetItemID(recipe)];
    end,
    CanHideSlot = function(self, slot)
        return self.HideVisualSlots[slot] or false;
    end,
    GetHiddenVisualItem = function(self)
        return ITEM_HIDDEN;
    end,
    GetHiddenVisualItemName = function(self, slot)
        if type(slot) == "string" then
            slot = GetInventorySlotInfo(slot);
        end
        return slot and TRANSMOGRIFIABLE_SLOTS[slot] and L["Tooltip.Transmog.Entry.Hidden."..TRANSMOGRIFIABLE_SLOTS[slot]] or L["Tooltip.Transmog.Entry.Hidden"];
    end,
    GetHiddenEnchant = function(self)
        return ENCHANT_HIDDEN, L["Tooltip.Transmog.Enchant.Hidden"];
    end,
    TransformEnchantName = function(self, name)
        name = name or "";
        name = name:gsub("%[", ""):gsub("%]", ""):gsub(".- %- ", ""):gsub(".-: ", "");
        return name:utf8sub(1, 1):utf8upper() .. name:utf8sub(2);
    end,
    CanTransmogrify = function(self, source)
        if source == ITEM_HIDDEN then return true; end
        if self:GetEnchantFromScroll(source) then return true; end
        return IsEquippableItem(source) and self:GetSkinInfo(source);
    end,
    GetCollectibleStatus = function(self, item)
        item = item and GetItemID(item);
        if item then
            if self:IsSkinSource(item) then
                local toy = self:GetToyIDByItem(item);
                if toy then
                    local skin = self:HasSkin(item);
                    local toy = self:HasToy(toy);
                    if skin ~= nil and toy ~= nil then
                        return skin and toy;
                    elseif skin ~= nil then
                        return skin;
                    elseif toy ~= nil then
                        return toy;
                    else
                        return;
                    end
                end

                return self:HasSkin(item);
            end

            local mount = self:GetMountIDByItem(item);
            if mount then
                return self:HasMount(mount);
            end

            local pet = self:GetPetIDByItem(item);
            if pet then
                return self:HasPet(pet);
            end

            local toy = self:GetToyIDByItem(item);
            if toy then
                return self:HasToy(toy);
            end
        end
    end,
    CreatureWeaponPreview = 0,
    searchUpdater = CreateFrame("Frame", ADDON_NAME.."SearchUpdater", UIParent),
    SearchMinChars = 3,
    SearchDelay = 0,
    SearchMaxSetsSlotMask = 5,
    LastSearch =
    {
        [LE_TRANSMOG_SEARCH_TYPE_ITEMS]       = { Token = 0, Params = { }, Duration = 0, NumResults = 0, Results = { } },
        [LE_TRANSMOG_SEARCH_TYPE_BASE_SETS]   = { Token = 0, Params = { }, Duration = 0, NumResults = 0, Results = { } },
        [LE_TRANSMOG_SEARCH_TYPE_USABLE_SETS] = { Token = 0, Params = { }, Duration = 0, NumResults = 0, Results = { } },
    },
    ItemNamesForSearch = { },
    SetNamesForSearch = { },
    UseServersideTextSearch = function(self)
        return not self.Config.Wardrobe.SearchClientside or not WCollections.appearanceCacheLoaded;
    end,
    PrepareSearchQuery = function(self, query)
        if not query or query == "" then
            return;
        elseif type(query) == "string" then
            query = query and query:utf8lower();
            query = query and { strsplit(" ", query) };
            for _, part in ipairs(query) do
                if part ~= "" then
                    return query;
                end
            end
        elseif type(query) == "table" then
            return query;
        end
    end,
    InternalSearch = function(self, normalizedText, query)
        if not query or query == "" then
            return true;
        elseif type(query) == "table" then
            for _, part in ipairs(query) do
                if part ~= "" and not normalizedText:find(part, 1, true) then
                    return false;
                end
            end
            return true;
        elseif type(query) == "string" then
            return normalizedText:find(query, 1, true);
        end
    end,
    TextMatchesSearch = function(self, text, query)
        if not query or query == "" then return true; end
        return text and self:InternalSearch(text:utf8lower(), query);
    end,
    ItemMatchesSearch = function(self, item, query)
        if not query or query == "" then return true; end
        local name = self.Config.Wardrobe.SearchCacheNames and self.ItemNamesForSearch[item];
        if not name then
            name = GetItemInfo(item);
            name = name and name:utf8lower();
            if name and self.Config.Wardrobe.SearchCacheNames then
                self.ItemNamesForSearch[item] = name;
            end
        end
        return name and self:InternalSearch(name, query);
    end,
    SetMatchesSearch = function(self, set, query)
        if not query or query == "" then return true; end
        local name = self.Config.Wardrobe.SearchCacheNames and self.SetNamesForSearch[set.setID];
        if not name then
            name = set.name or "";
            name = name.." "..(set.label or "");
            name = name.." "..(set.description or "");
            if self.Config.Wardrobe.SearchCacheNames and self.Config.Wardrobe.SearchSetsBySources then
                for _, source in ipairs(set.sources) do
                    local item = source.id;
                    local itemName;
                    do
                        local name = self.Config.Wardrobe.SearchCacheNames and self.ItemNamesForSearch[item];
                        if not name then
                            name = GetItemInfo(item);
                            name = name and name:utf8lower();
                            if name and self.Config.Wardrobe.SearchCacheNames then
                                self.ItemNamesForSearch[item] = name;
                            end
                        end
                        itemName = name;
                    end
                    name = name.." "..(itemName or "");
                end
            end
            name = name and name:utf8lower();
            if name and self.Config.Wardrobe.SearchCacheNames then
                self.SetNamesForSearch[set.setID] = name;
            end
        end
        return name and self:InternalSearch(name, query);
    end,
    IsSearchInProgress = function(self, type)
        local search = self.LastSearch[type];
        return search.NumResults == nil;
    end,
    IsSearchFinished = function(self, type, token)
        local search = self.LastSearch[type];
        return search.Token == token and search.NumResults == #search.Results;
    end,
    IsSearchMatchingParams = function(self, type, token, category, query, slot, id, enchant)
        query = self:UseServersideTextSearch() and query or "";
        local search = self.LastSearch[type];
        return search.Token == token and
               search.Params[1] == category and
               search.Params[2] == query and
               search.Params[3] == slot and
               search.Params[4] == id and
               search.Params[5] == enchant;
    end,
    Search = function(self, type, category, query, slot)
        query = self:UseServersideTextSearch() and query or "";
        local search = self.LastSearch[type];

        -- Deduplicate search queries
        if type == LE_TRANSMOG_SEARCH_TYPE_ITEMS and category == search.Params[1] and query == search.Params[2] and slot == search.Params[3] then
            if slot and slot ~= 0 then
                local _, id, enchant = strsplit(":", GetInventoryItemLink("player", slot) or "");
                if tonumber(id) == search.Params[4] and tonumber(enchant) == search.Params[5] then
                    return search.Token, search.Results.Loaded;
                end
            else
                return search.Token, search.Results.Loaded;
            end
        end
        if type == LE_TRANSMOG_SEARCH_TYPE_USABLE_SETS and query == search.Params[2] and slot == search.Params[3] and C_TransmogSets.MakeCacheKey() == search.Params[4] then
            return search.Token, search.Results.Loaded;
        end

        search.Token = search.Token + 1;
        search.Params = { category, query, slot, nil, nil };
        search.Duration = 0;
        search.NumResults = nil;
        table.wipe(search.Results);

        if not self.searchUpdater:GetScript("OnUpdate") then
            self.searchUpdater:SetScript("OnUpdate", WCollections.Callbacks.SearchUpdate);
        end

        if slot and slot ~= 0 and type == LE_TRANSMOG_SEARCH_TYPE_ITEMS then
            local _, id, enchant = strsplit(":", GetInventoryItemLink("player", slot) or "");
            search.Params[4] = tonumber(id);
            search.Params[5] = tonumber(enchant);
            self:SendAddonMessage(format("TRANSMOGRIFY:SEARCH:%d:%d:%s:%s:%d,%d,%d", type, search.Token, self:GetSlotByCategory(category), self:Encode(query or ""), slot, tonumber(id) or 0, tonumber(enchant) or 0));
        elseif type == LE_TRANSMOG_SEARCH_TYPE_USABLE_SETS then
            search.Params[4] = C_TransmogSets.MakeCacheKey();
            self:SendAddonMessage(format("TRANSMOGRIFY:SEARCH:%d:%d:%s:%s:%d", type, search.Token, self:GetSlotByCategory(category), self:Encode(query or ""), slot or 0));
        else
            self:SendAddonMessage(format("TRANSMOGRIFY:SEARCH:%d:%d:%s:%s", type, search.Token, self:GetSlotByCategory(category), self:Encode(query or "")));
        end
        return search.Token;
    end,
    EndSearch = function(self, type, token)
        local search = self.LastSearch[type];
        if search.Token == token and self:IsSearchInProgress(type) then
            self:SendAddonMessage(format("TRANSMOGRIFY:SEARCH:%d:%d:CANCEL", type, search.Token));
            search.Token = search.Token + 1;
        end
    end,
    WipeSearchResults = function(self, type)
        for t, search in pairs(self.LastSearch) do
            if not type or type == t then
                search.Token = search.Token + 1;
                table.wipe(search.Params);
                search.NumResults = 0;
                table.wipe(search.Results);
            end
        end
    end,
    GetFavoritesContainer = function(self)
        if self.Config.Wardrobe.PerCharacterFavorites then
            return self.Config.TransmogCollection.PerCharacter[self:GetCharacterConfigKey()].Favorites;
        else
            return self.Config.TransmogCollection.Favorites;
        end
    end,

    -- Sets
    ItemNameDescriptions = { },
    GetSetInfo = function(self, id, baseCollectedOnly)
        local set = self.Cache.Sets[id];
        if set then
            --set = deepcopy(set);
            local slots = { };
            for _, source in ipairs(set.sources) do
                source.collected = self:HasAvailableSkin(source.id);
                local info = self:GetSkinInfo(source.id);
                if info and info.InventoryType then
                    local slot = C_Transmog.GetSlotForInventoryType(info.InventoryType);
                    slots[slot] = slots[slot] or source.collected;
                end
            end
            set.collected = true;
            for slot, collected in pairs(slots) do
                if not collected then
                    set.collected = nil;
                    break;
                end
            end
            if not baseCollectedOnly and not set.collected and set.Variants and C_TransmogSets.GetBaseSetsFilter(LE_TRANSMOG_SET_FILTER_GROUP) then
                for _, variantID in ipairs(set.Variants) do
                    local variantSet = WCollections:GetSetInfo(variantID);
                    if variantSet and variantSet.collected then
                        set.collected = true;
                        break;
                    end
                end
            end
            set.favorite = C_TransmogSets.GetIsFavorite(set.setID);
            set.favoriteSetID = nil;
            if set.favorite then
                set.favoriteSetID = set.setID;
            elseif set.Variants then
                for _, variantID in ipairs(set.Variants) do
                    if C_TransmogSets.GetIsFavorite(variantID) then
                        set.favoriteSetID = variantID;
                        break;
                    end
                end
            end
            set.limitedTimeSet = nil;
        end
        return set;
    end,
    GetSetFavoritesContainer = function(self)
        if self.Config.Wardrobe.PerCharacterFavorites then
            return self.Config.TransmogCollection.PerCharacter[self:GetCharacterConfigKey()].SetFavorites;
        else
            return self.Config.TransmogCollection.SetFavorites;
        end
    end,

    -- Outfits
    MaxOutfits = 0,
    PrepaidOutfitsEnabled = false,
    Outfits = { },

    -- Claim Quests
    UnclaimedQuests = { },
    LastClaimQuestSkin = nil,
    LastClaimQuestData = nil,
    LastClaimSetSlotQuestSet = nil,
    LastClaimSetSlotQuestSlot = nil,
    LastClaimSetSlotQuestData = nil,
    IsUnclaimedQuest = function(self, quest)
        return self.UnclaimedQuests[quest];
    end,
    AreUnclaimedQuests = function(self, quests)
        if type(quests) == "string" then
            quests = { strsplit(",", quests) };
            for i, quest in ipairs(quests) do
                quests[i] = tonumber(quest);
            end
        end
        for _, quest in ipairs(quests) do
            if self:IsUnclaimedQuest(quest) then
                return true;
            end
        end
    end,
    CanClaimSkin = function(self, skin)
        local info = self:GetSkinInfo(skin);
        return info and info.SourceQuests and self:AreUnclaimedQuests(info.SourceQuests);
    end,
    ClaimQuest = function(self, quest, skin)
        self.LastClaimQuestSkin = nil;
        self.LastClaimQuestData = nil;
        self.LastClaimSetSlotQuestSet = nil;
        self.LastClaimSetSlotQuestSlot = nil;
        self.LastClaimSetSlotQuestData = nil;
        WCollections:SendAddonMessage(format("CLAIMQUEST:CLAIM:%d:%d", quest, skin));
    end,
    BeginClaimQuest = function(self, skin)
        if self.LastClaimQuestSkin == skin and self.LastClaimQuestData then
            self.Callbacks.ReceivedClaimQuests();
        elseif self.LastClaimQuestSkin ~= skin then
            self.LastClaimQuestSkin = skin;
            self.LastClaimQuestData = nil;
            self:SendAddonMessage(format("CLAIMQUEST:GETQUESTS:%d", skin));
        end
    end,
    CanClaimSetSlotSkin = function(self, set, slot)
        for _, source in ipairs(C_TransmogSets.GetSourcesForSlot(set, slot)) do
            local info = self:GetSkinInfo(source.sourceID);
            if info and info.SourceQuests and self:AreUnclaimedQuests(info.SourceQuests) then
                return true;
            end
        end
    end,
    BeginClaimSetSlotQuest = function(self, set, slot)
        if self.LastClaimSetSlotQuestSet == set and self.LastClaimSetSlotQuestSlot == slot and self.LastClaimSetSlotQuestData then
            self.Callbacks.ReceivedClaimSetSlotQuests();
        elseif self.LastClaimSetSlotQuestSet ~= set or self.LastClaimSetSlotQuestSlot ~= slot then
            self.LastClaimSetSlotQuestSet = set;
            self.LastClaimSetSlotQuestSlot = slot;
            self.LastClaimSetSlotQuestData = nil;
            self:SendAddonMessage(format("CLAIMQUEST:GETSLOTSETQUESTS:%d:%d", set, slot));
        end
    end,

    pendingTooltipInfo = { },
    SetPendingTooltipInfo = function(self, context, ...)
        self.pendingTooltipInfo[context] = { ... };
    end,
    ClearPendingTooltipInfo = function(self, context)
        self.pendingTooltipInfo[context] = nil;
    end,
    GetPendingTooltipInfo = function(self, context)
        local info = self.pendingTooltipInfo[context];
        if info then
            return unpack(info);
        end
    end,
    HasPendingTooltipInfo = function(self, context)
        return self.pendingTooltipInfo[context] ~= nil;
    end,

    -- Holidays
    ActiveHolidays = { },
    IsHolidayActive = function(self, holiday)
        return self.ActiveHolidays[holiday];
    end,

    -- Store
    StoreSkins = { },
    IsStoreItem = function(self, item, info)
        info = info or self:GetSkinInfo(item);
        if info then
            return info.SourceMask and bit.band(info.SourceMask, bit.lshift(1, TRANSMOG_SOURCE_STORE - 1)) ~= 0 or false;
        end
    end,
    IsStoreExclusiveItem = function(self, item, info)
        info = info or self:GetSkinInfo(item);
        if info then
            return info.SourceMask == bit.lshift(1, TRANSMOG_SOURCE_STORE - 1);
        end
    end,
    GetStoreSetSource = function(self, set, slot)
        for _, source in ipairs(C_TransmogSets.GetSourcesForSlot(set, slot)) do
            if self:IsStoreItem(source.sourceID) then
                return source.sourceID;
            end
        end
    end,

    -- Subscriptions
    Subscriptions = { },
    SubscriptionBySkin = { },
    GetSubscriptionForSkin = function(self, skin)
        local id = self.SubscriptionBySkin[skin];
        return id and self.Subscriptions[id];
    end,
    GetActiveSubscriptionForSkin = function(self, skin)
        local subscription = self:GetSubscriptionForSkin(skin);
        return subscription and subscription.Active and subscription or nil;
    end,
    GetSubscriptionForSetSource = function(self, set, slot)
        for _, source in ipairs(C_TransmogSets.GetSourcesForSlot(set, slot)) do
            local subscription = self:GetSubscriptionForSkin(source.sourceID);
            if subscription then
                return subscription;
            end
        end
    end,
    IsSubscriptionExclusiveItem = function(self, item, info)
        info = info or self:GetSkinInfo(item);
        if info then
            return info.SourceMask == bit.lshift(1, TRANSMOG_SOURCE_SUBSCRIPTION - 1);
        end
    end,
    HasAvailableSkin = function(self, skin)
        return self:HasSkin(skin) or self:GetActiveSubscriptionForSkin(skin) ~= nil;
    end,

    IsStoreAndSubscriptionExclusiveItem = function(self, item, info)
        info = info or self:GetSkinInfo(item);
        if info then
            return info.SourceMask == bit.bor(bit.lshift(1, TRANSMOG_SOURCE_STORE - 1), bit.lshift(1, TRANSMOG_SOURCE_SUBSCRIPTION - 1));
        end
    end,
    IsStoreOrSubscriptionExclusiveItem = function(self, item, info)
        info = info or self:GetSkinInfo(item);
        if info and info.SourceMask then
            return bit.band(info.SourceMask, bit.bnot(bit.bor(bit.lshift(1, TRANSMOG_SOURCE_STORE - 1), bit.lshift(1, TRANSMOG_SOURCE_SUBSCRIPTION - 1)))) == 0;
        end
    end,
    FormatRemainingTime = function(self, duration, short)
        if duration >= 24 * 60 * 60 then
            return format(short and SPELL_TIME_REMAINING_DAYS:match("%%.+;") or SPELL_TIME_REMAINING_DAYS, math.floor(duration / (24 * 60 * 60)));
        elseif duration >= 60 * 60 then
            return format(short and SPELL_TIME_REMAINING_HOURS:match("%%.+;") or SPELL_TIME_REMAINING_HOURS, math.floor(duration / (60 * 60)));
        elseif duration >= 60 then
            return format(short and SPELL_TIME_REMAINING_MIN:match("%%.+;") or SPELL_TIME_REMAINING_MIN, math.floor(duration / 60));
        elseif duration >= 0 then
            return format(short and SPELL_TIME_REMAINING_SEC:match("%%.+;") or SPELL_TIME_REMAINING_SEC, math.floor(duration));
        end
    end,

    -- Mounts
    MountNameXMountID = nil,
    ActiveMountPremiumEndTime = 0,
    ActiveMountPremiumScaling = nil,
    ActiveMountPremiumInfo = nil,
    ActiveMountSubscriptionEndTime = 0,
    ActiveMountSubscriptionScaling = nil,
    ActiveMountSubscriptionInfo = nil,
    ActiveMountSubscriptionMounts = { },
    IsActiveMountPremium = function(self)
        return self.ActiveMountPremiumEndTime and self.ActiveMountPremiumEndTime > 0 and time() < self.ActiveMountPremiumEndTime;
    end,
    GetActiveMountPremiumEndTime = function(self)
        return self:IsActiveMountPremium() and self.ActiveMountPremiumEndTime or nil;
    end,
    IsActiveMountSubscription = function(self)
        return self.ActiveMountSubscriptionEndTime and self.ActiveMountSubscriptionEndTime > 0 and time() < self.ActiveMountSubscriptionEndTime;
    end,
    GetActiveMountSubscriptionEndTime = function(self)
        return self:IsActiveMountSubscription() and self.ActiveMountSubscriptionEndTime or nil;
    end,
    IsActiveMountSubscriptionMount = function(self, mountID)
        return self:IsActiveMountSubscription() and self.ActiveMountSubscriptionMounts[mountID] and true or false;
    end,
    IsMountScalingAllowed = function(self)
        return self.ActiveMountPremiumScaling and self:IsActiveMountPremium() or
               self.ActiveMountSubscriptionScaling and self:IsActiveMountSubscription();
    end,
    GetMountScalingEndTime = function(self)
        return math.max(self.ActiveMountPremiumScaling and self:GetActiveMountPremiumEndTime() or 0,
                        self.ActiveMountSubscriptionScaling and self:GetActiveMountSubscriptionEndTime() or 0);
    end,
    HasMount = function(self, mountID)
        return self:HasAvailableMount(mountID) and not self:IsActiveMountSubscriptionMount(mountID);
    end,
    HasAvailableMount = function(self, mountID)
        return select(11, C_MountJournal.GetMountInfoByID(mountID));
    end,
    GetMountIDByItem = function(self, item)
        return self.ItemIDXMountID[item];
    end,
    GetMountFavoritesContainer = function(self)
        return self.Config.MountJournal.PerCharacter[self:GetCharacterConfigKey()].Favorites;
    end,
    GetMountNeedFanfareContainer = function(self)
        return self.Config.MountJournal.PerCharacter[self:GetCharacterConfigKey()].NeedFanfare;
    end,

    -- Pets
    ActivePetSubscriptionEndTime = 0,
    ActivePetSubscriptionInfo = nil,
    ActivePetSubscriptionPets = { },
    IsActivePetSubscription = function(self)
        return self.ActivePetSubscriptionEndTime and self.ActivePetSubscriptionEndTime > 0 and time() < self.ActivePetSubscriptionEndTime;
    end,
    GetActivePetSubscriptionEndTime = function(self)
        return self:IsActivePetSubscription() and self.ActivePetSubscriptionEndTime or nil;
    end,
    IsActivePetSubscriptionPet = function(self, petID)
        return self:IsActivePetSubscription() and self.ActivePetSubscriptionPets[petID] and true or false;
    end,
    HasPet = function(self, petID)
        return self:HasAvailablePet(petID) and not self:IsActivePetSubscriptionPet(petID);
    end,
    HasAvailablePet = function(self, petID)
        return C_PetJournal.PetIsUsable(petID);
    end,
    GetPetIDByItem = function(self, item)
        return self.ItemIDXPetID[item];
    end,
    GetPetFavoritesContainer = function(self)
        return self.Config.PetJournal.PerCharacter[self:GetCharacterConfigKey()].Favorites;
    end,
    GetPetNeedFanfareContainer = function(self)
        return self.Config.PetJournal.PerCharacter[self:GetCharacterConfigKey()].NeedFanfare;
    end,

    -- Toys
    ItemIDXToyID = { },
    ItemNameXToyItemID = { },
    ActiveToys = { },
    ActiveToySubscriptionEndTime = 0,
    ActiveToySubscriptionInfo = nil,
    ActiveToySubscriptionToys = { },
    IsActiveToySubscription = function(self)
        return self.ActiveToySubscriptionEndTime and self.ActiveToySubscriptionEndTime > 0 and time() < self.ActiveToySubscriptionEndTime;
    end,
    GetActiveToySubscriptionEndTime = function(self)
        return self:IsActiveToySubscription() and self.ActiveToySubscriptionEndTime or nil;
    end,
    IsActiveToySubscriptionToy = function(self, toyID)
        return self:IsActiveToySubscription() and self.ActiveToySubscriptionToys[toyID] and true or false;
    end,
    GetToyInfo = function(self, toyID)
        local toy = self.Cache.Toys[toyID];
        if toy then
            return unpack(toy);
        end
    end,
    GetToyIDByItem = function(self, item)
        return self.ItemIDXToyID[item];
    end,
    GetToyInfoByItem = function(self, item)
        local toyID = self:GetToyIDByItem(item);
        if toyID then
            return self:GetToyInfo(toyID);
        end
    end,
    GetToyItemByName = function(self, name)
        return self.ItemNameXToyItemID[name];
    end,
    GetToyFavoritesContainer = function(self)
        return self.Config.ToyBox.PerCharacter[self:GetCharacterConfigKey()].Favorites;
    end,
    GetToyNeedFanfareContainer = function(self)
        return self.Config.PetJournal.PerCharacter[self:GetCharacterConfigKey()].NeedFanfare;
    end,
    HasAvailableToy = function(self, toyID)
        return self:HasToy(toyID) or self:IsActiveToySubscriptionToy(toyID);
    end,

    -- Cooldowns
    ItemCooldowns = { },
    GetItemCooldownData = function(self, item)
        local cooldown = self.ItemCooldowns[item];
        if cooldown then
            local start, duration, enable = unpack(cooldown);
            if GetTime() < start + duration then
                return start, duration, enable;
            else
                self.ItemCooldowns[item] = nil;
            end
        end
    end,
    GetItemCooldown = function(self, item)
        local start, duration, enable = GetItemCooldown(item);
        local cstart, cduration, cenable = self:GetItemCooldownData(item);
        start = math.max(start, cstart or 0);
        duration = math.max(duration, cduration or 0);
        enable = math.max(enable, cenable and 1 or 0);
        return start, duration, enable;
    end,
    FormatItemCooldown = function(self, remaining)
        local text = "";
        local numbers = 0;
        if remaining >= 86400000 then
            text = text .. format(DAYS_ABBR, math.floor(remaining / 86400000));
            remaining = remaining % 86400000;
            numbers = numbers + 1;
        end
        if remaining >= 3600000 then
            text = text .. (text ~= "" and TIME_UNIT_DELIMITER or "") .. format(HOURS_ABBR, math.floor(remaining / 3600000));
            remaining = remaining % 3600000;
            numbers = numbers + 1;
        end
        if numbers < 2 then
            if remaining >= 60000 then
                text = text .. (text ~= "" and TIME_UNIT_DELIMITER or "") .. format(MINUTES_ABBR, math.floor(remaining / 60000));
                remaining = remaining % 60000;
                numbers = numbers + 1;
            end
            if numbers < 2 and remaining > 0 then
                text = text .. (text ~= "" and TIME_UNIT_DELIMITER or "") .. format(SECONDS_ABBR, math.floor(remaining / 1000));
            end
        end
        if text ~= "" then
            return text;
        end
    end,

    -- Callbacks
    Callbacks =
    {
        AddOwnedItem = function()
            if WCollections.Config.IconOverlays.Unowned.Enable then
                WCollections.IconOverlays:Update();
            end
        end,
        RemoveOwnedItem = function()
            if WCollections.Config.IconOverlays.Unowned.Enable then
                WCollections.IconOverlays:Update();
            end
        end,
        SkinListLoaded = function()
            if not WCollections.Cache.All.Loaded then
                return;
            end
            local function SearchForMissingCache(db)
                if WCollections.itemCacheRequestNeeded or not db.Loaded then
                    return;
                end
                for item in pairs(db) do
                    if type(item) == "number" and not GetItemInfo(item) then
                        WCollections.itemCacheRequestNeeded = true;
                        C_Timer.After(1, function()
                            if not WCollections.itemCacheRequested then
                                WCollections.itemCacheRequested = true;
                                WCollections:SendAddonMessage("PRELOADCACHE:ITEMS:0");
                                StaticPopup_Show("WCOLLECTIONS_PRELOADING_ITEM_CACHE");
                            end
                        end);
                        return;
                    end
                end
                WCollections.appearanceCacheLoaded = true;
            end
            --SearchForMissingCache(WCollections.Collections.Skins);
            SearchForMissingCache(WCollections.Cache.All);
            -- Count store-exclusive items to exclude them from total category count
            WCollections.Cache.All.StoreExclusiveCount = nil;
            WCollections.Cache.All.SubscriptionExclusiveCount = nil;
            WCollections.Cache.All.StoreAndSubscriptionExclusiveCount = nil;
            for item, info in pairs(WCollections.Cache.All) do
                if type(item) == "number" then
                    -- Dynamic store skins
                    if WCollections.StoreSkins.Loaded then
                        if WCollections.StoreSkins[item] then
                            info.SourceMask = bit.bor(info.SourceMask or 0, bit.lshift(1, TRANSMOG_SOURCE_STORE - 1));
                        elseif info.SourceMask then
                            info.SourceMask = bit.band(info.SourceMask, bit.bnot(bit.lshift(1, TRANSMOG_SOURCE_STORE - 1)));
                        end
                    end
                    -- Dynamic subscription skins
                    if WCollections:GetSubscriptionForSkin(item) then
                        info.SourceMask = bit.bor(info.SourceMask or 0, bit.lshift(1, TRANSMOG_SOURCE_SUBSCRIPTION - 1));
                    elseif info.SourceMask then
                        info.SourceMask = bit.band(info.SourceMask, bit.bnot(bit.lshift(1, TRANSMOG_SOURCE_SUBSCRIPTION - 1)));
                    end
                    -- Count exclusives so we can subtract them from total count
                    if WCollections:IsStoreExclusiveItem(item, info) then
                        WCollections.Cache.All.StoreExclusiveCount = (WCollections.Cache.All.StoreExclusiveCount or 0) + 1;
                    end
                    if WCollections:IsSubscriptionExclusiveItem(item, info) then
                        WCollections.Cache.All.SubscriptionExclusiveCount = (WCollections.Cache.All.SubscriptionExclusiveCount or 0) + 1;
                    end
                    if WCollections:IsStoreAndSubscriptionExclusiveItem(item, info) then
                        WCollections.Cache.All.StoreAndSubscriptionExclusiveCount = (WCollections.Cache.All.StoreAndSubscriptionExclusiveCount or 0) + 1;
                    end
                end
            end
            for slot, db in pairs(WCollections.Cache.Slot) do
                db.StoreExclusiveCount = nil;
                db.SubscriptionExclusiveCount = nil;
                db.StoreAndSubscriptionExclusiveCount = nil;
                for _, item in ipairs(db) do
                    local info = WCollections:GetSkinInfo(item);
                    if WCollections:IsStoreExclusiveItem(item, info) then
                        db.StoreExclusiveCount = (db.StoreExclusiveCount or 0) + 1;
                    end
                    if WCollections:IsSubscriptionExclusiveItem(item, info) then
                        db.SubscriptionExclusiveCount = (db.SubscriptionExclusiveCount or 0) + 1;
                    end
                    if WCollections:IsStoreAndSubscriptionExclusiveItem(item, info) then
                        db.StoreAndSubscriptionExclusiveCount = (db.StoreAndSubscriptionExclusiveCount or 0) + 1;
                    end
                end
            end
            -- Refresh UI
            WCollections:WipeSearchResults();
            C_TransmogCollection.WipeAppearanceCache();
            C_TransmogSets.ReportSetSourceCollectedChanged();
            C_Transmog.ValidateAllPending(true);
            WCollections:RaiseEvent("TRANSMOG_COLLECTION_UPDATED");
            WCollections.IconOverlays:Update();
            -- Check Mounts and Pets
            WCollections.Callbacks.MountListLoaded();
            -- Check Toys
            WCollections.Callbacks.ToyListLoaded();
        end,
        AddSkin = function(item)
            WCollections:WipeSearchResults();
            C_TransmogCollection.WipeAppearanceCache();
            C_TransmogCollection.AddNewAppearance(item);
            local info = WCollections:GetSkinInfo(item);
            if info and info.Sets then
                C_TransmogSets.ReportSetSourceCollectedChanged();
            end
            C_Transmog.ValidateAllPending(true);
            WCollections.Alerts.AddSkin(item);
            WCollections:RaiseEvent("TRANSMOG_COLLECTION_UPDATED");
            WCollections.IconOverlays:Update();
        end,
        RemoveSkin = function(item)
            WCollections:WipeSearchResults();
            C_TransmogCollection.WipeAppearanceCache();
            local info = WCollections:GetSkinInfo(item);
            if info and info.Sets then
                C_TransmogSets.ReportSetSourceCollectedChanged();
            end
            C_Transmog.ValidateAllPending(true);
            WCollections.Alerts.AddSkin(item, true);
            WCollections:RaiseEvent("TRANSMOG_COLLECTION_UPDATED");
            WCollections.IconOverlays:Update();
        end,
        ClearSkins = function()
            WCollections:WipeSearchResults();
            C_TransmogCollection.WipeAppearanceCache();
            C_TransmogSets.ReportSetSourceCollectedChanged();
            C_Transmog.ValidateAllPending(true);
            WCollections:RaiseEvent("TRANSMOG_COLLECTION_UPDATED");
            WCollections.IconOverlays:Update();
        end,
        ReceivedClaimQuests = function()
            if WCollections.LastClaimQuestSkin and WCollections.LastClaimQuestData then
                for _, model in ipairs(WardrobeCollectionFrame.ItemsCollectionFrame.Models) do
                    if model:IsShown() and model.visualInfo and model.visualInfo.visualID == WCollections.LastClaimQuestSkin and model.ClaimQuest:IsShown() then
                        if #WCollections.LastClaimQuestData == 1 then
                            WCollectionsClaimQuestPopup.skin = WCollections.LastClaimQuestSkin;
                            WCollectionsClaimQuestPopup.quest = deepcopy(WCollections.LastClaimQuestData[1]);
                            StaticPopupSpecial_Show(WCollectionsClaimQuestPopup);
                            return;
                        end
                        local menu = { };
                        table.insert(menu, { text = L["ClaimQuest.Menu.Title"], notCheckable = true, isTitle = true });
                        for _, quest in ipairs(WCollections.LastClaimQuestData) do
                            table.insert(menu,
                            {
                                text = format(L["ClaimQuest.Menu.Claim"], quest.Name),
                                notCheckable = true,
                                arg1 = WCollections.LastClaimQuestSkin,
                                arg2 = quest,
                                func = function(self, skin, quest)
                                    WCollectionsClaimQuestPopup.skin = skin;
                                    WCollectionsClaimQuestPopup.quest = deepcopy(quest);
                                    StaticPopupSpecial_Show(WCollectionsClaimQuestPopup);
                                end,
                            });
                        end
                        table.insert(menu, { text = CANCEL, notCheckable = true });
                        EasyMenu(menu, WardrobeCollectionFrame.ClaimQuestMenu, model.ClaimQuest, 0, 0, "MENU");
                        return;
                    end
                end
            end
        end,
        ReceivedClaimSetSlotQuests = function()
            if WCollections.LastClaimSetSlotQuestSet == WardrobeCollectionFrame.SetsCollectionFrame:GetSelectedSetID() and WCollections.LastClaimSetSlotQuestSlot and WCollections.LastClaimSetSlotQuestData then
                for itemFrame in WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.itemFramesPool:EnumerateActive() do
                    if itemFrame:IsShown() and C_Transmog.GetSlotForInventoryType(itemFrame.invType) == WCollections.LastClaimSetSlotQuestSlot and itemFrame.ClaimQuest:IsShown() then
                        if #WCollections.LastClaimSetSlotQuestData == 1 then
                            WCollectionsClaimQuestPopup.skin = WCollections.LastClaimSetSlotQuestData[1].ItemID;
                            WCollectionsClaimQuestPopup.quest = deepcopy(WCollections.LastClaimSetSlotQuestData[1]);
                            StaticPopupSpecial_Show(WCollectionsClaimQuestPopup);
                            return;
                        end
                        local menu = { };
                        table.insert(menu, { text = L["ClaimQuest.Menu.Title"], notCheckable = true, isTitle = true });
                        for _, quest in ipairs(WCollections.LastClaimSetSlotQuestData) do
                            table.insert(menu,
                            {
                                text = format(L["ClaimQuest.Menu.ClaimSetSlot"], quest.ItemColor, quest.ItemName, quest.Name),
                                notCheckable = true,
                                arg1 = quest.ItemID,
                                arg2 = quest,
                                func = function(self, skin, quest)
                                    WCollectionsClaimQuestPopup.skin = skin;
                                    WCollectionsClaimQuestPopup.quest = deepcopy(quest);
                                    StaticPopupSpecial_Show(WCollectionsClaimQuestPopup);
                                end,
                            });
                        end
                        table.insert(menu, { text = CANCEL, notCheckable = true });
                        EasyMenu(menu, WardrobeCollectionFrame.ClaimQuestMenu, itemFrame.ClaimQuest, 0, 0, "MENU");
                        return;
                    end
                end
            end
        end,
        RemoveUnclaimedQuest = function(quest)
            WCollections:RaiseEvent("TRANSMOG_COLLECTION_UPDATED");
        end,
        SearchUpdate = function(self, elapsed)
            for type, search in pairs(WCollections.LastSearch) do
                if WCollections:IsSearchInProgress(type) then
                    search.Duration = search.Duration + elapsed * 1000;
                end
            end
        end,
        SearchFinished = function(type)
            local search = WCollections.LastSearch[type];
            local category, query, slot, entry, enchant = unpack(search.Params);
            C_TransmogCollection.SearchFinished(type, search.Token, category, query, deepcopy(search.Results));
        end,
        OnChatMessageEventFilter = function(chatFrame, event, text, ...)
            if WCollections.Config.ChatLinks.OutfitIcon.Enable then
                local replaced;
                text, replaced = text:gsub("(|cffff80ff|Hitem:0:outfit:.-|h)%[([^]]-)%](|h|r)", function(pre, linktext, post)
                    local icon, text = TRANSMOG_OUTFIT_HYPERLINK_TEXT:match("^(|T.-|t)(.-)$");
                    icon = icon and icon:gsub("13:13:%-1:1", format("%1$d:%1$d:-1:%2$d", WCollections.Config.ChatLinks.OutfitIcon.Size or 13, WCollections.Config.ChatLinks.OutfitIcon.Offset or 1));
                    return format("|cffff80ff[%s|r%s%s]%s", icon or "", pre or "", linktext or text or "", post or "");
                end);
                if replaced and replaced > 0 then
                    return false, text, ...;
                end
            end
            return false;
        end,

        MountListLoaded = function()
            local function SearchForMissingCache(db)
                if not WCollections.cacheTestTooltip:GetParent() then
                    WCollections.cacheTestTooltip:AddFontStrings(WCollections.cacheTestTooltip:CreateFontString(), WCollections.cacheTestTooltip:CreateFontString());
                end
                for id, info in pairs(db) do
                    local creatureID = info[1];
                    if creatureID then
                        WCollections.cacheTestTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
                        WCollections.cacheTestTooltip:SetHyperlink(("unit:0xF5300%05X000000"):format(creatureID));
                        local shown = WCollections.cacheTestTooltip:IsShown();
                        local line = _G[WCollections.cacheTestTooltip:GetName().."TextLeft1"];
                        local text = line and line:GetText() and line:GetText() ~= "" and line:GetText();
                        WCollections.cacheTestTooltip:Hide();
                        if shown then
                            if text then
                                db[id][4] = text; -- Fill mount/pet name from creature cache
                            end
                        else
                            if not WCollections.mountCacheRequestNeeded then
                                WCollections.mountCacheRequestNeeded = true;
                                C_Timer.After(1.1, function()
                                    if not WCollections.mountCacheRequested then
                                        WCollections.mountCacheRequested = true;
                                        WCollections:SendAddonMessage("PRELOADCACHE:MOUNTS:0");
                                        StaticPopup_Show("WCOLLECTIONS_PRELOADING_MOUNT_CACHE");
                                    end
                                end);
                            end
                        end
                    end
                end
            end

            SearchForMissingCache(WCollections.Mounts);
            SearchForMissingCache(WCollections.Pets);
            WCollections.Callbacks.MountListUpdated();
            WCollections.Callbacks.PetListUpdated();
        end,
        MountListUpdated = function()
            WCollections:RaiseEvent("MOUNT_JOURNAL_SEARCH_UPDATED");
            WCollections.IconOverlays:Update();
        end,
        PetListUpdated = function()
            WCollections:RaiseEvent("PET_JOURNAL_SEARCH_UPDATED");
            WCollections.IconOverlays:Update();
        end,
        ToyListLoaded = function()
            local function SearchForMissingCache(db)
                if WCollections.itemCacheRequestNeeded or not db.Loaded then
                    return;
                end
                for id, info in pairs(db) do
                    if type(id) == "number" and not GetItemInfo(info[1]) then
                        WCollections.itemCacheRequestNeeded = true;
                        C_Timer.After(1, function()
                            if not WCollections.itemCacheRequested then
                                WCollections.itemCacheRequested = true;
                                WCollections:SendAddonMessage("PRELOADCACHE:ITEMS:0");
                                StaticPopup_Show("WCOLLECTIONS_PRELOADING_ITEM_CACHE");
                            end
                        end);
                        break;
                    end
                end
            end

            SearchForMissingCache(WCollections.Cache.Toys);

            table.wipe(WCollections.ItemIDXToyID);
            table.wipe(WCollections.ItemNameXToyItemID);
            for id, info in pairs(WCollections.Cache.Toys) do
                if type(id) == "number" and info[1] then
                    WCollections.ItemIDXToyID[info[1]] = id;
                    local name = GetItemInfo(info[1]);
                    if name then
                        WCollections.ItemNameXToyItemID[name] = info[1];
                    end
                end
            end

            WCollections.Callbacks.ToyListUpdated();
        end,
        ToyListUpdated = function()
            WCollections.Callbacks.ToyStatusUpdated();
            WCollections.IconOverlays:Update();
        end,
        ToyStatusUpdated = function(actionButtonUpdateType)
            WCollections:RaiseEvent("TOYS_UPDATED");
            WCollectionsUpdateActionBars(actionButtonUpdateType);
        end,
        AddToy = function(toyID)
            WCollections.Alerts.AddToy(toyID);
            local itemID = WCollections:GetToyInfo(toyID);
            if itemID then
                WCollections:RaiseEvent("TOYS_UPDATED", itemID, true);
            else
                WCollections:RaiseEvent("TOYS_UPDATED");
            end
            WCollectionsUpdateActionBars();
            WCollections.IconOverlays:Update();
        end,
        RemoveToy = function(toyID)
            WCollections.Alerts.AddToy(toyID, true);
            WCollections.Callbacks.ToyListUpdated();
        end,
        ClearToys = function()
            WCollections.Callbacks.ToyListUpdated();
        end,
    },

    -- Alerts
    Alerts =
    {
        AddSkin = function(item, revoke)
            local config = WCollections.Config.Alerts.AddSkin;
            if not config.Enable then return; end
            local text = revoke and ERR_REVOKE_TRANSMOG_S or ERR_LEARN_TRANSMOG_S;
            local color = config.Color;
            local colorHex = "|cFF"..RGBPercToHex(color.r, color.g, color.b);
            if config.FullRowColor then
                text = colorHex..text.."|r";
            else
                text = "|cFFFFFFFF"..format(text, "|r"..colorHex.."%s|r|cFFFFFFFF").."|r";
            end
            local linkType = WCollections:GetEnchantFromScroll(item) and "transmogillusion" or "transmogappearance";
            local name = GetItemInfo(item);
            if name then
                SendSystemMessage(format(text, format("|H%s:%d|h[%s]|h", linkType, item, name or "")));
            else
                WCollections:QueryItem(item);
                local handler = { };
                handler.func = function(arg)
                    local text, item = unpack(arg);
                    local name = GetItemInfo(item);
                    if name then
                        SendSystemMessage(format(text, format("|H%s:%d|h[%s]|h", linkType, item, name or "")));
                    else
                        WCollections.AceAddon:ScheduleTimer(handler.func, 1, arg);
                    end
                end;
                handler.func({ text, item });
            end
        end,
        AddToy = function(toyID, revoke)
            if revoke then return; end
            local config = WCollections.Config.Alerts.AddToy;
            if not config.Enable then return; end
            local text = ERR_LEARN_TOY_S;
            local color = config.Color;
            local colorHex = "|cFF"..RGBPercToHex(color.r, color.g, color.b);
            text = colorHex..format(text, "|r%s"..colorHex).."|r";
            local itemID = WCollections:GetToyInfo(toyID);
            if not itemID then return; end
            local _, link = GetItemInfo(itemID);
            if link then
                SendSystemMessage(format(text, link));
            else
                WCollections:QueryItem(itemID);
                local handler = { };
                handler.func = function(arg)
                    local text, item = unpack(arg);
                    local name = GetItemInfo(item);
                    if name then
                        SendSystemMessage(format(text, link));
                    else
                        WCollections.AceAddon:ScheduleTimer(handler.func, 1, arg);
                    end
                end;
                handler.func({ text, itemID });
            end
        end,
    },

    -- Bindings
    itemUnderCursor = { ID = nil, Bag = nil, Slot = nil },
    UnlockSkinHintCommand = "",
    UnlockSkinUnderCursor = function(self)
        if self.Allowed and self.itemUnderCursor.ID and self.itemUnderCursor.Bag then
            local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(self.itemUnderCursor.ID);
            texture = texture or WCollections:GetSkinIcon(self.itemUnderCursor.ID);
            StaticPopupDialogs["WCOLLECTIONS_UNLOCK_SKIN"].itemLink = "|T"..texture..":30:30:0:-8|t "..link;
            if self.itemUnderCursor.Slot then
                StaticPopupDialogs["WCOLLECTIONS_UNLOCK_SKIN"].commandData = self.itemUnderCursor.ID.." "..self.itemUnderCursor.Bag.." "..(self.itemUnderCursor.Slot - 1);
            else
                StaticPopupDialogs["WCOLLECTIONS_UNLOCK_SKIN"].commandData = self.itemUnderCursor.ID.." "..(self.itemUnderCursor.Bag - 1);
            end
            StaticPopup_Show("WCOLLECTIONS_UNLOCK_SKIN");
        end
    end,
    MenuWowcircle    = function(self) self:SendAddonCommand(".menu"); end,
    MenuTransmog     = function(self) self:SendAddonCommand(".menu transmog"); end,
    MenuTransmogSets = function(self) self:SendAddonCommand(".menu transmog set"); end,
    MenuCollections  = function(self) self:SendAddonCommand(".menu transmog collection"); end,
    MenuDaily        = function(self) self:SendAddonCommand(".menu activity"); end,

    -- Item Transmog
    ItemTransmogCache = { },
    GetItemTransmogCache = function(self, unit, bag, slot)
        unit = GetUnitName(unit or "player") or unit;
        self.ItemTransmogCache[unit] = self.ItemTransmogCache[unit] or { };
        self.ItemTransmogCache[unit][bag] = self.ItemTransmogCache[unit][bag] or { };
        if slot ~= nil then
            self.ItemTransmogCache[unit][bag][slot] = self.ItemTransmogCache[unit][bag][slot] or { };
            return self.ItemTransmogCache[unit][bag][slot];
        else
            return self.ItemTransmogCache[unit][bag];
        end
    end,
    PeekItemTransmogCacheID = function(self, unit, bag, slot)
        unit = GetUnitName(unit or "player") or unit;
        if slot ~= nil then
            return self.ItemTransmogCache[unit] and self.ItemTransmogCache[unit][bag] and self.ItemTransmogCache[unit][bag][slot] and self.ItemTransmogCache[unit][bag][slot].ID;
        else
            return self.ItemTransmogCache[unit] and self.ItemTransmogCache[unit][bag] and self.ItemTransmogCache[unit][bag].ID;
        end
    end,
    RemoveItemTransmogCache = function(self, unit, bag, slot)
        unit = GetUnitName(unit or "player") or unit;
        if not UnitIsUnit(unit, "player") then return; end
        if slot ~= nil then
            if self.ItemTransmogCache[unit] and self.ItemTransmogCache[unit][bag] then
                self.ItemTransmogCache[unit][bag][slot] = nil;
            end
        else
            if self.ItemTransmogCache[unit] then
                local cache = self.ItemTransmogCache[unit][bag];
                if cache then
                    cache.ID = nil;
                    cache.FakeEntry = nil;
                    cache.FakeEntryDeactivated = nil;
                    cache.FakeEnchant = nil;
                    cache.FakeEnchantName = nil;
                    cache.Flags = nil;
                    cache.Loaded = nil;
                    cache.Loading = nil;
                    if not next(cache) then
                        self.ItemTransmogCache[unit][bag] = nil;
                    end
                end
            end
        end
    end,
    ClearItemTransmogCache = function(self, unit)
        if UnitIsUnit(unit, "player") then return; end
        unit = GetUnitName(unit or "player") or unit;
        self.ItemTransmogCache[unit] = { };
    end,
    ClearItemTransmogCacheWithFakeEntry = function(self, unit, fakeEntry)
        if not UnitIsUnit(unit, "player") then return; end
        unit = GetUnitName(unit or "player") or unit;
        local toRemove = { };
        if self.ItemTransmogCache[unit] then
            for bag, slots in pairs(self.ItemTransmogCache[unit]) do
                if type(bag) == "number" then
                    if slots.FakeEntry == fakeEntry then
                        table.insert(toRemove, { unit, bag });
                    end
                    for slot, data in pairs(slots) do
                        if type(slot) == "number" then
                            if data.FakeEntry == fakeEntry then
                                table.insert(toRemove, { unit, bag, slot });
                            end
                        end
                    end
                end
            end
        end
        for _, params in ipairs(toRemove) do
            self:RemoveItemTransmogCache(unpack(params));
        end
    end,
    GetItemTransmog = function(self, unit, bag, slot)
        local id, request;
        if bag == -1 and slot then
            bag = BANK_CONTAINER_INVENTORY_OFFSET + slot;
            slot = nil;
        end
        if slot ~= nil then
            id = GetContainerItemID(bag, slot);
            request = bag.." "..(slot - 1);
        else
            id = oGetInventoryItemID(unit, bag);
            request = tostring(bag - 1);
        end
        if not id then return; end

        local cache = self:GetItemTransmogCache(unit, bag, slot);
        if cache.Loaded and (cache.ID == id or cache.FakeEntry == id and GetUnitName(unit) ~= GetUnitName("player")) then -- Upon inspect, GetInventoryItemID returns visible item IDs, i.e. fake transmogrified entries
            return cache.FakeEntry, cache.FakeEnchantName, cache.FakeEnchant, cache.Flags, cache.FakeEntryDeactivated;
        elseif (not cache.Loading or cache.ID ~= id) and GetUnitName(unit) == GetUnitName("player") and self.setEmptyItemTransmogCache then
            cache.ID = id;
            cache.Loaded = false;
            cache.Loading = true;
            self:SendAddonMessage("GETTRANSMOG:"..request);
        end
    end,
    EmptyItemTransmogCache = function(self, bag, slot)
        local id = slot and GetContainerItemID(bag, slot) or oGetInventoryItemID("player", bag);
        if id then
            local cache = self:GetItemTransmogCache("player", bag, slot);
            cache.ID = id;
            cache.Loaded = true;
        end
    end,
    setEmptyItemTransmogCache = false,
    SetEmptyItemTransmogCache = function(self)
        if self.setEmptyItemTransmogCache then return; end
        self.setEmptyItemTransmogCache = true;
        for slot=1,150 do
            if not (slot >= BANK_CONTAINER_INVENTORY_OFFSET + 1 and slot <= BANK_CONTAINER_INVENTORY_OFFSET + NUM_BANKGENERIC_SLOTS) then
                self:EmptyItemTransmogCache(slot);
            end
        end
        for bag=0,4 do
            for slot=1,36 do
                self:EmptyItemTransmogCache(bag, slot);
            end
        end
    end,
    setEmptyBankTransmogCache = false,
    SetEmptyBankTransmogCache = function(self)
        if self.setEmptyBankTransmogCache then return; end
        self.setEmptyBankTransmogCache = true;
        for slot = BANK_CONTAINER_INVENTORY_OFFSET + 1, BANK_CONTAINER_INVENTORY_OFFSET + NUM_BANKGENERIC_SLOTS do
            self:EmptyItemTransmogCache(slot);
        end
        for bag=5,11 do
            for slot=1,36 do
                self:EmptyItemTransmogCache(bag, slot);
            end
        end
    end,
    UpdateItemTransmogCache = function(self, bagID)
        local fromSlot = 1;
        local toSlot = 150;
        if bagID == -1 then
            fromSlot = BANK_CONTAINER_INVENTORY_OFFSET + 1;
            toSlot = BANK_CONTAINER_INVENTORY_OFFSET + NUM_BANKGENERIC_SLOTS;
        elseif bagID == 0 then
            fromSlot = CONTAINER_BAG_OFFSET + 1;
            toSlot = CONTAINER_BAG_OFFSET + 16;
        elseif bagID then
            fromSlot = 0;
            toSlot = 0;
        end
        for slot = fromSlot, toSlot do
            local id = oGetInventoryItemID("player", slot);
            if not id then
                self:RemoveItemTransmogCache("player", slot);
            elseif self:PeekItemTransmogCacheID("player", slot) ~= id then
                self:RemoveItemTransmogCache("player", slot);
            end
        end
        for bag = bagID or 0, bagID or 11 do
            if bag >= 5 and not self.setEmptyBankTransmogCache then break; end
            for slot=1,36 do
                local id = GetContainerItemID(bag, slot);
                if not id then
                    self:RemoveItemTransmogCache("player", bag, slot);
                elseif self:PeekItemTransmogCacheID("player", bag, slot) ~= id then
                    self:RemoveItemTransmogCache("player", bag, slot);
                end
            end
        end
    end,
    lastInspectTarget = "",
    inspectFrameHooked = false,
    missingInspectItems = nil,
    dataRequestTooltip = CreateFrame("GameTooltip", ADDON_NAME.."DataRequestTooltip", UIParent),
    cacheTestTooltip = CreateFrame("GameTooltip", ADDON_NAME.."CacheTestTooltip", UIParent, "GameTooltipTemplate"),
    textScanTooltip = CreateFrame("GameTooltip", ADDON_NAME.."TextScanTooltip", UIParent, "GameTooltipTemplate"),
    ForEachTooltipText = function(self, tooltip, func)
        local function ForEach(func, ...)
            for i = 1, select("#", ...) do
                local region = select(i, ...)
                if region and region:GetObjectType() == "FontString" and region:IsShown() then
                    if func(region) then
                        return true;
                    end
                end
            end
        end
        return ForEach(func, tooltip:GetRegions());
    end,
    awaitingItemCache = nil,
    QueryItem = function(self, item)
        if GetItemInfo(item) then return; end
        if not self.awaitingItemCache then
            self.awaitingItemCache = { };
            self.AceAddon:ScheduleRepeatingTimer(function()
                local found = nil;
                for item in pairs(WCollections.awaitingItemCache) do
                    if GetItemInfo(item) then
                        found = found or { };
                        table.insert(found, item);
                    end
                end
                if found then
                    for _, item in ipairs(found) do
                        WCollections.awaitingItemCache[item] = nil;
                        WCollections:RaiseEvent("GET_ITEM_INFO_RECEIVED", item, true);
                    end
                    WCollections:RaiseEvent("TRANSMOG_COLLECTION_ITEM_UPDATE");
                end
            end, 0.25);
        end
        if self.awaitingItemCache[item] then return; end
        self.awaitingItemCache[item] = true;
        self.dataRequestTooltip:SetHyperlink("item:" .. item);
        self.dataRequestTooltip:Hide();
    end,

    -- Config
    GetCharacterConfigKey = function(self)
        return format("%s - %s", UnitName("player"), GetRealmName());
    end,
    GetCVar = function(self, cvar)
        if not self.Config then
            if cvar == "transmogCurrentSpecOnly" then
                return false;
            else
                error("GetCVar OnLoad");
            end
        end
        return self.Config.CVar[self:GetCharacterConfigKey()][cvar];
    end,
    SetCVar = function(self, cvar, value)
        if self:GetCVar(cvar) == value then
            return false;
        end
        self.Config.CVar[self:GetCharacterConfigKey()][cvar] = value;
        return true;
    end,
    GetCVarBool = function(self, cvar)
        return not not self:GetCVar(cvar);
    end,
    SetCVarBool = function(self, cvar, value)
        self:SetCVar(cvar, not not value);
    end,
    GetCVarBitfield = function(self, cvar, index)
        return bit.band(self.Config.CVar[self:GetCharacterConfigKey()][cvar], bit.lshift(1, index - 1)) ~= 0;
    end,
    SetCVarBitfield = function(self, cvar, index, set)
        if self:GetCVarBitfield(cvar, index) == (set and true or false) then
            return false;
        end
        local container = self.Config.CVar[self:GetCharacterConfigKey()];
        if set then
            container[cvar] = bit.bor(container[cvar], bit.lshift(1, index - 1));
        else
            container[cvar] = bit.band(container[cvar], bit.bnot(bit.lshift(1, index - 1)));
        end
        return true;
    end,
    GetCameraOptionName = function(self, option)
        return L["Cameras."..option];
    end,

    -- Events
    registeredEvents =
    {
        TRANSMOGRIFY_UPDATE = { }, -- slotID, transmogType
        TRANSMOGRIFY_ITEM_UPDATE = { }, -- slotID, transmogType
        TRANSMOGRIFY_SUCCESS = { }, -- slotID, transmogType
        TRANSMOG_COLLECTION_UPDATED = { },
        TRANSMOG_COLLECTION_ITEM_UPDATE = { },
        TRANSMOG_COLLECTION_CAMERA_UPDATE = { },
        TRANSMOG_SEARCH_UPDATED = { },
        SEARCH_DB_LOADED = { },
        PLAYER_SPECIALIZATION_CHANGED = { },
        TRANSMOG_SOURCE_COLLECTABILITY_UPDATE = { }, -- sourceID, canCollect
        TRANSMOG_OUTFITS_CHANGED = { },
        TRANSMOG_SETS_UPDATE_FAVORITE = { },
        GET_ITEM_INFO_RECEIVED = { },
        MOUNT_JOURNAL_SEARCH_UPDATED = { },
        MOUNT_JOURNAL_USABILITY_CHANGED = { },
        PET_JOURNAL_SEARCH_UPDATED = { },
        TOYS_UPDATED = { }, -- itemID, new

        -- Custom
        WCOLLECTIONS_PRELOAD_ITEM_CACHE_PROGRESS = { },
        WCOLLECTIONS_PRELOAD_MOUNT_CACHE_PROGRESS = { },
        PLAYER_EQUIPMENT_CHANGED = { },
    },
    RegisterEvent = function(self, frame, event)
        self.registeredEvents[event][frame] = true;
    end,
    UnregisterEvent = function(self, frame, event)
        self.registeredEvents[event][frame] = nil;
    end,
    RaiseEvent = function(self, event, ...)
        for frame, _ in pairs(self.registeredEvents[event]) do
            local script = frame:GetScript("OnEvent");
            if script then
                script(frame, event, ...);
            end
        end
    end,

    -- Taint
    pendingUIDropDownMenu_Initialize = { },
    UIDropDownMenu_Initialize = function(self, frame, initFunction, displayMode, level, menuList)
        if self.pendingUIDropDownMenu_Initialize then
            table.insert(self.pendingUIDropDownMenu_Initialize, function()
                UIDropDownMenu_Initialize(frame, initFunction, displayMode, level, menuList);
            end);
        else
            UIDropDownMenu_Initialize(frame, initFunction, displayMode, level, menuList);
        end
    end,
    InitDropDownMenus = function(self)
        for _, func in ipairs(self.pendingUIDropDownMenu_Initialize) do
            func();
        end
        self.pendingUIDropDownMenu_Initialize = nil;
    end,

    -- Hooks
    MergeHook = function(self, name, func)
        local old = _G[name];
        _G[name] = old and function() old(); func(); end or func;
    end,
    DelveInto = function(self, var, ...)
        local num = select("#", ...);
        for i = 1, num do
            if not var then break; end
            var = var[select(i, ...)];
        end
        return var;
    end,
};

-- --------------------------------------
-- Helper functions to manage collections
-- --------------------------------------
local function LoadList(container, callback)
    return function(ids)
        for id in ids:gmatch("(%d+):") do
            container[tonumber(id)] = true;
        end
        if ends_with(ids, "END") then
            container.Loaded = true;
            if callback then
                callback(container);
            end
        end
    end;
end
local function LoadIndexedList(container, callback)
    return function(ids)
        for id in ids:gmatch("(%d+):") do
            table.insert(container, tonumber(id))
        end
        if ends_with(ids, "END") then
            container.Loaded = true;
            if callback then
                callback(container);
            end
        end
    end;
end
local function LoadIndexedStringList(container, callback)
    return function(ids)
        for data in ids:gmatch("(.-):") do
            table.insert(container, data)
        end
        if ends_with(ids, "END") then
            container.Loaded = true;
            if callback then
                callback(container);
            end
        end
    end;
end
local function LoadAllList(container, allContainer, callback, dataTransform)
    return function(ids)
        for id, data in ids:gmatch("(%d+)(.-):") do
            id = tonumber(id);
            table.insert(container, id)
            if data and dataTransform then
                allContainer[id] = dataTransform(data);
            else
                allContainer[id] = data or true;
            end
        end
        if ends_with(ids, "END") then
            container.Loaded = true;
            allContainer.Loaded = true;
            for _, db in pairs(WCollections.Cache.Slot) do
                if type(db) == "table" and not db.Loaded then
                    allContainer.Loaded = false;
                    break;
                end
            end
            if callback then
                callback(container, allContainer);
            end
        end
    end;
end
local function AddList(container, callback)
    return function(id)
        container[tonumber(id)] = true;
        if callback then
            callback(tonumber(id));
        end
    end;
end
local function RemoveList(container, callback)
    return function(id)
        container[tonumber(id)] = nil;
        if callback then
            callback(tonumber(id));
        end
    end;
end
local function ReloadList(request, container, callback)
    return function(ids)
        for id in pairs(container) do
            if type(id) == "number" then
                container[id] = nil;
            end
        end
        container.Loaded = false;
        if callback then
            callback(container);
        end
        WCollections:SendAddonMessage(request);
    end;
end
local function ReloadAllList(request, container, allContainer, callback)
    return function(ids)
        for index, id in pairs(container) do
            if type(index) == "number" then
                allContainer[id] = nil;
                container[index] = nil;
            end
        end
        container.Loaded = false;
        allContainer.Loaded = false;
        if callback then
            callback(container, allContainer);
        end
        WCollections:SendAddonMessage(request);
    end;
end

local cosmeticBags = { };
local function LoadItemTransmog(unit, slotStrings)
    local isPlayer = UnitIsUnit(unit, "player");
    local validateTransmog = false;
    table.wipe(cosmeticBags);
    for slotString in slotStrings:gmatch("(.-):") do
        local slots, itemString = strsplit("=", slotString, 2);
        local bag, slot = strsplit(",", slots, 2);
        local id, fakeEntry, fakeEnchantName, fakeEnchant, flags = strsplit(",", itemString);
        bag = tonumber(bag);
        if slot ~= nil then
            slot = tonumber(slot) + 1;
        else
            bag = bag + 1;
            if isPlayer then
                validateTransmog = true;
            end
        end
        local cache = WCollections:GetItemTransmogCache(unit, bag, slot);
        cache.ID = tonumber(id);
        cache.FakeEntry = tonumber(fakeEntry);
        cache.FakeEntryDeactivated = cache.FakeEntry and cache.FakeEntry < 0;
        cache.FakeEntry = cache.FakeEntry and math.abs(cache.FakeEntry);
        cache.FakeEnchant = tonumber(fakeEnchant);
        cache.FakeEnchantName = fakeEnchantName;
        cache.Flags = flags and flags ~= "" and WCollections:Decode(flags);
        cache.Loaded = true;
        cache.Loading = false;
        -- Collect bags containing cosmetic items for optimized WCollections.IconOverlays:Update
        if isPlayer and cache.Flags and cache.Flags:find(ITEM_COSMETIC, 1, true) then
            if not WCollections.hasCosmeticItems then
                WCollections.hasCosmeticItems = true;
            end
            if not slot and (bag >= BANK_CONTAINER_INVENTORY_OFFSET + 1 and bag <= BANK_CONTAINER_INVENTORY_OFFSET + NUM_BANKGENERIC_SLOTS) then
                bag = -1;
            end
            cosmeticBags[bag] = true;
        end
    end
    if validateTransmog then
        if WardrobeFrame_IsAtTransmogrifier() then
            C_Transmog.ValidateAllPending(true);
        end
    end
    if isPlayer then
        for bag in pairs(cosmeticBags) do
            WCollections.IconOverlays:Update(bag);
        end
    end
end

-- --------------------
-- Addon event handling
-- --------------------
function IsInspectFrameShown()
    return InspectFrame and InspectFrame:IsShown()
        or Examiner and Examiner:IsShown();
end
function addon:InitVersion()
    if self.versionRequestAttempts > 0 then
        self.versionRequestAttempts = self.versionRequestAttempts - 1;
        WCollections:SendAddonMessage("VERSION:"..ADDON_VERSION);
    else
        self:CancelTimer(self.versionTimer);
        self.versionTimer = nil;
    end
end
function addon:UpdateInspect(unit)
    if not WCollections.Config.RestoreItemIcons.Inspect then return; end

    -- GearScoreList requests inspects by hovering over players, which can screw up with us,
    -- since client can only hold one inspected unit in memory and we're expecting to update inspected slots later down the line
    if WCollections.lastInspectRequestUnit ~= unit then
        WCollections.lastInspectTarget = "";
        NotifyInspect("target");
        return;
    end

    WCollections.missingInspectItems = { };
    if WCollections.lastInspectTarget ~= "" and unit == WCollections.lastInspectTarget and IsInspectFrameShown() then
        if InspectPaperDollItemSlotButton_Update then
            for _, slot in pairs(TRANSMOGRIFIABLE_SLOTS) do
                InspectPaperDollItemSlotButton_Update(_G["Inspect"..slot]);
            end
        end
        local elvui = LibStub("AceAddon-3.0"):GetAddon("ElvUI", true);
        if elvui then
            local module = elvui:GetModule("Enhanced_PaperDoll", true) or elvui:GetModule("Enhanced_EquipmentInfo", true);
            if module then
                module:UpdatePaperDoll("target");
            end
        end
        if oGlow and oGlow.updateInspect then
            oGlow.updateInspect();
        end
        if Examiner then
            local module = Examiner:GetModuleFromToken("ItemSlots")
            if module then
                module:UpdateItemSlots();
            end
        end
        if KPack and WCollections:DelveInto(KPack, "options", "args", "Modules", "args", "list", "args", "Borders Colors") then
            local script = InspectFrame:GetScript("OnShow");
            if script then
                script(InspectFrame);
            end
        end
    end
    if WCollections.missingInspectItems and #WCollections.missingInspectItems > 0 then
        for i, id in pairs(WCollections.missingInspectItems) do
            WCollections:QueryItem(id);
        end
        self:ScheduleTimer("UpdateInspect", 1, unit);
    end
    WCollections.missingInspectItems = nil;
end
function addon:PLAYER_LOGIN(event)
    self.versionRequestAttempts = 3;
    self:InitVersion();
    if self.versionTimer then
        self:CancelTimer(self.versionTimer);
    end
    self.versionTimer = self:ScheduleRepeatingTimer("InitVersion", 10);
end
function addon:PLAYER_LOGOUT(event)
    local config = WCollections:DelveInto(WCollections, "Config", "Misc", "CompressCache");
    if (config == nil or config == true) and WCollections.Cache then
        if WCollections.Cache.Slot then
            for slot, db in pairs(WCollections.Cache.Slot) do
                local new = { Packed = table.concat(db, ",") };
                for k, v in pairs(db) do
                    if type(k) ~= "number" and k ~= "Packed" then
                        new[k] = v;
                    end
                end
                WCollections.Cache.Slot[slot] = new;
            end
        end
        if WCollections.Cache.All then
            for id, info in pairs(WCollections.Cache.All) do
                if type(id) == "number" and type(info) == "table" then
                    WCollections.Cache.All[id] = WCollections.PackSkin(info);
                end
            end
        end
        if WCollections.Cache.Sets then
            for id, info in pairs(WCollections.Cache.Sets) do
                if type(id) == "number" and type(info) == "table" then
                    WCollections.Cache.Sets[id] = WCollections.PackSet(info);
                end
            end
        end
    end
end
function addon:CHAT_MSG_ADDON(event, prefix, message, distribution, sender)
    if prefix ~= ADDON_PREFIX or sender ~= "" then return; end

    match(message, "VERSIONCHECK", function(version)
        self:PLAYER_LOGIN(event);
    end);
    match(message, "SERVERVERSION:", function(version)
        self.versionRequestAttempts = 0;
        local version, result, url = strsplit(":", version, 3);
        if version == "DISABLED" then
            result = "DISABLED";
        end
        if result ~= "OK" then
            WCollections.NewVersion = { Version = version, URL = url };
            if result == "DISABLED" then
                WCollections.NewVersion.Disabled = true;
            elseif result ~= "COMPATIBLE" then
                WCollections.NewVersion.Outdated = true;
            end
            if WCollections.Config.NewVersion.SkipVersionPopup ~= version and (result ~= "DISABLED" or not WCollections.Config.NewVersion.HideRetiredPopup) then
                WCollections.Config.NewVersion.SkipVersionPopup = nil;
                StaticPopup_Show("WCOLLECTIONS_NEW_VERSION");
            end
        end
        if not WCollections.Allowed and (result == "OK" or result == "COMPATIBLE") then
            WCollections.Allowed = true;
            WCollections:SendAddonMessage("GETTRANSMOG:ALL");
        end
    end);
    match(message, "CACHEVERSION:", function(version)
        if WCollections.Cache.Version == tonumber(version) and WCollections.Cache.AddonVersion == ADDON_VERSION then
            WCollections.Callbacks.SkinListLoaded();
        else
            WCollections:ClearCache();
            WCollections.Cache.Version = tonumber(version);
            WCollections.Cache.AddonVersion = ADDON_VERSION;
            for slot, db in pairs(WCollections.Cache.Slot) do
                WCollections:SendAddonMessage("LIST:ALL:"..slot);
            end
            WCollections:SendAddonMessage("LIST:DATA:SCROLLTOENCHANT");
            WCollections:SendAddonMessage("LIST:DATA:RECIPETODRESSABLE");
            WCollections:SendAddonMessage("LIST:DATA:SETS");
            WCollections:SendAddonMessage("LIST:DATA:CAMERAS");
            WCollections:SendAddonMessage("LIST:DATA:TOYS");
        end
    end);
    match(message, "UNLOCKSKINHINTCOMMAND:", function(command)
        WCollections.UnlockSkinHintCommand = command;
    end);
    match(message, "TOKEN:", function(token)
        token = tonumber(token);
        if token ~= 0 then
            WCollections.Token = token;
            WCollections:QueryItem(token);
        else
            WCollections.Token = nil;
        end
    end);
    match(message, "HIDEVISUALSLOTS:", function(slots)
        WCollections.HideVisualSlots = { };
        for _, slot in ipairs({ strsplit(":", slots) }) do
            if slot ~= "" then
                WCollections.HideVisualSlots[slot] = true;
            end
        end
    end);
    match(message, "WEAPONCOMPATIBILITY:", function(data)
        WCollections.WeaponCompatibility = { };
        for i, mask in ipairs({ strsplit(":", data) }) do
            if mask ~= "" and i ~= 10 and i ~= 12 and i ~= 13 and i ~= 18 then -- Skip obsolete, exotic and exotic2, spear
                mask = tonumber(mask) or bit.lshift(1, i - 1);
                local a = bit.rshift(bit.band(mask, 0x0001FF), 0);
                local b = bit.rshift(bit.band(mask, 0x000400), 1); -- Skip obsolete
                local c = bit.rshift(bit.band(mask, 0x01E000), 3); -- Skip exotic, exotic 2
                local d = bit.rshift(bit.band(mask, 0x1C0000), 4); -- Skip spear
                mask = bit.bor(bit.bor(bit.bor(a, b), c), d);
                table.insert(WCollections.WeaponCompatibility, mask);
            end
        end
    end);
    match(message, "SEARCHPARAMS:", function(data)
        local minChars, delay, maxSetsSlotMask = strsplit(":", data);
        WCollections.SearchMinChars = tonumber(minChars) or 3;
        WCollections.SearchDelay = math.max(1, tonumber(delay) or 0);
        WCollections.SearchMaxSetsSlotMask = tonumber(maxSetsSlotMask) or 5;
    end);
    match(message, "OUTFITPARAMS:", function(data)
        local maxOutfits, outfitCostHint, outfitEditCostHint, prepaidEnabled = strsplit(":", data);
        WCollections.MaxOutfits = tonumber(maxOutfits) or 0;
        WCollections.OutfitCostHint = WCollections:Decode(outfitCostHint);
        WCollections.OutfitEditCostHint = WCollections:Decode(outfitEditCostHint);
        WCollections.PrepaidOutfitsEnabled = tonumber(prepaidEnabled) == 1;
    end);
    match(message, "STOREPARAMS:", function(data)
        local urlSkinFormat = strsplit(":", data);
        WCollections.StoreURLSkinFormat = WCollections:Decode(urlSkinFormat);
    end);
    match(message, "PREVIEWCREATURE:", function(data)
        local type, id = strsplit(":", data);
        if type == "WEAPON" then
            WCollections.CreatureWeaponPreview = tonumber(id);
            C_Timer.NewTicker(5, function() WCollectionsModelPreloader:Refresh(); end);
        end

        if not WCollections.cacheTestTooltip:GetParent() then
            WCollections.cacheTestTooltip:AddFontStrings(WCollections.cacheTestTooltip:CreateFontString(), WCollections.cacheTestTooltip:CreateFontString());
        end
        WCollections.cacheTestTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
        WCollections.cacheTestTooltip:SetHyperlink(("unit:0xF5300%05X000000"):format(tonumber(id)))
        if not WCollections.cacheTestTooltip:IsShown() then
            WCollections:SendAddonMessage("PREVIEWCREATURE:" .. type);
        end
        WCollections.cacheTestTooltip:Hide();
    end);
    match(message, "ITEMNAMEDESCRIPTIONS:", LoadIndexedStringList(WCollections.ItemNameDescriptions, function(container)
        for index, description in ipairs(container) do
            container[description] = index;
        end
    end));
    match(message, "FEATURE:", function(data)
        match(data, "Wintergrasp", function()
            if WCollections.Config.Misc.WintergraspButton then
                WCollections:SetWintergraspButton(true);
            end
        end);
        match(data, "Timewalking", function(data)
            for _, str in ipairs({ strsplit(":", data) }) do
                if str == "RESET" then
                    WCollections:ResetTimewalking();
                    LFDQueueFrameTypeDropDown_SetUp(LFDQueueFrameTypeDropDown);
                elseif str == "END" then
                    LFDQueueFrameTypeDropDown_SetUp(LFDQueueFrameTypeDropDown);
                elseif str ~= "" then
                    local id, dataString = strsplit("=", str);
                    local name, typeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, texture, difficulty, maxPlayers, description, isHoliday, title = strsplit(",", dataString);
                    WCollections:AddTimewalking(tonumber(id),
                    {
                        WCollections:Decode(name),
                        tonumber(typeID) or 1,
                        tonumber(minLevel) or 0,
                        tonumber(maxLevel) or 80,
                        tonumber(recLevel) or 0,
                        tonumber(minRecLevel) or 0,
                        tonumber(maxRecLevel) or 0,
                        tonumber(expansionLevel) or 0,
                        tonumber(groupID) or 1,
                        WCollections:Decode(texture),
                        tonumber(difficulty) or 0,
                        tonumber(maxPlayers) or 5,
                        WCollections:Decode(description),
                        tonumber(isHoliday) == 1,
                        WCollections:Decode(title),
                    });
                end
            end
        end);
        match(data, "CTA:", function(data)
            match(data, "SHORTAGEREWARDS:", function(data)
                for _, str in ipairs({ strsplit(":", data) }) do
                    if str == "RESET" then
                        WCollections:ResetCTAShortageReward();
                        if LFDQueueFrame.type ~= "specific" then
                            LFDQueueFrameRandom_UpdateFrame();
                        end
                    elseif str == "END" then
                        if LFDQueueFrame.type ~= "specific" then
                            LFDQueueFrameRandom_UpdateFrame();
                        end
                    elseif str ~= "" then
                        local item, dataString = strsplit("=", str);
                        local shortageIndex, roles, isVisualOnly = strsplit(",", dataString);
                        WCollections:AddCTAShortageReward(tonumber(item),
                        {
                            ShortageIndex = (tonumber(shortageIndex) or 0) + 1,
                            Roles = tonumber(roles) or 0,
                            IsVisualOnly = tonumber(isVisualOnly) == 1,
                        });
                    end
                end
            end);
        end);
        match(data, "CFBG:", function(data)
            local faction = strsplit(":", data);
            WCollections.CFBG.Faction = faction ~= "" and faction or nil;
            MiniMapBattlefieldFrame_isArena();
            PlayerFrame_UpdatePvPStatus();
        end);
    end);
    match(message, "HOLIDAY:", function(data)
        match(data, "START:", function(holiday)
            WCollections.ActiveHolidays[tonumber(holiday)] = true;
            WCollections:WipeSearchResults();
            C_TransmogCollection.WipeAppearanceCache();
            C_Transmog.ValidateAllPending(true);
            WCollections:RaiseEvent("TRANSMOG_COLLECTION_UPDATED");
            WCollections.Callbacks.ToyStatusUpdated(ACTIONBUTTON_UPDATE_USABLE);
        end);
        match(data, "STOP:", function(holiday)
            WCollections.ActiveHolidays[tonumber(holiday)] = nil;
            WCollections:WipeSearchResults();
            C_TransmogCollection.WipeAppearanceCache();
            C_Transmog.ValidateAllPending(true);
            WCollections:RaiseEvent("TRANSMOG_COLLECTION_UPDATED");
            WCollections.Callbacks.ToyStatusUpdated(ACTIONBUTTON_UPDATE_USABLE);
        end);
    end);
    match(message, "SUBSCRIPTION:", function(data)
        match(data, "ADD:", function(data)
            local id, endTime, url, name, description = strsplit(":", data);
            id = tonumber(id);
            if id then
                local subscription =
                {
                    EndTime = tonumber(endTime),
                    Active = time() < tonumber(endTime),
                    URL = WCollections:Decode(url),
                    Name = WCollections:Decode(name),
                    Description = WCollections:Decode(description),
                    Skins = { },
                };

                WCollections.Subscriptions[id] = subscription;

                if subscription.Active and not WCollections.updateSubscriptionsScheduled then
                    WCollections.updateSubscriptionsScheduled = true;
                    C_Timer.NewTicker(1, function()
                        local now = nil;
                        local deactivated = false;
                        for id, subscription in pairs(WCollections.Subscriptions) do
                            if subscription.Active then
                                if not now then
                                    now = time();
                                end
                                if now >= subscription.EndTime then
                                    subscription.Active = false;
                                    deactivated = true;
                                    for _, skin in ipairs(subscription.Skins) do
                                        WCollections:ClearItemTransmogCacheWithFakeEntry("player", skin);
                                    end
                                end
                            end
                        end
                        if deactivated then
                            WCollections:WipeSearchResults();
                            C_TransmogCollection.WipeAppearanceCache();
                            C_TransmogSets.ReportSetSourceCollectedChanged();
                            C_Transmog.ValidateAllPending(true);
                            WCollections:RaiseEvent("TRANSMOG_COLLECTION_UPDATED");
                        end
                    end);
                end
            end
        end);
        for id, subscription in pairs(WCollections.Subscriptions) do
            local closureID = id;
            match(data, "SKINS:"..id..":", LoadIndexedList(subscription.Skins, function(skins)
                for _, skin in ipairs(skins) do
                    WCollections.SubscriptionBySkin[skin] = closureID;
                end
                WCollections.Callbacks.SkinListLoaded();
            end));
        end
        match(data, "REMOVE:", function(data)
            local id = strsplit(":", data);
            id = tonumber(id);
            if id then
                local subscription = WCollections.Subscriptions[id];
                if subscription then
                    subscription.EndTime = time();
                    subscription.Active = false;
                    WCollections:WipeSearchResults();
                    C_TransmogCollection.WipeAppearanceCache();
                    C_TransmogSets.ReportSetSourceCollectedChanged();
                    C_Transmog.ValidateAllPending(true);
                    WCollections:RaiseEvent("TRANSMOG_COLLECTION_UPDATED");
                end
            end
        end);
        match(data, "RELOAD", function()
            table.wipe(WCollections.Subscriptions);
            table.wipe(WCollections.SubscriptionBySkin);
        end);
    end);
    match(message, "DEVELOPER", function()
        WCollections.Developer = true;
    end);
    match(message, "SETUPSTARTED", function()
        table.wipe(WCollections.ItemNameDescriptions);
    end);
    match(message, "SETUPFINISHED", function()
        C_Timer.After(5, function()
            local function StartUp()
                if not WCollections.Config.Wardrobe.CameraOptionSetup and WCollections:PlayerHasDifferentCameraOptions() then
                    C_Timer.After(1, function()
                        StaticPopupSpecial_Show(WCollectionsCameraPreviewPopup);
                    end);
                end
            end
            if StaticPopup_Visible("WCOLLECTIONS_PRELOADING_ITEM_CACHE") then
                local oldOnHide = StaticPopupDialogs["WCOLLECTIONS_PRELOADING_ITEM_CACHE"].OnHide;
                StaticPopupDialogs["WCOLLECTIONS_PRELOADING_ITEM_CACHE"].OnHide = function(self)
                    oldOnHide(self);
                    StartUp();
                end;
            else
                StartUp();
            end
        end);
    end);
    match(message, "COLLECTIONS:", function(collections)
        for k, collection in pairs({ strsplit(":", collections) }) do
            if collection ~= "END" then
                WCollections:SendAddonMessage("LIST:"..collection);
            end
                if collection == "OWNEDITEM"        then WCollections.Collections.OwnedItems.Enabled = true;
            elseif collection == "SKIN"             then WCollections.Collections.Skins.Enabled = true;
            elseif collection == "TAKENQUEST"       then WCollections.Collections.TakenQuests.Enabled = true;
            elseif collection == "REWARDEDQUEST"    then WCollections.Collections.RewardedQuests.Enabled = true;
            elseif collection == "TOY"              then WCollections.Collections.Toys.Enabled = true;
            end
        end
    end);
    match(message, "LIST:", function(list)
        match(list, "OWNEDITEM:",           LoadList(WCollections.Collections.OwnedItems));
        match(list, "SKIN:",                LoadList(WCollections.Collections.Skins, WCollections.Callbacks.SkinListLoaded));
        match(list, "TAKENQUEST:",          LoadList(WCollections.Collections.TakenQuests));
        match(list, "REWARDEDQUEST:",       LoadList(WCollections.Collections.RewardedQuests));
        match(list, "TOY:",                 LoadList(WCollections.Collections.Toys, WCollections.Callbacks.ToyListLoaded));
        for slot, db in pairs(WCollections.Cache.Slot) do
            match(list, "ALL:"..slot..":",  LoadAllList(db, WCollections.Cache.All, WCollections.Callbacks.SkinListLoaded, WCollections.UnpackSkin));
        end
        match(list, "UNCLAIMEDQUEST:",     LoadList(WCollections.UnclaimedQuests));
        match(list, "HOLIDAY:",            LoadList(WCollections.ActiveHolidays));
        match(list, "STORESKIN:",          LoadList(WCollections.StoreSkins, WCollections.Callbacks.SkinListLoaded));
        match(list, "DATA:", function(data)
            match(data, "SCROLLTOENCHANT:", function(scrollToEnchants)
                for _, scrollToEnchant in ipairs({ strsplit(":", scrollToEnchants) }) do
                    if scrollToEnchant ~= "" and scrollToEnchant ~= "END" then
                        local scroll, enchant = strsplit("=", scrollToEnchant);
                        scroll = tonumber(scroll);
                        enchant = tonumber(enchant);
                        -- Scroll to enchant is 1:1
                        WCollections.Cache.ScrollToEnchant[scroll] = enchant;
                        -- Enchant to scroll is 1:many
                        local stored = WCollections.Cache.EnchantToScroll[enchant];
                        if not stored then
                            stored = scroll;
                        elseif type(stored) == "number" then
                            stored = { stored, scroll };
                        elseif type(stored) == "table" then
                            table.insert(stored, scroll);
                        end
                        WCollections.Cache.EnchantToScroll[enchant] = stored;
                    end
                end
            end);
            match(data, "RECIPETODRESSABLE:", function(recipeToDressables)
                for _, recipeToDressable in ipairs({ strsplit(":", recipeToDressables) }) do
                    if recipeToDressable ~= "" and recipeToDressable ~= "END" then
                        local recipe, dressable = strsplit("=", recipeToDressable);
                        WCollections.Cache.RecipeToDressable[tonumber(recipe)] = tonumber(dressable);
                    end
                end
            end);
            match(data, "SETS:", function(sets)
                for _, set in ipairs({ strsplit(":", sets) }) do
                    if set == "END" then
                        WCollections:PostprocessSetsAfterLoading();
                    elseif set ~= "" then
                        local id, data = strsplit("=", set);
                        id = tonumber(id);
                        WCollections.Cache.Sets[id] = WCollections.UnpackSet(id, data, true);
                    end
                end
            end);
            match(data, "CAMERAS:", function(cameras)
                for _, camera in ipairs({ strsplit(":", cameras) }) do
                    if camera ~= "" and camera ~= "END" then
                        local idString, dataString = strsplit("=", camera);
                        local option, race, sex, id = strsplit(",", idString);
                        local x, y, z, f, anim, name = strsplit(",", dataString);
                        option = tonumber(option) or 0;
                        race = tonumber(race) or 0;
                        sex = tonumber(sex) or 0;
                        id = tonumber(id) or 0;
                        x = tonumber(x) or 0;
                        y = tonumber(y) or 0;
                        z = tonumber(z) or 0;
                        f = tonumber(f) or 0;
                        anim = anim and tonumber(anim);
                        name = name and WCollections:Decode(name);
                        WCollections.Cache.Cameras[option * WCollections.CameraOptionsToCameraID[WCollections.CameraOptions[1]] + race * WCollections.RaceToCameraID.Human + sex * WCollections.SexToCameraID[1] + id] = { x, y, z, f, anim, name };
                    end
                end
            end);
            match(data, "TOYS:", function(toys)
                for _, toy in ipairs({ strsplit(":", toys) }) do
                    if toy == "END" then
                        WCollections.Cache.Toys.Loaded = true;
                        WCollections.Callbacks.ToyListLoaded();
                    elseif toy ~= "" then
                        local id, dataString = strsplit("=", toy, 2);
                        local itemID, flags, expansion, sourceType, sourceText, holiday = strsplit(",", dataString);
                        id = tonumber(id) or 0;
                        itemID = tonumber(itemID) or 0;
                        flags = tonumber(flags) or 0;
                        expansion = tonumber(expansion) or 0;
                        sourceType = tonumber(sourceType) or 0;
                        sourceText = sourceText and WCollections:Decode(sourceText);
                        holiday = tonumber(holiday) or nil;
                        WCollections.Cache.Toys[id] = { itemID, flags, expansion, sourceType, sourceText, holiday };
                    end
                end
            end);
        end);
    end);
    match(message, "ADD:", function(list)
        match(list, "OWNEDITEM:",           AddList(WCollections.Collections.OwnedItems, WCollections.Callbacks.AddOwnedItem));
        match(list, "SKIN:",                AddList(WCollections.Collections.Skins, WCollections.Callbacks.AddSkin));
        match(list, "TAKENQUEST:",          AddList(WCollections.Collections.TakenQuests));
        match(list, "REWARDEDQUEST:",       AddList(WCollections.Collections.RewardedQuests));
        match(list, "TOY:",                 AddList(WCollections.Collections.Toys, WCollections.Callbacks.AddToy));
    end);
    match(message, "REMOVE:", function(list)
        match(list, "OWNEDITEM:",           RemoveList(WCollections.Collections.OwnedItems, WCollections.Callbacks.RemoveOwnedItem));
        match(list, "SKIN:",                RemoveList(WCollections.Collections.Skins, WCollections.Callbacks.RemoveSkin));
        match(list, "TAKENQUEST:",          RemoveList(WCollections.Collections.TakenQuests));
        match(list, "REWARDEDQUEST:",       RemoveList(WCollections.Collections.RewardedQuests));
        match(list, "TOY:",                 RemoveList(WCollections.Collections.Toys, WCollections.Callbacks.RemoveToy));
        match(list, "UNCLAIMEDQUEST:",      RemoveList(WCollections.UnclaimedQuests, WCollections.Callbacks.RemoveUnclaimedQuest));
    end);
    match(message, "RELOAD:", function(list)
        match(list, "OWNEDITEM:",           ReloadList("LIST:OWNEDITEM",     WCollections.Collections.OwnedItems));
        match(list, "SKIN:",                ReloadList("LIST:SKIN",          WCollections.Collections.Skins, WCollections.Callbacks.ClearSkins));
        match(list, "TAKENQUEST:",          ReloadList("LIST:TAKENQUEST",    WCollections.Collections.TakenQuests));
        match(list, "REWARDEDQUEST:",       ReloadList("LIST:REWARDEDQUEST", WCollections.Collections.RewardedQuests));
        match(list, "TOY:",                 ReloadList("LIST:TOY",           WCollections.Collections.Toys, WCollections.Callbacks.ClearToys));
        for slot, db in pairs(WCollections.Cache.Slot) do
            match(list, "ALL:"..slot..":",  ReloadAllList("LIST:ALL:"..slot, db, WCollections.Cache.All));
        end
        match(list, "STORESKIN:",           ReloadList("LIST:STORESKIN",    WCollections.StoreSkins, WCollections.Callbacks.ClearSkins));
    end);
    match(message, "GETTRANSMOG:", function(data)
        if not match(data, "PLAYER:", function(nameSlotStrings)
            local unit, slotStrings = strsplit(":", nameSlotStrings, 2);
            WCollections:ClearItemTransmogCache(unit);
            LoadItemTransmog(unit, slotStrings);
            WCollections.AceAddon:UpdateInspect(unit);
        end) and not match(data, "ALL:", function(slotStrings)
            WCollections:SetEmptyItemTransmogCache();
            LoadItemTransmog("player", slotStrings);
        end) then
            LoadItemTransmog("player", data);
            WCollections:RaiseEvent("TRANSMOGRIFY_UPDATE");
            WCollections:RaiseEvent("PLAYER_EQUIPMENT_CHANGED");
        end
    end);
    match(message, "CLAIMQUEST:", function(data)
        match(data, "GETQUESTS:", function(result)
            local skin, questStrings = strsplit(":", result, 2);
            if tonumber(skin) == WCollections.LastClaimQuestSkin then
                WCollections.LastClaimQuestData = { };
                for _, questString in ipairs({ strsplit(":", questStrings) }) do
                    if questString == "END" then
                        WCollections.Callbacks.ReceivedClaimQuests();
                    elseif questString ~= "" then
                        local quest, questData = strsplit("=", questString, 2);
                        local name, choicesString = strsplit(",", questData, 2);
                        local info =
                        {
                            ID = tonumber(quest),
                            Name = WCollections:Decode(name),
                            Choices = { },
                        };
                        for _, choice in ipairs({ strsplit(",", choicesString) }) do
                            table.insert(info.Choices, tonumber(choice));
                        end
                        table.insert(WCollections.LastClaimQuestData, info);
                    end
                end
            end
        end);
        match(data, "GETSLOTSETQUESTS:", function(result)
            local set, slot, questStrings = strsplit(":", result, 3);
            if tonumber(set) == WCollections.LastClaimSetSlotQuestSet and tonumber(slot) == WCollections.LastClaimSetSlotQuestSlot then
                WCollections.LastClaimSetSlotQuestData = { };
                for _, questString in ipairs({ strsplit(":", questStrings) }) do
                    if questString == "END" then
                        WCollections.Callbacks.ReceivedClaimSetSlotQuests();
                    elseif questString ~= "" then
                        local quest, questData = strsplit("=", questString, 2);
                        local itemID, itemName, itemColor, questName, choicesString = strsplit(",", questData, 5);
                        local info =
                        {
                            ItemID = tonumber(itemID),
                            ItemName = WCollections:Decode(itemName),
                            ItemColor = itemColor,
                            ID = tonumber(quest),
                            Name = WCollections:Decode(questName),
                            Choices = { },
                        };
                        for _, choice in ipairs({ strsplit(",", choicesString) }) do
                            table.insert(info.Choices, tonumber(choice));
                        end
                        table.insert(WCollections.LastClaimSetSlotQuestData, info);
                    end
                end
            end
        end);
    end);
    match(message, "TRANSMOGRIFY:", function(data)
        match(data, "COST:", function(result)
            if not match(result, "OK:", function(costStrings)
                local moneyCost, tokenCost, key = strsplit(":", costStrings, 3);
                C_Transmog.ClearSlotFailReasons(key);
                C_Transmog.SetCost(key, tonumber(moneyCost), tonumber(tokenCost));
            end) and not match(result, "FAIL:", function(costStrings)
                local entryFailReasons, enchantFailReasons, key = strsplit(":", costStrings, 3);
                C_Transmog.ClearSlotFailReasons(key);
                if entryFailReasons ~= "" then
                    for _, slotReason in ipairs({ strsplit(",", entryFailReasons) }) do
                        local slot, reason = strsplit("=", slotReason, 2);
                        C_Transmog.SetSlotFailReason(key, tonumber(slot), LE_TRANSMOG_TYPE_APPEARANCE, WCollections:Decode(reason));
                    end
                end
                if enchantFailReasons ~= "" then
                    for _, slotReason in ipairs({ strsplit(",", enchantFailReasons) }) do
                        local slot, reason = strsplit("=", slotReason, 2);
                        C_Transmog.SetSlotFailReason(key, tonumber(slot), LE_TRANSMOG_TYPE_ILLUSION, WCollections:Decode(reason));
                    end
                end
                WCollections:RaiseEvent("TRANSMOGRIFY_UPDATE");
            end) then
                StaticPopup_Show("WCOLLECTIONS_ERROR", L["Popup.Error.Transmogrify.Cost"] .. result);
            end
        end);
        match(data, "APPLY:", function(result)
            if not match(result, "OK:", function(costStrings)
                local moneyCost, tokenCost, key = strsplit(":", costStrings, 3);
                C_Transmog.PendingApplied(key);
            end) and not match(result, "FAIL:", function(costStrings)
                local entryFailReasons, enchantFailReasons, key = strsplit(":", costStrings, 3);
                C_Transmog.ClearSlotFailReasons(key);
                if entryFailReasons ~= "" then
                    for _, slotReason in ipairs({ strsplit(",", entryFailReasons) }) do
                        local slot, reason = strsplit("=", slotReason, 2);
                        C_Transmog.SetSlotFailReason(key, tonumber(slot), LE_TRANSMOG_TYPE_APPEARANCE, WCollections:Decode(reason));
                    end
                end
                if enchantFailReasons ~= "" then
                    for _, slotReason in ipairs({ strsplit(",", enchantFailReasons) }) do
                        local slot, reason = strsplit("=", slotReason, 2);
                        C_Transmog.SetSlotFailReason(key, tonumber(slot), LE_TRANSMOG_TYPE_ILLUSION, WCollections:Decode(reason));
                    end
                end
                C_Transmog.PendingFailed();
                WCollections:RaiseEvent("TRANSMOGRIFY_UPDATE");
            end) then
                C_Transmog.PendingFailed();
                StaticPopup_Show("WCOLLECTIONS_ERROR", L["Popup.Error.Transmogrify.Apply"] .. result);
            end
        end);
        for type, search in pairs(WCollections.LastSearch) do
            match(data, "SEARCH:"..type..":"..search.Token..":", function(result)
                if not match(result, "OK:", function(resultsString)
                    local numResults = strsplit(":", resultsString, 1);
                    search.NumResults = tonumber(numResults);
                    table.wipe(search.Results);
                    if search.NumResults == 0 then
                        WCollections.Callbacks.SearchFinished(type);
                    end
                end) and not match(result, "RESULTS:", (type == LE_TRANSMOG_SEARCH_TYPE_USABLE_SETS and LoadIndexedStringList or LoadIndexedList)(search.Results, function()
                    if search.NumResults == #search.Results then
                        WCollections.Callbacks.SearchFinished(type);
                    else
                        StaticPopup_Show("WCOLLECTIONS_ERROR", L["Popup.Error.Transmogrify.Search.ResultsMismatch"]);
                    end
                end)) and not match(result, "FAIL:", function(result)
                    StaticPopup_Show("WCOLLECTIONS_ERROR", L["Popup.Error.Transmogrify.Search"] .. result);
                end) then
                    StaticPopup_Show("WCOLLECTIONS_ERROR", L["Popup.Error.Transmogrify.Search"] .. result);
                end
            end);
        end
        match(data, "OUTFIT:", function(result)
            match(result, "COST:", function(result)
                if not match(result, "OK:", function(result)
                    local moneyCost, tokenCost, outfitData = strsplit(":", result, 3);
                    if not WardrobeOutfitSaveFrame.editedOutfitID then
                        WardrobeOutfitSaveFrame:Update(false, true, nil, tonumber(moneyCost), tonumber(tokenCost));
                    end
                end) and not match(result, "FAIL:", function(result)
                    local moneyCost, tokenCost, failedItemMask, failedEnchantMask, errorText = strsplit(":", result);
                    if not WardrobeOutfitSaveFrame.editedOutfitID then
                        WardrobeOutfitSaveFrame:Update(false, false, WCollections:Decode(errorText), tonumber(moneyCost), tonumber(tokenCost), tonumber(failedItemMask), tonumber(failedEnchantMask));
                    end
                end) then
                    StaticPopup_Show("WCOLLECTIONS_ERROR", L["Popup.Error.Transmogrify.Outfit.Cost"] .. result);
                end
            end);
            match(result, "ADD:", function(result)
                if not match(result, "OK:", function(result)
                    local moneyCost, tokenCost, outfitData = strsplit(":", result, 3);
                    if not WardrobeOutfitSaveFrame.editedOutfitID then
                        StaticPopupSpecial_Hide(WardrobeOutfitSaveFrame);
                    end
                end) and not match(result, "FAIL:", function(result)
                    local moneyCost, tokenCost, failedItemMask, failedEnchantMask, errorText = strsplit(":", result);
                    if not WardrobeOutfitSaveFrame.editedOutfitID then
                        WardrobeOutfitSaveFrame:Update(false, false, WCollections:Decode(errorText), tonumber(moneyCost), tonumber(tokenCost), tonumber(failedItemMask), tonumber(failedEnchantMask));
                    end
                end) then
                    local id, name, flags, slotStrings = strsplit(":", result, 4);
                    id = tonumber(id);
                    if id then
                        WCollections.Outfits[id] =
                        {
                            Name = WCollections:Decode(name),
                            Flags = tonumber(flags) or 0,
                            Slots = slotStrings,
                        };
                        WCollections:RaiseEvent("TRANSMOG_OUTFITS_CHANGED");
                        C_Transmog.ValidateAllPending(true);
                    else
                        StaticPopup_Show("WCOLLECTIONS_ERROR", L["Popup.Error.Transmogrify.Outfit.Add"] .. result);
                    end
                end
            end);
            match(result, "EDIT:", function(result)
                if not match(result, "OK:", function(result)
                    local outfitID, moneyCost, tokenCost, outfitData = strsplit(":", result, 4);
                    outfitID = tonumber(outfitID);
                    if outfitID and outfitID == WardrobeOutfitSaveFrame.editedOutfitID then
                        StaticPopupSpecial_Hide(WardrobeOutfitSaveFrame);
                    end
                end) and not match(result, "FAIL:", function(result)
                    local outfitID, moneyCost, tokenCost, failedItemMask, failedEnchantMask, errorText = strsplit(":", result);
                    outfitID = tonumber(outfitID);
                    if outfitID and outfitID == WardrobeOutfitSaveFrame.editedOutfitID then
                        WardrobeOutfitSaveFrame:Update(false, false, WCollections:Decode(errorText), tonumber(moneyCost), tonumber(tokenCost), tonumber(failedItemMask), tonumber(failedEnchantMask));
                    end
                end) then
                    StaticPopup_Show("WCOLLECTIONS_ERROR", L["Popup.Error.Transmogrify.Outfit.Edit"] .. result);
                end
            end);
            match(result, "EDITCOST:", function(result)
                if not match(result, "OK:", function(result)
                    local outfitID, moneyCost, tokenCost, outfitData = strsplit(":", result, 4);
                    outfitID = tonumber(outfitID);
                    if outfitID and outfitID == WardrobeOutfitSaveFrame.editedOutfitID then
                        WardrobeOutfitSaveFrame:Update(false, true, nil, tonumber(moneyCost), tonumber(tokenCost));
                    end
                end) and not match(result, "FAIL:", function(result)
                    local outfitID, moneyCost, tokenCost, failedItemMask, failedEnchantMask, errorText = strsplit(":", result, 6);
                    outfitID = tonumber(outfitID);
                    if outfitID and outfitID == WardrobeOutfitSaveFrame.editedOutfitID then
                        WardrobeOutfitSaveFrame:Update(false, false, WCollections:Decode(errorText), tonumber(moneyCost), tonumber(tokenCost), tonumber(failedItemMask), tonumber(failedEnchantMask));
                    end
                end) then
                    StaticPopup_Show("WCOLLECTIONS_ERROR", L["Popup.Error.Transmogrify.Outfit.EditCost"] .. result);
                end
            end);
            match(result, "RENAME:", function(result)
                if not match(result, "OK", function() end) then
                    StaticPopup_Show("WCOLLECTIONS_ERROR", L["Popup.Error.Transmogrify.Outfit.Rename"] .. result);
                end
            end);
            match(result, "REMOVE:", function(result)
                if not match(result, "OK", function() end) then
                    local id = strsplit(":", result);
                    id = tonumber(id);
                    if id then
                        for specIndex = 1, GetNumSpecializations() do
                            if tonumber(WCollections:GetCVar("lastTransmogOutfitIDSpec"..specIndex)) == id then
                                WCollections:SetCVar("lastTransmogOutfitIDSpec"..specIndex, "");
                            end
                        end
                        WCollections.Outfits[id] = nil;
                        WCollections:RaiseEvent("TRANSMOG_OUTFITS_CHANGED");
                        C_Transmog.ValidateAllPending(true);
                    else
                        StaticPopup_Show("WCOLLECTIONS_ERROR", L["Popup.Error.Transmogrify.Outfit.Remove"] .. result);
                    end
                end
            end);
        end);
    end);
    match(message, "MOUNT:", function(result)
        match(result, "PREMIUM:STATUS:", function(result)
            local endTime, scaling, info = strsplit(":", result, 3);
            WCollections.ActiveMountPremiumEndTime = tonumber(endTime) or 0;
            WCollections.ActiveMountPremiumScaling = tonumber(scaling) == 1;
            WCollections.ActiveMountPremiumInfo = WCollections:Decode(info);
            WCollections.Callbacks.MountListUpdated();
            WCollectionsUpdateActionBars();
        end);
        match(result, "SUBSCRIPTION:STATUS:", function(result)
            if not match(result, "SPELLS:",  LoadList(WCollections.ActiveMountSubscriptionMounts, WCollections.Callbacks.MountListUpdated)) then
                local endTime, scaling, info = strsplit(":", result, 3);
                WCollections.ActiveMountSubscriptionEndTime = tonumber(endTime) or 0;
                WCollections.ActiveMountSubscriptionScaling = tonumber(scaling) == 1;
                WCollections.ActiveMountSubscriptionInfo = WCollections:Decode(info);
                table.wipe(WCollections.ActiveMountSubscriptionMounts);
                WCollections.Callbacks.MountListUpdated();
                WCollectionsUpdateActionBars();
            end
        end);
    end);
    match(message, "PET:", function(result)
        match(result, "SUBSCRIPTION:STATUS:", function(result)
            if not match(result, "SPELLS:",  LoadList(WCollections.ActivePetSubscriptionPets, WCollections.Callbacks.PetListUpdated)) then
                local endTime, scaling, info = strsplit(":", result, 3);
                WCollections.ActivePetSubscriptionEndTime = tonumber(endTime) or 0;
                WCollections.ActivePetSubscriptionInfo = WCollections:Decode(info);
                table.wipe(WCollections.ActivePetSubscriptionPets);
                WCollections.Callbacks.PetListUpdated();
            end
        end);
    end);
    match(message, "TOY:", function(result)
        match(result, "SUBSCRIPTION:STATUS:", function(result)
            if not match(result, "TOYS:",  LoadList(WCollections.ActiveToySubscriptionToys, WCollections.Callbacks.ToyListUpdated)) then
                local endTime, info = strsplit(":", result, 2);
                WCollections.ActiveToySubscriptionEndTime = tonumber(endTime) or 0;
                WCollections.ActiveToySubscriptionInfo = WCollections:Decode(info);
                table.wipe(WCollections.ActiveToySubscriptionToys);
                WCollections.Callbacks.ToyListUpdated();
            end
        end);
        match(result, "COOLDOWN:", function(result)
            for _, cooldown in ipairs({ strsplit(":", result) }) do
                if cooldown == "END" then
                    WCollections.Callbacks.ToyStatusUpdated(ACTIONBUTTON_UPDATE_COOLDOWN);
                elseif cooldown ~= "" then
                    local itemID, dataString = strsplit("=", cooldown, 2);
                    local start, duration, enabled = strsplit(",", dataString);
                    itemID = tonumber(itemID);
                    start = (tonumber(start) or 0) / 1000;
                    duration = (tonumber(duration) or 0) / 1000;
                    enabled = enabled == "1";
                    if itemID then
                        WCollections.ItemCooldowns[itemID] = { GetTime() - start, duration, enabled };
                    end
                end
            end
        end);
        match(result, "ACTIVE:", function(result)
            for _, itemID in ipairs({ strsplit(":", result) }) do
                if itemID == "END" then
                    WCollections.Callbacks.ToyStatusUpdated(ACTIONBUTTON_UPDATE_STATE);
                elseif itemID ~= "" then
                    itemID = tonumber(itemID);
                    if itemID then
                        WCollections.ActiveToys[math.abs(itemID)] = itemID > 0 or nil;
                    end
                end
            end
        end);
    end);
    match(message, "PRELOADCACHE:ITEMS:", function(result)
        local offset, total = strsplit(":", result);
        offset = tonumber(offset);
        total = tonumber(total);
        if not offset or not total then
            WCollections.preloadCacheItemsNextOffset = nil;
            StaticPopup_Hide("WCOLLECTIONS_PRELOADING_ITEM_CACHE");
            if result == "Throttled" then
                StaticPopup_Show("WCOLLECTIONS_ERROR", L["Popup.PreloadingItemCache.Throttled"]);
            else
                StaticPopup_Show("WCOLLECTIONS_ERROR", L["Popup.Error.UnknownParam"] .. result);
            end
        else
            WCollections:RaiseEvent("WCOLLECTIONS_PRELOAD_ITEM_CACHE_PROGRESS", offset, total);
            if offset < total then
                WCollections.preloadCacheItemsNextOffset = offset;
                WCollections:SendAddonMessage("PRELOADCACHE:ITEMS:"..offset);
            else
                WCollections.appearanceCacheLoaded = true;
                WCollections.preloadCacheItemsNextOffset = nil;
                WCollections.Callbacks.ToyListLoaded();
            end
        end
    end);
    match(message, "PRELOADCACHE:MOUNTS:", function(result)
        local offset, total = strsplit(":", result);
        offset = tonumber(offset);
        total = tonumber(total);
        if not offset or not total then
            WCollections.preloadCacheMountsNextOffset = nil;
            StaticPopup_Hide("WCOLLECTIONS_PRELOADING_MOUNT_CACHE");
            if result == "Throttled" then
                StaticPopup_Show("WCOLLECTIONS_ERROR", L["Popup.PreloadingMountCache.Throttled"]);
            else
                StaticPopup_Show("WCOLLECTIONS_ERROR", L["Popup.Error.UnknownParam"] .. result);
            end
        else
            WCollections:RaiseEvent("WCOLLECTIONS_PRELOAD_MOUNT_CACHE_PROGRESS", offset, total);
            if offset < total then
                WCollections.preloadCacheMountsNextOffset = offset;
                WCollections:SendAddonMessage("PRELOADCACHE:MOUNTS:"..offset);
            else
                WCollections.preloadCacheMountsNextOffset = nil;
                WCollections.Callbacks.MountListLoaded();
            end
        end
    end);
end
function addon:INSPECT_TALENT_READY(event)
    local target = GetUnitName("target");
    if not WCollections.Allowed or not WCollections.Config.RestoreItemIcons.Inspect or not target or not IsInspectFrameShown() then return; end
    local needs = self.needsInspectUpdate;
    self.needsInspectUpdate = nil;
    if target == WCollections.lastInspectTarget then
        if needs then
            -- Must be delayed because for some unknown reason GetInventoryItem* will return old values here
            if not self.inspectUpdateTimer then
                self.inspectUpdateTimer = self:ScheduleTimer(function() self.inspectUpdateTimer = nil; self:UpdateInspect(target); end, 0.1);
            end
        end
        return;
    end

    if not WCollections.inspectFrameHooked then
        if InspectFrame then
            InspectFrame:HookScript("OnHide", function(self)
                WCollections.lastInspectTarget = "";
            end);
        end
        if Examiner then
            Examiner:HookScript("OnHide", function(self)
                WCollections.lastInspectTarget = "";
            end);
        end
        WCollections.inspectFrameHooked = true;
    end
    WCollections.lastInspectTarget = target;
    WCollections:ClearItemTransmogCache(target);
    WCollections:SendAddonMessage("GETTRANSMOG:PLAYER:"..target);
end
function addon:UNIT_INVENTORY_CHANGED(event, unit)
    local target = GetUnitName(unit);
    if not WCollections.Allowed or not WCollections.Config.RestoreItemIcons.Inspect or not target or not IsInspectFrameShown() or target ~= WCollections.lastInspectTarget then return; end

    if not self.reinspectTimer then
        self.reinspectTimer = self:ScheduleTimer(function() self.reinspectTimer = nil; NotifyInspect("target"); end, 0.5);
    end

    self.needsInspectUpdate = true;
    WCollections:ClearItemTransmogCache(target);
    WCollections:SendAddonMessage("GETTRANSMOG:PLAYER:"..target);
end
local batchEquipmentRequest;
function addon:PLAYER_EQUIPMENT_CHANGED(event, slot, equipped)
    if CharacterFrame:IsShown() and PaperDollFrame:IsShown() then
        local slotName = TRANSMOGRIFIABLE_SLOTS[slot];
        local slotButton = slotName and _G["Character"..slotName];
        if slotButton and slotButton:IsShown() then
            PaperDollItemSlotButton_Update(slotButton);
        end
    end
    WCollections:RemoveItemTransmogCache("player", slot);
    if equipped and WCollections:IsSkinSource(oGetInventoryItemID("player", slot)) == true then
        if WardrobeFrame_IsAtTransmogrifier() then
            -- Request immediately, we need fresh info already
            WCollections:GetItemTransmog("player", slot);
        else
            if batchEquipmentRequest then
                WCollections.AceAddon:CancelTimer(batchEquipmentRequest);
            end
            batchEquipmentRequest = WCollections.AceAddon:ScheduleTimer(function()
                batchEquipmentRequest = nil;
                WCollections:SendAddonMessage("GETTRANSMOG:PLAYER:"..GetUnitName("player"));
            end, 1);
        end
    end
end
function addon:BANKFRAME_OPENED(event)
    if not WCollections.Allowed then return; end

    WCollections:SetEmptyBankTransmogCache();
    WCollections.IconOverlays:Update();
end
function addon:BAG_UPDATE(event, bagID)
    if not WCollections.Allowed then return; end

    WCollections:UpdateItemTransmogCache(bagID);
    WCollections.IconOverlays:Update(bagID);
end
function addon:PLAYERBANKSLOTS_CHANGED(event)
    if not WCollections.Allowed then return; end

    WCollections:UpdateItemTransmogCache(-1);
    WCollections.IconOverlays:Update(-1);
end
function addon:GUILDBANKBAGSLOTS_CHANGED(event)
    if not WCollections.Allowed then return; end

    WCollections.IconOverlays:Update();
end
function addon:ADDON_LOADED(event, addon)
    if WCollectionsInspectHook and (addon == "Blizzard_InspectUI" or InspectPaperDollItemSlotButton_Update) then
        hooksecurefunc("InspectPaperDollItemSlotButton_Update", WCollectionsInspectHook);
        WCollectionsInspectHook = nil;
    end
    if WCollectionsAuctionOnShowHook and (addon == "Blizzard_AuctionUI" or AuctionFrame) then
        AuctionFrame:HookScript("OnShow", WCollectionsAuctionOnShowHook);
        WCollectionsAuctionOnShowHook = nil;
    end
    if WCollectionsAuctionOnHideHook and (addon == "Blizzard_AuctionUI" or AuctionFrame) then
        AuctionFrame:HookScript("OnHide", WCollectionsAuctionOnHideHook);
        WCollectionsAuctionOnHideHook = nil;
    end
    if WCollectionsDressUpItemLink and addon == "Blizzard_AuctionUI" then
        DressUpItemLink = WCollectionsDressUpItemLink;
    end
    if WCollectionsDominosHook and (addon == "Dominos" or Dominos) then
        WCollectionsDominosHook();
        WCollectionsDominosHook = nil;
    end
    if WCollectionsBartender4Hook and (addon == "Bartender4" or Bartender4) then
        WCollectionsBartender4Hook();
        WCollectionsBartender4Hook = nil;
    end
    if WCollectionsElvUIHook and (addon == "ElvUI" or ElvUI) then
        WCollectionsElvUIHook();
        WCollectionsElvUIHook = nil;
    end
    if WCollectionsElvUIEnhancedHook and (addon == "ElvUI_Enhanced") then
        WCollectionsElvUIEnhancedHook();
        WCollectionsElvUIEnhancedHook = nil;
    end
    if WCollectionsElvUIConfigHook and (addon == "ElvUI_Config" or addon == "ElvUI_OptionsUI") then
        WCollectionsElvUIConfigHook();
        WCollectionsElvUIConfigHook = nil;
    end
end
function addon:PLAYER_ENTERING_WORLD(event)
    if WCollections and WCollections.preloadCacheItemsNextOffset then
        WCollections:SendAddonMessage("PRELOADCACHE:ITEMS:"..WCollections.preloadCacheItemsNextOffset);
    end
    if WCollections and WCollections.preloadCacheMountsNextOffset then
        WCollections:SendAddonMessage("PRELOADCACHE:MOUNTS:"..WCollections.preloadCacheMountsNextOffset);
    end
    C_MountJournal.RefreshMounts();
    C_PetJournal.RefreshPets();
    WCollectionsUpdateActionBars();
end

local inCombat = UnitAffectingCombat("player");
local function PlayerIsAlive()
    return not UnitIsDeadOrGhost("player");
end

function addon:PLAYER_REGEN_ENABLED()
    inCombat = false;
    WCollectionsUpdateActionBars(ACTIONBUTTON_UPDATE_USABLE);
end

function addon:PLAYER_REGEN_DISABLED()
    inCombat = true;
    WCollectionsUpdateActionBars(ACTIONBUTTON_UPDATE_USABLE);
end

local companionUpdateDeferred = false;
function addon:COMPANION_LEARNED(event)
    if not companionUpdateDeferred then
        companionUpdateDeferred = true;
        C_Timer.After(0.1, function()
            companionUpdateDeferred = false;
            C_MountJournal.RefreshMounts();
            C_PetJournal.RefreshPets();
            WCollectionsUpdateActionBars();
            WCollections.IconOverlays:Update();
        end);
    end
end

function addon:COMPANION_UNLEARNED(event)
    if not companionUpdateDeferred then
        companionUpdateDeferred = true;
        C_Timer.After(0.1, function()
            companionUpdateDeferred = false;
            C_MountJournal.RefreshMounts();
            C_PetJournal.RefreshPets();
            WCollections.IconOverlays:Update();
        end);
    end
end

local lastActionBarUpdateTime = 0;
function addon:SPELL_UPDATE_USABLE(event)
    WCollections:RaiseEvent("MOUNT_JOURNAL_USABILITY_CHANGED");
    if WCollections.Config.ActionButtons.Mounts and WCollections.Config.ActionButtons.MountsPerf and math.abs(lastActionBarUpdateTime - GetTime()) > 0.01 then
        lastActionBarUpdateTime = GetTime();
        WCollectionsUpdateActionBars(ACTIONBUTTON_UPDATE_USABLE);
    end
end

function addon:ACTIONBAR_UPDATE_USABLE(event)
    WCollections:RaiseEvent("MOUNT_JOURNAL_USABILITY_CHANGED");
    if WCollections.Config.ActionButtons.Mounts and WCollections.Config.ActionButtons.MountsPerf then
        lastActionBarUpdateTime = GetTime();
    end
end

local successfullyStartedCastID = nil;
function addon:UNIT_SPELLCAST_START(event, unit, name, rank, castID)
    if WCollections:IsMountScalingAllowed() and name and unit == "player" and IsOutdoors() then
        if castID == 0 then
            WCollectionsUpdateActionBars();
            return;
        end
        for i = 1, GetNumCompanions("MOUNT") do
            local _, _, spellID = GetCompanionInfo("MOUNT", i);
            if spellID and GetSpellInfo(spellID) == name then
                successfullyStartedCastID = castID;
            end
        end
    end
end

local waitingForMountFailure = false;
local suppressMountError = false;
function addon:UNIT_SPELLCAST_FAILED(event, unit, name, rank, castID)
    if WCollections:IsMountScalingAllowed() and name and unit == "player" and IsOutdoors() then
        if castID == 0 or castID == successfullyStartedCastID then
            C_Timer.After(0, WCollectionsUpdateActionBars);
            return;
        end
        if not waitingForMountFailure then
            return;
        end
        for i = 1, GetNumCompanions("MOUNT") do
            local _, _, spellID = GetCompanionInfo("MOUNT", i);
            if spellID and GetSpellInfo(spellID) == name then
                if PlayerIsAlive() and not inCombat and C_MountJournal.IsMountUsable(spellID, true) then
                    WCollections:SendAddonMessage("MOUNT:SCALINGCAST:"..spellID);
                    suppressMountError = true;
                end
            end
        end
    end
    waitingForMountFailure = false;
end

local waitingForLearnFailure = false;
local suppressLearnError = false;
hooksecurefunc("UseContainerItem", function(bag, slot)
    if not waitingForLearnFailure then
        return;
    end

    local item = GetContainerItemID(bag, slot);
    local mount = item and WCollections:GetMountIDByItem(item);
    local pet = item and WCollections:GetPetIDByItem(item);
    if mount and WCollections:HasAvailableMount(mount) and not WCollections:HasMount(mount)
    or pet and WCollections:HasAvailablePet(pet) and not WCollections:HasPet(pet) then
        WCollections:SendAddonMessage(format("MOUNT:FORCELEARN:%d:%d:%d", bag, slot - 1, item));
        suppressLearnError = true;
    end
    waitingForLearnFailure = false;
end);

local alreadyKnownPattern = FormatToPattern(ERR_SPELL_ALREADY_KNOWN_S);
local oldUIErrorsFrameOnEvent = UIErrorsFrame:GetScript("OnEvent");
UIErrorsFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "UI_ERROR_MESSAGE" and WCollections:IsMountScalingAllowed() then
        local text = ...;
        if text == SPELL_FAILED_NOT_HERE then
            waitingForMountFailure = true;
            C_Timer.After(0, function()
                if not suppressMountError then
                    self:AddMessage(text, 1.0, 0.1, 0.1, 1.0);
                end
                suppressMountError = false;
            end);
            return;
        end
    end
    if event == "UI_ERROR_MESSAGE" and (WCollections:IsActiveMountSubscription() or WCollections:IsActivePetSubscription()) then
        local text = ...;
        if text:match(alreadyKnownPattern) then
            waitingForLearnFailure = true;
            C_Timer.After(0, function()
                if not suppressLearnError then
                    self:AddMessage(text, 1.0, 0.1, 0.1, 1.0);
                end
                suppressLearnError = false;
            end);
            return;
        end
    end
    oldUIErrorsFrameOnEvent(self, event, ...);
end);

function WCollectionsUpdateActionBars() end
function addon:HookActionBars()
    local HookBartender4, specialButtons;

    local function Demacroify(type, id, subType, subID)
        if type == "macro" then
            local name, link = GetMacroItem(id);
            if name and link and WCollections.Config.ActionButtons.Toys then
                id = GetItemID(link);
                type = id and "item";
            end
        end
        return type, id, subType, subID;
    end
    local function IsCompanionUsable(id)
        return WCollections.Config.ActionButtons.Mounts and PlayerIsAlive() and not inCombat and WCollections:IsMountScalingAllowed() and IsOutdoors() and C_MountJournal.IsMountUsable(id, true);
    end
    local function IsItemUsable(id)
        return WCollections.Config.ActionButtons.Toys and PlayerIsAlive() and C_ToyBox.GetToyInfo(id) and PlayerHasToy(id) and C_ToyBox.IsToyUsable(id);
    end
    local function IsMacroUsable(id)
        local name = GetMacroSpell(id);
        if name and WCollections.Config.ActionButtons.Mounts and PlayerIsAlive() and not inCombat and WCollections:IsMountScalingAllowed() and IsOutdoors() then
            if not WCollections.MountNameXMountID then
                WCollections.MountNameXMountID = { };
                for id in pairs(WCollections.Mounts) do
                    WCollections.MountNameXMountID[GetSpellInfo(id)] = id;
                end
            end
            local spellID = WCollections.MountNameXMountID[name];
            if spellID then
                return C_MountJournal.IsMountUsable(spellID, true);
            end
        end
        local name, link = GetMacroItem(id);
        if name and link and WCollections.Config.ActionButtons.Toys then
            local id = GetItemID(link);
            return id and IsItemUsable(id);
        end
    end
    local function UpdateCompanion(icon, normalTexture, id)
        if IsCompanionUsable(id) then
            icon:SetVertexColor(1, 1, 1);
            normalTexture:SetVertexColor(1, 1, 1);
        end
    end
    local function UpdateItem(icon, normalTexture, id)
        if IsItemUsable(id) then
            icon:SetVertexColor(1, 1, 1);
            normalTexture:SetVertexColor(1, 1, 1);
        end
    end
    local function UpdateMacro(icon, normalTexture, id)
        if IsMacroUsable(id) then
            icon:SetVertexColor(1, 1, 1);
            normalTexture:SetVertexColor(1, 1, 1);
        end
    end
    local function UpdateUsable(self)
        local icon = _G[self:GetName().."Icon"];
        local normalTexture = _G[self:GetName().."NormalTexture"];

        -- Bartender4
        if self.BT4init then
            HookBartender4(self);
            icon = self.icon;
            normalTexture = self.normalTexture;
        end

        local type, id, subType, subID = GetActionInfo(self.action);
        if type == "companion" and subType == "MOUNT" then
            UpdateCompanion(icon, normalTexture, subID);
        elseif type == "item" then
            UpdateItem(icon, normalTexture, id);
        elseif type == "macro" then
            UpdateMacro(icon, normalTexture, id);
        end

        -- KActionBars
        if KActionBars and KActionBarsDB.range == true and WCollections.Config.ActionButtons.Addons.KActionBars then
            if IsActionInRange(self.action) == 0 then icon:SetVertexColor(1.0, 0.1, 0.1) end
        end
    end

    -- Blizzard
    hooksecurefunc("ActionButton_UpdateUsable", UpdateUsable);
if WCollections.Config.ActionButtons.Toys then
    hooksecurefunc("ActionButton_UpdateState", function(self)
        local type, id, subType, subID = Demacroify(GetActionInfo(self.action));
        if type == "item" then
            if C_ToyBox.GetToyInfo(id) and PlayerHasToy(id) then
                self:SetChecked(WCollections.ActiveToys[id]);
            end
        end
    end);
    hooksecurefunc("ActionButton_UpdateCooldown", function(self)
        local type, id, subType, subID = Demacroify(GetActionInfo(self.action));
        if type == "item" then
            if C_ToyBox.GetToyInfo(id) and PlayerHasToy(id) then
                local start, duration, enable = WCollections:GetItemCooldown(id);
                CooldownFrame_SetTimer(_G[self:GetName().."Cooldown"], start, duration, enable);
            end
        end
    end);
    hooksecurefunc("ActionButton_SetTooltip", function(self)
        local type, id, subType, subID = Demacroify(GetActionInfo(self.action));
        if type == "item" then
            if GetItemCount(id) == 0 and C_ToyBox.GetToyInfo(id) and PlayerHasToy(id) then
                if ( GetCVar("UberTooltips") == "1" ) then
                    GameTooltip_SetDefaultAnchor(GameTooltip, self);
                else
                    local parent = self:GetParent();
                    if ( parent == MultiBarBottomRight or parent == MultiBarRight or parent == MultiBarLeft ) and not self.BT4init then -- Bartender4
                        GameTooltip:SetOwner(self, "ANCHOR_LEFT");
                    else
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                    end
                end
                if self.BT4init and specialButtons[self.action] then -- Bartender4
                    GameTooltip:SetText(specialButtons[self.action].tooltip) -- Bartender4
                    self.UpdateTooltip = ActionButton_SetTooltip;
                elseif ( GameTooltip:SetToyByItemID(id) ) then
                    self.UpdateTooltip = ActionButton_SetTooltip;
                else
                    self.UpdateTooltip = nil;
                end
            end
        end
    end);
    local lastPreAction, lastPreButton;
    local oldActionButton_CalculateAction = ActionButton_CalculateAction;
    hooksecurefunc("ActionButton_CalculateAction", function(self, button)
        lastPreAction = oldActionButton_CalculateAction(self, button);
        lastPreButton = button;
    end);
    hooksecurefunc("UseAction", function(action, unit, button)
        -- Prevent accidental trigger when placing cursor item into action button slot
        if action ~= lastPreAction or button ~= lastPreButton then
            return;
        end

        local type, id, subType, subID = GetActionInfo(action);
        if type == "item" then
            if GetItemCount(id) == 0 and IsItemUsable(id) then
                UseToy(id);
            end
        end
    end);
end
if WCollections.Config.ActionButtons.Toys and WCollections.Config.ActionButtons.Addons.ButtonForge then
    local function ButtonForge_UseItem(name) -- ButtonForge
        local id = name and type(name) == "string" and WCollections:GetToyItemByName(name);
        if id and GetItemCount(id) == 0 and IsItemUsable(id) then
            UseToy(id);
        end
    end
    hooksecurefunc("EquipItemByName", ButtonForge_UseItem);
    hooksecurefunc("SecureCmdUseItem", ButtonForge_UseItem);
end
    local actionBarPrefixes = { "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton", "MultiBarLeftButton" };
    local function UpdateBlizzard(type)
        for _, bar in pairs(actionBarPrefixes) do
            for i = 1, 12 do
                local button = _G[bar..i];
                if button then
                    local slot = ActionButton_GetPagedID(button) or ActionButton_CalculateAction(button) or button:GetAttribute("action");
                    if slot and HasAction(slot) then
                        if not type or type == ACTIONBUTTON_UPDATE_STATE then ActionButton_UpdateState(button); end
                        if not type or type == ACTIONBUTTON_UPDATE_USABLE then ActionButton_UpdateUsable(button); end
                        if not type or type == ACTIONBUTTON_UPDATE_COOLDOWN then ActionButton_UpdateCooldown(button); end
                    end
                end
            end
        end
    end

    -- Bartender4
    specialButtons = {
        [132] = { icon = "Interface\\Icons\\Spell_Shadow_SacrificialShield", tooltip = LEAVE_VEHICLE}, -- Vehicle Leave Button
    }
    local hookedBartender4;
    HookBartender4 = function(self)
        if not WCollections.Config.ActionButtons.Addons.Bartender then return; end
        if self.BT4init and not hookedBartender4 then
            hookedBartender4 = true;
            local Button = getmetatable(self).__index;
            function Button:UpdateUsable()
                local isUsable, notEnoughMana = IsUsableAction(self.action)
                local icon = self.icon

                if Bartender4.db.profile.outofrange == "button" and self.outOfRange then
                    local oorc = Bartender4.db.profile.colors.range
                    icon:SetVertexColor(oorc.r, oorc.g, oorc.b)
                else
                    if isUsable or specialButtons[self.action] then
                        icon:SetVertexColor(1.0, 1.0, 1.0)
                    elseif notEnoughMana then
                        local oomc = Bartender4.db.profile.colors.mana
                        icon:SetVertexColor(oomc.r, oomc.g, oomc.b)
                    else
                        icon:SetVertexColor(0.4, 0.4, 0.4)
                        UpdateUsable(self);
                    end
                end
            end
            function Button:SetTooltip()
                ActionButton_SetTooltip(self);
            end
            function Button:WCollectionsUpdate(type)
                if not type then self:Update(); end
                if not type or type == ACTIONBUTTON_UPDATE_STATE then ActionButton_UpdateState(self); end
                if not type or type == ACTIONBUTTON_UPDATE_USABLE then ActionButton_UpdateUsable(self); end
                if not type or type == ACTIONBUTTON_UPDATE_COOLDOWN then ActionButton_UpdateCooldown(self); end
            end
        end
    end
    local function UpdateBartender4(type)
        if not WCollections.Config.ActionButtons.Addons.Bartender then return; end
        if Bartender4 then
            for _, bar in Bartender4.Bar:GetAll() do
                if bar.ForAll then
                    bar:ForAll("WCollectionsUpdate", type);
                end
            end
        end
    end

    -- ButtonForge
    local hookedButtonForge;
    local function HookButtonForge(self)
        if not WCollections.Config.ActionButtons.Addons.ButtonForge then return; end
        if not hookedButtonForge then
            hookedButtonForge = true;
            hooksecurefunc(BFButton, "UpdateUsableCompanion", function(self)
                if not WCollections.Config.ActionButtons.Mounts then return; end
                local id = select(3, GetCompanionInfo(self.CompanionType, self.CompanionIndex));
                if (self.CompanionType == "MOUNT" and (not PlayerIsAlive() or inCombat or IsIndoors() or not C_MountJournal.IsMountUsable(id, true))) then
                    self.WIcon:SetVertexColor(0.4, 0.4, 0.4);
                    self.WNormalTexture:SetVertexColor(1.0, 1.0, 1.0);
                else
                    self.WIcon:SetVertexColor(1.0, 1.0, 1.0);
                    self.WNormalTexture:SetVertexColor(1.0, 1.0, 1.0);
                end
            end);
            hooksecurefunc(BFButton, "UpdateUsableItem", function(self) UpdateItem(self.WIcon, self.WNormalTexture, self.ItemId); end);
            hooksecurefunc(BFButton, "UpdateUsableMacro", function(self) UpdateMacro(self.WIcon, self.WNormalTexture, self.MacroIndex); end);
            hooksecurefunc(BFButton, "UpdateCheckedItem", function(self)
                local id = self.ItemId;
                if WCollections.Config.ActionButtons.Toys and id and C_ToyBox.GetToyInfo(id) and PlayerHasToy(id) then
                    self.Widget:SetChecked(WCollections.ActiveToys[id]);
                end
            end);
            hooksecurefunc(BFButton, "UpdateCooldownItem", function(self)
                local id = self.ItemId;
                if WCollections.Config.ActionButtons.Toys and id and C_ToyBox.GetToyInfo(id) and PlayerHasToy(id) then
                    local start, duration, enable = WCollections:GetItemCooldown(id);
                    CooldownFrame_SetTimer(self.WCooldown, start, duration, enable);
                end
            end);
            hooksecurefunc(BFButton, "UpdateTooltipItem", function(self)
                self = self.ParentButton or self;
                local id = self.ItemId;
                if WCollections.Config.ActionButtons.Toys and id and GetItemCount(id) == 0 and C_ToyBox.GetToyInfo(id) and PlayerHasToy(id) then
                    GameTooltip_SetDefaultAnchor(GameTooltip, self.Widget);
                    GameTooltip:SetToyByItemID(id);
                end
            end);
            hooksecurefunc(BFButton, "TranslateMacro", function(self)
                if self.Mode == "macro" and self.MacroMode == "item" and type(self.ItemId) == "string" and self.ItemLink then
                    local id = GetItemID(self.ItemLink);
                    if id then
                        self.ItemId = id;
                        BFButton.FullRefresh(self);
                    end
                end
            end);
            function BFButton:UpdateTooltipMacro()
                self = self.ParentButton or self; --This is a sneaky cheat incase the widget was used to get here...

                if (self.MacroMode == "spell") then
                    self:UpdateTooltipSpell();
                elseif (self.MacroMode == "item") then
                    self:UpdateTooltipItem();
                elseif (self.MacroMode == "companion") then
                    self:UpdateTooltipCompanion();
                end
            end
        end
    end
    local function UpdateButtonForge(type)
        if not WCollections.Config.ActionButtons.Addons.ButtonForge then return; end
        if BFEventFrames then
            HookButtonForge();
            if not type or type == ACTIONBUTTON_UPDATE_STATE then BFEventFrames["Checked"]:OnEvent(); end
            if not type or type == ACTIONBUTTON_UPDATE_USABLE then BFEventFrames["Usable"]:OnEvent(); end
            if not type or type == ACTIONBUTTON_UPDATE_COOLDOWN then BFEventFrames["Cooldown"]:OnEvent(); end
        end
    end

    -- LibActionButton
    local hookedLibActionButton_action;
    local function HookLibActionButton(lib)
        if not WCollections.Config.ActionButtons.Addons.LibActionButton then return; end
        if lib and not hookedLibActionButton_action then
            for button in next, lib.buttonRegistry do
                if button._state_type == "action" and not hookedLibActionButton_action then
                    hookedLibActionButton_action = true;
                    local Action = getmetatable(button).__index;
                    function Action:IsUsable()
                        local type, id, subType, subID = GetActionInfo(self._state_action);
                        local usable;
                        if WCollections.Config.ActionButtons.Mounts and type == "companion" and subType == "MOUNT" then
                            usable = IsCompanionUsable(subID);
                        elseif WCollections.Config.ActionButtons.Toys and type == "item" then
                            usable = IsItemUsable(id);
                        elseif type == "macro" then
                            usable = IsMacroUsable(id);
                        end
                        return usable or IsUsableAction(self._state_action);
                    end
                    function Action:IsCurrentlyActive()
                        local type, id, subType, subID = Demacroify(GetActionInfo(self._state_action));
                        if WCollections.Config.ActionButtons.Toys and type == "item" then
                            if C_ToyBox.GetToyInfo(id) and PlayerHasToy(id) then
                                return WCollections.ActiveToys[id];
                            end
                        end
                        return IsCurrentAction(self._state_action);
                    end
                    function Action:GetCooldown()
                        local type, id, subType, subID = Demacroify(GetActionInfo(self._state_action));
                        if WCollections.Config.ActionButtons.Toys and type == "item" then
                            if C_ToyBox.GetToyInfo(id) and PlayerHasToy(id) then
                                return WCollections:GetItemCooldown(id);
                            end
                        end
                        return GetActionCooldown(self._state_action);
                    end
                    function Action:SetTooltip()
                        local type, id, subType, subID = Demacroify(GetActionInfo(self._state_action));
                        if WCollections.Config.ActionButtons.Toys and type == "item" then
                            if GetItemCount(id) == 0 and C_ToyBox.GetToyInfo(id) and PlayerHasToy(id) then
                                return GameTooltip:SetToyByItemID(id);
                            end
                        end
                        return GameTooltip:SetAction(self._state_action);
                    end
                end
            end
        end
    end
    local function UpdateLibActionButtonFor(lib, type)
        if not WCollections.Config.ActionButtons.Addons.LibActionButton then return; end
        if lib then
            HookLibActionButton(lib);
            local script = lib.eventFrame and lib.eventFrame:GetScript("OnEvent");
            if script then
                if not type or type == ACTIONBUTTON_UPDATE_STATE then
                    script(lib.eventFrame, "ACTIONBAR_UPDATE_STATE");
                end
                if not type or type == ACTIONBUTTON_UPDATE_USABLE then
                    script(lib.eventFrame, "ACTIONBAR_UPDATE_USABLE");
                    --script(lib.eventFrame, "SPELL_UPDATE_USABLE");
                end
                if not type or type == ACTIONBUTTON_UPDATE_COOLDOWN then
                    script(lib.eventFrame, "ACTIONBAR_UPDATE_COOLDOWN");
                    --script(lib.eventFrame, "SPELL_UPDATE_COOLDOWN");
                end
            end
        end
    end
    local function UpdateLibActionButton(type)
        if not WCollections.Config.ActionButtons.Addons.LibActionButton then return; end
        UpdateLibActionButtonFor(LibStub("LibActionButton-1.0", true), type);
        UpdateLibActionButtonFor(LibStub("LibActionButton-1.0-ElvUI", true), type);
    end

    -- Finalize
    function WCollectionsUpdateActionBars(type)
        UpdateBlizzard(type);
        UpdateBartender4(type);
        UpdateButtonForge(type);
        UpdateLibActionButton(type);
    end
    WCollectionsUpdateActionBars();
end

-- ---------------------------------------------------------------------------
-- Replace transmogrified icons on paper doll frames with their original icons
-- ---------------------------------------------------------------------------
function addon:HookRestoreItemIcons()

hooksecurefunc("NotifyInspect", function(unit)
    WCollections.lastInspectRequestUnit = GetUnitName(unit);
end);
GetInventoryItemID = function(unit, slot, ...)
    if WCollections.Allowed and WCollections.Config.RestoreItemIcons.Equipment and UnitIsUnit(unit, "player") then
        -- Do nothing, GetInventoryItemID should be able to return real values for current player
    elseif WCollections.Allowed and WCollections.Config.RestoreItemIcons.Inspect and UnitIsUnit(unit, "target") and GetUnitName("target") == WCollections.lastInspectTarget then
        local id = WCollections:GetItemTransmogCache(unit, slot).ID;
        if id and id ~= 0 then
            return id;
        end
    end
    return oGetInventoryItemID(unit, slot, ...);
end
--[[ Called from secure code
local oGetInventoryItemLink = GetInventoryItemLink;
GetInventoryItemLink = function(unit, slot, ...)
    if WCollections.Allowed and WCollections.Config.RestoreItemIcons.Equipment and UnitIsUnit(unit, "player") then
        -- Do nothing, GetInventoryItemLink should be able to return real values for current player
    elseif WCollections.Allowed and WCollections.Config.RestoreItemIcons.Inspect and UnitIsUnit(unit, "target") and GetUnitName("target") == WCollections.lastInspectTarget then
        local id = WCollections:GetItemTransmogCache(unit, slot).ID;
        if id and id ~= 0 then
            local link = oGetInventoryItemLink(unit, slot, ...);
            if not link then
                local _, link = GetItemInfo(id);
                return link;
            end
            local parts = { strsplit(":", link) };
            parts[2] = id;
            return table.concat(parts, ":");
        end
    end
    return oGetInventoryItemLink(unit, slot, ...);
end
]]
local oGetInventoryItemTexture = GetInventoryItemTexture;
WCollectionsGetInventoryItemTexture = function(unit, slot, ...)
    if WCollections.Allowed and WCollections.Config.RestoreItemIcons.Equipment and UnitIsUnit(unit, "player") then
        local id = GetInventoryItemID(unit, slot);
        if not id or id == 0 then return; end
        local texture = WCollections:GetSkinIcon(id);
        return texture or oGetInventoryItemTexture(unit, slot, ...);
    elseif WCollections.Allowed and WCollections.Config.RestoreItemIcons.Inspect and UnitIsUnit(unit, "target") and GetUnitName("target") == WCollections.lastInspectTarget then
        local id = WCollections:GetItemTransmogCache(unit, slot).ID or GetInventoryItemID(unit, slot);
        if not id or id == 0 then return; end
        local texture = WCollections:GetSkinIcon(id);
        if not texture and WCollections.missingInspectItems then
            table.insert(WCollections.missingInspectItems, id);
        end
        return texture or oGetInventoryItemTexture(unit, slot, ...);
    end
    return oGetInventoryItemTexture(unit, slot, ...);
end

if WCollections.Config.RestoreItemIcons.Global then
    GetInventoryItemTexture = WCollectionsGetInventoryItemTexture;
else
    if WCollections.Config.RestoreItemIcons.Equipment then
        hooksecurefunc("PaperDollItemSlotButton_Update", function(self)
            local textureName = WCollectionsGetInventoryItemTexture("player", self:GetID());
            local cooldown = _G[self:GetName().."Cooldown"];
            if ( textureName ) then
                SetItemButtonTexture(self, textureName);
                SetItemButtonCount(self, GetInventoryItemCount("player", self:GetID()));
                if ( GetInventoryItemBroken("player", self:GetID()) ) then
                    SetItemButtonTextureVertexColor(self, 0.9, 0, 0);
                    SetItemButtonNormalTextureVertexColor(self, 0.9, 0, 0);
                else
                    SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0);
                    SetItemButtonNormalTextureVertexColor(self, 1.0, 1.0, 1.0);
                end
                if ( cooldown ) then
                    local start, duration, enable = GetInventoryItemCooldown("player", self:GetID());
                    CooldownFrame_SetTimer(cooldown, start, duration, enable);
                end
                self.hasItem = 1;
            else
                local textureName = self.backgroundTextureName;
                if ( self.checkRelic and UnitHasRelicSlot("player") ) then
                    textureName = "Interface\\Paperdoll\\UI-PaperDoll-Slot-Relic.blp";
                end
                SetItemButtonTexture(self, textureName);
                SetItemButtonCount(self, 0);
                SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0);
                SetItemButtonNormalTextureVertexColor(self, 1.0, 1.0, 1.0);
                if ( cooldown ) then
                    cooldown:Hide();
                end
                self.hasItem = nil;
            end
        end);
    end
    if WCollections.Config.RestoreItemIcons.Inspect then
        function WCollectionsInspectHook(button)
            local unit = InspectFrame.unit;
            local textureName = WCollectionsGetInventoryItemTexture(unit, button:GetID());
            if ( textureName ) then
                SetItemButtonTexture(button, textureName);
                SetItemButtonCount(button, GetInventoryItemCount(unit, button:GetID()));
                button.hasItem = 1;
            else
                local textureName = button.backgroundTextureName;
                if ( button.checkRelic and UnitHasRelicSlot(unit) ) then
                    textureName = "Interface\\Paperdoll\\UI-PaperDoll-Slot-Relic.blp";
                end
                SetItemButtonTexture(button, textureName);
                SetItemButtonCount(button, 0);
                button.hasItem = nil;
            end
        end
        if InspectPaperDollItemSlotButton_Update then
            hooksecurefunc("InspectPaperDollItemSlotButton_Update", WCollectionsInspectHook);
        end
    end
end

if WCollections.Config.RestoreItemIcons.EquipmentManager then
    local _equippedItems = {};
    local _numItems;
    local _specialIcon;
    local _TotalItems;
    function RefreshEquipmentSetIconInfo()
        _numItems = 0;
        for i = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
            _equippedItems[i] = WCollectionsGetInventoryItemTexture("player", i);
            if(_equippedItems[i]) then
                _numItems = _numItems + 1;
                for j=INVSLOT_FIRST_EQUIPPED, (i-1) do
                    if(_equippedItems[i] == _equippedItems[j]) then
                        _equippedItems[i] = nil;
                        _numItems = _numItems - 1;
                        break;
                    end
                end
            end
        end
    end
    function GetEquipmentSetIconInfo(index)
        for i = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
            if (_equippedItems[i]) then
                index = index - 1;
                if ( index == 0 ) then
                    return _equippedItems[i], -i;
                end
            end
        end
        if(index>GetNumMacroIcons()) then
            return _specialIcon, index;
        end
        return GetMacroIconInfo(index), index;
    end
    function GearManagerDialogPopup_Update()
        RefreshEquipmentSetIconInfo();

        local popup = GearManagerDialogPopup;
        local buttons = popup.buttons;
        local offset = FauxScrollFrame_GetOffset(GearManagerDialogPopupScrollFrame) or 0;
        local button;
        -- Icon list
        local texture, index, button, realIndex;
        for i=1, NUM_GEARSET_ICONS_SHOWN do
            local button = buttons[i];
            index = (offset * NUM_GEARSET_ICONS_PER_ROW) + i;
            if ( index <= _TotalItems ) then
                texture, _ = GetEquipmentSetIconInfo(index);
                -- button.name:SetText(index); --dcw
                button.icon:SetTexture(texture);
                button:Show();
                if ( index == popup.selectedIcon ) then
                    button:SetChecked(1);
                elseif ( texture == popup.selectedTexture ) then
                    button:SetChecked(1);
                    popup:SetSelection(false, index);
                else
                    button:SetChecked(nil);
                end
            else
                button.icon:SetTexture("");
                button:Hide();
            end
        end
        -- Scrollbar stuff
        FauxScrollFrame_Update(GearManagerDialogPopupScrollFrame, ceil(_TotalItems / NUM_GEARSET_ICONS_PER_ROW) , NUM_GEARSET_ICON_ROWS, GEARSET_ICON_ROW_HEIGHT );
    end
    function RecalculateGearManagerDialogPopup()
        local popup = GearManagerDialogPopup;
        local selectedSet = GearManagerDialog.selectedSet;
        if ( selectedSet ) then
            popup:SetSelection(true, selectedSet.icon:GetTexture());
            local editBox = GearManagerDialogPopupEditBox;
            editBox:SetText(selectedSet.name);
            editBox:HighlightText(0);
        end
        RefreshEquipmentSetIconInfo();
        _TotalItems = GetNumMacroIcons() + _numItems;
        _specialIcon = nil;
        local texture;
        if(popup.selectedTexture) then
            local index = 1;
            local foundIndex = nil;
            for index=1, _TotalItems do
                texture, _ = GetEquipmentSetIconInfo(index);
                if ( texture == popup.selectedTexture ) then
                    foundIndex = index;
                    break;
                end
            end
            if (foundIndex == nil) then
                _specialIcon = popup.selectedTexture;
                _TotalItems = _TotalItems + 1;
                foundIndex = _TotalItems;
            else
                _specialIcon = nil;
            end
            local offsetnumIcons = floor((_TotalItems-1)/NUM_GEARSET_ICONS_PER_ROW);
            local offset = floor((foundIndex-1) / NUM_GEARSET_ICONS_PER_ROW);
            offset = offset + min((NUM_GEARSET_ICON_ROWS-1), offsetnumIcons-offset) - (NUM_GEARSET_ICON_ROWS-1);
            if(foundIndex<=NUM_GEARSET_ICONS_SHOWN) then
                offset = 0;
            end
            FauxScrollFrame_OnVerticalScroll(GearManagerDialogPopupScrollFrame, offset*GEARSET_ICON_ROW_HEIGHT, GEARSET_ICON_ROW_HEIGHT, nil);
        end
        GearManagerDialogPopup_Update();
    end
end

end

-- -------------------------------------------------------------------------------------
-- Inform the server that we're reloading UI and the addon might be disabled from now on
-- -------------------------------------------------------------------------------------
local oReloadUI = ReloadUI;
ReloadUI = function(...)
    if WCollections.Allowed then
        WCollections:SendAddonMessage("RELOADUI");
    end
    oReloadUI(...);
end

-- ---------------------------------
-- Add support for custom hyperlinks
-- ---------------------------------
local oChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow;
ChatFrame_OnHyperlinkShow = function(self, link, text, button, ...)
    if ( strsub(link, 1, 16) == "transmogillusion" ) then
        if ( IsModifiedClick("CHATLINK") ) then
            local _, sourceID = strsplit(":", link);
            local itemLink = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sourceID));
            HandleModifiedItemClick(itemLink);
        elseif not HandleModifiedItemClick(link) then
            DressUpTransmogLink(link);
        end
        return;
    elseif ( strsub(link, 1, 18) == "transmogappearance" ) then
        if ( IsModifiedClick("CHATLINK") ) then
            local _, sourceID = strsplit(":", link);
            local itemLink = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sourceID));
            HandleModifiedItemClick(itemLink);
        elseif IsModifiedClick("DRESSUP") then
            DressUpTransmogLink(link);
        else
            if ( not CollectionsJournal ) then
                CollectionsJournal_LoadUI();
            end
            if ( CollectionsJournal ) then
                WardrobeCollectionFrame_OpenTransmogLink(link);
            end
        end
        return;
    elseif ( strsub(link, 1, 13) == "item:0:outfit" ) then
        local sources, mainHandEnchant, offHandEnchant = C_TransmogCollection.GetItemTransmogInfoListFromOutfitHyperlink(link);
        if sources then
            if ( IsModifiedClick("CHATLINK") ) then
                local hyperlink = C_TransmogCollection.GetOutfitHyperlinkFromItemTransmogInfoList(sources, mainHandEnchant, offHandEnchant);
                if not ChatEdit_InsertLink(hyperlink) then
                    ChatFrame_OpenChat(hyperlink);
                end
            elseif DressUpSources then
                DressUpSources(sources, mainHandEnchant, offHandEnchant);
            else
                StaticPopup_Show("WCOLLECTIONS_ERROR", L["Popup.Error.DressUp.OutfitPreviewAddonDisabled"]);
            end
        else
            DEFAULT_CHAT_FRAME:AddMessage(TRANSMOG_OUTFIT_LINK_INVALID, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
        end
    elseif ( strsub(link, 1, 18) == "item:0:transmogset" ) then
        local setID = tonumber(link:match("^item:0:transmogset:(%d+)"));
        if setID then
            if ( IsModifiedClick("CHATLINK") ) then
                local hyperlink = C_TransmogSets.GetSetHyperlink(setID);
                if not ChatEdit_InsertLink(hyperlink) then
                    ChatFrame_OpenChat(hyperlink);
                end
            else
                if not CollectionsJournal:IsVisible() or not WardrobeCollectionFrame:IsVisible() then
                    ToggleCollectionsJournal(COLLECTIONS_JOURNAL_TAB_INDEX_APPEARANCES);
                end
                WardrobeCollectionFrame_SetTab(2);
                WardrobeCollectionFrame.SetsCollectionFrame:SelectSet(setID);
                WardrobeCollectionFrame.SetsCollectionFrame:ScrollToSet(C_TransmogSets.GetBaseSetID(setID));
            end
        end
    end
    return oChatFrame_OnHyperlinkShow(self, link, text, button, ...);
end

for _, chatMsg in ipairs({ "CHAT_MSG_BATTLEGROUND", "CHAT_MSG_BATTLEGROUND_LEADER", "CHAT_MSG_CHANNEL", "CHAT_MSG_EMOTE", "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING", "CHAT_MSG_SAY", "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_YELL" }) do
    ChatFrame_AddMessageEventFilter(chatMsg, WCollections.Callbacks.OnChatMessageEventFilter);
end

SlashCmdList["TRANSMOG_OUTFIT"] = function(msg)
    if DressUpSources then
        DressUpSources(TransmogUtil.ParseOutfitSlashCommand(msg));
    else
        StaticPopup_Show("WCOLLECTIONS_ERROR", L["Popup.Error.DressUp.OutfitPreviewAddonDisabled"]);
    end
end

-- ------------------------------------------------------------
-- Add extra lines to tooltips about collection-related objects
-- ------------------------------------------------------------
local function GetTooltipItem(tooltip)
    local name, link = tooltip:GetItem();
    if not link then return; end
    local _, id, _ = strsplit(":", link);
    if not id then return; end
    id = tonumber(id);
    if id == ITEM_BACK or id == ITEM_HIDDEN then return; end
    return id, name, link;
end

local function IsTooltipItemRecipe(tooltip, id)
    if not tooltip:GetName() then return false; end
    local dressable = WCollections:GetDressableFromRecipe(id);
    if dressable then
        if WCollections:GetEnchantFromScroll(dressable) then
            return false;
        end
        return true, dressable;
    end

    local line = _G[tooltip:GetName().."TextLeft"..1];
    if line and line:IsShown() and line:GetText() then
        local itemName = line:GetText();
        local productName = (itemName or ""):match(".-: (.+)");
        productName = productName and "\n"..productName:utf8lower();
        if productName then
            return WCollections:ForEachTooltipText(tooltip, function(line)
                if (line:GetText() or ""):utf8lower() == productName then
                    return true;
                end
            end);
        end
    end
    return false;
end

local function IsTooltipItemCollectible(tooltip)
    return not WCollections:ForEachTooltipText(tooltip, function(line)
        local text = line:GetText();
        if text and (text:match(FormatToPattern(ITEM_DURATION_SEC)) or
                     text:match(FormatToPattern(ITEM_DURATION_MIN)) or
                     text:match(FormatToPattern(ITEM_DURATION_HOURS)) or
                     text:match(FormatToPattern(ITEM_DURATION_DAYS))) then
            return true;
        end
    end);
end

local function TooltipHandlerItem(tooltip)
    if not WCollections.Allowed then return; end

    if WCollections:HasPendingTooltipInfo("SetToyByItemID") then return; end

    local id = GetTooltipItem(tooltip);
    if not id then return; end

    local isRecipe, productID = IsTooltipItemRecipe(tooltip, id);
    if isRecipe and not tooltip.WCollectionsAwaitingRecipe then
        tooltip.WCollectionsAwaitingRecipe = true;
        if productID then
            id = productID;
        else
            return;
        end
    else
        tooltip.WCollectionsAwaitingRecipe = nil;
    end

    local show = false;
    if WCollections.Config.TooltipSets.Collected   and WCollections:IsSkinSource(id) == true and WCollections:HasSkin(id) == true
    or WCollections.Config.TooltipSets.Uncollected and WCollections:IsSkinSource(id) == true and WCollections:HasSkin(id) == false then
        if CollectionWardrobeUtil.AddSourceSetsToTooltip(tooltip, id) then
            show = true;
        end
    end
    local color = WCollections.Config.TooltipCollection.Color;
    local separator = not WCollections.Config.TooltipCollection.Separator;
    if WCollections.Config.TooltipCollection.OwnedItems and WCollections:HasOwnedItem(id) == false then
        if not separator then separator = true; tooltip:AddLine(" "); end
        tooltip:AddLine(L["Tooltip.OwnedItems"], color.r, color.g, color.b, false);
        show = true;
    end
    if WCollections.Config.TooltipCollection.Skins and WCollections:IsSkinSource(id) == true and WCollections:HasSkin(id) == false and IsTooltipItemCollectible(tooltip) then
        if not separator then separator = true; tooltip:AddLine(" "); end
        tooltip:AddLine(L["Tooltip.Skins"], color.r, color.g, color.b, false);
        show = true;
    end
    if WCollections:IsActiveMountSubscription() or WCollections:IsActivePetSubscription() then
        for i = 1, 20 do
            local line = _G[tooltip:GetName().."TextLeft"..i];
            if line and line:IsShown() and line:GetText() == ITEM_SPELL_KNOWN and IsSameColor(1, 0.125, 0.125, line:GetTextColor()) then
                local mount = id and WCollections:GetMountIDByItem(id);
                local pet = id and WCollections:GetPetIDByItem(id);
                if mount and WCollections:HasAvailableMount(mount) and not WCollections:HasMount(mount)
                or pet and WCollections:HasAvailablePet(pet) and not WCollections:HasPet(pet) then
                    line:SetText(L["Tooltip.SubscriptionLearned"]);
                    show = true;
                    break;
                end
            end
        end
    end
    if WCollections.Config.TooltipCollection.Toys or WCollections.Config.TooltipCollection.ToyUnlock and tooltip:GetName() then
        local toyID = WCollections:GetToyIDByItem(id);
        if toyID then
            if WCollections.Config.TooltipCollection.ToyUnlock and WCollections.Config.TooltipCollection.ToyUnlockEmbed and WCollections:HasToy(toyID) == false then
                local anyLine, useLine, replacementText;
                for i = 1, 20 do
                    local line = _G[tooltip:GetName().."TextLeft"..i];
                    if line and line:IsShown() and line:GetText() and line:GetText() ~= "" and line:GetText() ~= " " then
                        local text = line:GetText();
                        local r, g, b = line:GetTextColor();
                        if IsSameColor(r, g, b, 0, 1, 0) then
                            local s, e = text:find(ITEM_SPELL_TRIGGER_ONUSE);
                            local prefix = ITEM_TOY_ONUSE;
                            if s == 1 and e then
                                useLine = useLine or line;
                                replacementText = format("%s|n|n%s", prefix, text:sub(e + 2));
                                break;
                            else
                                s, e = text:find(ITEM_SPELL_TRIGGER_ONEQUIP);
                                prefix = prefix:gsub(ITEM_SPELL_TRIGGER_ONUSE, ITEM_SPELL_TRIGGER_ONEQUIP);
                                if s == 1 and e then
                                    anyLine = anyLine or line;
                                    replacementText = format("%s|n|n%s", prefix, text:sub(e + 2));
                                end
                            end
                        end
                    end
                end
                local line = useLine or anyLine;
                if line then
                    line:SetText(replacementText);
                    show = true;
                end
            end
            if WCollections.Config.TooltipCollection.ToyUnlock and not WCollections.Config.TooltipCollection.ToyUnlockEmbed and WCollections:HasToy(toyID) == false then
                if not separator then separator = true; tooltip:AddLine(" "); end
                tooltip:AddLine(L["Tooltip.Toys"], color.r, color.g, color.b, false);
            end
            if WCollections.Config.TooltipCollection.Toys then
                local line = _G[tooltip:GetName().."TextLeft2"];
                if line and line:IsShown() and line:GetText()then
                    line:SetText(format("|cFF88AAFF%s|r|n%s", TOY, line:GetText()));
                    show = true;
                end
            end
        end
    end
    if show then
        tooltip:Show();
    end
end
local function TooltipHandlerClear(tooltip)
    WCollections.itemUnderCursor.ID = nil;
    WCollections.itemUnderCursor.Bag = nil;
    WCollections.itemUnderCursor.Slot = nil;
end
local function TooltipHandlerHyperlink(tooltip, link)
    if not WCollections.Allowed then return; end

    local linkType, linkData = strsplit(":", link);
    if linkType == "quest" then
        local id = tonumber((linkData));

        local show = false;
        local color = WCollections.Config.TooltipCollection.Color;
        local separator = not WCollections.Config.TooltipCollection.Separator;
        if WCollections.Config.TooltipCollection.TakenQuests and WCollections:HasTakenQuest(id) == false then
            if not separator then separator = true; tooltip:AddLine(" "); end
            tooltip:AddLine(L["Tooltip.TakenQuests"], color.r, color.g, color.b, false);
            show = true;
        elseif WCollections.Config.TooltipCollection.RewardedQuests and WCollections:HasRewardedQuest(id) == false then
            if not separator then separator = true; tooltip:AddLine(" "); end
            tooltip:AddLine(L["Tooltip.RewardedQuests"], color.r, color.g, color.b, false);
            show = true;
        end
        if show then
            tooltip:Show();
        end
    end
end
local function TooltipHandlerInventory(tooltip, ...)
    if not WCollections.Allowed then return; end

    local id = GetTooltipItem(tooltip);
    if not id then return; end

    if WCollections:IsSkinSource(id) == true then
        local show = false;

        local unit, bag, slot;
        if type(select(1, ...)) == "string" then
            unit, bag = ...;
        else
            unit = "player";
            bag, slot = ...;
        end

        local hasPendingUndo, pendingEntry, hasPendingIllusionUndo, pendingEnchant = WCollections:GetPendingTooltipInfo("SetTransmogrifyItem");

        if WCollections.Config.TooltipTransmog.Enable or WCollections.Config.TooltipFlags.Enable then
            local fakeEntry, fakeEnchantName, fakeEnchant, flags, fakeEntryDeactivated = WCollections:GetItemTransmog(unit, bag, slot);
            if pendingEntry or pendingEnchant then
                if pendingEntry and pendingEntry ~= 0 then
                    fakeEntry = pendingEntry;
                    fakeEntryDeactivated = false;
                end
                if pendingEnchant and pendingEnchant ~= 0 then
                    fakeEnchant = pendingEnchant;
                    fakeEnchantName = select(2, GetItemInfo(fakeEnchant));
                    if fakeEnchantName then
                        fakeEnchantName = WCollections:TransformEnchantName(fakeEnchantName);
                    else
                        fakeEnchantName = L["Tooltip.Transmog.Loading"];
                    end
                end
            end
            local prefixText = "";
            local text = "";
            if WCollections.Config.TooltipFlags.Enable then
                local color = WCollections.Config.TooltipFlags.Color;
                local colorHex = "|cFF"..RGBPercToHex(color.r, color.g, color.b);
                if flags and flags ~= "" then
                    prefixText = prefixText..(#prefixText > 0 and "|n" or "")..colorHex..flags.."|r";
                    if not WCollections.hasCosmeticItems and flags:find(ITEM_COSMETIC, 1, true) then
                        WCollections.hasCosmeticItems = true;
                    end
                end
            end
            if WCollections.Config.TooltipTransmog.Enable then
                local color = WCollections.Config.TooltipTransmog.Color;
                local colorHex = "|cFF"..RGBPercToHex(color.r, color.g, color.b);
                if fakeEntry and fakeEntry ~= 0 or hasPendingUndo then
                    if hasPendingUndo then
                        text = text..colorHex..TRANSMOGRIFY_TOOLTIP_REVERT.."|r";
                    else
                        if pendingEntry or pendingEnchant then
                            text = text..colorHex..WILL_BE_TRANSMOGRIFIED_HEADER.."|r";
                        else
                            text = text..colorHex..TRANSMOGRIFIED_HEADER.."|r";
                        end
                        local name = GetItemInfo(fakeEntry);
                        local texture = WCollections:GetSkinIcon(fakeEntry);
                        if fakeEntry == ITEM_HIDDEN then
                            local slot = slot;
                            if not slot then
                                slot = bag;
                            else
                                slot = nil;
                                local info = WCollections:GetSkinInfo(id);
                                if info and info.InventoryType then
                                    slot = C_Transmog.GetSlotForInventoryType(info.InventoryType);
                                else
                                    local invType = select(9, GetItemInfo(id));
                                    invType = invType and WCollections.InvTypeNameToEnum[invType];
                                    if invType then
                                        slot = C_Transmog.GetSlotForInventoryType(invType);
                                    end
                                end
                            end
                            name = WCollections:GetHiddenVisualItemName(slot);
                            texture = [[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]];
                        end
                        if not name or not texture then
                            name = "|cFFFF0000"..RETRIEVING_ITEM_INFO.."|r";
                            texture = [[Interface\Icons\INV_Misc_QuestionMark]];
                            WCollections:QueryItem(fakeEntry);
                        end
                        local size = WCollections.Config.TooltipTransmog.IconEntry.Size or 0;
                        local crop = WCollections.Config.TooltipTransmog.IconEntry.Crop and ":0:0:64:64:6:58:6:58" or "";
                        if fakeEntry == ITEM_HIDDEN and WCollections.Config.TooltipTransmog.NewHideVisualIcon then
                            texture = [[Interface\AddOns\WCollections\Interface\Transmogrify\Transmogrify]];
                            crop = ":0:0:512:512:417:443:90:116";
                        end
                        local icon = WCollections.Config.TooltipTransmog.IconEntry.Enable and ("|T"..texture..":"..size..":"..size..crop.."|t ") or "";
                        text = text.."|n"..colorHex..icon..format(L[fakeEntryDeactivated and "Tooltip.Transmog.EntryFormat.Deactivated" or "Tooltip.Transmog.EntryFormat"], name).."|r";
                    end
                end
                if fakeEnchant and fakeEnchant ~= 0 or hasPendingIllusionUndo then
                    local scroll = WCollections:GetScrollFromEnchant(fakeEnchant);
                    local texture = scroll and WCollections:GetSkinIcon(scroll);
                    if not texture then
                        texture = [[Interface\AddOns\WCollections\Textures\EnchantIcon]]; -- [[Interface\Icons\INV_Scroll_05]]
                    end
                    local size = WCollections.Config.TooltipTransmog.IconEnchant.Size or 0;
                    local crop = WCollections.Config.TooltipTransmog.IconEnchant.Crop and ":0:0:64:64:6:58:6:58" or "";
                    if fakeEnchant == ENCHANT_HIDDEN and WCollections.Config.TooltipTransmog.NewHideVisualIcon then
                        texture = [[Interface\AddOns\WCollections\Interface\Transmogrify\Transmogrify]];
                        crop = ":0:0:512:512:417:443:90:116";
                    end
                    local icon = WCollections.Config.TooltipTransmog.IconEnchant.Enable and ("|T"..texture..":"..size..":"..size..crop.."|t ") or "";
                    text = text..(#text > 0 and "|n" or "")..colorHex..icon..format(L["Tooltip.Transmog.EnchantFormat"], hasPendingIllusionUndo and TRANSMOGRIFY_TOOLTIP_REVERT or fakeEnchantName).."|r";
                end
            end
            if text ~= "" then
                for i = 2,3 do
                    local line = _G[tooltip:GetName().."TextLeft"..i];
                    if line and line:GetText() and line:GetText():match(ITEM_LEVEL) then
                        line:SetText(line:GetText().."|n"..text);
                        line:SetNonSpaceWrap(false);
                        show = true;
                        break;
                    end
                end
                if not show then
                    for i = 2,5 do
                        local line = _G[tooltip:GetName().."TextLeft"..i];
                        if line and line:GetText() and not line:GetText():match(ITEM_HEROIC) and not line:GetText():match(ITEM_HEROIC_EPIC) then
                            line:SetText(text.."|n"..line:GetText());
                            line:SetNonSpaceWrap(false);
                            show = true;
                            break;
                        end
                    end
                end
            end
            if prefixText ~= "" then
                for i = 2, 2 do
                    local line = _G[tooltip:GetName().."TextLeft"..i];
                    if line and line:GetText() then
                        line:SetText(prefixText.."|n"..line:GetText());
                        line:SetNonSpaceWrap(false);
                        show = true;
                        break;
                    end
                end
            end
        end

        if WCollections.Config.TooltipCollection.SkinUnlock and unit == "player" and WCollections:HasSkin(id) == false and IsTooltipItemCollectible(tooltip) then
            local color = WCollections.Config.TooltipCollection.Color;
            local text;
            if GetBindingKey("WCOLLECTIONS_UNLOCK_SKIN") then
                text = format(L["Tooltip.UnlockSkin.Binding"], table.concat({ GetBindingKey("WCOLLECTIONS_UNLOCK_SKIN") }, L["Tooltip.UnlockSkin.Binding.Separator"]));
            else
                text = format(L["Tooltip.UnlockSkin.Command"], WCollections.UnlockSkinHintCommand);
            end
            tooltip:AddLine(text, color.r * 0.75, color.g * 0.75, color.b * 0.75, false);
            WCollections.itemUnderCursor.ID = id;
            WCollections.itemUnderCursor.Bag = bag;
            WCollections.itemUnderCursor.Slot = slot;
            show = true;
        end

        if (WCollections.Config.RestoreItemSets.Equipment and unit == "player" or WCollections.Config.RestoreItemSets.Inspect and UnitIsUnit(unit, "target") and GetUnitName("target") == WCollections.lastInspectTarget) and bag >= 1 and bag <= 19 then
            for i = 1, 30 do
                local line = _G[tooltip:GetName().."TextLeft"..i];
                local line2 = _G[tooltip:GetName().."TextLeft"..(i+1)];
                local line3 = _G[tooltip:GetName().."TextLeft"..(i+2)];
                if line and line:GetText() and line:GetText() ~= " " and not line:GetText():match("|c") and IsSameColor(1, 0.8235, 0, line:GetTextColor()) and
                   line2 and line2:GetText() and line2:GetText() ~= " " and not line2:GetText():match("|c") and (IsSameColor(0.5, 0.5, 0.5, line2:GetTextColor()) or IsSameColor(1, 1, 0.5922, line2:GetTextColor())) and
                   line3 and line3:GetText() and line3:GetText() ~= " " and not line3:GetText():match("|c") and (IsSameColor(0.5, 0.5, 0.5, line3:GetTextColor()) or IsSameColor(1, 1, 0.5922, line3:GetTextColor())) then
                    local data = WCollections:GetItemSetData(unit, id);
                    local setName, count, max = line:GetText():match(FormatToPattern(ITEM_SET_NAME));
                    if not data or not setName or not count or not max or not tonumber(max) or tonumber(max) == 0 then break; end
                    line:SetText(ITEM_SET_NAME:format(setName, data.EquippedItemCount, tonumber(max)));
                    for index, item in ipairs(data.SetItems) do
                        i = i + 1;
                        line = _G[tooltip:GetName().."TextLeft"..i];
                        if not line or line:GetText() == " " then -- Can happen if items are still caching
                            i = i - 1;
                            break;
                        end
                        if data.EquippedItems[index] then
                            line:SetTextColor(1, 1, 0x97 / 0xFF, 1); -- Hardcoded in .exe
                        else
                            line:SetTextColor(0.5, 0.5, 0.5, 1); -- Hardcoded in .exe
                        end
                        if data.EquippedItemNames[index] then
                            line:SetText(("  %s"):format(data.EquippedItemNames[index])); -- Hardcoded in .exe
                        end
                    end
                    i = i + 1;
                    line = _G[tooltip:GetName().."TextLeft"..i];
                    if line and line:GetText() == " " then
                        for index, threshold in ipairs(data.SetSpellThresholds) do
                            i = i + 1;
                            line = _G[tooltip:GetName().."TextLeft"..i];
                            local _, description = line:GetText():match(FormatToPattern(ITEM_SET_BONUS_GRAY));
                            if not description then
                                description = line:GetText():match(FormatToPattern(ITEM_SET_BONUS));
                            end
                            if description then
                                if data.EquippedItemCount >= threshold then
                                    line:SetFormattedText(ITEM_SET_BONUS, description);
                                    line:SetTextColor(0, 1, 0, 1); -- Hardcoded in .exe
                                else
                                    line:SetFormattedText(ITEM_SET_BONUS_GRAY, threshold, description);
                                    line:SetTextColor(0.5, 0.5, 0.5, 1); -- Hardcoded in .exe
                                end
                            end
                        end
                    end
                    break;
                end
            end
        end

        if show then
            tooltip:Show();
        end
    end
end

CreateFrame("Frame", ADDON_NAME.."TooltipHooker", UIParent):SetScript("OnUpdate", function(self, ...)
    local tooltips =
    {
        -- Game's own tooltips
        GameTooltip, ItemRefTooltip,
        -- Tooltips from other addons (feel free to add yours)
        AtlasLootTooltip, AtlasQuestTooltip, LightHeadedTooltip, MobMapTooltip, PWTooltip,
    };
    for k, tooltip in pairs(tooltips) do
        if tooltip then
            tooltip:HookScript("OnTooltipSetItem", TooltipHandlerItem);
            tooltip:HookScript("OnTooltipCleared", TooltipHandlerClear);
            hooksecurefunc(tooltip, "SetHyperlink", TooltipHandlerHyperlink);
            hooksecurefunc(tooltip, "SetInventoryItem", TooltipHandlerInventory);
            hooksecurefunc(tooltip, "SetBagItem", TooltipHandlerInventory);
        end
    end
    self:SetScript("OnUpdate", nil);
end);
