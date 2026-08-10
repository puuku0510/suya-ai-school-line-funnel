$ErrorActionPreference = 'Stop'

$csv = Join-Path (Get-Location).Path 'kaneko-three-funnels-handoff\kaneko-three-funnels-all-scenarios.csv'
$map = @{
    11 = @('13_uoqZJY14DwBZZe7mcFTkkE-umdd3AX', 'セミナー3日程案内', 'META_SEMINAR_01-seminar-three-dates.png')
    12 = @('1TJcHlzjBljzex6UaexU-app0GpFuRI5K', '金子さん向けセミナー初期案内', 'META_SEMINAR_16_金子さん_セミナー初期案内.png')
    14 = @('1Hs1omPXAszBt_06r5nnIGFS8kHrRYtAW', '金子さん向けセミナー日程選択', 'META_SEMINAR_17_金子さん_日程選択.png')
    15 = @('1xxqJTBBM9ICNyq8QRZOEH_eKjlSqSCqR', 'AIひとり起業セミナー訴求', 'META_SEMINAR_02-ai-solo-business.png')
    20 = @('1TfZL9mHXInWc6LCLOoJNmpwH6znqJLcZ', 'セミナー第2回案内', 'META_SEMINAR_04-seminar-second-session.png')
    25 = @('1yrLlzX5f_0dyNEwmmawSqjPnFl55cQtN', 'セミナー本日開催', 'META_SEMINAR_03-seminar-today.png')
    28 = @('1ExnPbEFrCOaYOdqHC0SC9KGVSzmedlQm', 'セミナー最終案内', 'META_SEMINAR_05-seminar-final-day.png')
    29 = @('1VjHp1HnL3vcKWdFwd6fIEmCPHDhyaCFu', '金子さん向け申込完了案内', 'META_SEMINAR_19_金子さん_申込完了.png')
    36 = @('1tBMYqNwTv8OeKvfo4V_1H--VEujTmVfm', '金子さん向け本日ライブ案内', 'META_SEMINAR_18_金子さん_本日ライブ.png')
    42 = @('1nKhNf4mPteiuMqUOjWe5GT1bhBRMZ9ld', '金子さん向けVSL案内', 'META_SEMINAR_21_金子さん_VSL案内.png')
    46 = @('1aDsy7ttWVdlGA-ba8R_EHHam7lYuIi4M', 'VSL残り2日', 'META_SEMINAR_08-vsl-two-days.png')
    51 = @('1Y9NCfQLupBAplJDlJMD7MgyzMwQlXvPq', 'VSL公開最終日', 'META_SEMINAR_09-vsl-final-day.png')
    56 = @('1FLRsX4ZylbiaUUV1J4JM9G0oZ1hm2IA_', 'VSL終了まで1時間', 'META_SEMINAR_10-vsl-one-hour.png')
    67 = @('1QOiYn2-7lwedp2kBfyTh9N6TqFrgWDoW', 'VSL視聴完了のお礼', 'META_SEMINAR_11-vsl-complete-thanks.png')
    68 = @('1G5rZx9tepJhSirDHK19xZwobJiO-wsNg', '金子さん向けロードマップ作成会', 'META_SEMINAR_20_金子さん_ロードマップ作成会.png')
    70 = @('1mxunMVvNIOEN2YSV8dHds6nKx8cCW15k', 'ロードマップ作成会案内', 'META_SEMINAR_06-roadmap-session.png')
    71 = @('1ygs3It2ectQXDTrNhPMcrDcBpAeT8F3Y', '学びを行動へつなげる案内', 'META_SEMINAR_12-learning-to-action.png')
    73 = @('1-3WyEis8sNJhM0rhJGkOAzsVzN4Xbw1S', '動画終了・ロードマップ作成会受付', 'META_SEMINAR_13-video-closed-roadmap-open.png')
    75 = @('1w32JTpAdRDA2toSYaaQfBKhegpu8h4q3', '個別案内締切', 'META_SEMINAR_07-direct-invite-deadline.png')
    76 = @('1gxPIqZXdnXrPerx02k5NYiaACf3pMSrU', '個別案内の最終案内', 'META_SEMINAR_14-final-direct-invite.png')
    82 = @('12gMRxej-ZC0NN-YwcheiupmCgQWps1Vl', 'AIマニアの放課後オプチャ案内', 'META_SEMINAR_15-openchat-ai-mania.png')
    83 = @('18_-EvW5CpNIrGCZBv1LQ61iuaXjGS7y3', '金子さん向けオプチャ案内', 'META_SEMINAR_22_金子さん_オプチャ案内.png')
}

$rows = Import-Csv -Encoding UTF8 -LiteralPath $csv
foreach ($row in $rows) {
    $no = [int]$row.'No.'
    if ($row.ファネル -ne 'Meta広告_セミナー直行' -or -not $map.ContainsKey($no)) { continue }

    $image = $map[$no]
    $sheetRow = $no + 12
    $row.'画像URL（YouTube原本）' = 'https://drive.usercontent.google.com/download?id=' + $image[0] + '&export=view&confirm=t'
    $row.'画像プレビュー（セル内）' = '=IF(U' + $sheetRow + '="","",IMAGE(U' + $sheetRow + '))'
    $row.'画像内テキスト' = $image[1]
    $row.'使用指示・注意' = '吉本さんDrive原案 ' + $image[2] + ' を原寸・無加工で使用。本文・絵文字・分岐・配信時刻は承認済み行を維持する。'
}

$repo = (Get-Location).Path
$repoForGit = $repo.Replace('\', '/')
$originalCsv = Join-Path $repo '.codex-original-three-funnels-meta.csv'
$gitProcess = Start-Process -FilePath 'git' -ArgumentList @(
    '-c', "safe.directory=$repoForGit",
    'show', 'HEAD:kaneko-three-funnels-handoff/kaneko-three-funnels-all-scenarios.csv'
) -RedirectStandardOutput $originalCsv -WindowStyle Hidden -Wait -PassThru
if ($gitProcess.ExitCode -ne 0) { throw 'Could not read the committed CSV.' }

$raw = [IO.File]::ReadAllText($originalCsv, [Text.Encoding]::UTF8)
foreach ($no in ($map.Keys | Sort-Object)) {
    $updatedRow = $rows | Where-Object { $_.ファネル -eq 'Meta広告_セミナー直行' -and [int]$_.'No.' -eq $no }
    $serialized = ((@($updatedRow) | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1) -join "`r`n")
    $pattern = '(?ms)^Meta広告_セミナー直行,REVIEW_METAセミナー直行_20260805,' + $no + ',.*?(?=^Meta広告_セミナー直行,REVIEW_METAセミナー直行_20260805,\d+,|^Instagram_10大特典,|\z)'
    $replacement = $serialized + "`r`n"
    $next = [Text.RegularExpressions.Regex]::Replace($raw, $pattern, [Text.RegularExpressions.MatchEvaluator]{ param($match) $replacement }, 1)
    if ($next -eq $raw) { throw "Could not replace Meta seminar CSV No.$no" }
    $raw = $next
}
[IO.File]::WriteAllText($csv, $raw, (New-Object Text.UTF8Encoding($true)))

$updated = Import-Csv -Encoding UTF8 -LiteralPath $csv | Where-Object {
    $_.ファネル -eq 'Meta広告_セミナー直行' -and $_.'画像URL（YouTube原本）' -like 'https://drive.usercontent.google.com/*'
}
Write-Output "updated_meta_seminar_image_rows=$($updated.Count)"
