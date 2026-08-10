# 兼子さん用｜LINE・ファネル日報チェック

このフォルダは、兼子さんが日報Spreadsheetへ入力した後に、Claude Codeが同じ基準で入力漏れ・誤入力・数式破損を検査するための説明書です。

- [日報Spreadsheet](https://docs.google.com/spreadsheets/d/1DylkYidyekEIZlBhlWnz5n-pGRCXiadgGGWqmCusME0/edit)
- [チェック用スクリプト](../scripts/check-kaneko-daily-report.ps1)
- [Claude Codeプロジェクトルール](../CLAUDE.md)
- [LINEファネル統合ダッシュボード](LINEファネル統合ダッシュボード.md)
- Claude Code専用コマンド: `/check-daily-report`
- ダッシュボード確認コマンド: `/check-funnel-dashboard`
- Spreadsheet ID: `1DylkYidyekEIZlBhlWnz5n-pGRCXiadgGGWqmCusME0`

## 承認・ログインについて

- GitHubリポジトリは公開されているため、閲覧・取得のためのGitHub招待や承認は不要です。
- チェックスクリプトはSpreadsheetを読み取り専用URLから取得します。Googleログイン、OAuth、サービスアカウント、APIキーは不要です。
- Spreadsheetへ数字を入力するときは、従来どおり編集権限を持つGoogleアカウントで開いてください。チェックスクリプトには編集権限はありません。
- Claude Codeが初回実行時にコマンド実行やネットワーク通信の許可を表示した場合は、`powershell.exe` の実行と `docs.google.com` への読み取り通信を許可してください。
- `-ExecutionPolicy Bypass` は今回のスクリプト実行中だけ有効です。Windows全体の設定は変更しません。

注意: 現在は、リンクを知っている人が日報Spreadsheetを読み取れる設定です。個人情報・機密情報を入れる場合は公開読み取りを停止し、Google認証方式へ切り替えてください。

## この日報の仕組み

### 1. 初期棚卸し

運用開始前に一度だけ、公式LINEとファネルの開始残高を入力します。

- 公式LINE開始残高: 現在友だち数・累計ブロック
- ファネル開始残高: 自動配信中・手動対応中・Zoom案内中・オプチャ案内済み・遷移エラー

ここで入力した数字は、その後の日次差分を判断する基準です。`基準日時` は日付だけでなく、実際にLINEまたはUTAGEを確認した時刻まで記録します。

### 2. LINE日次

`1日 × 1公式LINE = 1行` です。LINE Official Account Managerの当日増減と、確認時点の残高を記録します。

- 対象日: 集計するデータの日
- 集計対象期間: 対象日の00:00〜23:59を自動表示
- データ確認日時: 実際に管理画面を確認した日時
- 当日値: 新規LINE登録、ブロック増加
- 残高: 現在友だち数、累計ブロック、自動配信中、手動対応中
- 異常管理: 異常種別、影響人数、対応状況

0件でも空欄にせず `0` を入力します。異常がなければ `問題なし` と `対応不要` を選択します。

### 3. ファネル日次

`1日 × 1ファネル = 1行` です。左から実際のファネル順に、オファー人数・申込または移行人数・その段階でのブロック人数を記録します。

1. ファネル流入
2. Zoomサポート会
3. セミナー
4. セミナー後面談
5. VSL・面談
6. オプチャ
7. 遷移・滞留エラー

率と合計はSpreadsheetが自動計算します。どのステージを必須入力にするかは `ルート設定` の「対象／対象外」を正本とします。

### 4. ダッシュボード

`LINE日次` と `ファネル日次` のうち、入力状態が `入力完了` になった行だけを集計します。数字を入力しても必須欄が空白ならダッシュボードには反映されません。

ダッシュボードは参照専用です。直接入力・数式変更をしません。

## スクリプトが検査するもの

- 黄色の必須入力欄が埋まっているか
- 0件を空欄にしていないか
- 数値が0以上の整数か
- 異常なしの場合に `問題なし / 対応不要` になっているか
- 異常ありの場合に影響人数・対応状況があるか
- 公式LINE名・ファネル管理名が `ルート設定` と一致するか
- 同じ日・同じ公式LINE／ファネルが重複していないか
- 毎日監視対象のファネル行が存在するか
- 対象日がルートの開始日・終了日と矛盾していないか
- `#REF!` などの数式エラーがないか
- 基準日時・確認日時に時刻が含まれるか
- 最終的な入力状態が `入力完了` か

## 兼子さんの毎日の作業

1. Spreadsheetの黄色いセルだけ入力する。
2. 0件も `0` と入力する。
3. 行の挿入・削除、行全体のコピー＆ペースト、灰色・青色セルの編集はしない。
4. Claude Codeへ次のプロンプトを送る。
5. `PASS` になるまで、指摘された黄色セルだけ修正する。
6. 数式エラー・自動参照エラーは自分で直さず、管理者へ報告する。

Claude Codeでは、毎日同じ専用コマンドを実行します。日付入力は不要です。

```text
/check-daily-report
```

日付を省略すると、日本時間の前日分を自動で検査します。過去日を再確認するときだけ `/check-daily-report 2026-08-10` のように日付を付けます。

## Claude Codeへ渡すプロンプト

```text
このリポジトリを正本として扱ってください。
最初に kaneko-daily-report-checker/README.md を読み、日報Spreadsheetの仕組みと入力ルールを理解してください。

兼子さんが日報を入力しました。通常は次を実行してください。日付を省略すると、日本時間の前日分が自動選択されます。

powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./scripts/check-kaneko-daily-report.ps1 -JsonOutputPath ./daily-report-check.json

過去日を再確認する場合だけ `-TargetDate YYYY-MM-DD` を追加してください。

実行結果を、次の3区分で日本語で報告してください。
1. 兼子さんが黄色セルへ追加入力・修正する項目
2. 数式や自動参照の問題で、兼子さんが触ってはいけない項目
3. 正常に入力できていた項目

エラーがある場合は、シート名・行番号・列名・入力すべき値を具体的に示してください。
数式セル、ダッシュボード、ルート設定を無断で変更しないでください。
UTAGEやLINEの実数と照合していない場合は、入力形式だけを検査したことを明記してください。
```

## 実行方法

日本時間の前日分を自動判定（毎日の通常実行）:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-kaneko-daily-report.ps1
```

過去日を指定して再確認:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-kaneko-daily-report.ps1 -TargetDate 2026-08-10
```

機械可読JSONも保存:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-kaneko-daily-report.ps1 `
  -TargetDate 2026-08-10 `
  -JsonOutputPath .\daily-report-check.json
```

## 終了コード

| 終了コード | 意味 |
|---:|---|
| `0` | エラーなし。入力形式の検査に合格 |
| `1` | 入力漏れ・不整合・数式エラーあり |
| その他 | Spreadsheetの取得失敗など実行上の問題 |

`PASS` はSpreadsheet上の入力形式が正しいことを意味します。UTAGE・LINE Official Account Managerの実数と一致することまでは保証しません。実数照合が必要な場合は、各管理画面を読み取りで確認してください。
