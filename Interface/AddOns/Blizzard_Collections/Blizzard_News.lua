local NEWS_BUTTON_HEIGHT = 46;
local AddNewsPanelVisible = false;
local waitingForPin = false;
local accountLevel = 0;

local newsTypeStrings = {
	[0] = NEWS_JOURNAL_FILTER_REGULAR,
	[1] = NEWS_JOURNAL_FILTER_MAINTENANCE,
	[2] = NEWS_JOURNAL_FILTER_UPDATES,
	[3] = NEWS_JOURNAL_FILTER_CUSTOM,
	[4] = NEWS_JOURNAL_FILTER_FEATURE,
};

function NewsJournal_OnLoad(self)
	Mixin(self, SetShownMixin);

	WCollections:RegisterEvent(self, "NEWS_JOURNAL_SEARCH_UPDATED");
	self.ListScrollFrame.update = NewsJournal_UpdateNewsList;
	self.ListScrollFrame.scrollBar.doNotHide = true;
	
	HybridScrollFrame_CreateButtons(self.ListScrollFrame, "NewsListButtonTemplate", 44, 0);
end

function NewsJournal_OnEvent(self, event, ...)
	if ( event == "NEWS_JOURNAL_SEARCH_UPDATED" ) then
		if (self:IsVisible()) then
			self.deferredUpdate = false;
			C_NewsJournal.RefreshNews();
			NewsJournal_UpdateNewsList();
			NewsJournal_UpdateNewsDisplay();
		end
	end
end

function NewsJournal_OnShow(self)
	C_NewsJournal.RefreshNews();
	NewsJournal_UpdateNewsList();
	if (not NewsJournal.selectedNewsID) then
		NewsJournal_Select(1);
	end
	NewsJournal_UpdateNewsDisplay();

	if(WCollections:GetNewsIndex() > 0) then
		NewsJournalAddNewsButton:Show();
		NewsJournalEditNewsButton:Show();
		NewsJournalDelNewsButton:Show();
	end

	SetPortraitToTexture(CollectionsJournalPortrait, [[Interface\Icons\inv_scroll_06]]);
	-- Fix frame levels
	self.LeftInset:SetFrameLevel(self:GetFrameLevel() + 1);
	self.RightInset:SetFrameLevel(self:GetFrameLevel() + 1);
	self.searchBox:SetFrameLevel(self:GetFrameLevel() + 2);
	self.NewsDisplay:SetFrameLevel(self:GetFrameLevel() + 2);
	self.ListScrollFrame:SetFrameLevel(self:GetFrameLevel() + 2);
	NewsJournalFilterButton:SetFrameLevel(self:GetFrameLevel() + 2);
end

