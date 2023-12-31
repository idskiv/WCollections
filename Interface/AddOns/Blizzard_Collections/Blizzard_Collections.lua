COLLECTIONS_FANFARE_ICON = "Interface/Icons/Item_Shop_GiftBox01";
COLLECTIONS_FANFARE_DISPLAY_ID = 71933;

function CollectionsJournal_SetTab(self, tab)
	PanelTemplates_SetTab(self, tab);
	WCollections:SetCVar("petJournalTab", tab);
	CollectionsJournal_UpdateSelectedTab(self);
	CollectionsJournalPortraitButton:UpdateVisibility();
	WardrobeFramePortraitButton:UpdateVisibility();
end

local function ShouldShowHeirloomTabHelpTip()
	if WCollections:GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_HEIRLOOM_JOURNAL_TAB) or IsKioskModeEnabled() then
		return false;
	end

	if PetJournal_HelpPlate and HelpPlate_IsShowing(PetJournal_HelpPlate) then
		return false;
	end

	return C_Heirloom.ShouldShowHeirloomHelp();
end

local function ShouldShowWardrobeTabHelpTip()
	if WCollections:GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_JOURNAL_TAB) or IsKioskModeEnabled() then
		return false;
	end

	if PetJournal_HelpPlate and HelpPlate_IsShowing(PetJournal_HelpPlate) then
		return false;
	end

	if CollectionsJournal.HeirloomTabHelpBox:IsShown() then
		return false;
	end

	return true;
end

function CollectionsJournal_ValidateTab(tabNum)
	return true;
end

function CollectionsJournal_UpdateSelectedTab(self)
	local selected = PanelTemplates_GetSelectedTab(self);

	if (not CollectionsJournal_ValidateTab(selected)) then
		PanelTemplates_SetTab(self, 1);
		selected = 1;
	end
	
	NewsJournal:SetShown(selected == 1);
	MountJournal:SetShown(selected == 2);
	AurasJournal:SetShown(selected == 3);
	PetJournal:SetShown(selected == 4);
	ToyBox:SetShown(selected == 5);
	--HeirloomsJournal:SetShown(selected == 6);
	-- don't touch the wardrobe frame if it's used by the transmogrifier
	if ( WardrobeCollectionFrame:GetParent() == self or not WardrobeCollectionFrame:GetParent():IsShown() ) then
		if ( selected == 6 ) then
			HideUIPanel(WardrobeFrame);
			WardrobeCollectionFrame_SetContainer(self);
		else
			WardrobeCollectionFrame:Hide();
		end
	end

	if ( selected == 1 ) then
		CollectionsJournalTitleText:SetText(NEWS);
	elseif ( selected == 2 ) then
		CollectionsJournalTitleText:SetText(MOUNTS);
	elseif ( selected == 3 ) then
		CollectionsJournalTitleText:SetText(AURAS);
	elseif (selected == 4 ) then
		CollectionsJournalTitleText:SetText(COMPANIONS);
	elseif (selected == 5 ) then
		CollectionsJournalTitleText:SetText(TOY_BOX);
	elseif (selected == 6 ) then
		CollectionsJournalTitleText:SetText(WARDROBE);
	end

	--self.HeirloomTabHelpBox:SetShown(ShouldShowHeirloomTabHelpTip());
	--self.WardrobeTabHelpBox:SetShown(ShouldShowWardrobeTabHelpTip());
end

function CollectionsJournal_OnShow(self)
	CollectionsJournalPortraitButton:UpdateVisibility();
	WardrobeFramePortraitButton:UpdateVisibility();
	HideUIPanel(WardrobeFrame);
	CollectionsMicroButtonAlert:Hide();
	WCollectionsMinimapHelpBox:Hide();
	WCollections:SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WCOLLECTIONS_MICRO_BUTTON, true);
	--MicroButtonPulseStop(CollectionsMicroButton);

	PlaySound("igCharacterInfoOpen");
	CollectionsJournal_UpdateSelectedTab(self);
	UpdateMicroButtons();
end

function CollectionsJournal_OnHide(self)
	PlaySound("igCharacterInfoClose");
	UpdateMicroButtons();

	--CollectionsMicroButton:EvaluateAlertVisibility();
end
