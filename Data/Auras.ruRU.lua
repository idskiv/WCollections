-- Load localization only if it matches the client locale
if GetLocale() ~= "ruRU" then
    return;
end

WCollections.AurasTemplate = 
{
    -- Жуткий лутбокс 2019
    [22581] = {"spells\\focusedcasting_state_chest.mdx", "|cFFFFD200Источник: |rЖуткий лутбокс 2019"},
    [33342] = {"spells\\creature_spellportal_purple.mdx", "|cFFFFD200Источник: |rЖуткий лутбокс 2019"},
    [36542] = {"Spells\\Sap_State_Head.mdx", "|cFFFFD200Источник: |rЖуткий лутбокс 2019"},
    [65630] = {"spells\\druid_starfallstate.mdx", "|cFFFFD200Источник: |rЖуткий лутбокс 2019"},
    [65712] = {"interface\\buttons\\talktomequestion_ltblue.m2", "|cFFFFD200Источник: |rЖуткий лутбокс 2019"},
    [69663] = {"spells\\skull.mdx", "|cFFFFD200Источник: |rЖуткий лутбокс 2019"},
    [70788] = {"world\\generic\\passivedoodads\\particleemitters\\aurayellowshort.mdx", "|cFFFFD200Источник: |rЖуткий лутбокс 2019"},
    [72523] = {"spells\\shadowmourne_cast_high.mdx", "|cFFFFD200Источник: |rЖуткий лутбокс 2019"},
    [31796] = {"Spells\\Crow_Baked.mdx", "|cFFFFD200Источник: |rЛЖуткий лутбокс 2019"},

    -- Солнечный лутбокс 2021
    [44885] = {"Spells\\Nature_Precast_Chest.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)"},
    [40159] = {"creature\\questobjects\\creature_powercrystal.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)"},
    [36952] = {"spells\\endlessrage_state_head.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)"},
    [70504] = {"spells\\banish_chest_blue.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)"},
    [66625] = {"Spells\\LightningStorm_CloudLow_State.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)"},
    [56572] = {"Spells\\Shadow_Snare_High_base.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)"},
    [43452] = {"spells\\SmokeFlare_White.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)"},
    [42726] = {"world\\lordaeron\\stratholme\\passivedoodads\\fx\\stratholmefiresmokeembers.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)"},
    [42466] = {"spells\\steam.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)"},
    [56274] = {"World\\Generic\\PVP\\Fires\\LowPolyFireAnim.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)"},
    [72209] = {"Spells\\Demolisher_Missile_Blue.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021"},

    -- Эпический лутбокс 2021-2022
    [67549] = {"spells\\Ulduar_BlackHole_H.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)"},
    [75230] = {"Spells\\Shadow_Precast_Low_Hand.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)"},
    [71994] = {"interface\\buttons\\talktomequestion_ltblue.m2", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)"},
    [68302] = {"spells\\burrowearth_brown_missile_v2.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)"},
    [64785] = {"interface\\buttons\\talktomequestion_ltblue.m2", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)"},
    [63893] = {"Spells\\Nature_Precast_Chest.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)"},
    [62641] = {"Spells\\ChainLightning_Impact_Chest.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)"},
    [63096] = {"spells\\diseasecloud.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)"},
    [62398] = {"Spells\\MightAura_Impact_Base.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)"},
    [62300] = {"spells\\nefarian_state_base.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)"},
    [57630] = {"Spells\\RitualSummoning_PreCast_Base.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)"},
    [57551] = {"spells\\shadowdance_state.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)"},
    [48795] = {"Spells\\FaerieFire_NoGlow.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)"},
    [70571] = {"spells\\holyzone.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022"},
    [69859] = {"Spells\\WellOfSouls_Base.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022"},

    -- Сокровище Гринча 2022-2023
    [36193] = {"spells\\missile_sawblade.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023"},
    [46423] = {"spells\\SnowballPowdery_Impact_Base.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023"},
    [56327] = {"interface\\buttons\\talktomequestion_ltblue.m2", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023"},
    [49310] = {"spells\\floatingmine.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023"},
    [70763] = {"interface\\buttons\\talktomequestion_ltblue.m2", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023"},
    [70573] = {"Spells\\Arcane_Form_Precast.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023"},
    [66763] = {"Spells\\ArcaneForceShield_Green.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023"},
    [71947] = {"interface\\buttons\\talktomequestion_ltblue.m2", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023"},
    [57901] = {"spells\\giftofnaaru.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023"},
    [62348] = {"spells\\Ritual_Arcane_PreCast_Base.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023"},
    [71986] = {"interface\\buttons\\talktomequestion_ltblue.m2", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023"},
    [68802] = {"spells\\SandVortex_State_Base.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023"},
    [62639] = {"spells\\warrior_bladestorm.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023"},
    [61236] = {"spells\\instancenewportal_blue_arcane.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023"},
    [57687] = {"spells\\instancenewportal_blue_arcane.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023"},
    [54141] = {"spells\\mage_arcanebarrage_impact.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023"},
    [49311] = {"spells\\arcanebomb_missle.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023"},
    [68855] = {"interface\\buttons\\talktomequestion_ltblue.m2", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023"},

    -- ПвЕ ладдер
    [69144] = {"Spells\\Shadow_Precast_Med_Base.mdx", "|cFFFFD200Источник: |rПвЕ ладдер"},
    [73572] = {"interface\\buttons\\talktomequestion_ltblue.m2", "|cFFFFD200Источник: |rПвЕ ладдер"},
    [56075] = {"Spells\\fireforceshield_purple.mdx", "|cFFFFD200Источник: |rПвЕ ладдер"},
    [47705] = {"Spells\\Fire_Form_Precast.mdx", "|cFFFFD200Источник: |rПвЕ ладдер"},
    [47503] = {"Spells\\Corruption_ImpactDot_Med_Base.mdx", "|cFFFFD200Источник: |rПвЕ ладдер"},

    -- За 1 место РБГ
    [73572] = {"spells\\SnowballPowdery_Impact_Base.mdx", "|cFFFFD200Источник: |rЗа 1 место РБГ"},

    -- За определенное количество баг-репортов
    [40158] = {"Spells\\ShellShield_State_Base.mdx", "|cFFFFD200Источник: |rЗа определенное количество баг-репортов"},

    -- Бусты в дискорде
    [74621] = {"spells\\forceshield_andxplosion.mdx", "|cFFFFD200Источник: |rБусты в дискорде"},
    [70970] = {"Spells\\Shadowbolt_Chest_Impact.mdx", "|cFFFFD200Источник: |rБусты в дискорде"},

    -- За участие в бета-тестах
    [72100] = {"spells\\baseflagcapred_impact_base.mdx", "|cFFFFD200Источник: |rЗа участие в бета-тестах"},
};
