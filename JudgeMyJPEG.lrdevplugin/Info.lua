--[[----------------------------------------------------------------------------
JudgeMyJPEG - Plugin Lightroom Classic
Analyse vos photos directement depuis Lightroom avec l'IA de JudgeMyJPEG
------------------------------------------------------------------------------]]

return {
	-- Informations du plugin
	LrSdkVersion = 9.0,
	LrSdkMinimumVersion = 6.0,

	LrToolkitIdentifier = 'fr.judgemyjpeg.lightroom',
	LrPluginName = 'JudgeMyJPEG',

	VERSION = { major = 1, minor = 1, revision = 0 },

	-- Informations de contact
	LrPluginInfoUrl = 'https://www.judgemyjpeg.com/plugin-lightroom',
	LrPluginInfoProvider = 'PluginInfoProvider.lua',

	-- Menu dans Library
	LrLibraryMenuItems = {
		{
			title = 'Analyser la photo sélectionnée',
			file = 'AnalyzePhoto.lua',
			enabledWhen = 'photosSelected',
		},
		{
			title = 'Comparer 2 photos (A/B)',
			file = 'ComparePhotos.lua',
			enabledWhen = 'photosSelected',
		},
		{
			title = LOC '$$$/JudgeMyJPEG/Menu/Separator1=–',
		},
		{
			title = 'Paramètres JudgeMyJPEG',
			file = 'Settings.lua',
		},
	},

	-- Export presets (optionnel, pour futures fonctionnalités)
	LrExportMenuItems = {
		{
			title = 'Analyser avant export',
			file = 'AnalyzeBeforeExport.lua',
		},
	},
}
