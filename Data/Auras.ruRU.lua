-- Load localization only if it matches the client locale
if GetLocale() ~= "ruRU" then
    return;
end

WCollections.AurasTemplate = 
{
    -- Жуткий лутбокс 2019
    [22581] = {"spells\\focusedcasting_state_chest.mdx", "|cFFFFD200Источник: |rЖуткий лутбокс 2019", 0, 0, 0},
    [33342] = {"spells\\creature_spellportal_purple.mdx", "|cFFFFD200Источник: |rЖуткий лутбокс 2019", 0, 0, 0},
    [36542] = {"Spells\\Sap_State_Head.mdx", "|cFFFFD200Источник: |rЖуткий лутбокс 2019", 0, 0, 0},
    [65630] = {"spells\\druid_starfallstate.mdx", "|cFFFFD200Источник: |rЖуткий лутбокс 2019", 0, 0, 0},
    [65712] = {"interface\\buttons\\talktomequestion_ltblue.m2", "|cFFFFD200Источник: |rЖуткий лутбокс 2019", 0, 0, 0},
    [69663] = {"spells\\skull.mdx", "|cFFFFD200Источник: |rЖуткий лутбокс 2019", 0, 0, 0},
    [70788] = {"world\\generic\\passivedoodads\\particleemitters\\aurayellowshort.mdx", "|cFFFFD200Источник: |rЖуткий лутбокс 2019", 0, 0, 0},
    [72523] = {"spells\\shadowmourne_cast_high.mdx", "|cFFFFD200Источник: |rЖуткий лутбокс 2019", 0, 0, 0},
    [31796] = {"Spells\\Crow_Baked.mdx", "|cFFFFD200Источник: |rЖуткий лутбокс 2019", 0, 0, 0},

    -- Солнечный лутбокс 2021
    [44885] = {"Spells\\Nature_Precast_Chest.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)", 0, 0, 0},
    [40159] = {"creature\\questobjects\\creature_powercrystal.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)", 0, 0, 0},
    [36952] = {"spells\\endlessrage_state_head.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)", 0, 0, 0},
    [70504] = {"spells\\banish_chest_blue.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)", 0, 0, 0},
    [66625] = {"Spells\\LightningStorm_CloudLow_State.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)", 0, 0, 0},
    [56572] = {"Spells\\Shadow_Snare_High_base.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)", 0, 0, 0},
    [43452] = {"spells\\SmokeFlare_White.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)", 0, 0, 0},
    [42726] = {"world\\lordaeron\\stratholme\\passivedoodads\\fx\\stratholmefiresmokeembers.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)", 0, 0, 0},
    [42466] = {"spells\\steam.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)", 0, 0, 0},
    [56274] = {"World\\Generic\\PVP\\Fires\\LowPolyFireAnim.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021, Ларец Душ(Особые задания)", 0, 0, 0},
    [72209] = {"Spells\\Demolisher_Missile_Blue.mdx", "|cFFFFD200Источник: |rСолнечный лутбокс 2021", 0, 0, 0},

    -- Эпический лутбокс 2021-2022
    [67549] = {"spells\\Ulduar_BlackHole_H.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)", 0, 0, 0},
    [75230] = {"Spells\\Shadow_Precast_Low_Hand.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)", 0, 0, 0},
    [71994] = {"interface\\buttons\\talktomequestion_ltblue.m2", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)", 0, 0, 0},
    [68302] = {"spells\\burrowearth_brown_missile_v2.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)", 0, 0, 0},
    [64785] = {"interface\\buttons\\talktomequestion_ltblue.m2", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)", 0, 0, 0},
    [63893] = {"Spells\\Nature_Precast_Chest.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)", 0, 0, 0},
    [62641] = {"Spells\\ChainLightning_Impact_Chest.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)", 0, 0, 0},
    [63096] = {"spells\\diseasecloud.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)", 0, 0, 0},
    [62398] = {"Spells\\MightAura_Impact_Base.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)", 0, 0, 0},
    [62300] = {"spells\\nefarian_state_base.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)", 0, 0, 0},
    [57630] = {"Spells\\RitualSummoning_PreCast_Base.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)", 0, 0, 0},
    [57551] = {"spells\\shadowdance_state.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)", 0, 0, 0},
    [48795] = {"Spells\\FaerieFire_NoGlow.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022, Ларец Душ(Особые задания)", 0, 0, 0},
    [70571] = {"spells\\holyzone.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022", 0, 0, 0},
    [69859] = {"Spells\\WellOfSouls_Base.mdx", "|cFFFFD200Источник: |rЭпический лутбокс 2021-2022", 0, 0, 0},

    -- Сокровище Гринча 2022-2023
    [36193] = {"spells\\missile_sawblade.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023", 0, 0, 0},
    [46423] = {"spells\\SnowballPowdery_Impact_Base.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023", 0, 0, 0},
    [56327] = {"interface\\buttons\\talktomequestion_ltblue.m2", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023", 0, 0, 0},
    [49310] = {"spells\\floatingmine.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023", 0, 0, 0},
    [70763] = {"interface\\buttons\\talktomequestion_ltblue.m2", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023", 0, 0, 0},
    [70573] = {"Spells\\Arcane_Form_Precast.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023", 0, 0, 0},
    [66763] = {"Spells\\ArcaneForceShield_Green.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023", 0, 0, 0},
    [71947] = {"interface\\buttons\\talktomequestion_ltblue.m2", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023", 0, 0, 0},
    [57901] = {"spells\\giftofnaaru.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023", 0, 0, 0},
    [62348] = {"spells\\Ritual_Arcane_PreCast_Base.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023", 0, 0, 0},
    [71986] = {"interface\\buttons\\talktomequestion_ltblue.m2", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023", 0, 0, 0},
    [68802] = {"spells\\SandVortex_State_Base.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023", 0, 0, 0},
    [62639] = {"spells\\warrior_bladestorm.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023", 0, 0, 0},
    [61236] = {"spells\\instancenewportal_blue_arcane.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023", 0, 0, 0},
    [57687] = {"spells\\instancenewportal_blue_arcane.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023", 0, 0, 0},
    [54141] = {"spells\\mage_arcanebarrage_impact.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023", 0, 0, 0},
    [49311] = {"spells\\arcanebomb_missle.mdx", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023", 0, 0, 0},
    [68855] = {"interface\\buttons\\talktomequestion_ltblue.m2", "|cFFFFD200Источник: |rСокровище Гринча 2022-2023", 0, 0, 0},

    -- ПвЕ ладдер
    [69144] = {"Spells\\Shadow_Precast_Med_Base.mdx", "|cFFFFD200Источник: |rПвЕ ладдер", 0, 0, 0},
    [73572] = {"interface\\buttons\\talktomequestion_ltblue.m2", "|cFFFFD200Источник: |rПвЕ ладдер", 0, 0, 0},
    [56075] = {"Spells\\fireforceshield_purple.mdx", "|cFFFFD200Источник: |rПвЕ ладдер", 0, 0, 0},
    [47705] = {"Spells\\Fire_Form_Precast.mdx", "|cFFFFD200Источник: |rПвЕ ладдер", 0, 0, 0},
    [47503] = {"Spells\\Corruption_ImpactDot_Med_Base.mdx", "|cFFFFD200Источник: |rПвЕ ладдер", 0, 0, 0},

    -- За 1 место РБГ
    [73572] = {"spells\\SnowballPowdery_Impact_Base.mdx", "|cFFFFD200Источник: |rЗа 1 место РБГ", 0, 0, 0},

    -- За определенное количество баг-репортов
    [40158] = {"Spells\\ShellShield_State_Base.mdx", "|cFFFFD200Источник: |rЗа определенное количество баг-репортов", 0, 0, 0},

    -- Бусты в дискорде
    [74621] = {"spells\\forceshield_andxplosion.mdx", "|cFFFFD200Источник: |rБусты в дискорде", 0, 0, 0},
    [70970] = {"Spells\\Shadowbolt_Chest_Impact.mdx", "|cFFFFD200Источник: |rБусты в дискорде", 0, 0, 0},

    -- За участие в бета-тестах
    [72100] = {"spells\\baseflagcapred_impact_base.mdx", "|cFFFFD200Источник: |rЗа участие в бета-тестах", 0, 0, 0},
};
