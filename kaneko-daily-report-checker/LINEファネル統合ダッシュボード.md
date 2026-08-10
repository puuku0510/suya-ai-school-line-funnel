# 兼子さん用｜LINEファネル統合ダッシュボード

対象Spreadsheet: [兼子さん｜LINEファネル日次管理](https://docs.google.com/spreadsheets/d/1DylkYidyekEIZlBhlWnz5n-pGRCXiadgGGWqmCusME0/edit)

## 何が自動で見えるか

- `ファネル現在地`: 現在LINE内にいる人数を、公式LINE・流入元・ファネル・現在ステージ別に表示します。1人の現在ステージは1つです。
- `コホート分析`: LINE登録日を母集団に、Zoom申込、セミナー申込、VSL、面談、オプチャリンククリックまでの人数と率を表示します。
- `計測実装ガイド`: UTAGEで付与する永続イベントラベルと、手動・エラー・停止などの現在状態ラベルの正本です。

YouTubeだけがZoomサポート会を通ります。InstagramとMeta広告のZoom率は `対象外` です。セミナー・Zoomの実参加と欠席は自動KPIに含めず、申込完了までを数えます。オプチャは実参加ではなくリンククリックを自動計測します。

## 手入力との役割分担

- 兼子さんは従来どおり `LINE日次` と `ファネル日次` の黄色セルを入力します。
- 自動ダッシュボードの3タブと `自動同期_*` タブには入力しません。
- 手動対応・エラーを別台帳へ二重入力しません。UTAGEの処理状態ラベルを正本にします。

処理状態ラベルは現在値なので、開始時に付与し、解消時に解除します。

| 状態 | UTAGEラベル | 優先順位 |
|---|---|---:|
| エラー | `ops_error`, `transition_error`, `stagnation_error` | 1 |
| 手動対応 | `manual_in_funnel`, `manual_after_funnel`, `sales_in_progress` | 2 |
| 停止 | `delivery_stopped`, `opted_out`, `sales_stop` | 3 |
| 自動配信 | 上記状態ラベルなし | 4 |

一方、`evt_*` は到達履歴です。付与後は解除しません。同じ人に状態が重なった場合は `エラー > 手動 > 停止 > 自動` の順で表示します。

## 自動同期

集計元は公開リポジトリ [suya-youtube-line-dashboard](https://github.com/puuku0510/suya-youtube-line-dashboard) です。既存アプリは残し、GitHub Actionsが毎日 `00:00 / 12:00 JST` にUTAGE集計CSVを更新します。

- `funnel-current.csv`: 現在ステージ×処理状態
- `funnel-cohort.csv`: LINE登録日コホートの累積到達
- `funnel-sync-health.csv`: ラベル取得率・未分類人数・同期状態

Spreadsheetの非表示タブ `自動同期_現在`、`自動同期_コホート`、`自動同期_ヘルス` がCSVを読み込みます。氏名、メール、LINE ID、共通読者IDは公開CSVへ出しません。

## 初回公開後の確認

1. `suya-youtube-line-dashboard` をpushする。
2. GitHub Actions `sync-dashboard` を手動実行する。
3. `ファネル現在地` の最終同期が `GitHub公開前` から日時へ変わることを確認する。
4. `要確認` が出たら、`計測実装ガイド` に従ってUTAGEラベルを直す。
5. `コホート分析` で流入元を切り替え、YouTubeのみZoom率が表示されることを確認する。

既存運用ラベルは解除される場合があるため、公開直後の過去コホートは部分値になる可能性があります。新フローから永続 `evt_*` を付けることで精度が安定します。

## Claude Codeでの確認

```text
/check-funnel-dashboard
```

この確認は公開CSVの構造・同期状態・個人情報列の混入を検査します。UTAGE実数との完全一致を保証するものではありません。
