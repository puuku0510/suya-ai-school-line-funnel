# Meta広告 → VSL → ロードマップ作成会

Meta広告からLINEへ登録した人に、最初からVSLを案内するUTAGEファネルです。特典配布、YouTube用Zoom活用サポート会、ライブセミナーは入りません。

## 読む順番

1. [`kaneko-meta-utage-implementation-guide.md`](kaneko-meta-utage-implementation-guide.md)
2. [`meta-ads-vsl-all-scenarios-live.csv`](meta-ads-vsl-all-scenarios-live.csv)
3. [`Meta広告_LINEファネル_全シナリオ.csv`](Meta広告_LINEファネル_全シナリオ.csv)（原稿作成時のコピー正本）

## 現在の状態

- 実機監査日: 2026-08-02
- UTAGE配信アカウント: `3TS1vbmqlbNx`
- VSL未視聴・途中・完了・再公開の5シナリオと個別相談リマインダが稼働中
- VSL公開URL、ロードマップ作成会URLは200を確認済み
- VSL対象65通すべての上位状態除外条件を監査時に補強済み
- 登録直後の動画案内は即時から1分後へ変更し、除外条件を適用済み
- 欠席後フォローと営業状態の運用アクションは追加確認が必要

## Claude Code／Codexへの開始プロンプト

```text
このフォルダだけをMeta広告ファネルの正本として扱ってください。
README、実装指示書、2つのCSVを最初に読んでください。

対象UTAGE配信アカウントは 3TS1vbmqlbNx です。Instagram・YouTubeのセミナーやサポート会を追加しないでください。

既存本番設定を取得し、VSL未視聴・途中・完了・再公開・予約・欠席・営業状態の停止条件を監査してください。本番変更前に差分とテスト方法を提示し、変更後は実値を再取得してください。
```
