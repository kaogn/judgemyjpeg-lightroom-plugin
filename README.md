# JudgeMyJPEG for Adobe Lightroom Classic (v1.1.1)

An official, open-source Adobe Lightroom Classic plugin that renders a temporary JPEG preview locally and sends it to [JudgeMyJPEG](https://www.judgemyjpeg.com) for AI photo feedback.

## Features

- Analyze the selected photo directly inside your Lightroom catalog — score out of 100, summary, and concrete technical suggestions.
- Pair Lightroom Classic with your JudgeMyJPEG account in one click through your browser.
- Render a temporary JPEG preview automatically without modifying your original RAW files or catalog.
- Choose **Coach** (constructive technical guidance) or **Roast** (unfiltered humor).
- Receive critiques in **7 languages**: English, French, Spanish, German, Italian, Portuguese, and Simplified Chinese (`zh`).
- Store scores directly in Lightroom plugin metadata (`JudgeMyJPEG Score`, `JudgeMyJPEG Mode`, etc.) and sync full results to your JudgeMyJPEG account.
- Free and open-source plugin (works with any JudgeMyJPEG account, which includes 3 free analyses/month; optional Pro plans for unlimited usage).

## Install

1. Download and extract `JudgeMyJPEG-Lightroom-Plugin-v1.1.1.zip` (or clone this repository).
2. In Adobe Lightroom Classic, open **File → Plug-in Manager**.
3. Click **Add** and select `JudgeMyJPEG.lrdevplugin`.
4. Under **JudgeMyJPEG Account**, click **Connect in Browser** to pair your account, then select your preferred **Mode** and **Language**.
5. Select one photo in Library and choose **Library → Plug-in Extras → Analyze Selected Photo**.

Compatible with Adobe Lightroom Classic 6.0+.

## Development

The plugin is written in Lua and uses Lightroom Classic's SDK (no build step required).

## License and names

The plugin source is licensed under the MIT License; see [LICENSE](LICENSE). The bundled JSON module retains its own MIT notice in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

JudgeMyJPEG is a product name of CodeCraft Plus. The MIT license does not grant rights to the JudgeMyJPEG or Adobe trademarks, or to the hosted JudgeMyJPEG service. This project is not affiliated with Adobe.

Support: [contact.judgemyjpeg@gmail.com](mailto:contact.judgemyjpeg@gmail.com) · [https://www.judgemyjpeg.com/plugin-lightroom](https://www.judgemyjpeg.com/plugin-lightroom)