function NewsJournal_UpdateNewsList()
	local scrollFrame = NewsJournal.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;

	local numNews = C_NewsJournal.GetNumNews();
	local showNews = true;
	local playerLevel = UnitLevel("player");

	if  ( numNews < 1 ) then
		NewsJournal.NewsDisplay.NoNews:Show();
		showNews = false;
	else
		NewsJournal.NewsDisplay.NoNews:Hide();
	end

	local numDisplayedNews = C_NewsJournal.GetNumDisplayedNews();
	for i=1, #buttons do
		local button = buttons[i];
		local displayIndex = i + offset;
		if ( displayIndex <= numDisplayedNews and showNews ) then
			local index = displayIndex;
			local _, _, _NewsID, _, _, _ = C_NewsJournal.GetDisplayedNewsInfo(index);
			local Date, Title, _NewsID, Text, icon, Type, isPublic = C_NewsJournal.GetNewsInfoByID(_NewsID);
			local needsFanFare = C_NewsJournal.NeedsFanfare(_NewsID);
			local notPublicNews = true;

			button.title:SetText(dec(Title));
			button.icon:SetTexture(icon); 
			if(isPublic == 0) then
				button.new:SetText("Не опубликовано");
				button.new:SetShown(notPublicNews);
				button.newGlow:SetShown(notPublicNews);
			else
				button.new:SetText(NEW_CAPS);
				button.new:SetShown(needsFanFare);
				button.newGlow:SetShown(needsFanFare);
			end
			NewsJournal.NewsDisplay.InfoButton.New:Hide();
			NewsJournal.NewsDisplay.InfoButton.NewGlow:Hide();

			button.index = index;
			button._NewsID = _NewsID;

			button.DragButton.ActiveTexture:Hide();
			button:Show();

			if ( NewsJournal.selectedNewsID == _NewsID ) then
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
			button.DragButton:SetEnabled(true);
			button.title:SetFontObject("GameFontNormal");
			button.icon:SetAlpha(0.75);
			button.additionalText = nil;
			button.background:SetVertexColor(1, 0, 0, 1);
		else
			button.title:SetText("");
			button.icon:SetTexture([[Interface\Icons\Trade_Engineering]]);
			button.new:Hide();
			button.newGlow:Hide();
			button.index = nil;
			button._NewsID = 0;
			button.selected = false;
			button.unusable:Hide();
			button.DragButton.ActiveTexture:Hide();
			button.selectedTexture:Hide();
			button:SetEnabled(false);
			button.DragButton:SetEnabled(false);
			button.icon:SetDesaturated(true);
			button.icon:SetAlpha(0.5);
			button.background:SetVertexColor(1, 1, 1, 1);
			button.iconBorder:Hide();
		end
	end

	local totalHeight = numDisplayedNews * NEWS_BUTTON_HEIGHT;
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight());
	if ( not showNews ) then
		NewsJournal.selectedNewsID = nil;
		NewsJournal.selectedNewsID = nil;
		NewsJournal_UpdateNewsDisplay();
	end
end


function NewsJournal_UpdateNewsDisplay()
	if ( NewsJournal.selectedNewsID ) then
		local Date, Title, _NewsID, Text, icon, isPublic = C_NewsJournal.GetNewsInfoByID(NewsJournal.selectedNewsID);
		if Title and Text then
			local server_time = time();
			server_time = tonumber(server_time);
			NewsJournal.NewsDisplay.InfoButton.Title:SetFontObject("GameFontBlackMedium");
			NewsJournal.NewsDisplay.InfoButton.Title:SetText(dec(Title));
			NewsJournal.NewsDisplay.InfoButton.New:Hide();
			NewsJournal.NewsDisplay.InfoButton.NewGlow:Hide();
			NewsJournal.NewsDisplay.InfoButton.Icon:SetTexture(icon);
			NewsJournal_NewsText:Hide();
			local decText = dec(Text);
			NewsTextPanelScroll:SetScrollChild(NewsJournal_NewsText);
			NewsJournal_NewsText:SetText(decText);
			NewsJournal.NewsDisplay.InfoButton.Title:Show();
			NewsJournal_NewsText:Show();

			NewsJournal.NewsDisplay.lastDisplayed = _NewsID;
		end

		NewsJournal.NewsDisplay.InfoButton:Show();
		NewsJournal.NewsDisplay.YesAurasTex:Show();
	else
		NewsJournal.NewsDisplay.InfoButton:Hide();
		NewsJournal.NewsDisplay.InfoButton.Title:Hide();
		NewsJournal.NewsDisplay.NoNews:Show();
		NewsJournal_NewsText:Hide();
	end
end

function NewsJournal_Select(index)
	local _, Title, _NewsID = C_NewsJournal.GetDisplayedNewsInfo(index);

	NewsJournal.selectedNewsID = _NewsID;
	NewsJournal.selectedNewsID = _NewsID;
	if(_NewsID ~= nil) then
		C_NewsJournal.ClearFanfare(_NewsID);
	end
	NewsJournal_UpdateNewsList();
	NewsJournal_UpdateNewsDisplay();
end

function NewsListItem_OnClick(self, button)
	if not self._NewsID or self._NewsID == 0 then
		return;
	end

	if ( self._NewsID ~= NewsJournal.selectedNewsID ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		NewsJournal_Select(self.index);
	end
end

function NewsJournal_OnSearchTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);
	C_NewsJournal.SetSearch(self:GetText());
end

function NewsJournal_ClearSearch()
	NewsJournal.searchBox:SetText("");
