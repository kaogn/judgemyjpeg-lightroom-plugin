--[[----------------------------------------------------------------------------
JudgeMyJPEG - Adobe Lightroom Classic Plugin
Analyze selected catalog photos directly with JudgeMyJPEG AI.
------------------------------------------------------------------------------]]

return {
	LrSdkVersion = 9.0,
	LrSdkMinimumVersion = 6.0,

	LrToolkitIdentifier = 'fr.judgemyjpeg.lightroom',
	LrPluginName = 'JudgeMyJPEG',

	VERSION = { major = 1, minor = 1, revision = 1 },

	LrPluginInfoUrl = 'https://www.judgemyjpeg.com/plugin-lightroom',
	LrPluginInfoProvider = 'PluginInfoProvider.lua',
	LrMetadataProvider = 'MetadataDefinition.lua',

	LrLibraryMenuItems = {
		{
			title = 'Analyze Selected Photo',
			file = 'AnalyzePhoto.lua',
			enabledWhen = 'photosSelected',
		},
		{
			title = LOC '$$$/JudgeMyJPEG/Menu/Separator1=–',
		},
		{
			title = 'JudgeMyJPEG Settings',
			file = 'Settings.lua',
		},
	},
}
