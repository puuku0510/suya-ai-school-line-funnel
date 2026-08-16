# LP5-1 漫画LP｜デプロイ一式

`site-root` は、LP5-1（漫画・自由な生き方）をCloudflare Pagesへ公開するための一式です。

## 公開前に設定する値

`site-root/assets/tracking-config.js` の次の2項目を実値へ置換してください。

- `META_PIXEL_ID_PENDING`：Meta Pixel ID
- `UTAGE_URL_LP5_1_PENDING`：LP5-1専用UTAGE登録経路URL

ほかのLP用のPENDING値は、このLP5-1単体デプロイでは未設定のままで問題ありません。

## デプロイ

1. 上記2項目を設定する。
2. `site-root` の中身をCloudflare Pagesへアップロードする。
3. `/lp5-1/` を開く。

予定URL：`https://lp.xenomagic.com/lp5-1/`

## 公開前チェック

- PCと幅390pxのスマートフォンで画像欠け・横スクロールがない。
- CTAがLP5-1専用UTAGE URLへ遷移する。
- UTM、`fbclid`、`gclid`、`lp_id`、`cr_id`がCTA遷移先へ引き継がれる。
- `window.__AI_SEMINAR_TRACKING_READY__` の `utageConfigured` と `pixelConfigured` が両方 `true`。
- 未登録LINEアカウントで実登録し、UTAGE登録経路・シナリオ・Meta CAPIのLeadを確認する。

## 検品結果

- 収録ファイル：55点
- HTMLからのローカル参照切れ：0件
- 元の検品済み納品データとのハッシュ差分：0件
