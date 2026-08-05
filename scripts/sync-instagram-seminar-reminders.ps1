$ErrorActionPreference = 'Stop'

$csv = Join-Path (Get-Location).Path 'kaneko-three-funnels-handoff\kaneko-three-funnels-all-scenarios.csv'
$all = Import-Csv -Encoding UTF8 -LiteralPath $csv
$original = @($all | Where-Object { $_.ファネル -eq 'Instagram_10大特典' } | Sort-Object { [int]$_.'No.' })
if ($original.Count -ne 85) { throw "Expected 85 Instagram rows before cadence expansion, got $($original.Count)." }

$byNo = @{}
foreach ($row in $original) { $byNo[[int]$row.'No.'] = $row }

function Copy-Row([object]$source) { return $source.PSObject.Copy() }
function Set-Value([object]$row, [string]$name, [object]$value) { $row.$name = $value }

$expanded = New-Object System.Collections.Generic.List[object]
foreach ($source in $original) {
    $oldNo = [int]$source.'No.'
    $row = Copy-Row $source
    $shift = 0
    if ($oldNo -gt 16) { $shift += 2 }
    if ($oldNo -gt 39) { $shift += 2 }
    Set-Value $row 'No.' ($oldNo + $shift)

    if ($oldNo -eq 40) { Set-Value $row '管理名称' 'REG-M04（前日19:00メール）' }
    if ($oldNo -eq 41) { Set-Value $row '管理名称' 'REG-M05（1時間前メール）' }
    if ($oldNo -eq 42) {
        Set-Value $row '管理名称' 'REG-M06（翌日10:00・再公開希望確認メール）'
        Set-Value $row '件名' '見逃し配信をご希望ですか？｜[セミナー名]'
        Set-Value $row '本文（全文・編集可）' @'
%line_name%さん

こすもすです😊
昨日の「AIでひとり起業攻略法」について、
見逃した方・もう一度確認したい方向けに、
3日間の見逃し配信をご用意しています。

視聴を希望する方は、下のリンクから
見逃し配信を希望してください👇

[再公開希望アクション]

配信停止をご希望の方はこちら：%cancel%
'@
        Set-Value $row 'CTA文言' '3日間の見逃し配信を希望する'
        Set-Value $row 'CTA URL／変数' '[再公開希望アクション]'
        Set-Value $row '実装メモ' '吉本さん原案 IG-RQ-01 の文章・絵文字をメール形式へ転用。リンク押下者だけ3日VSLへ進め、未押下者へVSLを送らない。'
        Set-Value $row '使用指示・注意' '吉本さん原案 IG-RQ-01 を基礎。本文・絵文字を維持し、メールに必要な宛名・配信停止だけ補う。VSL URLは直接記載しない。'
    }

    $expanded.Add($row)

    if ($oldNo -eq 16) {
        $d7Morning = Copy-Row $byNo[16]
        Set-Value $d7Morning 'No.' 17
        Set-Value $d7Morning '管理ID' 'IG-SEM-D7-10-NEW'
        Set-Value $d7Morning '配信タイミング' '登録から7日後 10:00'
        Set-Value $d7Morning '推奨形式' 'テキスト＋ボタン'
        Set-Value $d7Morning '管理名称' 'SEM-D7-01（開催7日前10:00）'
        Set-Value $d7Morning '本文（全文・編集可）' @'
【LINEメッセージ 1／text】
セミナー開催まで【あと1週間】です！🗓️✨

今回のセミナーでは、単にAIの知識を
増やすだけではなく、以下の3点を
あなたのペースに合わせて整理していきます🌱✨

１．今のあなたに実践できること🚀
２．あなたの生活・仕事で「AIを活かせる場面」🤖
３．今日からスタートできる「最初の一歩」💪

▼お席の確保はこちらからどうぞ👇😊
[セミナー申込URL]
'@
        Set-Value $d7Morning 'CTA文言' 'セミナー内容を確認する'
        Set-Value $d7Morning '停止・除外条件' 'セミナー申込済み／面談予約済／商談中／成約／営業停止は除外'
        Set-Value $d7Morning '実装メモ' '吉本さん原案 SEM-U17 の文章・絵文字を基礎に、開催1週間前の案内だけ追記。セミナー申込で即停止し、登録時点で7日前を過ぎている場合はスキップ。'
        Set-Value $d7Morning '画像URL（YouTube原本）' $null
        Set-Value $d7Morning '画像プレビュー（セル内）' $null
        Set-Value $d7Morning '画像内テキスト' $null
        Set-Value $d7Morning '使用指示・注意' '吉本さん原案 SEM-U17 を基礎。本文・絵文字を優先し、開催1週間前の表記と分岐・変数だけ現行確定ルールへ合わせる。'
        $expanded.Add($d7Morning)

        $d7Evening = Copy-Row $byNo[19]
        Set-Value $d7Evening 'No.' 18
        Set-Value $d7Evening '管理ID' 'IG-SEM-D7-20-NEW'
        Set-Value $d7Evening '配信タイミング' '登録から7日後 20:00'
        Set-Value $d7Evening '管理名称' 'SEM-D7-02（開催7日前20:00）'
        Set-Value $d7Evening '本文（全文・編集可）' @'
【LINEメッセージ 1／text】
セミナー開催まで【あと1週間】です！🗓️✨

セミナーのお申し込みは、お名前と
メールアドレスを入力するだけで完了します📝✨

ご登録後、参加URLをLINEとメールの
両方へお送りします。
当日都合が悪くなりましたら、キャンセルの連絡をいただければ問題ございませんので、
まずは開催日時が合うかだけでも確認してみてくださいね👇😊
[セミナー申込URL]
'@
        Set-Value $d7Evening 'CTA文言' '日時を確認して申し込む'
        Set-Value $d7Evening '停止・除外条件' 'セミナー申込済み／面談予約済／商談中／成約／営業停止は除外'
        Set-Value $d7Evening '実装メモ' '吉本さん原案 SEM-U18 の文章・絵文字を基礎に、開催1週間前の案内だけ追記。セミナー申込で即停止し、登録時点で7日前を過ぎている場合はスキップ。'
        Set-Value $d7Evening '画像URL（YouTube原本）' $null
        Set-Value $d7Evening '画像プレビュー（セル内）' $null
        Set-Value $d7Evening '画像内テキスト' $null
        Set-Value $d7Evening '使用指示・注意' '吉本さん原案 SEM-U18 を基礎。本文・絵文字を優先し、開催1週間前の表記と分岐・変数だけ現行確定ルールへ合わせる。'
        $expanded.Add($d7Evening)
    }

    if ($oldNo -eq 39) {
        $d7Mail = Copy-Row $byNo[40]
        Set-Value $d7Mail 'No.' 42
        Set-Value $d7Mail '管理ID' 'IG-REG-M-D7-NEW'
        Set-Value $d7Mail '配信タイミング' 'イベント7日前 08:00'
        Set-Value $d7Mail '管理名称' 'REG-M02（7日前メール）'
        Set-Value $d7Mail '件名' '開催1週間前｜[セミナー名]'
        Set-Value $d7Mail '本文（全文・編集可）' @'
%line_name%さん

こすもすです😊
セミナー開催の【1週間前】となりました！🗓️

「うっかり忘れていた！」とならないように、
カレンダーへのご登録や、参加用URLの保存が
お済みか、今一度ご確認くださいね😊👇

━━━━━━━━━━━━━━━━━━━━
【日時】%event_schedule%
【参加URL】[ZoomURL]
━━━━━━━━━━━━━━━━━━━━

配信停止をご希望の方はこちら：%cancel%
'@
        Set-Value $d7Mail 'CTA文言' '参加情報を確認する'
        Set-Value $d7Mail 'CTA URL／変数' '[ZoomURL]'
        Set-Value $d7Mail '実装メモ' '吉本さん原案 REG-L02 の文章・絵文字をメール形式へ転用。配信時刻・分岐・変数は確定済みInstagram設計を優先。'
        Set-Value $d7Mail '使用指示・注意' '吉本さん原案 REG-L02 を基礎。本文・絵文字は維持し、メールに必要な宛名・参加情報・配信停止だけ既存メール形式で補う。'
        $expanded.Add($d7Mail)

        $d3Mail = Copy-Row $byNo[40]
        Set-Value $d3Mail 'No.' 43
        Set-Value $d3Mail '管理ID' 'IG-REG-M-D3-NEW'
        Set-Value $d3Mail '配信タイミング' 'イベント3日前 08:00'
        Set-Value $d3Mail '管理名称' 'REG-M03（3日前メール）'
        Set-Value $d3Mail '件名' '開催3日前｜[セミナー名]'
        Set-Value $d3Mail '本文（全文・編集可）' @'
%line_name%さん

こすもすです😊
セミナー開催まで【あと3日】です！⏰✨

お早めにお申し込みいただいた方にのみ、
よりセミナーを充実した時間にする方法をお伝えします㊙️

以下の3点を参加前に整理しておくのがオススメです！
・今の仕事でのお悩み
・自分の得意なこと
・AIでやってみたいこと

というのも、セミナー時は常に質疑応答を受け付けております。☺️
特に最後には長い時間確保し、壁打ちの時間を用意しているので、
少しだけ質問や解消したい事を考えておくと、
私が全てお答えいたします🚀🔥

楽しみにしていてください😊

━━━━━━━━━━━━━━━━━━━━
【日時】%event_schedule%
【参加URL】[ZoomURL]
━━━━━━━━━━━━━━━━━━━━

配信停止をご希望の方はこちら：%cancel%
'@
        Set-Value $d3Mail 'CTA文言' '参加URLを確認する'
        Set-Value $d3Mail 'CTA URL／変数' '[ZoomURL]'
        Set-Value $d3Mail '実装メモ' '吉本さん原案 REG-L03 の文章・絵文字をメール形式へ転用。配信時刻・分岐・変数は確定済みInstagram設計を優先。'
        Set-Value $d3Mail '使用指示・注意' '吉本さん原案 REG-L03 を基礎。本文・絵文字は維持し、メールに必要な宛名・参加情報・配信停止だけ既存メール形式で補う。'
        $expanded.Add($d3Mail)
    }
}

