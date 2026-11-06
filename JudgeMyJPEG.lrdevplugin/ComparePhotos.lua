--[[----------------------------------------------------------------------------
JudgeMyJPEG - Compare Photos
Compare 2 photos sélectionnées (Battle A/B)
------------------------------------------------------------------------------]]

local LrApplication = import 'LrApplication'
local LrDialogs = import 'LrDialogs'
local LrTasks = import 'LrTasks'
local LrLogger = import 'LrLogger'
local LrFunctionContext = import 'LrFunctionContext'
local LrProgressScope = import 'LrProgressScope'

local JudgeMyJPEGAPI = require 'JudgeMyJPEGAPI'

local logger = LrLogger('JudgeMyJPEG')
logger:enable('logfile')

--[[----------------------------------------------------------------------------
Fonction principale de comparaison
------------------------------------------------------------------------------]]
LrTasks.startAsyncTask(function()
	LrFunctionContext.callWithContext('comparePhotos', function(context)
		local catalog = LrApplication.activeCatalog()
		local selectedPhotos = catalog:getTargetPhotos()

		if #selectedPhotos ~= 2 then
			LrDialogs.message(
				'Sélection incorrecte',
				'Veuillez sélectionner exactement 2 photos à comparer.\n\n' ..
					'Actuellement sélectionnées: ' .. #selectedPhotos,
				'info'
			)
			return
		end

		local progressScope = LrProgressScope({
			title = 'JudgeMyJPEG - Battle Photo',
			functionContext = context,
		})

		progressScope:setCaption('Préparation des photos...')

		-- Demander les URLs des deux photos
		local photoUrlA = LrDialogs.presentTextDialog({
			title = 'Photo A - URL',
			message = 'Entrez l\'URL publique de la première photo:',
			defaultValue = '',
			actionVerb = 'Suivant',
		})

		if not photoUrlA or photoUrlA == '' then
			progressScope:done()
			return
		end

		local photoUrlB = LrDialogs.presentTextDialog({
			title = 'Photo B - URL',
			message = 'Entrez l\'URL publique de la deuxième photo:',
			defaultValue = '',
			actionVerb = 'Comparer',
		})

		if not photoUrlB or photoUrlB == '' then
			progressScope:done()
			return
		end

		progressScope:setCaption('Comparaison en cours avec l\'IA...')
		progressScope:setPortionComplete(0.5, 1)

		-- Appel API
		local result, errorMsg = JudgeMyJPEGAPI.comparePhotos(photoUrlA, photoUrlB)

		if errorMsg then
			progressScope:done()
			LrDialogs.message('Erreur', errorMsg, 'critical')
			return
		end

		progressScope:setPortionComplete(1, 1)
		progressScope:done()

		-- Extraction des résultats
		local winner = result.result.winner
		local scoreA = result.result.photo_a_score
		local scoreB = result.result.photo_b_score
		local comparison = result.result.comparison

		-- Construction du message
		local winnerEmoji = winner == 'photo_a' and '🥇' or '🥈'
		local loserEmoji = winner == 'photo_a' and '🥈' or '🥇'

		local message = string.format(
			'%s Photo A: %d/100\n%s Photo B: %d/100\n\n',
			winnerEmoji,
			scoreA,
			loserEmoji,
			scoreB
		)

		if winner == 'photo_a' then
			message = message .. '🏆 Gagnant: Photo A\n\n'
		elseif winner == 'photo_b' then
			message = message .. '🏆 Gagnant: Photo B\n\n'
		else
			message = message .. '🤝 Égalité!\n\n'
		end

		message = message .. comparison

		-- Affichage
		LrDialogs.message(
			'Battle Photo - ' .. (winner == 'photo_a' and 'A' or 'B') .. ' gagne!',
			message,
			'info'
		)

		logger:info(string.format('Comparaison terminée - Gagnant: %s (%d vs %d)', winner, scoreA, scoreB))
	end)
end)
