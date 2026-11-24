--[[----------------------------------------------------------------------------
JudgeMyJPEG - Plugin Info Provider
Persists Coach/Roast mode and 7-language preference in LrPrefs.prefsForPlugin().
------------------------------------------------------------------------------]]

local LrDialogs = import 'LrDialogs'
local LrPrefs = import 'LrPrefs'
local LrProgressScope = import 'LrProgressScope'
local LrTasks = import 'LrTasks'
local LrView = import 'LrView'
local bind = LrView.bind

local JudgeMyJPEGAPI = require 'JudgeMyJPEGAPI'

local function syncPreferencesToPrefs(propertyTable)
	local prefs = LrPrefs.prefsForPlugin()
	if propertyTable.analysisMode == 'smart' or propertyTable.analysisMode == 'roast' then
		prefs.analysisMode = propertyTable.analysisMode
	end
	if propertyTable.language and propertyTable.language ~= '' then
		prefs.language = propertyTable.language
	end
end

return {
	startDialog = function(propertyTable)
		local prefs = LrPrefs.prefsForPlugin()
		propertyTable.analysisMode = prefs.analysisMode or 'smart'
		propertyTable.language = prefs.language or 'en'
		propertyTable.connectionStatus = JudgeMyJPEGAPI.isConnected()
			and 'Connected to JudgeMyJPEG'
			or 'Not connected'

		propertyTable:addObserver('analysisMode', function(properties)
			syncPreferencesToPrefs(properties)
		end)
		propertyTable:addObserver('language', function(properties)
			syncPreferencesToPrefs(properties)
		end)
	end,

	endDialog = function(propertyTable)
		syncPreferencesToPrefs(propertyTable)
	end,

	sectionsForTopOfDialog = function(f, propertyTable)
		return {
			{
				title = 'JudgeMyJPEG Account',
				f:row {
					f:static_text {
						title = 'Analyze your selected photo directly inside Lightroom Classic — no manual export or image URL required. Free accounts include 3 analyses/month.',
						width_in_chars = 60,
						height_in_lines = 2,
						wrap = true,
					},
				},
				f:row {
					f:static_text { title = bind 'connectionStatus', width_in_chars = 40 },
				},
				f:row {
					f:push_button {
						title = 'Connect in Browser',
						action = function()
							LrTasks.startAsyncTask(function()
								local progressScope = LrProgressScope({ title = 'JudgeMyJPEG Pairing' })
								local token, errorMessage = JudgeMyJPEGAPI.connect(progressScope)
								progressScope:done()

								if token then
									propertyTable.connectionStatus = 'Connected to JudgeMyJPEG'
									LrDialogs.message('JudgeMyJPEG', 'Connected successfully. You can now analyze selected photos from Library > Plug-in Extras.', 'info')
								else
									LrDialogs.message('JudgeMyJPEG', errorMessage or 'Connection canceled.', 'critical')
								end
							end)
						end,
					},
					f:push_button {
						title = 'Disconnect',
						action = function()
							JudgeMyJPEGAPI.clearToken()
							propertyTable.connectionStatus = 'Not connected'
						end,
					},
				},
			},
			{
				title = 'Analysis Preferences',
				f:row {
					f:static_text { title = 'Mode:', width = LrView.share 'label_width' },
					f:popup_menu {
						value = bind 'analysisMode',
						items = {
							{ title = 'Coach (constructive)', value = 'smart' },
							{ title = 'Roast (unfiltered)', value = 'roast' },
						},
						width_in_chars = 24,
					},
				},
				f:row {
					f:static_text { title = 'Language:', width = LrView.share 'label_width' },
					f:popup_menu {
						value = bind 'language',
						items = {
							{ title = 'English', value = 'en' },
							{ title = 'Français', value = 'fr' },
							{ title = 'Español', value = 'es' },
							{ title = 'Deutsch', value = 'de' },
							{ title = 'Italiano', value = 'it' },
							{ title = 'Português', value = 'pt' },
							{ title = '中文 (简体)', value = 'zh' },
						},
						width_in_chars = 24,
					},
				},
			},
		}
	end,
}
