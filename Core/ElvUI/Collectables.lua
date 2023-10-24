WCollections:MergeHook("WCollectionsElvUIHook", function()

local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local MF = E:GetModule("Enhanced_ModelFrames", true) or E:GetModule("HookModelFrames", true)

local _G = _G
local select = select
local ipairs, pairs, unpack = ipairs, pairs, unpack

local CreateFrame = CreateFrame
local GetItemInfo = GetItemInfo
local PlayerHasToy = PlayerHasToy
local hooksecurefunc = hooksecurefunc
local GetItemQualityColor = GetItemQualityColor
local C_TransmogCollection_GetSourceInfo = C_TransmogCollection.GetSourceInfo

local function clearBackdrop(self)
	self:SetBackdropColor(0, 0, 0, 0)
end

local function toyTextColor(text, r, g, b)
	if r == 0.33 and g == 0.27 and b == 0.2 then
		text:SetTextColor(0.4, 0.4, 0.4)
	elseif r == 1 and g == 0.82 and b == 0 then
		text:SetTextColor(0.9, 0.9, 0.9)
	end
end

local function petNameColor(iconBorder, r, g, b)
	local parent = iconBorder:GetParent()
	if not parent.name then return end

	if parent.isDead and parent.isDead:IsShown() then
		parent.name:SetTextColor(0.9, 0.3, 0.3)
	elseif r and parent.owned then
		parent.name:SetTextColor(r, g, b)
	else
		parent.name:SetTextColor(0.4, 0.4, 0.4)
	end
end

local function mountNameColor(self)
	local button = self:GetParent()
	local name = button.name

	if name:GetFontObject() == _G.GameFontDisable then
		name:SetTextColor(0.4, 0.4, 0.4)
	else
		if button.background then
			local _, g, b = button.background:GetVertexColor()
			if g == 0 and b == 0 then
				name:SetTextColor(0.9, 0.3, 0.3)
				return
			end
		end

		name:SetTextColor(0.9, 0.9, 0.9)
	end
end

local function selectedTextureSetShown(texture, shown) -- used sets list
	local parent = texture:GetParent()
	local icon = parent.icon or parent.Icon
	if shown then
		parent:SetBackdropBorderColor(1, .8, .1)
		icon.backdrop:SetBackdropBorderColor(1, .8, .1)
	else
		local r, g, b = unpack(E.media.bordercolor)
		parent:SetBackdropBorderColor(r, g, b)
		icon.backdrop:SetBackdropBorderColor(r, g, b)
	end
end

local function selectedTextureShow(texture) -- used for pets/mounts
	local parent = texture:GetParent()
	parent:SetBackdropBorderColor(1, .8, .1)
	parent.icon.backdrop:SetBackdropBorderColor(1, .8, .1)
end

local function selectedTextureHide(texture) -- used for pets/mounts
	local parent = texture:GetParent()
	if not parent.hovered then
		local r, g, b = unpack(E.media.bordercolor)
		parent:SetBackdropBorderColor(r, g, b)
		parent.icon.backdrop:SetBackdropBorderColor(r, g, b)
	end

	if parent.petList then
		petNameColor(parent.iconBorder, parent.iconBorder:GetVertexColor())
	end
end

local function buttonOnEnter(button)
	local r, g, b = unpack(E.media.rgbvaluecolor)
	local icon = button.icon or button.Icon
	button:SetBackdropBorderColor(r, g, b)
	icon.backdrop:SetBackdropBorderColor(r, g, b)
	button.hovered = true
end

local function buttonOnLeave(button)
	local icon = button.icon or button.Icon
	if button.selected or (button.SelectedTexture and button.SelectedTexture:IsShown()) then
		button:SetBackdropBorderColor(1, .8, .1)
		icon.backdrop:SetBackdropBorderColor(1, .8, .1)
	else
		local r, g, b = unpack(E.media.bordercolor)
		button:SetBackdropBorderColor(r, g, b)
		icon.backdrop:SetBackdropBorderColor(r, g, b)
	end
	button.hovered = nil
end

local function transmogSlotButtonSelect(texture)
	texture:GetParent().backdrop:SetBackdropBorderColor(1, .8, .1)
end

local function transmogSlotButtonUnselect(texture)
	texture:GetParent().backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
end

local function JournalScrollButtons(frame)
	for i, bu in ipairs(frame.buttons) do
		bu:StripTextures_WCollections()
		bu:SetTemplate('Transparent', nil, nil, true)
		bu:Size(210, 42)

		local point, relativeTo, relativePoint, xOffset, yOffset = bu:GetPoint()
		bu:ClearAllPoints()

		if i == 1 then
			bu:Point(point, relativeTo, relativePoint, 44, yOffset)
		else
			bu:Point(point, relativeTo, relativePoint, xOffset, -2)
		end

		local icon = bu.icon or bu.Icon
		icon:Size(40)
		icon:Point('LEFT', -43, 0)
		icon:SetTexCoord(unpack(E.TexCoords))
		icon:CreateBackdrop(nil, nil, nil, true)
		icon.backdrop:SetAlpha(0);

		bu:HookScript('OnEnter', buttonOnEnter)
		bu:HookScript('OnLeave', buttonOnLeave)

		local highlight = _G[bu:GetName()..'Highlight']
		if highlight then
			highlight:SetTexture(1, 1, 1, 0.3)
			highlight:SetBlendMode('ADD')
			highlight:SetAllPoints(bu.icon)
		end

		if bu.ProgressBar then
			bu.ProgressBar:SetTexture(E.media.normTex)
			bu.ProgressBar:SetVertexColor(0.251, 0.753, 0.251, 1) -- 0.0118, 0.247, 0.00392
		end

		if frame:GetParent() == _G.WardrobeCollectionFrame.SetsCollectionFrame then
			bu.Favorite:SetTexture([[Interface\AddOns\WCollections\Interface\Common\FavoritesIcon]])
			bu.Favorite:Point('TOPLEFT', bu.Icon, 'TOPLEFT', -8, 8)

			hooksecurefunc(bu.SelectedTexture, 'SetShown', selectedTextureSetShown)
		else
			bu.selectedTexture:SetTexture()
			hooksecurefunc(bu.selectedTexture, 'Show', selectedTextureShow)
			hooksecurefunc(bu.selectedTexture, 'Hide', selectedTextureHide)

			if frame:GetParent() == _G.PetJournal then
				bu.mountList = true
				bu.petTypeIcon:Point('TOPRIGHT', -1, -1)
				bu.petTypeIcon:Point('BOTTOMRIGHT', -1, 1)

				bu.DragButton.ActiveTexture:SetTexture(E.Media.Textures.White8x8)
				bu.DragButton.ActiveTexture:SetVertexColor(0.9, 0.8, 0.1, 0.3)

				bu.favorite:SetTexture([[Interface\AddOns\WCollections\Interface\Common\FavoritesIcon]])
				bu.favorite:Point('TOPLEFT', bu.DragButton, 'TOPLEFT' , -8, 8)
				bu.favorite:Size(32, 32)

				bu.SubscriptionOverlay:SetTexture([[Interface\AddOns\WCollections\Textures\MountSubscriptionOverlay]]);

				hooksecurefunc(bu.name, 'SetFontObject', mountNameColor)
				hooksecurefunc(bu.background, 'SetVertexColor', mountNameColor)
			elseif frame:GetParent() == _G.MountJournal then
				bu.mountList = true
				bu.factionIcon:SetDrawLayer('OVERLAY')
				bu.factionIcon:Point('TOPRIGHT', -1, -1)
				bu.factionIcon:Point('BOTTOMRIGHT', -1, 1)

				bu.DragButton.ActiveTexture:SetTexture(E.Media.Textures.White8x8)
				bu.DragButton.ActiveTexture:SetVertexColor(0.9, 0.8, 0.1, 0.3)

				bu.favorite:SetTexture([[Interface\AddOns\WCollections\Interface\Common\FavoritesIcon]])
				bu.favorite:Point('TOPLEFT', bu.DragButton, 'TOPLEFT' , -8, 8)
				bu.favorite:Size(32, 32)

				bu.SubscriptionOverlay:SetTexture([[Interface\AddOns\WCollections\Textures\MountSubscriptionOverlay]]);

				bu.unusable:Size(40);
				bu.unusable:Point('LEFT', -43, 0)
				bu.unusable:SetTexture(1, 0, 0, 0.2);

				hooksecurefunc(bu.name, 'SetFontObject', mountNameColor)
				hooksecurefunc(bu.background, 'SetVertexColor', mountNameColor)
			end
		end
	end
end

local function SkinNewsFrame()
	S:HandleItemButton(_G.NewsJournalSummonRandomFavoriteButton, true)
	S:HandleButton_WCollections(_G.NewsJournalFilterButton)

	_G.NewsJournalFilterButton:ClearAllPoints()
	_G.NewsJournalFilterButton:Point('LEFT', _G.NewsJournalSearchBox, 'RIGHT', 5, 0)

	local NewsJournal = _G.NewsJournal
	NewsJournal:StripTextures_WCollections()
	NewsJournal.NewsDisplay:StripTextures_WCollections()
	NewsJournal.NewsDisplay.ShadowOverlay:StripTextures_WCollections()
	NewsJournal.NewsCount:StripTextures_WCollections()

	S:HandleIcon(NewsJournal.NewsDisplay.InfoButton.Icon)

	S:HandleButton(_G.NewsJournalNewsButton)
	S:HandleEditBox(_G.NewsJournalSearchBox)
	S:HandleScrollBar(_G.NewsJournalListScrollFrameScrollBar)
	S:HandleRotateButton(NewsJournal.NewsDisplay.ModelFrame.RotateLeftButton)
	S:HandleRotateButton(NewsJournal.NewsDisplay.ModelFrame.RotateRightButton)

	JournalScrollButtons(NewsJournal.ListScrollFrame)

	NewsJournal.NewsButton.SubscriptionOverlay:Point("LEFT", NewsJournal.NewsButton, "RIGHT", 0, 0);
	NewsJournal.NewsButton.SubscriptionOverlay:SetScale(1.2);
end

local function SkinMountFrame()
	S:HandleItemButton(_G.MountJournalSummonRandomFavoriteButton, true)
	S:HandleButton_WCollections(_G.MountJournalFilterButton)

	_G.MountJournalFilterButton:ClearAllPoints()
	_G.MountJournalFilterButton:Point('LEFT', _G.MountJournalSearchBox, 'RIGHT', 5, 0)

	local MountJournal = _G.MountJournal
	MountJournal:StripTextures_WCollections()
	MountJournal.MountDisplay:StripTextures_WCollections()
	MountJournal.MountDisplay.ShadowOverlay:StripTextures_WCollections()
	MountJournal.MountCount:StripTextures_WCollections()

	S:HandleIcon(MountJournal.MountDisplay.InfoButton.Icon)

	S:HandleButton(_G.MountJournalMountButton)
	S:HandleEditBox(_G.MountJournalSearchBox)
	S:HandleScrollBar(_G.MountJournalListScrollFrameScrollBar)
	S:HandleRotateButton(MountJournal.MountDisplay.ModelFrame.RotateLeftButton)
	S:HandleRotateButton(MountJournal.MountDisplay.ModelFrame.RotateRightButton)

	JournalScrollButtons(MountJournal.ListScrollFrame)

	MountJournal.MountButton.SubscriptionOverlay:Point("LEFT", MountJournal.MountButton, "RIGHT", 0, 0);
	MountJournal.MountButton.SubscriptionOverlay:SetScale(1.2);
end

local function SkinAurasFrame()
	S:HandleItemButton(_G.AurasJournalSummonRandomFavoriteButton, true)
	S:HandleButton_WCollections(_G.AurasJournalFilterButton)

	_G.AurasJournalFilterButton:ClearAllPoints()
	_G.AurasJournalFilterButton:Point('LEFT', _G.AurasJournalSearchBox, 'RIGHT', 5, 0)

	local AurasJournal = _G.AurasJournal
	AurasJournal:StripTextures_WCollections()
	AurasJournal.AurasDisplay:StripTextures_WCollections()
	AurasJournal.AurasDisplay.ShadowOverlay:StripTextures_WCollections()
	AurasJournal.AurasCount:StripTextures_WCollections()
	AurasJournal.SubscriptionStatus:StripTextures_WCollections()

	S:HandleIcon(AurasJournal.AurasDisplay.InfoButton.Icon)

	S:HandleButton(_G.AurasJournalAurasButton)
	S:HandleEditBox(_G.AurasJournalSearchBox)
	S:HandleScrollBar(_G.AurasJournalListScrollFrameScrollBar)
	S:HandleRotateButton(AurasJournal.AurasDisplay.ModelFrame.RotateLeftButton)
	S:HandleRotateButton(AurasJournal.AurasDisplay.ModelFrame.RotateRightButton)

	JournalScrollButtons(AurasJournal.ListScrollFrame)

	AurasJournal.AurasButton.SubscriptionOverlay:Point("LEFT", AurasJournal.AurasButton, "RIGHT", 0, 0);
	AurasJournal.AurasButton.SubscriptionOverlay:SetScale(1.2);
end

local function SkinPetFrame()
	S:HandleItemButton(_G.PetJournalSummonRandomFavoritePetButton, true)
	S:HandleButton_WCollections(_G.PetJournalFilterButton)

	_G.PetJournalFilterButton:ClearAllPoints()
	_G.PetJournalFilterButton:Point('LEFT', _G.PetJournalSearchBox, 'RIGHT', 5, 0)

	local PetJournal = _G.PetJournal
	PetJournal:StripTextures_WCollections()
	PetJournal.PetDisplay:StripTextures_WCollections()
	PetJournal.PetDisplay.ShadowOverlay:StripTextures_WCollections()
	PetJournal.PetCount:StripTextures_WCollections()
	PetJournal.SubscriptionStatus:StripTextures_WCollections()

	S:HandleIcon(PetJournal.PetDisplay.InfoButton.Icon)

	S:HandleButton(_G.PetJournalSummonButton)
	S:HandleEditBox(_G.PetJournalSearchBox)
	S:HandleScrollBar(_G.PetJournalListScrollFrameScrollBar)
	S:HandleRotateButton(PetJournal.PetDisplay.ModelFrame.RotateLeftButton)
	S:HandleRotateButton(PetJournal.PetDisplay.ModelFrame.RotateRightButton)

	JournalScrollButtons(PetJournal.ListScrollFrame)
end

local function SkinToyFrame()
	local ToyBox = _G.ToyBox
	S:HandleButton_WCollections(_G.ToyBoxFilterButton)
	S:HandleEditBox(ToyBox.searchBox)
	_G.ToyBoxFilterButton:Point('LEFT', ToyBox.searchBox, 'RIGHT', 2, 0)
	ToyBox.iconsFrame:StripTextures_WCollections()
	ToyBox.iconsFrame.OverlayLayer:StripTextures_WCollections()
	ToyBox.SubscriptionStatus:StripTextures_WCollections()
	S:HandleNextPrevButton(ToyBox.PagingFrame.NextPageButton, "right", nil, true)
	S:HandleNextPrevButton(ToyBox.PagingFrame.PrevPageButton, "left", nil, true)

	ToyBox.progressBar.border:Hide()
	ToyBox.progressBar:DisableDrawLayer('BACKGROUND')
	ToyBox.progressBar:SetStatusBarTexture(E.media.normTex)
	ToyBox.progressBar:CreateBackdrop()
	E:RegisterStatusBar(ToyBox.progressBar)

	for i = 1, 18 do
		local button = ToyBox.iconsFrame['spellButton'..i]
		S:HandleItemButton(button, true)
		button.iconTexture:SetParent(button);

		button.iconTextureUncollected:SetTexCoord(unpack(E.TexCoords))
		button.iconTextureUncollected:SetInside(button)
		button.hover:SetAllPoints(button.iconTexture)
		button.checked:SetAllPoints(button.iconTexture)
		button.pushed:SetAllPoints(button.iconTexture)
		button.cooldown:SetAllPoints(button.iconTexture)

		hooksecurefunc(button.name, 'SetTextColor', toyTextColor)
		hooksecurefunc(button.new, 'SetTextColor', toyTextColor)
		E:RegisterCooldown(button.cooldown)

		button.SubscriptionOverlay:Point("TOPRIGHT", 7, 7);
	end

	hooksecurefunc('ToySpellButton_UpdateButton', function(button)
		if button.itemID and PlayerHasToy(button.itemID) then
			local _, _, quality = GetItemInfo(button.itemID)
			if quality then
				button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
			else
				button.backdrop:SetBackdropBorderColor(0.9, 0.9, 0.9)
			end
		else
			button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)
end

local function SkinTransmogFrames()
	local WardrobeCollectionFrame = _G.WardrobeCollectionFrame
	S:HandleTab(WardrobeCollectionFrame.ItemsTab)
	S:HandleTab(WardrobeCollectionFrame.SetsTab)
	WardrobeCollectionFrame.ItemsTab:SetHeight(WardrobeCollectionFrame.ItemsTab:GetHeight() + 4)
	WardrobeCollectionFrame.SetsTab:SetHeight(WardrobeCollectionFrame.SetsTab:GetHeight() + 4)
	do
		local OFFSET = 10;
		local _, _, _, x, y = WardrobeCollectionFrame.ItemsTab.backdrop:GetPoint();
		WardrobeCollectionFrame.ItemsTab.backdrop:Point("TOPLEFT", x, y - OFFSET);
		WardrobeCollectionFrame.SetsTab.backdrop:Point("TOPLEFT", x, y - OFFSET);
		local l, r, t, b = WardrobeCollectionFrame.ItemsTab:GetHitRectInsets();
		WardrobeCollectionFrame.ItemsTab:SetHitRectInsets(l, r, t + OFFSET, b);
		WardrobeCollectionFrame.SetsTab:SetHitRectInsets(l, r, t + OFFSET, b);
	end

	WardrobeCollectionFrame.progressBar:StripTextures_WCollections()
	WardrobeCollectionFrame.progressBar:CreateBackdrop()
	WardrobeCollectionFrame.progressBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(WardrobeCollectionFrame.progressBar)

	S:HandleEditBox(_G.WardrobeCollectionFrameSearchBox)

	WardrobeCollectionFrame.FilterButton:Point('LEFT', WardrobeCollectionFrame.searchBox, 'RIGHT', 2, 0)
	S:HandleButton_WCollections(WardrobeCollectionFrame.FilterButton)
	S:HandleDropDownBox(_G.WardrobeCollectionFrameWeaponDropDown)
	WardrobeCollectionFrame.ItemsCollectionFrame:StripTextures_WCollections()
	WardrobeCollectionFrame.ItemsCollectionFrame.OverlayLayer:StripTextures_WCollections()

	local function SkinCollectionModel(Model)
		Model.Border:SetAlpha(0)
		if Model.TransmogStateTexture then
			Model.TransmogStateTexture:SetAlpha(0)
		end

		local border = CreateFrame('Frame', nil, Model)
		border:SetTemplate()
		border:ClearAllPoints()
		border:SetPoint('TOPLEFT', Model, 'TOPLEFT', 0, 1) -- dont use set inside, left side needs to be 0
		border:SetPoint('BOTTOMRIGHT', Model, 'BOTTOMRIGHT', 1, -1)
		border:SetBackdropColor(0, 0, 0, 0)
		border.callbackBackdropColor = clearBackdrop

		if Model.NewGlow then Model.NewGlow:SetParent(border) end
		if Model.NewString then Model.NewString:SetParent(border) end

		for i=1, Model:GetNumRegions() do
			local region = select(i, Model:GetRegions())
			if region:IsObjectType('Texture') then -- check for hover glow
				local texture = region:GetTexture()
				if texture:lower() == ([[Interface\AddOns\WCollections\Interface\Transmogrify\Transmogrify]]):lower() or texture:lower() == ([[Interface\AddOns\WCollections\Interface\Transmogrify\TransmogSetsVendor]]):lower() then
					region:SetTexture(1, 1, 1, 0.3)
					region:SetBlendMode('ADD')
					region:SetAllPoints(Model)
				end
			end
		end

		hooksecurefunc(Model.Border, 'SetAtlas', function(_, texture)
			if texture == 'transmog-wardrobe-border-uncollected' then
				border:SetBackdropBorderColor(0.9, 0.9, 0.3)
			elseif texture == 'transmog-wardrobe-border-unusable' then
				border:SetBackdropBorderColor(0.9, 0.3, 0.3)
			elseif Model.TransmogStateTexture and Model.TransmogStateTexture:IsShown() then
				border:SetBackdropBorderColor(1, 0.7, 1)
			else
				border:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end)
	end

	for _, Frame in ipairs(WardrobeCollectionFrame.ContentFrames) do
		if Frame.Models then
			for _, Model in pairs(Frame.Models) do
				SkinCollectionModel(Model);
			end
		end

		local pending = Frame.PendingTransmogFrame
		if pending then
			local Glowframe = pending.Glowframe
			Glowframe:SetTexture(nil)
			Glowframe:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, nil, pending:GetFrameLevel())

			if Glowframe.backdrop then
				Glowframe.backdrop:SetPoint('TOPLEFT', pending, 'TOPLEFT', 0, 1) -- dont use set inside, left side needs to be 0
				Glowframe.backdrop:SetPoint('BOTTOMRIGHT', pending, 'BOTTOMRIGHT', 1, -1)
				Glowframe.backdrop:SetBackdropBorderColor(1, 0.7, 1)
				Glowframe.backdrop:SetBackdropColor(0, 0, 0, 0)
			end

			for i = 1, 12 do
				if i < 5 then
					Frame.PendingTransmogFrame['Smoke'..i]:Hide()
				end

				Frame.PendingTransmogFrame['Wisp'..i]:Hide()
			end
		end

		local paging = Frame.PagingFrame
		if paging then
			S:HandleNextPrevButton(paging.PrevPageButton, "left", nil, true)
			S:HandleNextPrevButton(paging.NextPageButton, "right", nil, true)
		end
	end

	local SetsCollectionFrame = WardrobeCollectionFrame.SetsCollectionFrame
	SetsCollectionFrame:SetTemplate('Transparent')
	SetsCollectionFrame.RightInset:StripTextures_WCollections()
	SetsCollectionFrame.RightInset.OverlayLayer:StripTextures_WCollections()
	SetsCollectionFrame.LeftInset:StripTextures_WCollections()
	JournalScrollButtons(SetsCollectionFrame.ScrollFrame)
	S:HandleScrollBar(SetsCollectionFrame.ScrollFrame.scrollBar)

	local DetailsFrame = SetsCollectionFrame.DetailsFrame
	DetailsFrame.Name:FontTemplate(nil, 16)
	DetailsFrame.LongName:FontTemplate(nil, 16)
	S:HandleButton_WCollections(DetailsFrame.VariantSetsButton)

	hooksecurefunc(SetsCollectionFrame, 'SetItemFrameQuality', function(_, itemFrame)
		local icon = itemFrame.Icon
		if not icon.backdrop then
			icon:CreateBackdrop()
			icon:SetTexCoord(unpack(E.TexCoords))
			itemFrame.IconBorder:Hide()
		end

		if itemFrame.collected then
			local quality = C_TransmogCollection_GetSourceInfo(itemFrame.sourceID).quality
			local r, g, b = GetItemQualityColor(quality or 1)
			icon.backdrop:SetBackdropBorderColor(r, g, b)
		else
			icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end)

	_G.WardrobeSetsCollectionVariantSetsButton.Icon:SetTexture(E.Media.Textures.ArrowUp)
	_G.WardrobeSetsCollectionVariantSetsButton.Icon:SetRotation(S.ArrowRotation.down)

	local WardrobeFrame = _G.WardrobeFrame
	S:HandlePortraitFrame_WCollections(WardrobeFrame, true)

	for i=1, 6 do
		S:HandleTab(_G['WardrobeFrameTab'..i])
	end

	local WardrobeOutfitFrame = _G.WardrobeOutfitFrame
	WardrobeOutfitFrame:StripTextures_WCollections()
	WardrobeOutfitFrame:SetTemplate('Transparent')
	S:HandleButton(_G.WardrobeOutfitDropDown.SaveButton)
	S:HandleDropDownBox(_G.WardrobeOutfitDropDown, 221)
	_G.WardrobeOutfitDropDown:Height(34)
	_G.WardrobeOutfitDropDown.SaveButton:ClearAllPoints()
	_G.WardrobeOutfitDropDown.SaveButton:Point('TOPLEFT', _G.WardrobeOutfitDropDown, 'TOPRIGHT', -2, -2)

	local WardrobeTransmogFrame = _G.WardrobeTransmogFrame
	WardrobeTransmogFrame:StripTextures_WCollections()

	for i = 1, #WardrobeTransmogFrame.SlotButtons do
		local slotButton = WardrobeTransmogFrame.SlotButtons[i]
		slotButton:SetFrameLevel(slotButton:GetFrameLevel() + 2)
		slotButton:StripTextures_WCollections()
		slotButton:CreateBackdrop()--nil, nil, nil, nil, nil, nil, nil, true
		slotButton.backdrop:SetPoint("TOPLEFT", -2, 2);
		slotButton.backdrop:SetPoint("BOTTOMRIGHT", 2, -2);
		slotButton.Border:Kill()
		slotButton.Icon:SetTexCoord(unpack(E.TexCoords))
		--slotButton.Icon:SetInside(slotButton.backdrop)
		slotButton.NoItemTexture:SetTexture([[Interface\AddOns\WCollections\Interface\Transmogrify\Textures]]);
		slotButton.HiddenVisualCover:SetTexture([[Interface\AddOns\WCollections\Interface\Transmogrify\Transmogrify]]);
		slotButton.StatusBorder:SetTexture([[Interface\AddOns\WCollections\Interface\Transmogrify\Transmogrify]]);
		slotButton:GetHighlightTexture():SetTexture(1, 1, 1, 0.3)
		slotButton:GetHighlightTexture():SetBlendMode('ADD')
		slotButton:GetHighlightTexture():SetAllPoints(slotButton.Icon)
		hooksecurefunc(slotButton.SelectedTexture, "Show", transmogSlotButtonSelect);
		hooksecurefunc(slotButton.SelectedTexture, "Hide", transmogSlotButtonUnselect);

		local undo = slotButton.UndoButton
		if undo then undo:SetHighlightTexture(nil) end

		local pending = slotButton.PendingFrame
		if pending then
			if slotButton.transmogType == 1 then
				pending.Glow:Size(48)
				pending.Ants:Size(30)
			else
				pending.Glow:Size(74)
				pending.Ants:Size(48)
			end
		end
	end

	WardrobeTransmogFrame.SpecButton:ClearAllPoints()
	WardrobeTransmogFrame.SpecButton:Point('RIGHT', WardrobeTransmogFrame.ApplyButton, 'LEFT', -2, 0)
	S:HandleButton_WCollections(WardrobeTransmogFrame.SpecButton)
	S:HandleButton(WardrobeTransmogFrame.ApplyButton)
	S:HandleButton_WCollections(WardrobeTransmogFrame.Model.ClearAllPendingButton)

	WardrobeCollectionFrame.ItemsCollectionFrame:StripTextures_WCollections()
	WardrobeCollectionFrame.ItemsCollectionFrame:SetTemplate('Transparent')

	WardrobeCollectionFrame.SetsTransmogFrame:StripTextures_WCollections()
	WardrobeCollectionFrame.SetsTransmogFrame.OverlayLayer:StripTextures_WCollections()
	WardrobeCollectionFrame.SetsTransmogFrame:SetTemplate('Transparent')
	S:HandleNextPrevButton(WardrobeCollectionFrame.SetsTransmogFrame.PagingFrame.NextPageButton, "left")
	S:HandleNextPrevButton(WardrobeCollectionFrame.SetsTransmogFrame.PagingFrame.PrevPageButton, "right")

	local WardrobeOutfitEditFrame = _G.WardrobeOutfitEditFrame
	WardrobeOutfitEditFrame:StripTextures_WCollections()
	WardrobeOutfitEditFrame:SetTemplate('Transparent')
	WardrobeOutfitEditFrame.EditBox.LeftTexture:SetAlpha(0);
	WardrobeOutfitEditFrame.EditBox.RightTexture:SetAlpha(0);
	WardrobeOutfitEditFrame.EditBox.MiddleTexture:SetAlpha(0);
	S:HandleEditBox(WardrobeOutfitEditFrame.EditBox)
	WardrobeOutfitEditFrame.EditBox.backdrop:Point("TOPLEFT", -2, -4)
	WardrobeOutfitEditFrame.EditBox.backdrop:Point("BOTTOMRIGHT", 2, 4)
	S:HandleButton(WardrobeOutfitEditFrame.AcceptButton)
	S:HandleButton(WardrobeOutfitEditFrame.CancelButton)
	S:HandleButton(WardrobeOutfitEditFrame.DeleteButton)

	local WardrobeOutfitSaveFrame = _G.WardrobeOutfitSaveFrame
	WardrobeOutfitSaveFrame:StripTextures_WCollections()
	WardrobeOutfitSaveFrame:SetTemplate('Transparent')
	WardrobeOutfitSaveFrame.EditBox.LeftTexture:SetAlpha(0);
	WardrobeOutfitSaveFrame.EditBox.RightTexture:SetAlpha(0);
	WardrobeOutfitSaveFrame.EditBox.MiddleTexture:SetAlpha(0);
	S:HandleEditBox(WardrobeOutfitSaveFrame.EditBox)
	WardrobeOutfitSaveFrame.EditBox.backdrop:Point("TOPLEFT", -2, -4)
	WardrobeOutfitSaveFrame.EditBox.backdrop:Point("BOTTOMRIGHT", 2, 4)
	S:HandleCheckBox(WardrobeOutfitSaveFrame.Prepaid)
	S:HandleButton(WardrobeOutfitSaveFrame.AcceptButton)
	S:HandleButton(WardrobeOutfitSaveFrame.CancelButton)
	WardrobeOutfitSaveFrame.SlotsContainer:StripTextures_WCollections();
	WardrobeOutfitSaveFrame.SlotsContainer:CreateBackdrop();
	for _, button in ipairs(WardrobeOutfitSlotsSelectionFrame.Buttons) do
		S:HandleCheckBox(button)
		button.Failed:SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]]);
		button.IconOverlayApplied:SetTexture([[Interface\AddOns\WCollections\Interface\Transmogrify\Transmogrify]]);
		button.IconOverlayPending:SetTexture([[Interface\AddOns\WCollections\Interface\Transmogrify\PurpleIconAlertAnts]]);
	end

	WCollectionsClaimQuestPopup:StripTextures_WCollections()
	WCollectionsClaimQuestPopup:SetTemplate('Transparent')
	S:HandleButton(WCollectionsClaimQuestPopup.AcceptButton);
	S:HandleButton(WCollectionsClaimQuestPopup.CancelButton);
	for _, Model in ipairs(WCollectionsClaimQuestPopup.Models) do
		SkinCollectionModel(Model);
	end

	WCollectionsCameraPreviewPopup:StripTextures_WCollections()
	WCollectionsCameraPreviewPopup:SetTemplate('Transparent')
	S:HandleButton(WCollectionsCameraPreviewPopup.AcceptButton);
	S:HandleNextPrevButton(WCollectionsCameraPreviewPopup.OptionsPrev, "left");
	S:HandleNextPrevButton(WCollectionsCameraPreviewPopup.OptionsNext, "right");
	WCollectionsCameraPreviewPopup.OptionsPrev:Point("RIGHT", WCollectionsCameraPreviewPopup.Options, "LEFT", 12, 3);
	WCollectionsCameraPreviewPopup.OptionsNext:Point("LEFT", WCollectionsCameraPreviewPopup.Options, "RIGHT", 0, 3);
	S:HandleDropDownBox(WCollectionsCameraPreviewPopup.Options, nil, "down");
	for _, Model in ipairs(WCollectionsCameraPreviewPopup.Models) do
		SkinCollectionModel(Model);
		Model.Text:Point("TOP", Model, "BOTTOM", 0, -3);
	end
