# Instagram｜吉本さん原案画像

吉本さん作成のGoogle Spreadsheet「インスタファネル」と、吉本さんのGoogle Drive画像フォルダから回収したPNGです。再生成・リデザイン・文言変更はしていません。

- 原案Spreadsheet: https://docs.google.com/spreadsheets/d/1q8Ch26-dT0S0NmVgku2gYvcYwjSvjDahLbSSfRLXmvg/edit
- 原本画像フォルダ: https://drive.google.com/drive/folders/1v2byw5Lp9x6-9tlcBlYEXdbb40GKm68v
- 回収日: 2026-08-06
- `source-original/`: Driveから取得した13枚の原本。ファイル名・画質・画像内文言を変更していない正本
- 直下の日本語名PNG: 実装者が用途を判断しやすいよう、原本と同一内容を用途別に整理した参照コピー
- Instagram実装では、本文・絵文字と同様に吉本さん原本画像を優先する
- 画像を加工・差し替えする場合は、すやさんの再承認を取る

## 13枚の実装対応表

| 原本ファイル | Spreadsheet行 | CSV No. | Instagram現行実装での用途 |
|---|---:|---:|---|
| `source-original/8a963208-e6c2-4363-8049-9099e2528212.png` | 23 | 11 | 登録直後・豪華10大特典の受取ガイド |
| `source-original/7d3a84d1-785a-4cbe-95c8-eec7c4f543d5.png` | 24 | 12 | 登録5分後・特典⑤のセミナー招待券 |
| `source-original/a61066b1-911e-4aa9-9dae-effb289e7601.png` | 25 | 13 | AIでひとり起業攻略法の説明 |
| `source-original/84dbdc97-a0b4-4788-9d9c-6d402e369798.png` | 26 | 14 | セミナー参加限定の残り5特典 |
| `source-original/f4b7db08-16a9-43f0-aaf3-caa0cb744151.png` | 48 | 36 | セミナー前日リマインド |
| `source-original/9994c0c9-dd85-4813-9d25-adadd2687812.png` | 49 | 37 | セミナー当日リマインド・人物あり版 |
| `source-original/e012febb-3b0a-4b8a-8ebb-91255149c38f.png` | 51 | 39 | セミナー当日リマインド・人物なし版 |
| `source-original/edab37b2-5f31-4063-acc0-498b0d4d1096.png` | 52 | 40 | 20:00開始・ライブ参加案内 |
| `source-original/6c890565-c8b5-4e58-948d-db5502dabbed.png` | 60 | 48 | 再公開希望者への3日VSL初回案内 |
| `source-original/b8df8636-aa27-4f4a-a7a1-7ce2e3631b87.png` | 85 | 73 | VSL視聴完了者への30分個別面談案内 |
| `source-original/6641105e-3faa-4150-9a5f-6c64d87ba6dd.png` | 86 | 74 | セミナー参加者向け個別面談クリエイティブ |
| `source-original/54f809d5-cf88-40f4-88b3-4147a1ec8fe7.png` | 95 | 83 | 個別面談予約完了 |
| `source-original/生成画像1.png` | 100 | 88 | LINEオープンチャット初回案内 |

上記13行は、`REVIEW_Instagram10大特典_20260805` のU列に原本URL、V列にセル内プレビュー、X列に画像内テキスト、Y列に使用指示を設定済みです。

## 実装上の注意

- 13枚をすべて素材として保持し、Spreadsheet対応行の画像を無加工で使用する。
- `6641105e-3faa-4150-9a5f-6c64d87ba6dd.png` は画像内では「セミナー参加者様へ」となっているが、参加／欠席判定の新設はしない。承認済みのVSL完了・面談シナリオ内のクリエイティブとしてのみ使用する。
- 画像内の「3日間限定」「20:00」などは、実際の公開期限・開催時刻と一致する場合だけ本番公開する。不一致なら勝手に加工せず、差し替え承認を取る。
