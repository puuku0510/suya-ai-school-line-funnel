# IGハーネス × 面談専用LINE 実装一式

このフォルダが、InstagramのIGハーネスから面談専用LINEへ誘導し、UTAGEで個別面談の予約・リマインドを行う案件の共有用正本です。

## 実装担当者が最初に読む順番

1. [実装指示書](./instagram-ig-harness-consultation-line-implementation-guide.md)
2. [承認済み全シナリオCSV](./instagram-ig-harness-consultation-line-all-scenarios.csv)
3. [承認済みGoogle Spreadsheet](https://docs.google.com/spreadsheets/d/1q8Ch26-dT0S0NmVgku2gYvcYwjSvjDahLbSSfRLXmvg/edit?gid=1075291337#gid=1075291337)

実装時の文章は、CSVおよびGoogle Spreadsheetの承認済み文章をそのまま使ってください。表現を独自に書き換えないでください。

## Claude Code／Codexへ渡すプロンプト

下記をコピーし、このGitHubフォルダのURLと一緒にClaude CodeまたはCodexへ渡してください。

```text
以下のGitHubフォルダを、この案件の実装仕様の正本として扱ってください。

https://github.com/puuku0510/suya-ai-school-line-funnel/tree/main/instagram-ig-harness-consultation-line-handoff

最初にREADME、実装指示書、全シナリオCSVをすべて読み、内容を省略せずに把握してください。

目的は、IGハーネスの既存特典送付シナリオから面談専用LINEへ誘導し、UTAGEの「イベント・予約 ＞ 個別相談・個別予約」を使って、登録直後の予約案内、未予約リマインド、予約完了、1週間前、3日前、当日、1時間前の案内を正しく実装することです。

作業ルール:
1. 既存のIGハーネス、UTAGE、LINE公式アカウントの設定を先に確認してください。
2. 同名または同目的の登録経路、ラベル、シナリオ、イベントがある場合は、新規作成せず差分を提示してください。
3. 文章は承認済みCSVから一字一句コピーし、独自に要約・改善しないでください。
4. UTAGEの置換文字、画面名、URLは推測せず、実画面で選択できる値を使ってください。
5. 本番変更前に「既存設定」「作成・変更予定」「影響範囲」「テスト方法」を一覧で提示してください。
6. 本番操作の権限がなければ、実装担当者がクリックできる粒度で一手ずつ案内してください。
7. 予約完了後に未予約リマインドが届かないことを最重要テスト項目にしてください。
8. 実装完了後は、指示書のテストケースをすべて実施し、結果と未確認事項を報告してください。

まず実装は開始せず、資料を読んだうえで、作業計画と確認が必要な実値の一覧を提示してください。
```

## 完了の定義

- IGハーネスの追いDMからInstagram専用のLINE登録経路へ遷移できる。
- LINE登録直後に予約案内が届く。
- 未予約者だけに24時間後、72時間後の案内が届く。
- 予約完了時に未予約シナリオが即停止する。
- 予約直後、1週間前、3日前、当日朝、1時間前のメッセージが新しい予約日時を基準に届く。
- 日程変更、キャンセル、面談完了後に旧リマインドが届かない。
- Google Spreadsheet、CSV、UTAGE実装内容が一致している。
