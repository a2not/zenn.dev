---
title: "The Design of Transparent Telemetryを読む"
emoji: "🌌"
type: "tech"
topics: ["go", "oss", "proposal"]
published: false
---

[目次ページはこちら](https://zenn.dev/a2not/articles/telemetry-index)

[The Design of Transparent Telemetry](https://research.swtch.com/telemetry-design)^["[Transparent Telemetry](https://research.swtch.com/telemetry)" © Russ Cox [Licensed under CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)]

Transparent Telemetryのデザインについて、5つの要素に分けて説明しています。

- Counting: カウンタの値(メトリクス)を週毎にローカルファイルとして管理する
- Configuration: 
- Reporting:
- Publishing:
- Opt-out:

# [Counting](https://research.swtch.com/telemetry-design#counting)