end

local ManualBackdrop = {
	bgFile = "Interface\\AddOns\\WCollections\\Interface\\PetBattles\\news_background",
	edgeFile = "",
	tile = false,
}

function AddNewsPanel_OnLoad(self)

	AddNewsPanel_NewsTitle:SetBackdrop(ManualBackdrop);
	AddNewsPanel_NewsTitle:SetBackdropColor(1, 1, 1, 1);
	AddNewsPanel_NewsTitle:SetBackdropBorderColor(0, 0, 0, 0);
	AddNewsPanel_FilterButton:SetFrameLevel(self:GetFrameLevel() + 2);
	AddNewsPanel_Public:SetFrameLevel(self:GetFrameLevel() + 2);

	local Scroll = CreateFrame('ScrollFrame', 'AddNewsPanelScroll', AddNewsPanel_AddNewsTextZone, 'UIPanelScrollFrameTemplate');
	Scroll:SetPoint('TOPLEFT', AddNewsPanel_AddNewsTextZone, 'TOPLEFT', 8, -10);
	Scroll:SetPoint('BOTTOMRIGHT', AddNewsPanel_AddNewsTextZone, 'BOTTOMRIGHT', -30, 8);
	Scroll:SetScrollChild(AddNewsPanel_NewsText);
end

function AddNewsPanelAddNewsButton_OnClick()
	if(AddNewsPanelVisible) then
		AddNewsPanel:Hide();
		AddNewsPanelVisible = false;
	else
		AddNewsPanel.ID = WCollections:GetNewsIndex();
		AddNewsPanel.Type = 1;
		AddNewsPanel.isPublic = 0;
		AddNewsPanel.Edit = false;
		AddNewsPanel_NewsTitle:SetText("");
		AddNewsPanel_NewsText:SetText("");
		AddNewsPanel_Public:SetChecked(false);
		AddNewsPanel:SetPoint("TOPRIGHT", "CollectionsJournal", "TOPRIGHT",600, 0);
		AddNewsPanel:Show();
		AddNewsPanelVisible = true;
	end
end

function AddNewsPanelEditNewsButton_OnClick()
	if(AddNewsPanelVisible) then
		AddNewsPanel:Hide();
		AddNewsPanelVisible = false;
	else
		AddNewsPanel.ID  = NewsJournal.selectedNewsID;
		local Date, Title, _NewsID, Text, icon, Type, isPublic = C_NewsJournal.GetNewsInfoByID(NewsJournal.selectedNewsID);

		AddNewsPanel_NewsTitle:SetText(dec(Title));
		AddNewsPanel_NewsText:SetText(dec(Text));
		AddNewsPanel.Type = Type;
		AddNewsPanel.isPublic = isPublic;
		AddNewsPanel.Edit = true;

		if isPublic == 1 then
			AddNewsPanel_Public:SetChecked(true);
		else
			AddNewsPanel_Public:SetChecked(false);
		end

		AddNewsPanel:SetPoint("TOPRIGHT", "CollectionsJournal", "TOPRIGHT",600, 0);
		AddNewsPanel:Show();
		AddNewsPanelVisible = true;
	end
end

function AddNewsPanelDelNewsButton_OnClick()
	local ID  = NewsJournal.selectedNewsID;
	WCollections:SendAddonMessage("NEWS:DEL:"..ID);
	C_NewsJournal.RefreshNews();
	NewsJournal_UpdateNewsList();
	NewsJournal_UpdateNewsDisplay();
end

