--[[----------------------------------------------------------------------------
JudgeMyJPEG - API client for Lightroom Classic
Handles browser pairing, JPEG rendering and authenticated analysis requests.
------------------------------------------------------------------------------]]

local LrBase64 = import 'LrBase64'
local LrExportSession = import 'LrExportSession'
local LrFileUtils = import 'LrFileUtils'
local LrHttp = import 'LrHttp'
local LrLogger = import 'LrLogger'
local LrPathUtils = import 'LrPathUtils'
local LrPrefs = import 'LrPrefs'
local LrTasks = import 'LrTasks'
local LrUUID = import 'LrUUID'
local json = require 'json'

local logger = LrLogger('JudgeMyJPEG')
logger:enable('logfile')

local JudgeMyJPEGAPI = {}

JudgeMyJPEGAPI.BASE_URL = 'https://www.judgemyjpeg.com'
JudgeMyJPEGAPI.PAIRING_START_URL = JudgeMyJPEGAPI.BASE_URL .. '/api/lightroom/pair/start'
JudgeMyJPEGAPI.PAIRING_STATUS_URL = JudgeMyJPEGAPI.BASE_URL .. '/api/lightroom/pair/status'
JudgeMyJPEGAPI.PAIRING_PAGE_URL = JudgeMyJPEGAPI.BASE_URL .. '/auth/lightroom'
JudgeMyJPEGAPI.ANALYZE_URL = JudgeMyJPEGAPI.BASE_URL .. '/api/lightroom/analyze'

local function getStatusCode(headers)
	if not headers then return nil end
	for _, header in ipairs(headers) do
		if header.field == 'status' then
			return tonumber(header.value)
		end
	end
	return nil
end

local function getPreferences()
	return LrPrefs.prefsForPlugin()
end

function JudgeMyJPEGAPI.getToken()
	local prefs = getPreferences()
	return prefs.accessToken or prefs.mcpToken
end

function JudgeMyJPEGAPI.isConnected()
	local token = JudgeMyJPEGAPI.getToken()
	return token ~= nil and token ~= ''
end

function JudgeMyJPEGAPI.getSettings()
	local prefs = getPreferences()
	return {
		tone = prefs.analysisMode or 'smart',
		language = prefs.language or 'fr',
	}
end

function JudgeMyJPEGAPI.clearToken()
	getPreferences().accessToken = nil
end

local function generatePairingCode()
	local ok, uuid = pcall(LrUUID.generateUUID)
	if ok and uuid then
		return uuid
	end
	return tostring(os.time()) .. '-' .. tostring(math.random()) .. '-' .. tostring(math.random())
end

function JudgeMyJPEGAPI.startPairing()
	local code = generatePairingCode()
	local response, headers = LrHttp.post(
		JudgeMyJPEGAPI.PAIRING_START_URL,
		json.encode({ code = code }),
		{ { field = 'Content-Type', value = 'application/json' } },
		'POST',
		15
	)

	if getStatusCode(headers) ~= 201 then
		logger:error('Unable to start Lightroom pairing: ' .. tostring(response))
		return nil, 'Impossible de démarrer la connexion JudgeMyJPEG.'
	end

	return code, nil
end

function JudgeMyJPEGAPI.waitForPairing(code, progressScope)
	for attempt = 1, 60 do
		local response, headers = LrHttp.get(
			JudgeMyJPEGAPI.PAIRING_STATUS_URL .. '?code=' .. code,
			{},
			15
		)
		local status = getStatusCode(headers)

		if status == 200 and response then
			local ok, payload = pcall(json.decode, response)
			if ok and payload.status == 'completed' and payload.accessToken then
				return payload.accessToken, nil
			end
		elseif status == 404 then
			return nil, 'La demande de connexion a expiré.'
		elseif status == 503 then
			return nil, 'Le service de connexion est temporairement indisponible.'
		end

		if progressScope then
			progressScope:setPortionComplete(attempt / 60, 1)
			progressScope:setCaption('En attente de la connexion dans le navigateur...')
		end
		LrTasks.sleep(2)
	end

	return nil, 'La connexion a pris trop de temps. Relancez l’opération.'
end

function JudgeMyJPEGAPI.connect(progressScope)
	local code, startError = JudgeMyJPEGAPI.startPairing()
	if startError then return nil, startError end

	LrHttp.openUrlInBrowser(JudgeMyJPEGAPI.PAIRING_PAGE_URL .. '?code=' .. code)
	local token, errorMessage = JudgeMyJPEGAPI.waitForPairing(code, progressScope)
	if token then
		getPreferences().accessToken = token
	end
	return token, errorMessage
end

