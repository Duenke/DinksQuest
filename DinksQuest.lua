DinksQuest = LibStub("AceAddon-3.0"):NewAddon("DinksQuest", "AceConsole-3.0", "AceEvent-3.0")

------------------------------------------
-- #region: locals
------------------------------------------



------------------------------------------
-- #endregion: locals
------------------------------------------

------------------------------------------
-- #region: lifecycle functions
------------------------------------------

function DinksQuest:OnInitialize()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteringWorld")
end

function DinksQuest:OnEnable()
	self:Print("Addon Enabled")
end

function DinksQuest:OnDisable()
	self:Print("Addon Disabled")
end

------------------------------------------
-- #endregion: lifecycle functions
------------------------------------------

------------------------------------------
-- #region: local functions
------------------------------------------

function DinksQuest:OnPlayerEnteringWorld()
	self.progressFrame = CreateProgressFrame()
	self:RegisterEvent("QUEST_LOG_UPDATE", "UpdateQuestProgress")
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateQuestProgress")
end

function CreateProgressFrame()
	local frame = CreateFrame("Frame", "DinksQuestProgressFrame", UIParent)
	frame:SetSize(200, 100)
	frame:SetPoint("TOPRIGHT", ObjectiveTrackerFrame, "TOPRIGHT", 200, 0)
	frame:Show()

	frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.text:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
	frame.text:SetText("Party Quest Progress:")

	return frame
end

function DinksQuest:UpdateQuestProgress()
	local questID = C_SuperTrack.GetSuperTrackedQuestID()
	if questID and IsInGroup() then
		local progress = GetPartyQuestProgress(questID)
		UpdateProgressFrame(self.progressFrame, progress)
	else
		self.progressFrame:Hide()
	end
end

function GetPartyQuestProgress(questID)
	local progress = {}
	for i = 1, GetNumGroupMembers() do
		local unit = "party" .. i
		if UnitExists(unit) then
			local objectives = C_QuestLog.GetQuestObjectives(questID)
			if objectives then
				for _, objective in ipairs(objectives) do
					local text, type, finished = GetQuestObjectiveInfo(questID, objective.index, false)
					table.insert(progress, { name = UnitName(unit), text = text, finished = finished })
				end
			end
		end
	end
	return progress
end

function UpdateProgressFrame(frame, progress)
	frame:Hide()
	if #progress > 0 then
		local text = frame.text
		for _, p in ipairs(progress) do
			local line = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			line:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -5)
			line:SetText(p.name .. ": " .. p.text .. (p.finished and " (Completed)" or ""))
			text = line
		end
		frame:Show()
	end
end

------------------------------------------
-- #endregion: local functions
------------------------------------------
