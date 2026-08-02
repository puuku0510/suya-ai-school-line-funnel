# Instagram 10大特典 → ライブセミナー → VSL

Instagram経由のLINE登録者へ特典①〜④を配布し、特典⑤としてライブセミナーへ案内します。セミナーを見逃した人にはVSLを送り、視聴完了後に `AIひとり起業ロードマップ作成会` へ案内するファネルです。

YouTubeの特典活用サポート会は、このファネルには入れません。Meta広告のVSL直行導線も混在させません。

## 読む順番

1. [`instagram-10-benefits-live-seminar-vsl-implementation-guide.md`](instagram-10-benefits-live-seminar-vsl-implementation-guide.md)
2. [`instagram-live-state-20260802.csv`](instagram-live-state-20260802.csv)（今回の実機変更差分）
3. [`instagram-10-benefits-live-seminar-vsl-all-scenarios.csv`](instagram-10-benefits-live-seminar-vsl-all-scenarios.csv)（全本文・絵文字を含む監査時スナップショット）

## 現在の状態

- 実機監査日: 2026-08-02
- UTAGE配信アカウント: `66ET2JNrdHub`
- 特典①〜④、セミナー未申込追撃、申込直後LINE、イベント日時基準の申込者リマインド8本は稼働中
- VSL未視聴5通、途中離脱5通、90%以上視聴後6通は下書き
- 申込ページクリックを申込完了扱いしていた既存アクションは29通すべてから解除済み
- `SEMページ閲覧_Instagram`、`SEM申込完了_Instagram`、`SEM参加_Instagram`、`SEM欠席_VSL開始_Instagram` を作成・接続済み
- Instagram用VSLは登録日起算の読者別期限を使い、読者文脈のない直アクセスを404へ送る設定
- VSL初回クリック5本と動画79分地点をInstagram専用アクションへ接続済み
- 旧「登録から○日後」リマインド8本は下書き化し、イベント日時基準の8本へ置換済み
- 開催翌日09:00に参加済・遅刻を特典配布へ、09:05に参加予定・無断キャンセルをVSLへ振り分ける
- 本番前に、参加状況更新とLINE実読者による計測リンクの疎通テストが必要

## Claude Code／Codexへの開始プロンプト

```text
このフォルダだけをInstagram 10大特典ファネルの正本として扱ってください。
README、実装指示書、全シナリオCSVを最初にすべて読んでください。

対象UTAGE配信アカウントは 66ET2JNrdHub です。YouTube用・Meta広告用のシナリオやURLは使用禁止です。

既存設定を先に取得し、申込ページクリックとイベント申込完了を別状態にしてください。セミナー欠席・未参加者だけをVSLへ送り、VSL視聴完了後だけロードマップ作成会へ送ってください。

本番変更前に差分、影響範囲、テスト方法、未確定値を提示してください。本文を独自に変更せず、変更後はID・ステータス・条件・URLを再取得して照合してください。
```
