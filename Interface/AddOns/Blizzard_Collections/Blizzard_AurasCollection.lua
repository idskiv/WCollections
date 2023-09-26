local AURAS_BUTTON_HEIGHT = 46;

function AurasJournal_OnLoad(self)
	Mixin(self, SetShownMixin);
	Mixin(self.AurasButton, SetEnabledMixin);

	WCollections:RegisterEvent(self, "AURAS_JOURNAL_SEARCH_UPDATED");
	self.ListScrollFrame.update = AurasJournal_UpdateAurasList;
	self.ListScrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "AurasListButtonTemplate", 44, 0);
end

function AurasJournal_OnEvent(self, event, ...)
	if ( event == "AURAS_JOURNAL_SEARCH_UPDATED" ) then
		if (self:IsVisible()) then
			self.deferredUpdate = false;
			C_AurasJournal.RefreshAuras();
			AurasJournal_UpdateAurasList();
			AurasJournal_UpdateAurasDisplay();
		end
	end
end

function AurasJournal_OnShow(self)
	C_AurasJournal.RefreshAuras();
	AurasJournal_UpdateAurasList();
	if (not AurasJournal.selectedSpellID) then
		AurasJournal_Select(1);
	end
	AurasJournal_UpdateAurasDisplay();
	SetPortraitToTexture(CollectionsJournalPortrait, [[Interface\AddOns\WCollections\Interface\Icons\AurasJournalPortrait]]);
	-- Fix frame levels
	self.LeftInset:SetFrameLevel(self:GetFrameLevel() + 1);
	self.RightInset:SetFrameLevel(self:GetFrameLevel() + 1);
	self.searchBox:SetFrameLevel(self:GetFrameLevel() + 2);
	self.AurasDisplay:SetFrameLevel(self:GetFrameLevel() + 2);
	self.ListScrollFrame:SetFrameLevel(self:GetFrameLevel() + 2);
end

function AurasJournal_OnHide(self)
	C_AurasJournal.ClearRecentFanfares();
end

function AurasJournal_UpdateAurasList()
	local scrollFrame = AurasJournal.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;

	local numAuras = C_AurasJournal.GetNumAuras();
	AurasJournal.numOwned = 0;
	local showAuras = true;
	local playerLevel = UnitLevel("player");
	if  ( numAuras > 1 ) then
		local auraIDs = C_AurasJournal.GetAuraIDs();
		for i, auraID in ipairs(auraIDs) do
			local _, _, _, _, _, _, _, isCollected = C_AurasJournal.GetAuraInfoByID(auraID);
			if (isCollected) then
				AurasJournal.numOwned = AurasJournal.numOwned + 1;
			end
		end
	end

	local numDisplayedAuras = C_AurasJournal.GetNumDisplayedAuras();
	for i=1, #buttons do
		local button = buttons[i];
		local displayIndex = i + offset;
		if ( displayIndex <= numDisplayedAuras and showAuras ) then
			local index = displayIndex;
			local auraName, spellID, icon, modelPath, active, isFavorite, isFiltered, isCollected = C_AurasJournal.GetDisplayedAuraInfo(index);
			local needsFanFare = C_AurasJournal.NeedsFanfare(spellID);


			button.name:SetText(auraName);
			button.icon:SetTexture(icon); 
			button.new:SetShown(false);
			button.newGlow:SetShown(false);
			AurasJournal.AurasDisplay.InfoButton.New:Hide();
			AurasJournal.AurasDisplay.InfoButton.NewGlow:Hide();

			button.index = index;
			button.spellID = spellID;

			button.active = active;
			if (active) then
				button.DragButton.ActiveTexture:Show();
			else
				button.DragButton.ActiveTexture:Hide();
			end
			button:Show();

			if ( AurasJournal.selectedSpellID == spellID ) then
				button.selected = true;
				button.selectedTexture:Show();
			else
				button.selected = false;
				button.selectedTexture:Hide();
			end
			button:SetEnabled(true);
			button.unusable:Hide();
			button.iconBorder:Hide();
			button.background:SetVertexColor(1, 1, 1, 1);
			if (isCollected) then
				button.DragButton:SetEnabled(true);
				button.name:SetFontObject("GameFontNormal");
				button.icon:SetAlpha(0.75);
				button.additionalText = nil;
				button.background:SetVertexColor(1, 0, 0, 1);
			else
				button.icon:SetDesaturated(true);
				button.DragButton:SetEnabled(false);
				button.icon:SetAlpha(0.25);
				button.additionalText = nil;
				button.name:SetFontObject("GameFontDisable");
			end

			if ( isFavorite ) then
				button.favorite:Show();
			else
				button.favorite:Hide();
			end

			button.factionIcon:Hide();

			if ( button.showingTooltip ) then
				AurasJournalAurasButton_UpdateTooltip(button);
			end
		else
			button.name:SetText("");
			button.icon:SetTexture([[Interface\Icons\Trade_Engineering]]);
			button.new:Hide();
			button.newGlow:Hide();
			button.SubscriptionOverlay:Hide();
			button.index = nil;
			button.spellID = 0;
			button.selected = false;
			button.unusable:Hide();
			button.DragButton.ActiveTexture:Hide();
			button.selectedTexture:Hide();
			button:SetEnabled(false);
			button.DragButton:SetEnabled(false);
			button.icon:SetDesaturated(true);
			button.icon:SetAlpha(0.5);
			button.favorite:Hide();
			button.factionIcon:Hide();
			button.background:SetVertexColor(1, 1, 1, 1);
			button.iconBorder:Hide();
		end
	end

	local totalHeight = numDisplayedAuras * AURAS_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight());
	AurasJournal.AurasCount.Count:SetText(AurasJournal.numOwned);
	if ( not showAuras ) then
		AurasJournal.selectedSpellID = nil;
		AurasJournal.selectedAurasID = nil;
		AurasJournal_UpdateAurasDisplay();
		AurasJournal.AurasCount.Count:SetText(0);
	end
