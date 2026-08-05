$ErrorActionPreference = 'Stop'

$csv = Join-Path (Get-Location).Path 'kaneko-three-funnels-handoff\kaneko-three-funnels-all-scenarios.csv'
$map = @{
    11 = @('1Nh4_vdd1fOpvrmIFTaxjUSrK2ADEIV-t', '公式LINE登録で豪華10大特典（AI×ひとり起業完全版）', '8a963208-e6c2-4363-8049-9099e2528212.png')
    12 = @('1_VhKIcMLuby5D7FQQ7MLGTJcMseY4f7I', '登録特典⑤・オンラインセミナー招待券／参加者へ特典⑥〜⑩', '7d3a84d1-785a-4cbe-95c8-eec7c4f543d5.png')
    13 = @('1hDHYwE25L5n73r3M4u7dnhZP935HQ8-5', 'AIでひとり起業攻略法とは何か／具体的な次の一歩', 'a61066b1-911e-4aa9-9dae-effb289e7601.png')
    14 = @('1N4ce4deT64SE9bn9-tsgLF3B-K6o4coO', 'セミナー参加限定特典①〜⑤（豪華特典⑥〜⑩）', '84dbdc97-a0b4-4788-9d9c-6d402e369798.png')
    36 = @('1Z9VB42yiv1z89nCcPCO37reyGAPcLgtf', 'いよいよ明日開催・AIでひとり起業攻略法', 'f4b7db08-16a9-43f0-aaf3-caa0cb744151.png')
    37 = @('1XtcF3PKgU1v3is1AMfU6Y2u-m4SIP4u5', 'いよいよ本日開催・まだ申込可能・参加者限定5特典', '9994c0c9-dd85-4813-9d25-adadd2687812.png')
    39 = @('1LzdwxCZo6t1L1_48Qto7ZCfEm0To2kw6', 'いよいよ本日開催・まだ申込可能・参加者限定5特典（人物なし版）', 'e012febb-3b0a-4b8a-8ebb-91255149c38f.png')
    40 = @('1178CLZ6IuL48LtOLodOt42idmxdI649q', '20:00開始・AIでインスタ集客する方法・ライブ参加案内', 'edab37b2-5f31-4063-acc0-498b0d4d1096.png')
    48 = @('1yzVOowf9tGuaAintrOgi6rdIDqiE9tSt', 'セミナー不参加者へ3日間限定の録画公開', '6c890565-c8b5-4e58-948d-db5502dabbed.png')
    73 = @('1zDdYksox-PG8m4w80F3160DbK4iy8DOM', '動画視聴者へ30分無料個別面談', 'b8df8636-aa27-4f4a-a7a1-7ce2e3631b87.png')
    74 = @('1Ohu9GY2Tfou6npPdp-9bE4CUJj4kzLxV', 'セミナー参加者へ30分無料個別面談', '6641105e-3faa-4150-9a5f-6c64d87ba6dd.png')
    83 = @('1YCKctnlBFecaORB5B8Aa4z0ZnoWchcW6', '個別面談の予約ありがとうございます', '54f809d5-cf88-40f4-88b3-4147a1ec8fe7.png')
    88 = @('1rO5MZ9rDi6NHj-7zdqZOQs7VtrrLGfpn', 'LINEオープンチャット・無料勉強会の案内', '生成画像1.png')
}

$rows = Import-Csv -Encoding UTF8 -LiteralPath $csv
foreach ($row in $rows) {
    $no = [int]$row.'No.'
    if ($row.ファネル -ne 'Instagram_10大特典' -or -not $map.ContainsKey($no)) {
        continue
    }

    $image = $map[$no]
    $sheetRow = $no + 12
    $row.'画像URL（YouTube原本）' = 'https://drive.usercontent.google.com/download?id=' + $image[0] + '&export=view&confirm=t'
    $row.'画像プレビュー（セル内）' = '=IF(U' + $sheetRow + '="","",IMAGE(U' + $sheetRow + '))'
    $row.'画像内テキスト' = $image[1]
    $row.'使用指示・注意' = '吉本さん原案 ' + $image[2] + ' を原寸・無加工で使用。文章・絵文字・分岐・配信時刻は承認済み行を維持する。'
}

$repo = (Get-Location).Path
$repoForGit = $repo.Replace('\', '/')
$originalCsv = Join-Path $repo '.codex-original-three-funnels.csv'
$gitProcess = Start-Process -FilePath 'git' -ArgumentList @(
    '-c', "safe.directory=$repoForGit",
    'show', 'HEAD:kaneko-three-funnels-handoff/kaneko-three-funnels-all-scenarios.csv'
) -RedirectStandardOutput $originalCsv -WindowStyle Hidden -Wait -PassThru
if ($gitProcess.ExitCode -ne 0) {
    throw 'Could not read the committed CSV for minimal record replacement.'
}

$raw = [IO.File]::ReadAllText($originalCsv, [Text.Encoding]::UTF8)
foreach ($no in ($map.Keys | Sort-Object)) {
    $updatedRow = $rows | Where-Object { $_.ファネル -eq 'Instagram_10大特典' -and [int]$_.'No.' -eq $no }
    $serialized = ((@($updatedRow) | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1) -join "`r`n")
    $pattern = '(?ms)^Instagram_10大特典,REVIEW_Instagram10大特典_20260805,' + $no + ',.*?(?=^Instagram_10大特典,REVIEW_Instagram10大特典_20260805,\d+,|\z)'
    $replacement = $serialized + "`r`n"
    $next = [Text.RegularExpressions.Regex]::Replace($raw, $pattern, [Text.RegularExpressions.MatchEvaluator]{ param($match) $replacement }, 1)
    if ($next -eq $raw) {
        throw "Could not replace Instagram CSV No.$no"
    }
    $raw = $next
}

[IO.File]::WriteAllText($csv, $raw, (New-Object Text.UTF8Encoding($true)))
$workspaceRoot = Split-Path (Split-Path $repo -Parent) -Parent
Move-Item -LiteralPath $originalCsv -Destination (Join-Path $workspaceRoot '.codex-temp-inspection-original.csv') -Force

$updated = Import-Csv -Encoding UTF8 -LiteralPath $csv | Where-Object {
    $_.ファネル -eq 'Instagram_10大特典' -and $_.'画像URL（YouTube原本）' -like 'https://drive.usercontent.google.com/*'
}

Write-Output "updated_image_rows=$($updated.Count)"
