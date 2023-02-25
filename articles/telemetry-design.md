---
title: "The Design of Transparent Telemetryを読む"
emoji: "🌌"
type: "tech"
topics: ["go", "oss", "proposal"]
published: false
---

[目次ページはこちら](https://zenn.dev/a2not/articles/telemetry-index)

[The Design of Transparent Telemetry](https://research.swtch.com/telemetry-design)^["[Transparent Telemetry](https://research.swtch.com/telemetry)" © Russ Cox [Licensed under CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)]

<!-- ソフトウェアがどのように使われ、期待するパフォーマンスを発揮しているかを知るためのモダンな手法として、Russはtelemetryを上げています。その上で、それをオープンソース向けにした新たなデザインとして"Transparent Telemetry"を提案しています。 -->

# [Counting](https://research.swtch.com/telemetry-design#counting)

