---
title: "Viteでgrpc-webを使うのはおすすめできない"
emoji: "⛈️"
type: "tech"
topics: ["vite", "grpc", "grpc-web", "typescript", "javascript"]
published: true
---

# 結論

公式 (https://github.com/grpc/grpc-web) は使えるがおすすめしない。

（※ 間違いや提案などあればコメント下さい。）

# 公式の問題点

[grpc-web not working in a Vite+Typescript app #1242](https://github.com/grpc/grpc-web/issues/1242) などで議論になっていた通りViteとgrpc-webの相性が悪いと言われていたが、原因は公式のgrpc-webがCommon JSかClosureのみしか生成できないことにある。

Viteは原則ESMしか理解しないのでそのままimportすることができない。

## 回避策

Viteは世の中に多数存在するCJS製ライブラリが依存関係に含まれているケースに対応するために、デフォルトで`node_modules/` 内などのCJSをESMに変換してくれる機能を持っている（[依存関係の事前バンドル](https://ja.vitejs.dev/guide/dep-pre-bundling#%E4%BE%9D%E5%AD%98%E9%96%A2%E4%BF%82%E3%81%AE%E4%BA%8B%E5%89%8D%E3%83%8F%E3%82%99%E3%83%B3%E3%83%88%E3%82%99%E3%83%AB) を参照）。

そのため、grpc-webにより生成されたCJSのコードをパッケージ化してしまえばよい。

[サンプル実装](https://github.com/a2not/vite-grpc-web)

## 別の問題点

上記の回避策でViteとの相性が悪い問題は解消するが、ESMを生成できない以外にもgrpc-webがモダン化に追いつけていない別の問題がある。

Viteでgrpc-webを利用したアプリケーションをビルドすると分かるが、生成されたコードが依存する [`google-protobuf`](https://www.npmjs.com/package/google-protobuf) というランタイムライブラリに`eval` が含まれていることについてWarningが出る。

```
node_modules/google-protobuf/google-protobuf.js (48:475) Use of eval in "node_modules/google-protobuf/google-protobuf.js" is strongly discouraged as it poses security risks and may cause issues with minification.
```

この`eval` は、`google-protobuf` がclosureコンパイラによって作られており、その際にコンパイラが依存する[`closure-library`](https://github.com/google/closure-library/tree/master) によって出力されるのだが、[Closure Library is in Maintenance Mode #1214](https://github.com/google/closure-library/issues/1214) にもある通り`closure-library` はモダンなJSの出力に対応できていない・今後もできないと予想されることから今はメンテナンスモードとなっており、2024年8月1日を持って開発終了する事が決まっている。

`google-protobuf` が`closure-library` に依存せずにモダンなJSとして更新される、もしくはgrpc-webの生成コードが依存するランタイムライブラリが`google-protobuf` から新しいものに置き換えられるなどしない限り、この`eval` の問題は今後改善される見込みがないことになる。

あくまでWarningなので気にしないという手も無くはないが、少なくともプロダクションで利用する場合は、例え公式であっても上記の`eval` の問題を含め今後古くなって顕在化する問題点等が改善される見込みの極めて低いパッケージには出来れば依存したくない。

ちなみに、[先述の`closure-library` が開発終了する発表をしたissue](https://github.com/google/closure-library/issues/1214#issue-1973000284) では、下記の通り`protobufjs` や`ts-proto` などを`goog.proto` の代替として提案している。

> For protocol buffers (goog.proto, goog.proto2), consider protobufjs or ts-proto.

# 代替

公式に頼れない時点でデファクトスタンダードは無いように思うので要件や好みに合わせて選択することになるが、個人的には[`connect-web`](https://www.npmjs.com/package/@connectrpc/connect-web)が使いやすく信頼できるように思う。

[`protobuf-ts`](https://github.com/timostamm/protobuf-ts) も悪く無い。

上記2つは少なくとも公式と同じWarningは出ないことを確認している^[[connect-web](https://github.com/a2not/vite-grpc-web/tree/connect-web), [protobuf-ts](https://github.com/a2not/vite-grpc-web/tree/protobuf-ts)各ブランチで確認]のと、ESMとして使えるのでパッケージ化などの回りくどいワークアラウンドを必要としないので少なくとも公式よりは良いと思う。