function JudgeMyJPEGAPI.exportPhotoTemp(photo)
	local tempPath = LrPathUtils.getStandardFilePath('temp')
	local exportFolder = LrPathUtils.child(tempPath, 'JudgeMyJPEG')
	LrFileUtils.createAllDirectories(exportFolder)

	local fileName = LrPathUtils.leafName(photo:getFormattedMetadata('fileName'))
	local baseName = fileName:gsub('%.[^%.]+$', '')
	local exportPath = LrPathUtils.child(exportFolder, 'JudgeMyJPEG_' .. baseName .. '_' .. tostring(os.time()) .. '.jpg')
	local exportSession = LrExportSession {
		photosToExport = { photo },
		exportSettings = {
			LR_export_destinationType = 'specificFolder',
			LR_export_destinationPathPrefix = exportFolder,
			LR_export_useSubfolder = false,
			LR_format = 'JPEG',
			LR_jpeg_quality = 0.9,
			LR_size_maxWidth = 2048,
			LR_size_maxHeight = 2048,
			LR_size_resizeType = 'wh',
			LR_collisionHandling = 'overwrite',
		},
	}

	for _, rendition in exportSession:renditions() do
		local success, pathOrMessage = rendition:waitForRender()
		if not success then
			return nil, 'Impossible de convertir la photo en JPEG: ' .. tostring(pathOrMessage)
		end
		if pathOrMessage and LrFileUtils.exists(pathOrMessage) then
			return pathOrMessage, nil
		end
	end

	if LrFileUtils.exists(exportPath) then
		return exportPath, nil
	end

	return nil, 'Lightroom n’a pas produit de fichier JPEG.'
end

function JudgeMyJPEGAPI.analyzePhoto(photo, progressScope)
	local token = JudgeMyJPEGAPI.getToken()
	if not token or token == '' then
		return nil, 'Connectez d’abord votre compte JudgeMyJPEG dans les paramètres du plugin.'
	end

	local renderedPath, exportError = JudgeMyJPEGAPI.exportPhotoTemp(photo)
	if not renderedPath then return nil, exportError end

	if progressScope then progressScope:setCaption('Préparation de l’image...') end
	local fileContent = LrFileUtils.readFile(renderedPath)
	if not fileContent then
		LrFileUtils.delete(renderedPath)
		return nil, 'Impossible de lire le JPEG exporté.'
	end

	local settings = JudgeMyJPEGAPI.getSettings()
	local body = json.encode({
		imageBase64 = LrBase64.encode(fileContent),
		filename = LrPathUtils.leafName(renderedPath),
		tone = settings.tone,
		language = settings.language,
	})

	if progressScope then progressScope:setCaption('Analyse JudgeMyJPEG en cours...') end
	local response, headers = LrHttp.post(
		JudgeMyJPEGAPI.ANALYZE_URL,
		body,
		{
			{ field = 'Authorization', value = 'Bearer ' .. token },
			{ field = 'Content-Type', value = 'application/json' },
			{ field = 'User-Agent', value = 'JudgeMyJPEG-Lightroom-Plugin/1.1' },
		},
		'POST',
		60
	)

	LrFileUtils.delete(renderedPath)

	local status = getStatusCode(headers)
	if status ~= 200 then
		local message = status == 403 and 'Votre quota d’analyses est atteint.' or 'Erreur API (' .. tostring(status) .. ').'
		logger:error('Lightroom analysis failed: ' .. tostring(response))
		return nil, message
	end

	local ok, result = pcall(json.decode, response)
	if not ok or not result.analysis then
		return nil, 'Réponse invalide du serveur JudgeMyJPEG.'
	end

	return result, nil
end

-- Kept for the legacy Battle feature. New installations use the browser token
-- for individual analysis; compare remains on the previous MCP endpoint.
function JudgeMyJPEGAPI.comparePhotos(photoUrlA, photoUrlB)
	local token = getPreferences().mcpToken
	if not token or token == '' then
		return nil, 'La comparaison A/B utilise encore l’ancien Token MCP.'
	end

	local response, headers = LrHttp.post(
		'https://mcp-server-production-57ab.up.railway.app/mcp/compare',
		json.encode({ photo_a = photoUrlA, photo_b = photoUrlB }),
		{
			{ field = 'Content-Type', value = 'application/json' },
			{ field = 'x-mcp-token', value = token },
		},
		'POST',
		30
	)

	if getStatusCode(headers) ~= 200 then
		return nil, 'Erreur API de comparaison.'
	end

	local ok, result = pcall(json.decode, response)
	if not ok then return nil, 'Réponse invalide de comparaison.' end
	return result, nil
end

return JudgeMyJPEGAPI
