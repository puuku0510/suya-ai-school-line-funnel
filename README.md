# すやさん「AIひとり起業スクール」LINEファネル

UTAGEで運用する媒体別LINEファネルの正本リポジトリです。媒体ごとに入口と分岐が異なるため、資料・アカウント・シナリオ・URLを混在させないでください。

## 兼子さんの日報チェック

兼子さんがLINE・ファネル日報を入力した後は、[`kaneko-daily-report-checker/`](kaneko-daily-report-checker/) の説明に従って入力監査を実行してください。

- [日報Spreadsheet](https://docs.google.com/spreadsheets/d/1DylkYidyekEIZlBhlWnz5n-pGRCXiadgGGWqmCusME0/edit)
- [仕組み・毎日の手順・Claude Code用プロンプト](kaneko-daily-report-checker/README.md)
- [自動チェックスクリプト](scripts/check-kaneko-daily-report.ps1)
- [LINEファネル統合ダッシュボードの仕組み](kaneko-daily-report-checker/LINEファネル統合ダッシュボード.md)

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-kaneko-daily-report.ps1
```

日付を指定しない場合、日本時間の前日分を自動で検査します。判定が `PASS` になるまで、黄色い入力セルだけを修正します。数式、自動参照、ダッシュボード、ルート設定は兼子さんが変更しません。

## 媒体別の正本

| 媒体 | 正しい入口 | 正本 |
|---|---|---|
| YouTube | 動画別特典 → 活用サポート → ライブセミナー → VSL | [`docs/youtube-line-funnel-spec.md`](docs/youtube-line-funnel-spec.md) |
| Instagram 10大特典 | 特典①〜④ → 5分後に特典⑤ライブセミナー → 翌朝の再公開希望者だけVSL → ロードマップ作成会 | [`instagram-10-benefits-live-seminar-vsl/`](instagram-10-benefits-live-seminar-vsl/) |
| Meta広告 | 広告 → LINE → VSL → ロードマップ作成会 | [`kaneko-meta-utage-handoff/`](kaneko-meta-utage-handoff/) |

## 金子さん向け3ファネル統合ハンドオフ（2026-08-05承認版）

VSL直行、Metaセミナー直行、Instagram 10大特典を新規実装するときは、[`kaneko-three-funnels-handoff/`](kaneko-three-funnels-handoff/) を正本として使用してください。承認済みSpreadsheet 3タブ、Claude Code／Codex開始プロンプト、実装指示書、全263行のCSVを1フォルダにまとめています。

YouTubeファネルおよびYouTube配信アカウント `Y86og5tIw1hZ` は参照専用で、変更禁止です。

## 2026-08-06 特典クリック判定の共通修正

- YouTubeは、正しいキーワード受信と特典配布完了をもって受取済み扱いにし、実際の特典リンククリック有無では分岐しません。
- Instagramは、専用LINE登録と特典①〜④の配布完了をもって受取済み扱いにし、実際の特典クリック有無では分岐しません。
- 旧「特典リンク未クリック」催促シナリオは実装・配信しません。既存UTAGEにある場合は手動で停止します。
- YouTubeの10分後メッセージ「キーワードの送信は大丈夫そうですか？」は、キーワード未送信者だけに従来どおり送ります。
- セミナー申込、再公開希望、VSL視聴、面談予約ページなど、特典以外の計測クリックはこの修正の対象外です。

`instagram-ig-harness-consultation-line-handoff/` は、Instagramから面談専用LINEへ直接誘導する旧案件です。今回の「10大特典」ファネルとは別物なので、実装時に参照しません。

## 2026-08-02 実機監査

- Instagram配信アカウント: `66ET2JNrdHub`
- Meta広告配信アカウント: `3TS1vbmqlbNx`
- Instagramは誤った申込完了アクションを29通から解除し、ページ閲覧・申込完了・参加・欠席・VSLクリック・VSL完了を専用アクションへ接続済みです。
- Instagramの旧登録日起算リマインド8本は下書き化し、イベント日時基準8本へ置換しました。開催翌日09:00に参加者、09:05に欠席者を自動分岐します。
- InstagramのVSLページは読者文脈なしの直アクセスを404へ送る設定です。下書きの参加者特典・VSL配信は、LINE実読者テスト後に公開します。
- Meta広告はVSL起点の6シナリオが稼働中です。VSL対象65通すべての上位状態除外条件を監査時に補強しました。
- 本番予約・本文・配信時刻を変更するときは、各案件READMEの未完了項目とテストケースを先に確認してください。

## Claude Code／Codexへの開始プロンプト

```text
このGitHubリポジトリを正本として扱ってください。
最初に対象媒体をYouTube / Instagram 10大特典 / Meta広告から1つだけ選び、その媒体のREADME、実装指示書、CSVをすべて読んでください。

UTAGEの既存本番設定を取得し、新規作成・更新・変更しないものを分けて提示してください。別媒体のアカウント、シナリオ、URL、ラベルを流用しないでください。

承認済み本文を独自に書き換えず、実値を推測しないでください。本番変更前に差分、影響範囲、テスト方法、未確定値を提示し、変更後はUTAGEから再取得して照合してください。

特典リンクのクリック有無を状態や分岐条件にしないでください。YouTubeはキーワード受信・特典配布完了、Instagramは登録・特典①〜④配布完了を受取済みの入口とします。旧「特典リンク未クリック」シナリオは停止対象です。セミナー・VSL・面談など特典以外の計測クリックは維持してください。
```
