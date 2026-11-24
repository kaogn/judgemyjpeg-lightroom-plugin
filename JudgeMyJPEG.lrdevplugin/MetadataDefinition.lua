--[[----------------------------------------------------------------------------
JudgeMyJPEG - Custom Metadata Definition for Lightroom Classic
Declares plugin metadata properties so photo:setPropertyForPlugin writes safely.
------------------------------------------------------------------------------]]

return {
	metadataFieldsForPhotos = {
		{
			id = 'judgeScore',
			title = 'JudgeMyJPEG Score',
			dataType = 'string',
			browsable = true,
			searchable = true,
			readOnly = true,
		},
		{
			id = 'judgeAnalysisDate',
			title = 'JudgeMyJPEG Analysis Date',
			dataType = 'string',
			browsable = false,
			searchable = true,
			readOnly = true,
		},
		{
			id = 'judgeTone',
			title = 'JudgeMyJPEG Mode',
			dataType = 'string',
			browsable = true,
			searchable = true,
			readOnly = true,
		},
		{
			id = 'judgeComposition',
			title = 'JudgeMyJPEG Composition',
			dataType = 'string',
			browsable = false,
			searchable = false,
			readOnly = true,
		},
		{
			id = 'judgeLighting',
			title = 'JudgeMyJPEG Lighting',
			dataType = 'string',
			browsable = false,
			searchable = false,
			readOnly = true,
		},
		{
			id = 'judgeFocus',
			title = 'JudgeMyJPEG Sharpness',
			dataType = 'string',
			browsable = false,
			searchable = false,
			readOnly = true,
		},
		{
			id = 'judgeExposure',
			title = 'JudgeMyJPEG Exposure',
			dataType = 'string',
			browsable = false,
			searchable = false,
			readOnly = true,
		},
	},
	schemaVersion = 1,
}