end

function AurasJournalAurasButton_UpdateTooltip(self)
	GameTooltip:SetHyperlink("spell:"..self.spellID);
end

function AurasJournal_UpdateAurasDisplay()
	C_AurasJournal.GetAurasList();
    C_AurasJournal.UpdateActiveAura();
	if ( AurasJournal.selectedAurasID ) then
		local auraName, spellID, icon, modelPath, active, _, source, isCollected = C_AurasJournal.GetAuraInfoByID(AurasJournal.selectedAurasID);
		if auraName then
			local needsFanFare = C_AurasJournal.NeedsFanfare(AurasJournal.selectedAurasID);

			AurasJournal.AurasDisplay.InfoButton.Name:SetText(auraName);

			if needsFanFare then
				local offsetX = math.min(AurasJournal.AurasDisplay.InfoButton.Name:GetStringWidth(), AurasJournal.AurasDisplay.InfoButton.Name:GetWidth());
				AurasJournal.AurasDisplay.InfoButton.New:SetPoint("LEFT", AurasJournal.AurasDisplay.InfoButton.Name, "LEFT", offsetX + 8, 0);
				AurasJournal.AurasDisplay.InfoButton.Icon:SetTexture(icon);
			else
				AurasJournal.AurasDisplay.InfoButton.New:Hide();
				AurasJournal.AurasDisplay.InfoButton.NewGlow:Hide();

				AurasJournal.AurasDisplay.InfoButton.Icon:SetTexture(icon);
			end

			AurasJournal.AurasDisplay.InfoButton.Source:SetText(source);
			--AurasJournal.AurasDisplay.InfoButton.Lore:SetText(source)

			AurasJournal.AurasDisplay.lastDisplayed = spellID;

			AurasJournal.AurasDisplay.ModelWithControlsTemplate:Hide();
			AurasJournal.AurasDisplay.ModelWithControlsTemplate:SetPosition(0, 0, 0);
			--AurasJournal.AurasDisplay.ModelWithControlsTemplate.zoomLevel = 0;
			AurasJournal.AurasDisplay.ModelWithControlsTemplate:SetModel(modelPath);
			AurasJournal.AurasDisplay.ModelWithControlsTemplate:Show();
		end

		AurasJournal.AurasDisplay.ModelWithControlsTemplate:Show();
		AurasJournal.AurasDisplay.YesAurasTex:Show();
		AurasJournal.AurasDisplay.InfoButton:Show();

		if ( active ) then
			AurasJournal.AurasButton:SetText(AURA_UNAPPLY);
			AurasJournal.AurasButton:SetEnabled(isCollected);
		else
			AurasJournal.AurasButton:SetText(AURA_APPLY);
			AurasJournal.AurasButton:SetEnabled(isCollected);
		end
	else
		AurasJournal.AurasDisplay.InfoButton:Hide();
		AurasJournal.AurasDisplay.ModelWithControlsTemplate:Hide();
		AurasJournal.AurasDisplay.YesAurasTex:Hide();
		AurasJournal.AurasButton:SetEnabled(false);
		AurasJournal.AurasButton.SubscriptionOverlay:Hide();
	end
end

function AurasJournal_Select(index)
	local auraName, spellID = C_AurasJournal.GetDisplayedAuraInfo(index);

	AurasJournal.selectedSpellID = spellID;
	AurasJournal.selectedAurasID = spellID;
	AurasJournal_UpdateAurasList();
	AurasJournal_UpdateAurasDisplay();
end


function AurasJournalAurasButton_UseAuras(aurasID)
	if (aurasID == tonumber(WCollections:GetActiveVisualAura()) ) then
		WCollections:SendAddonMessage("AURAS:UNAPPLY:"..aurasID);
		WCollections.ActiveVisualAura = 0;
	else
		WCollections:SendAddonMessage("AURAS:APPLY:"..aurasID);
		WCollections.ActiveVisualAura = aurasID;
	end

	AurasJournal_UpdateAurasList();
	AurasJournal_UpdateAurasDisplay();
end

function AurasJournalAurasButton_OnClick(self)
	if AurasJournal.selectedAurasID then
		AurasJournalAurasButton_UseAuras(AurasJournal.selectedAurasID);
	end
end


function AurasListItem_OnClick(self, button)
	if not self.spellID or self.spellID == 0 then
		return;
	end

	if ( self.spellID ~= AurasJournal.selectedSpellID ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		AurasJournal_Select(self.index);
	end
end

function AurasJournal_OnSearchTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);
	C_AurasJournal.SetSearch(self:GetText());
end

function AurasJournal_ClearSearch()
	AurasJournal.searchBox:SetText("");
end