function AddNewsPanelSendButton_OnClick()
	local ID  = AddNewsPanel.ID or WCollections:GetNewsIndex();
	local News_time = time();
	local Title = AddNewsPanel_NewsTitle:GetText();
	local Text = AddNewsPanel_NewsText:GetText();
	local TypeNews = AddNewsPanel.Type or 1;
	local isPublic = AddNewsPanel.isPublic;
	Title = enc(Title);
	Text = enc(Text);
	News_time = tostring(News_time);

	if (#Title > 0 and #Text > 0) then
		if(AddNewsPanel.Edit) then
			WCollections:SendAddonMessage("NEWS:ADD:"..ID..":"..News_time..":"..Title.."\2"..TypeNews..":"..isPublic..":E");
		else
			WCollections:SendAddonMessage("NEWS:ADD:"..ID..":"..News_time..":"..Title.."\2"..TypeNews..":"..isPublic..":A");
		end

		local size = #Text;
		local size_index = math.ceil(size / 200);
	
		for i=0, size_index-1 do
			local end_index;

			if (((i+1)*200 - 1) < size) then
				end_index = (i+1)*200 - 1;
			else
				end_index = size;
			end

			local text_part = string.sub(Text, i*200, end_index); 
			if (i < size_index-1) then		
				WCollections:SendAddonMessage("NEWS:ADDTEXT:"..ID..":"..text_part);
			else
				WCollections:SendAddonMessage("NEWS:ADDTEXT:"..ID..":"..text_part..":END");
			end
		end

		C_NewsJournal.RefreshNews();
		NewsJournal_UpdateNewsList();
		NewsJournal_UpdateNewsDisplay();

		AddNewsPanel.ID = WCollections:GetNewsIndex();
		AddNewsPanel.Type = 1;
		AddNewsPanel.isPublic = 0;
		AddNewsPanel_NewsTitle:SetText("");
		AddNewsPanel_NewsText:SetText("");
		AddNewsPanel:Hide();
		AddNewsPanelVisible = false;
	end
end

function AddNewsPanelPublic_OnClick()
	if(AddNewsPanel_Public:GetChecked()) then
		AddNewsPanel.isPublic = 1;
	else
		AddNewsPanel.isPublic = 0;
	end
end

function NewsJournalFilterDropDown_OnLoad(self)
	WCollections:UIDropDownMenu_Initialize(self, NewsJournalFilterDropDown_Initialize, "MENU");
end

function NewsJournalFilterDropdown_ResetFilters()
	C_NewsJournal.SetDefaultFilters();
	NewsJournalFilterButton.ResetButton:Hide();
end

function NewsJournalResetFiltersButton_UpdateVisibility()
	NewsJournalFilterButton.ResetButton:SetShown(not C_NewsJournal.IsUsingDefaultFilters());
end

function NewsJournalFilterDropDown_Initialize(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.keepShownOnClick = true;

	for i=1, 5 do
		info = UIDropDownMenu_CreateInfo();
		info.keepShownOnClick = true;
		info.isNotRadio = true;

		info.text = newsTypeStrings[i-1];

		info.func = function(_, _, _, value)
						C_NewsJournal.SetTypeFilter(i, value);
					end
		info.checked = function() return C_NewsJournal.IsTypeChecked(i) end;
		UIDropDownMenu_AddButton(info, level);
	end;
end

function AddNewsPanelFilterDropDown_OnLoad(self)
	WCollections:UIDropDownMenu_Initialize(self, AddNewsPanelFilterDropDown_Initialize, "MENU");
end

function NewsJournalFilterDropdown_ResetFilters()
	C_NewsJournal.SetDefaultFilters();
	AddNewsPanelFilterButton.ResetButton:Hide();
end

function AddNewsPanelResetFiltersButton_UpdateVisibility()
	AddNewsPanelFilterButton.ResetButton:SetShown(not C_NewsJournal.IsUsingDefaultFilters());
end

function AddNewsPanelFilterDropDown_Initialize(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.keepShownOnClick = true;

	for i=1, 5 do
		info = UIDropDownMenu_CreateInfo();
		info.keepShownOnClick = false;
		info.isNotRadio = false;

		info.text = newsTypeStrings[i-1];

		info.func = function(_, _, _, value)
						AddNewsPanelFilterDropDown_SetCheck(i);
					end
		info.checked = function() return AddNewsPanelFilterDropDown_isCheck(i) end;
		UIDropDownMenu_AddButton(info, level);
	end;
end


function AddNewsPanelFilterDropDown_isCheck(index)
	if(AddNewsPanel.Type == index) then
		return true;
	end

	return false;
end

function AddNewsPanelFilterDropDown_SetCheck(index)
	AddNewsPanel.Type = index;
end

