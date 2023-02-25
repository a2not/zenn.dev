---
title: "Transparent Telemetryの概要"
emoji: "🌌"
type: "tech"
topics: ["go", "oss", "proposal"]
published: false
---

# 背景

Goのtoolchainにtelemetryを導入することで、`go`, `gopls`, `govulncheck`などのコマンドラインツールの使われ方についての情報を収集し、オープンソースであるGo言語の開発に活用しようというproposalがあります。
[telemetry in the Go toolchain #58409](https://github.com/golang/go/discussions/58409) 

Discussionsは賛否両論ですが、本記事執筆時点ではDiscussionsはLockされ、[proposalの投稿](https://github.com/golang/go/discussions/58409#discussion-4835204)には👍(162)よりも👎(518)のリアクションが多くついていたり、[「デフォルトでoff、もしくは初回利用時にon/offを選択できるようにすべき」](https://github.com/golang/go/discussions/58409#discussioncomment-4905912)といった意見が支持を集めている現状のようです。

本記事は、Go toolchainへのtelemetry導入のproposalの展望を理解するために、proposalと同じ時期に投稿された[Transparent Telemetry](https://research.swtch.com/telemetry)の4本の記事（Discussionsを受けて追加された1本の追加記事含む）について概要をまとめます。^[この記事は和訳記事ではなく、個人的な解釈に基づいた概要のまとめです。誤りに気づいた場合はコメント下さい。]

