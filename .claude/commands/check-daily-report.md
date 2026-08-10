兼子さんの日報Spreadsheetを検査してください。

1. `kaneko-daily-report-checker/README.md` とルートの `CLAUDE.md` を読みます。
2. `$ARGUMENTS` が空の場合は、毎日の通常実行として次を実行します。日本時間の前日分が自動選択されます。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-kaneko-daily-report.ps1 -JsonOutputPath .\.codex-temp-daily-report-check.json
```

3. 過去日の指定がある場合だけ、次を実行します。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-kaneko-daily-report.ps1 -TargetDate $ARGUMENTS -JsonOutputPath .\.codex-temp-daily-report-check.json
```

4. `.codex-temp-daily-report-check.json` を読み、次の3区分で日本語報告します。
   - 兼子さんが黄色セルへ入力・修正する項目
   - 数式・自動参照・構造の問題で、兼子さんが触ってはいけない項目
   - 正常に入力できていた項目
5. シート名・行番号・列名・入れる値を具体的に示します。
6. Spreadsheetは編集しません。UTAGE・LINEの実数と未照合なら、その旨を明記します。
