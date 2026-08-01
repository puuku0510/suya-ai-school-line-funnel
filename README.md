# すやさん「AIひとり起業スクール」LINEファネル

UTAGEで運用する媒体別LINEファネルの正本リポジトリです。媒体ごとに入口と分岐が異なるため、資料・アカウント・シナリオ・URLを混在させないでください。

## 媒体別の正本

| 媒体 | 正しい入口 | 正本 |
|---|---|---|
| YouTube | 動画別特典 → 活用サポート → ライブセミナー → VSL | [`docs/youtube-line-funnel-spec.md`](docs/youtube-line-funnel-spec.md) |
| Instagram 10大特典 | 特典①〜④ → 特典⑤ライブセミナー → 欠席・見逃しVSL → ロードマップ作成会 | [`instagram-10-benefits-live-seminar-vsl/`](instagram-10-benefits-live-seminar-vsl/) |
| Meta広告 | 広告 → LINE → VSL → ロードマップ作成会 | [`kaneko-meta-utage-handoff/`](kaneko-meta-utage-handoff/) |

`instagram-ig-harness-consultation-line-handoff/` は、Instagramから面談専用LINEへ直接誘導する旧案件です。今回の「10大特典」ファネルとは別物なので、実装時に参照しません。

## 2026-08-02 実機監査

- Instagram配信アカウント: `66ET2JNrdHub`
- Meta広告配信アカウント: `3TS1vbmqlbNx`
- Instagramは、申込ページクリックと申込完了を同じ状態としていたため分離が必要です。
- InstagramのVSLページは読者文脈なしの直アクセスを404へ送る設定です。未公開とは断定せず、LINE計測リンク経由で確認します。動画完了アクションとイベント後の自動遷移は未完成です。
- Meta広告はVSL起点の6シナリオが稼働中です。VSL対象65通すべての上位状態除外条件を監査時に補強しました。
- 本番予約・本文・配信時刻を変更するときは、各案件READMEの未完了項目とテストケースを先に確認してください。

## Claude Code／Codexへの開始プロンプト

```text
このGitHubリポジトリを正本として扱ってください。
最初に対象媒体をYouTube / Instagram 10大特典 / Meta広告から1つだけ選び、その媒体のREADME、実装指示書、CSVをすべて読んでください。

UTAGEの既存本番設定を取得し、新規作成・更新・変更しないものを分けて提示してください。別媒体のアカウント、シナリオ、URL、ラベルを流用しないでください。

承認済み本文を独自に書き換えず、実値を推測しないでください。本番変更前に差分、影響範囲、テスト方法、未確定値を提示し、変更後はUTAGEから再取得して照合してください。
```
