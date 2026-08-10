LINEファネル統合ダッシュボードの公開集計を検査してください。

1. `kaneko-daily-report-checker/LINEファネル統合ダッシュボード.md` を読みます。
2. 次を実行します。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-funnel-dashboard.ps1
```

3. CSV構造、同期状態、未分類人数、ラベル取得率、個人情報列の有無を日本語で報告します。
4. `pending` の場合は「GitHub公開後の初回同期が未実行」と明記します。
5. SpreadsheetやUTAGEを自動修正しません。