end

local function SkinCollectionsFrames()
	S:HandlePortraitFrame_WCollections(_G.CollectionsJournal, true)

	for i=1, 7 do
		S:HandleTab(_G['CollectionsJournalTab'..i])
	end

	SkinNewsFrame()
	SkinAurasFrame()
	SkinMountFrame()
	SkinPetFrame()
	SkinToyFrame()
end

function S:Blizzard_Collections()
	if not E.private.skins.blizzard.enable then return end
	if E.private.skins.blizzard.collections then SkinCollectionsFrames() end
	if E.private.skins.blizzard.transmogrify then SkinTransmogFrames() end
end

S:AddCallback("Collections_WCollections", function()
	S:Blizzard_Collections();
end);

V.skins.blizzard.collections = true;
V.skins.blizzard.transmogrify = true;

end);
WCollections:MergeHook("WCollectionsElvUIEnhancedHook", function()

local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local MF = E:GetModule("Enhanced_ModelFrames", true) or E:GetModule("HookModelFrames", true)

S:AddCallback("CollectionsModels_WCollections", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.transmogrify then return end

	if MF and MF.ModelWithControls_WCollections and E.private.enhanced.character.modelFrames then
		MF:ModelWithControls_WCollections(WardrobeCollectionFrame.SetsCollectionFrame.Model);
		MF:ModelWithControls_WCollections(WardrobeTransmogFrame.Model);
	end
end);

end);
WCollections:MergeHook("WCollectionsElvUIConfigHook", function()

local E, L, V, P, G = unpack(ElvUI);

E.Options.args.skins.args.blizzard.args.collections = {
	type = "toggle",
	name = COLLECTIONS,
	desc = L["TOGGLESKIN_DESC"]
};
E.Options.args.skins.args.blizzard.args.transmogrify = {
	type = "toggle",
	name = TRANSMOGRIFY,
	desc = L["TOGGLESKIN_DESC"]
};

end);
