--[[----------------------------------------------------------------------------
JudgeMyJPEG - Plugin Info Provider
------------------------------------------------------------------------------]]

local LrDialogs = import 'LrDialogs'
local LrProgressScope = import 'LrProgressScope'
local LrTasks = import 'LrTasks'
local LrView = import 'LrView'
local bind = LrView.bind

local JudgeMyJPEGAPI = require 'JudgeMyJPEGAPI'

return {
	sectionsForTopOfDialog = function(f, propertyTable)
		propertyTable.connectionStatus = JudgeMyJPEGAPI.isConnected()
			and 'Compte JudgeMyJPEG connecté'
			or 'Compte JudgeMyJPEG non connecté'

		return {
			{
				title = 'JudgeMyJPEG',
				f:row {
					f:static_text {
						title = 'Analysez la photo sélectionnée avec JudgeMyJPEG, sans exporter manuellement de fichier.',
						width_in_chars = 58,
						height_in_lines = 2,
						wrap = true,
					},
				},
				f:row {
					f:static_text { title = bind 'connectionStatus', width_in_chars = 40 },
				},
				f:row {
					f:push_button {
						title = 'Se connecter dans le navigateur',
						action = function()
							LrTasks.startAsyncTask(function()
								local progressScope = LrProgressScope({ title = 'Connexion JudgeMyJPEG' })
								local token, errorMessage = JudgeMyJPEGAPI.connect(progressScope)
								progressScope:done()

								if token then
									propertyTable.connectionStatus = 'Compte JudgeMyJPEG connecté'
									LrDialogs.message('JudgeMyJPEG', 'Connexion réussie. Vous pouvez analyser une photo.', 'info')
								else
									LrDialogs.message('JudgeMyJPEG', errorMessage or 'Connexion annulée.', 'critical')
								end
							end)
						end,
					},
					f:push_button {
						title = 'Déconnecter',
						action = function()
							JudgeMyJPEGAPI.clearToken()
							propertyTable.connectionStatus = 'Compte JudgeMyJPEG non connecté'
						end,
					},
				},
			},
			{
				title = 'Préférences d’analyse',
				f:row {
					f:static_text { title = 'Ton :', width = LrView.share 'label_width' },
					f:popup_menu {
						value = bind 'analysisMode',
						items = {
							{ title = 'Coach', value = 'smart' },
							{ title = 'Roast', value = 'roast' },
						},
						width_in_chars = 20,
					},
				},
				f:row {
					f:static_text { title = 'Langue :', width = LrView.share 'label_width' },
					f:popup_menu {
						value = bind 'language',
						items = {
							{ title = 'Français', value = 'fr' },
							{ title = 'English', value = 'en' },
							{ title = 'Español', value = 'es' },
							{ title = 'Deutsch', value = 'de' },
							{ title = 'Italiano', value = 'it' },
							{ title = 'Português', value = 'pt' },
						},
						width_in_chars = 20,
					},
				},
			},
			{
				title = 'Compatibilité ancienne version',
				f:row {
					f:static_text {
						title = 'Les anciens Tokens MCP restent disponibles uniquement pour la comparaison A/B.',
						width_in_chars = 58,
						height_in_lines = 2,
						wrap = true,
					},
				},
				f:row {
					f:password_field {
						value = bind 'mcpToken',
						width_in_chars = 40,
					},
				},
			},
		}
	end,
}
