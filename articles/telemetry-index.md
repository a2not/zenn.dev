---
title: "Transparent Telemetryの概要"
emoji: "🌌"
type: "tech"
topics: ["go", "oss", "proposal"]
published: false
---

# 背景

Goのツールチェーンにtelemetryを導入することで、`go`, `gopls`, `govulncheck`などのコマンドラインツールの使われ方についての情報を収集し、オープンソースであるGo言語の開発に活用しようというDiscussionsがあります。
[telemetry in the Go toolchain #58409](https://github.com/golang/go/discussions/58409) 

本記事執筆時点ではDiscussionsはLockされ、[Discussionsの投稿](https://github.com/golang/go/discussions/58409#discussion-4835204)には👍(162)よりも👎(518)のリアクションが多くついていたり、導入に関しては賛否両論といった現状のようです。

本記事は、Goツールチェーンへのtelemetry導入の展望を理解するために、Discussionsと同じ2023年2月8日にRuss Coxにより投稿された[Transparent Telemetry](https://research.swtch.com/telemetry)^["[Transparent Telemetry](https://research.swtch.com/telemetry)" © Russ Cox [Licensed under CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)]の4本の記事(Discussionsを受けて追加された1本の追加記事含む)について概要をまとめます。^[この記事は完全な和訳記事ではなく、個人的な解釈に基づいたまとめで、一部省略や表現の変更などがあります。誤りに気づいた場合はコメント下さい。]



# [Transparent Telemetry for Open-Source Projects](https://research.swtch.com/telemetry-intro)

ソフトウェアがどのように使われ、期待するパフォーマンスを発揮しているかを知るためのモダンな手法として、Russはtelemetryを上げています。その上で、それをオープンソース向けにした新たなデザインとして"Transparent Telemetry"を提案しています。

[Transparent Telemetry for Open-Source Projectsを読む](https://zenn.dev/a2not/articles/telemetry-intro)



# [The Design of Transparent Telemetry](https://research.swtch.com/telemetry-design)

準備中



# [Use Cases for Transparent Telemetry](https://research.swtch.com/telemetry-uses)

準備中



# [Opting In to Transparent Telemetry](https://research.swtch.com/telemetry-opt-in)

準備中



# 最後に

すべて一つの記事にまとめようと考えていましたが、具体例など興味深く丁寧にまとめていたら長くなりそうなので、記事ごとに分割して公開していく予定です。

