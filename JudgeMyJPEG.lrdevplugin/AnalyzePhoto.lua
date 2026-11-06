--[[----------------------------------------------------------------------------
JudgeMyJPEG - Analyse la photo sélectionnée dans Lightroom Classic
------------------------------------------------------------------------------]]

local LrApplication = import 'LrApplication'
local LrDialogs = import 'LrDialogs'
local LrFunctionContext = import 'LrFunctionContext'
local LrLogger = import 'LrLogger'
local LrProgressScope = import 'LrProgressScope'
local LrTasks = import 'LrTasks'
local LrView = import 'LrView'
local LrBinding = import 'LrBinding'
local LrColor = import 'LrColor'

local JudgeMyJPEGAPI = require 'JudgeMyJPEGAPI'
local logger = LrLogger('JudgeMyJPEG')
logger:enable('logfile')

local function showAnalysisResults(analysis, photo)
	LrFunctionContext.callWithContext('analysisResults', function(context)
		local f = LrView.osFactory()
		local properties = LrBinding.makePropertyTable(context)
		local partialScores = analysis.partialScores or {}
		local suggestions = analysis.suggestions or {}
		local score = tonumber(analysis.score) or 0
		local scoreColor = score >= 85 and 'green' or score >= 70 and 'orange' or 'red'

		local contents = f:column {
			bind_to_object = properties,
			spacing = f:control_spacing(),
			f:static_text {
				title = 'Résultats de l’analyse JudgeMyJPEG',
				text_color = LrColor(scoreColor),
				font = '<system/bold>',
			},
			f:separator {},
			f:row {
				f:static_text { title = 'Score global:', width = LrView.share('label_width') },
				f:static_text { title = score .. '/100', font = '<system/bold>' },
			},
			f:row {
				f:static_text { title = 'Composition:', width = LrView.share('label_width') },
				f:static_text { title = tostring(partialScores.composition or '—') .. '/15' },
			},
			f:row {
				f:static_text { title = 'Éclairage:', width = LrView.share('label_width') },
				f:static_text { title = tostring(partialScores.lighting or partialScores.light or '—') .. '/15' },
			},
			f:row {
				f:static_text { title = 'Netteté:', width = LrView.share('label_width') },
				f:static_text { title = tostring(partialScores.focus or '—') .. '/15' },
			},
			f:row {
				f:static_text { title = 'Exposition:', width = LrView.share('label_width') },
				f:static_text { title = tostring(partialScores.exposure or '—') .. '/15' },
			},
			f:separator {},
			f:static_text { title = 'Résumé:', font = '<system/bold>' },
			f:scrolled_view {
				horizontal_scroller = false,
				width = 420,
				height = 120,
				f:static_text { title = analysis.summary or '—', width = 400 },
			},
			f:static_text { title = 'Suggestions:', font = '<system/bold>' },
			f:scrolled_view {
				horizontal_scroller = false,
				width = 420,
				height = 150,
				f:static_text { title = table.concat(suggestions, '\n• '), width = 400 },
			},
		}

		LrDialogs.presentModalDialog {
			title = 'JudgeMyJPEG - ' .. photo:getFormattedMetadata('fileName'),
			contents = contents,
			cancelVerb = '< exclude "Cancel" >',
			actionVerb = 'Fermer',
		}
	end)
end

LrTasks.startAsyncTask(function()
	LrFunctionContext.callWithContext('analyzePhoto', function(context)
		local catalog = LrApplication.activeCatalog()
		local selectedPhotos = catalog:getTargetPhotos()

		if #selectedPhotos ~= 1 then
			LrDialogs.message(
				'Sélection incorrecte',
				'Veuillez sélectionner exactement une photo dans Lightroom Classic.',
				'info'
			)
			return
		end

		local photo = selectedPhotos[1]
		local progressScope = LrProgressScope({
			title = 'JudgeMyJPEG - Analyse en cours',
			functionContext = context,
		})

		local result, errorMessage = JudgeMyJPEGAPI.analyzePhoto(photo, progressScope)
		progressScope:done()

		if errorMessage then
			LrDialogs.message('JudgeMyJPEG', errorMessage, 'critical')
			return
		end

		local analysis = result.analysis
		local partialScores = analysis.partialScores or {}
		catalog:withWriteAccessDo('JudgeMyJPEG Analysis', function()
			photo:setPropertyForPlugin(_PLUGIN, 'judgeScore', tostring(analysis.score or ''))
			photo:setPropertyForPlugin(_PLUGIN, 'judgeAnalysisDate', os.date('%Y-%m-%d %H:%M:%S'))
			photo:setPropertyForPlugin(_PLUGIN, 'judgeTone', JudgeMyJPEGAPI.getSettings().tone)
			photo:setPropertyForPlugin(_PLUGIN, 'judgeComposition', tostring(partialScores.composition or ''))
			photo:setPropertyForPlugin(_PLUGIN, 'judgeLighting', tostring(partialScores.lighting or partialScores.light or ''))
			photo:setPropertyForPlugin(_PLUGIN, 'judgeFocus', tostring(partialScores.focus or ''))
			photo:setPropertyForPlugin(_PLUGIN, 'judgeExposure', tostring(partialScores.exposure or ''))
		end)

		showAnalysisResults(analysis, photo)
		logger:info('Lightroom analysis completed - score: ' .. tostring(analysis.score))
	end)
end)
