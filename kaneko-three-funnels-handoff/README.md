# 金子さん用｜YouTube 3入口・Instagram・Meta広告 UTAGEファネル実装ハンドオフ

Spreadsheet承認済み（スプシOK: 2026-08-09）・UTAGE実装待ちの2026-08-10版正本です。

- [承認済みGoogle Spreadsheet](https://docs.google.com/spreadsheets/d/1TGC-Jtf4z2IA1PpL8dK0oyHrh74d2uPkmfGCNQCnxus/edit)
- [GitHub案件フォルダ](https://github.com/puuku0510/suya-ai-school-line-funnel/tree/agent/audit-instagram-meta-funnels/kaneko-three-funnels-handoff)
- [UTAGE実装指示書](kaneko-three-funnels-implementation-guide.md)
- [5ファネル統合CSV](kaneko-three-funnels-all-scenarios.csv)

## 最初に読む順番

1. この `README.md`
2. [UTAGE実装指示書](kaneko-three-funnels-implementation-guide.md)
3. [5ファネル統合CSV](kaneko-three-funnels-all-scenarios.csv)
4. [シート別セル完全CSV](exports/)
5. [画像原本ハッシュ台帳](assets-manifest.csv)
6. [検証記録](validation-report.md)
7. Google Spreadsheetの承認済み5シート
8. UTAGE本番（ID・URL・イベント・連携の実値確認だけに使う）

## 承認済み対象

| 媒体・入口 | Spreadsheet | 行数 | 運用 |
|---|---|---:|---|
| YouTube ゆっくりAI | [REVIEW_YouTube_ゆっくりAI_20260810](https://docs.google.com/spreadsheets/d/1TGC-Jtf4z2IA1PpL8dK0oyHrh74d2uPkmfGCNQCnxus/edit?gid=1154979349) | 199 | 新規読者だけ新ルート。既存読者は旧ルート完走 |
| YouTube さとり | [REVIEW_YouTube_さとり_20260810](https://docs.google.com/spreadsheets/d/1TGC-Jtf4z2IA1PpL8dK0oyHrh74d2uPkmfGCNQCnxus/edit?gid=1874201366) | 199 | 新規読者だけ新ルート。既存読者は旧ルート完走 |
| YouTube ゆるAI | [REVIEW_YouTube_ゆるAI_20260810](https://docs.google.com/spreadsheets/d/1TGC-Jtf4z2IA1PpL8dK0oyHrh74d2uPkmfGCNQCnxus/edit?gid=746825696) | 199 | 新規読者だけ新ルート。既存読者は旧ルート完走 |
| Instagram 10大特典 | [REVIEW_Instagram10大特典_20260810](https://docs.google.com/spreadsheets/d/1TGC-Jtf4z2IA1PpL8dK0oyHrh74d2uPkmfGCNQCnxus/edit?gid=1974159573) | 145 | 新規読者だけ新ルート。既存読者は旧ルート完走 |
| Meta広告 セミナー直行 | [REVIEW_METAセミナー直行_20260810](https://docs.google.com/spreadsheets/d/1TGC-Jtf4z2IA1PpL8dK0oyHrh74d2uPkmfGCNQCnxus/edit?gid=1425948398) | 118 | 新規・既存とも新ルートへ状態別移行 |

合計860行。Meta広告VSL直行87行は今回変更せず、既存参照ファネルとして保持します。

## 絶対条件

- 本文、絵文字、画像、CTA、配信順、承認済み時刻を独自に書き換えない。
- ID、URL、イベント、置換文字、別LINE連携キーを推測しない。
- 1人に複数の営業オファーを同時配信しない。
- 個別面談は予約ページクリックではなく、予約完了を全オファー停止点にする。
- 面談完了者はゴール。自動オプチャを含む全営業配信を停止する。
- 特典リンクを開いたかどうかで分岐しない。
- YouTube 3入口は流入タグだけ分離し、YouTube/Instagram共通の2日程セミナーへ合流する。
- YouTubeだけZoomサポート会を挟む。InstagramとMeta広告は挟まない。
- Instagramは特典①〜④を登録直後、特典⑤＝セミナー案内を5分後に送る。
- Metaセミナー直行はYouTube/Instagramとは別の2日程を使う。
- Instagram 13枚、Meta 22枚の吉本さん原本画像を無加工で使う。
- 画像内の3日程・参加者・不参加者などが実際の対象条件と一致しない場合は送信せず、原本保管とする。
- YouTubeの `廃止対象（UTAGEで停止）` 6行と `旧読者のみ・新規停止` 行を新規読者へ実装しない。

## Claude Code／Coderへそのまま渡すプロンプト

```text
このGitHub案件フォルダを2026-08-10版UTAGEファネルの正本として扱ってください。

最初に README.md、kaneko-three-funnels-implementation-guide.md、kaneko-three-funnels-all-scenarios.csv、exports/ の5つのシート別CSV、assets-manifest.csv、validation-report.md をすべて読んでください。

次にUTAGEの既存本番設定を読み取りで監査し、対象アカウント・LINE連携・登録経路・ラベル・アクション・シナリオ・イベント・VSLページ・面談予約・計測リンク・既存読者数を実値で一覧化してください。「新規作成」「既存を更新」「変更しない」「停止」をオブジェクトID単位で分けてください。

絶対条件:
- Spreadsheet承認済みの本文、絵文字、画像、CTA、配信順、配信時刻を独自に書き換えない。
- ID、URL、イベント、置換文字、個別面談用公式LINEとの照合キーを推測しない。
- YouTube/Instagramは2026-08-10以降の新規読者だけ新ルートへ入れ、既存読者は旧ルートを完走させる。
- Metaセミナー直行は既存読者も状態別に新ルートへ移行する。ただし進行中VSLの起点と72時間期限をリセットしない。
- YouTube 3入口は媒体タグを分離し、YouTube/Instagram共通の2日程へ合流する。Metaは別の2日程を使う。
- InstagramはZoomサポートを挟まず、特典①〜④を即時、特典⑤＝セミナー案内を5分後に送る。
- 特典リンクのクリック有無で分岐しない。
- 1人1オファーを徹底し、セミナー申込、VSL開始・完了、面談予約完了、面談完了、オプチャクリックで競合配信を停止する。
- 面談予約ページクリックではなく予約完了を全停止点にする。メインLINEと別の個別面談LINEを連携する。
- 2日程未申込者は第2日程終了の翌朝06:00からVSL。申込者は本人の日程翌朝06:00に面談案内、同日23:59締切、未予約なら次の朝06:00からVSL。
- 「どちらの日程も合わない」は募集を止め、前回企画ダイジェスト版として72時間VSLへ即移行する。再クリックで期限を延長しない。
- VSL未視聴・途中・完了を排他制御し、72時間終了後も面談未予約ならオプチャへ移行する。
- 面談無断欠席者にはNS-01〜03の3通を送り、未再予約ならオプチャへ移行する。
- 面談完了者はゴールとし、自動オプチャを含む全営業配信を停止する。
- Instagram 13枚・Meta 22枚の原本画像をassets/から無加工で設定する。

本番変更前に、対象アカウント、対象人数、変更前後差分、誤配信リスク、未確定の実値、テスト計画、ロールバック方法を提示して、人間の承認を待ってください。本番権限がなければ、画面名・項目名・入力値をクリック単位で案内してください。

実装後は指示書の全テストケースを実行し、UTAGEから実値を再取得して、件数、分岐、停止条件、URL、画像、置換文字、対象読者を報告してください。
```

## ファイルと画像

- 統合CSV: 860行・32列。YouTubeの4本文列、UTAGE編集URL、原本メッセージIDも保持。
- シート別CSV: Spreadsheetセルを媒体別に保持。
- Instagram原本: [assets/instagram-yoshimoto/source-original/](assets/instagram-yoshimoto/source-original/)
- Meta原本: [assets/meta-seminar-yoshimoto/source-original/](assets/meta-seminar-yoshimoto/source-original/)
- 画像台帳: [assets-manifest.csv](assets-manifest.csv)
- 検証スクリプト: [verify-handoff.ps1](verify-handoff.ps1)

Windows PowerShellでの再検証:

```powershell
& .\verify-handoff.ps1
```

期待結果: `Handoff verification passed.`

## 完了条件

- 5シート・860行とUTAGE実装対象が対応する。
- YouTube 3入口、Instagram、Metaの日程・流入・読者移行が混ざらない。
- 予約完了・面談完了・成約・営業停止で競合配信が止まる。
- VSLの72時間起点が延長・リセットされない。
- 無断欠席3通後の出口がオプチャへつながる。
- 原本画像35枚が対応行へ設定される。
- 本番テストとロールバック記録が実装指示書へ追記される。
