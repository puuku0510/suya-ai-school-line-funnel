# Claude Code運用ルール

このリポジトリは、すやさん「AIひとり起業スクール」のUTAGE・LINEファネルと、兼子さんの日報運用の正本です。最初にルートの `README.md` を読み、対象作業の専用READMEへ進んでください。

## 兼子さんの日報を確認するとき

ユーザーから「日報を入力した」「入力を確認して」「ちゃんと入力できているか見て」と依頼された場合は、必ず次の順で進めます。

1. `kaneko-daily-report-checker/README.md` を読む。
2. 通常は対象日を指定しない。スクリプトが日本時間の前日分を自動判定する。過去日の再確認を明示された場合だけ日付を指定する。
3. `scripts/check-kaneko-daily-report.ps1` を実行する。
4. JSON結果を読み、次の3区分で日本語報告する。
   - 兼子さんが黄色セルへ入力・修正する項目
   - 数式・自動参照・シート構造の問題で、兼子さんが触ってはいけない項目
   - 正常に入力できていた項目
5. 各指摘には、シート名・行番号・列名・入れる値または対応方法を付ける。

標準実行:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-kaneko-daily-report.ps1 -JsonOutputPath .\.codex-temp-daily-report-check.json
```

対象日指定:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-kaneko-daily-report.ps1 -TargetDate YYYY-MM-DD -JsonOutputPath .\.codex-temp-daily-report-check.json
```

## 禁止事項

- 入力確認の依頼だけでSpreadsheetを編集しない。
- 灰色・青色の数式セル、ダッシュボード、ルート設定を兼子さん向けの修正対象にしない。
- 行の挿入・削除・行全体のコピー＆ペーストを案内しない。
- `PASS` をUTAGE・LINEの実数照合済みという意味で報告しない。
- UTAGE・LINE実数を推測しない。実数照合を依頼された場合だけ各管理画面を読み取りで確認する。

チェック結果が `FAIL` でも、入力値の自動修正は別の明示依頼があるまで行いません。
