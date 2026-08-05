# 金子さん用｜3媒体UTAGEファネル実装ハンドオフ

VSL直行、Metaセミナー直行、Instagram 10大特典の3ファネルを、承認済みGoogle SpreadsheetからUTAGEへ実装するための正本フォルダです。

## 先に読むもの

1. [実装指示書](kaneko-three-funnels-implementation-guide.md)
2. [承認済み全シナリオCSV](kaneko-three-funnels-all-scenarios.csv)
3. [Google Spreadsheet](https://docs.google.com/spreadsheets/d/1TGC-Jtf4z2IA1PpL8dK0oyHrh74d2uPkmfGCNQCnxus/edit)

Spreadsheetの承認対象は次の3タブです。

- `REVIEW_META_VSL直行_20260805`
- `REVIEW_METAセミナー直行_20260805`
- `REVIEW_Instagram10大特典_20260805`

2026-08-05に、すやさんから「スプシOK」を受領済みです。2026-08-06にInstagramだけ追加方針が入り、吉本さん原案の文章・絵文字・画像を最優先する形へ更新しています。原案に足りない行だけYouTube承認済み本文で補い、新規オリジナル文は作りません。

Instagram画像は [吉本さん原案画像](assets/instagram-yoshimoto/README.md) を参照してください。吉本さんのDrive原本13枚を `assets/instagram-yoshimoto/source-original/` に格納し、Spreadsheetの対応13行へ原本URLとセル内プレビューを設定済みです。

## 実装対象と非対象

| 対象 | 入口 | 承認済みデータ行 |
|---|---|---:|
| Meta広告 VSL直行 | LINE登録 → 3日VSL | 87 |
| Meta広告 セミナー直行 | LINE登録 → セミナー申込 | 83 |
| Instagram 10大特典 | 特典①〜④ → 5分後に特典⑤＝セミナー案内 | 85 |

合計255行です。

非対象:

- YouTubeファネルおよびYouTube配信アカウント `Y86og5tIw1hZ` の変更
- Instagramでの特典⑥〜⑩のLINE配布（セミナー中のQRで配布）
- Instagram登録後に短い案内動画を挟むこと
- セミナー参加／欠席をVSL入口の条件にすること
- 再公開希望ボタンを押していない人へのVSL配信
- Instagramの文章・絵文字を、吉本さん原案または指定済みYouTube補完文以外へ独自リライトすること
- 吉本さん原案画像13枚を再生成・リデザイン・画像内文言変更すること

## Claude Code／Codexへ渡す開始プロンプト

```text
この案件では、GitHubの kaneko-three-funnels-handoff フォルダを実装仕様の正本として扱ってください。

最初に、次の3ファイルをすべて読んでください。
1. README.md
2. kaneko-three-funnels-implementation-guide.md
3. kaneko-three-funnels-all-scenarios.csv

次に、UTAGEの既存本番設定を読み取りで監査し、3ファネルそれぞれについて「新規作成」「既存を更新」「変更しない」を分けた差分計画を提示してください。対象UTAGEアカウントID、LINE登録経路、イベントID、VSLページID、予約枠ID、計測リンク、ラベルID、アクションID、URL、Zoom URL、置換文字は推測せず、実機から取得するか未確定値一覧にしてください。

絶対条件:
- YouTubeファネルおよびYouTube配信アカウント Y86og5tIw1hZ を変更しない。
- 承認済みCSVの本文、件名、絵文字、画像、CTA、順番、配信時刻を独自に書き換えない。
- 3媒体のアカウント、登録経路、ラベル、シナリオ、イベント、URLを混在させない。
- Meta VSL直行は初回3日VSLの終了後、再公開希望ボタンを押した人だけ同じVSLを再度3日公開する。
- Metaセミナー直行とInstagramは、セミナー申込済み・面談未予約者へ翌日10:00に再公開希望確認を送り、クリック者だけ3日VSLへ入れる。参加／欠席は判定条件にしない。
- Instagramは特典①〜④を登録直後、特典⑤のセミナー案内を5分後に送る。短い案内動画は挟まない。特典⑥〜⑩はセミナー中のQR配布でありLINEでは送らない。
- Instagramの本文・絵文字は吉本さん原案を最優先する。原案で通数が足りない箇所だけ承認済みYouTube本文を使い、新規オリジナル文章を作らない。画像は assets/instagram-yoshimoto/source-original/ の13枚をREADME対応表どおり設定し、加工しない。
- 面談予約、商談中、次回面談あり、成約、営業停止の上位状態が付いたら、競合する下位シナリオを即停止する。
- 不明な実値や事実根拠を推測で本番設定しない。

本番変更前に、次を提示して人間の承認を得てください。
1. 対象アカウントと変更オブジェクト一覧
2. 変更前後の差分
3. 影響人数と誤配信リスク
4. 未確定の実値一覧
5. テスト計画とロールバック方法

実装権限がない場合は、UTAGEの画面名、クリック順、入力値、保存後の確認方法まで操作単位で提示してください。実装後は指示書の全テストケースを実行し、メッセージ数、状態遷移、停止条件、URL、画像、置換文字、送信者名を実機から再取得して報告してください。
```

## 正本の優先順位

1. 承認済みSpreadsheet 3タブ: コピーと行単位設定
2. このフォルダの実装指示書: 状態、分岐、停止条件、実装順
3. このフォルダのCSV: 機械可読な承認済み255行
4. UTAGE既存本番: 実値と既存IDの確認元

矛盾を見つけた場合は本番変更を止め、差分を報告してください。YouTube本番を正本としてコピーした共通本文であっても、YouTube側へ逆反映してはいけません。

## 完了条件

- 3ファネルが媒体別に分離されている。
- CSVの255行とUTAGEの実装件数が一致する。
- 全アクションに入口、終了、競合停止がある。
- 面談予約直後に募集配信が止まる。
- セミナー型は再公開希望者だけVSLへ入る。
- Meta VSL直行だけVSLが最大2サイクルになる。
- Instagramの特典⑤は登録5分後、特典⑥〜⑩はLINE非配信。
- Instagramの吉本さん原本画像13枚がSpreadsheetの対応行とUTAGEにすべて設定されている。
- YouTubeの更新履歴に本案件由来の変更がない。
- テスト結果と未解決事項が実装指示書へ追記されている。

