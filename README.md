# JudgeMyJPEG for Lightroom Classic

An Adobe Lightroom Classic plugin that sends a rendered JPEG to JudgeMyJPEG for photo feedback.

## Features

- Analyze the selected photo and view its score, summary, and suggestions.
- Pair Lightroom with a JudgeMyJPEG account through the browser.
- Render a temporary JPEG from the selected photo before analysis.
- Choose **Coach** for constructive guidance or **Roast** for a humorous critique.
- Select French, English, Spanish, German, Italian, or Portuguese for the analysis.
- Save results to the connected JudgeMyJPEG account and use its analysis quota.

The comparison command is a legacy feature. It still relies on the older MCP token flow and public image URLs; the regular photo analysis does not.

## Install

1. Download or clone this repository.
2. In Lightroom Classic, open **File → Plug-in Manager**.
3. Select **Add** and choose `JudgeMyJPEG.lrdevplugin`.
4. Open the plugin settings and connect your JudgeMyJPEG account in the browser.
5. Select one photo, then choose **Library → Plug-in Extras → Analyze Selected Photo**.

The plugin metadata declares Lightroom Classic 6.0 as its minimum version. The included SDK metadata and Adobe's compatibility requirements may vary by Lightroom release.

## Development

The plugin is written in Lua and uses Lightroom Classic's SDK. It has no separate build step. Report bugs with the Lightroom version, plugin version, and steps to reproduce.

## License and names

The plugin source is licensed under the MIT License; see [LICENSE](LICENSE). The bundled JSON module retains its own MIT notice in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

JudgeMyJPEG is a product name of CodeCraft Plus. The MIT license does not grant rights to the JudgeMyJPEG or Adobe trademarks, or to the hosted JudgeMyJPEG service. This project is not affiliated with Adobe.

Support: [contact.judgemyjpeg@gmail.com](mailto:contact.judgemyjpeg@gmail.com)