$expanded = @($expanded | Sort-Object { [int]$_.'No.' })
if ($expanded.Count -ne 89) { throw "Expected 89 expanded Instagram rows, got $($expanded.Count)." }
for ($i = 0; $i -lt $expanded.Count; $i++) {
    if ([int]$expanded[$i].'No.' -ne ($i + 1)) { throw "Instagram No. sequence breaks at index $i." }
    if ($expanded[$i].'画像URL（YouTube原本）') {
        $sheetRow = [int]$expanded[$i].'No.' + 12
        Set-Value $expanded[$i] '画像プレビュー（セル内）' ('=IF(U' + $sheetRow + '="","",IMAGE(U' + $sheetRow + '))')
    }
}

$serialized = (($expanded | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1) -join "`r`n") + "`r`n"
$raw = [IO.File]::ReadAllText($csv, [Text.Encoding]::UTF8)
$pattern = '(?ms)^Instagram_10大特典,REVIEW_Instagram10大特典_20260805,1,.*\z'
$next = [Text.RegularExpressions.Regex]::Replace($raw, $pattern, [Text.RegularExpressions.MatchEvaluator]{ param($match) $serialized }, 1)
if ($next -eq $raw) { throw 'Could not replace the Instagram CSV segment.' }
[IO.File]::WriteAllText($csv, $next, (New-Object Text.UTF8Encoding($true)))

Write-Output 'instagram_rows=89'
Write-Output 'unregistered_d7=2'
Write-Output 'unregistered_d3=2'
Write-Output 'registered_d7_channels=2'
Write-Output 'registered_d3_channels=2'
