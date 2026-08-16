# すやさん「AIひとり起業スクール」LINEファネル

YouTubeからLINE登録した見込み客に、動画固有特典を配布し、個別面談・ライブセミナー・期間限定VSL・オープンチャット勉強会を通じて成約へつなぐUTAGE実装用パッケージです。

## 成果物

- `advertising-lp/lp5-1-manga-deploy/` — LP5-1 漫画LPのCloudflare Pagesデプロイ一式
- `docs/youtube-line-funnel-spec.md` — 全体フロー、タグ、優先順位、停止・遷移ルール
- `docs/youtube-line-message-copy.md` — LINE・メールの全文台本と推奨形式
- `docs/utage-implementation-checklist.md` — UTAGEへの実装順と公開前テスト
- `skills/suya-ai-school-funnel/` — YouTube・X・Instagramに対応した再利用Skill

## 今回の設計範囲

- 現行ファネルの入口はYouTube
- 最終CVは `AIひとり起業スクール` の成約
- 個別面談は30分Zoom。入口側は `[特典名] 活用サポート会`、セミナー後は `AIひとり起業ロードマップ作成会`
- 本命ライブセミナーは `AIでひとり起業攻略法`
- オープンチャットは `AIマニアの放課後`
- 成約時は集客ファネルを完全停止

価格・募集人数・実績・残席・特典の具体値は、事実確認前に本文へ固定していません。角括弧の変数をキャンペーンごとに差し替えて使います。

## 推奨の読み順

1. ファネル仕様書で状態と停止条件を確認する
2. UTAGE実装チェックリストの順にタグとシナリオを作る
3. 全文台本を登録し、変数を差し替える
4. テスト友だちで全分岐を通す
