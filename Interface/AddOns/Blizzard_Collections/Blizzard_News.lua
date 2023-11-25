local NEWS_BUTTON_HEIGHT = 46;
local AddNewsPanelVisible = false;

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
	SetPortraitToTexture(CollectionsJournalPortrait, [[Interface\Icons\inv_scroll_06]]);
	-- Fix frame levels
	self.LeftInset:SetFrameLevel(self:GetFrameLevel() + 1);
	self.RightInset:SetFrameLevel(self:GetFrameLevel() + 1);
	self.searchBox:SetFrameLevel(self:GetFrameLevel() + 2);
	self.NewsDisplay:SetFrameLevel(self:GetFrameLevel() + 2);
	self.ListScrollFrame:SetFrameLevel(self:GetFrameLevel() + 2);
end

function NewsJournal_UpdateNewsList()
	local scrollFrame = NewsJournal.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;

	local numNews = C_NewsJournal.GetNumNews();
	local showNews = true;
	local playerLevel = UnitLevel("player");

	local numDisplayedNews = C_NewsJournal.GetNumDisplayedNews();
	for i=1, #buttons do
		local button = buttons[i];
		local displayIndex = i + offset;
		if ( displayIndex <= numDisplayedNews and showNews ) then
			local index = displayIndex;
			local Title, _NewsID, Text, icon, isPublic = C_NewsJournal.GetDisplayedNewsInfo(index);

			button.name:SetText(Title);
			button.icon:SetTexture(icon); 
			button.new:SetShown(false);
			button.newGlow:SetShown(false);
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
			button.name:SetFontObject("GameFontNormal");
			button.icon:SetAlpha(0.75);
			button.additionalText = nil;
			button.background:SetVertexColor(1, 0, 0, 1);
		else
			button.name:SetText("");
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
	C_NewsJournal.GetNewsList();
	if ( NewsJournal.selectedNewsID ) then
		local Title, _NewsID, Text, icon, isPublic = C_NewsJournal.GetNewsInfoByID(NewsJournal.selectedNewsID);
		if Title then
			NewsJournal.NewsDisplay.InfoButton.Title:SetText(Title);
			NewsJournal.NewsDisplay.InfoButton.New:Hide();
			NewsJournal.NewsDisplay.InfoButton.NewGlow:Hide();
			NewsJournal.NewsDisplay.InfoButton.Icon:SetTexture(icon);
			NewsJournal.NewsDisplay.InfoButton.NewsText:SetText(Text);
			NewsJournal.NewsDisplay.lastDisplayed = _NewsID;
		end

		NewsJournal.NewsDisplay.InfoButton:Show();
		NewsJournal.NewsDisplay.YesAurasTex:Show();
	else
		NewsJournal.NewsDisplay.InfoButton:Hide();
	end
end

function NewsJournal_Select(index)
	local NewsName, _NewsID = C_NewsJournal.GetDisplayedNewsInfo(index);

	NewsJournal.selectedNewsID = _NewsID;
	NewsJournal.selectedNewsID = _NewsID;
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
	bgFile = "Interface\\AddOns\\WCollections\\Interface\\PetBattles\\news_background2",
	edgeFile = "",
	tile = false,
}

function AddNewsPanel_OnLoad(self)
	AddNewsPanel_Send:SetFrameLevel(self:GetFrameLevel() + 1);
	AddNewsPanel_NewsTitle:SetFrameLevel(self:GetFrameLevel() + 1);
	AddNewsPanel_NewsText:SetMultiLine(true);
	AddNewsPanel_NewsText:SetBackdrop(ManualBackdrop);
	AddNewsPanel_NewsText:SetBackdropColor(1, 1, 1, 1);
	AddNewsPanel_NewsText:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.3);

	local text = "";
	for i=1,33 do
    	text = text.."\n";
	end
	AddNewsPanel_NewsText:SetText(text);

	AddNewsPanel_NewsTitle:SetMultiLine(true);
	AddNewsPanel_NewsTitle:SetHeight(54);
	AddNewsPanel_NewsTitle:SetBackdrop(ManualBackdrop);
	AddNewsPanel_NewsTitle:SetBackdropColor(1, 1, 1, 1);
	AddNewsPanel_NewsTitle:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.3);
	
	
	local Scroll = CreateFrame('ScrollFrame', 'AddNewsPanelScroll', AddNewsPanel_AddNewsTextZone, 'UIPanelScrollFrameTemplate')
	Scroll:SetPoint('TOPLEFT', AddNewsPanel_AddNewsTextZone, 'TOPLEFT', 8, -30)
	Scroll:SetPoint('BOTTOMRIGHT', AddNewsPanel_AddNewsTextZone, 'BOTTOMRIGHT', -30, 8)
	Scroll:SetScrollChild(AddNewsPanel_NewsText);
end

function AddNewsButton_OnClick()
	if(AddNewsPanelVisible) then
		AddNewsPanel:Hide();
		AddNewsPanelVisible = false;
	else
		AddNewsPanel:SetPoint("TOPRIGHT", "CollectionsJournal", "TOPRIGHT",600, 0);
		AddNewsPanel:Show();
		AddNewsPanelVisible = true;
	end
end
