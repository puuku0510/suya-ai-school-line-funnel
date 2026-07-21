param(
    [string]$Source = "docs/youtube-line-message-copy.md",
    [string]$Output = "exports/youtube-line-funnel-messages.csv"
)

$ErrorActionPreference = "Stop"

function Convert-MarkdownCell {
    param([string]$Value)

    $clean = $Value.Trim()
    $clean = $clean -replace '<br>', "`r`n"
    $clean = $clean -replace '\*\*', ''
    $clean = $clean -replace '`', ''
    return $clean.Trim()
}

$rows = [System.Collections.Generic.List[object]]::new()
$section = ""
$salesIndex = 0

foreach ($line in Get-Content -Encoding UTF8 -LiteralPath $Source) {
    if ($line -match '^##\s+\d+\.\s+(.+)$') {
        $section = Convert-MarkdownCell $Matches[1]
        continue
    }

    if ($line -match '^\|\s+([A-Z]+-[A-Z0-9]+)\s+\|') {
        $cells = $line.Trim().Trim('|').Split('|') | ForEach-Object { $_.Trim() }
        if ($cells.Count -ne 5) {
            throw "Unexpected message row column count: $line"
        }

        $id = Convert-MarkdownCell $cells[0]
        $timing = Convert-MarkdownCell $cells[1]
        $subject = ""

        if ($id -like 'REG-M*') {
            $format = "メール"
            $subject = Convert-MarkdownCell $cells[2]
        }
        else {
            $format = Convert-MarkdownCell $cells[2]
        }

        $rows.Add([pscustomobject][ordered]@{
            'ID' = $id
            'シナリオ' = $section
            '配信タイミング' = $timing
            '推奨形式' = $format
            '件名' = $subject
            '本文' = Convert-MarkdownCell $cells[3]
            'CTA' = Convert-MarkdownCell $cells[4]
            '停止・自動処理' = ""
        })
        continue
    }

    if ($section -eq '営業担当者が面談後に送る共通文' -and $line -match '^\|\s+(成約|次回面談あり|次回面談なし|営業停止希望)\s+\|') {
        $cells = $line.Trim().Trim('|').Split('|') | ForEach-Object { $_.Trim() }
        if ($cells.Count -ne 4) {
            throw "Unexpected sales row column count: $line"
        }

        $salesIndex++
        $rows.Add([pscustomobject][ordered]@{
            'ID' = "SALES-{0:D2}" -f $salesIndex
            'シナリオ' = $section
            '配信タイミング' = "面談後"
            '推奨形式' = Convert-MarkdownCell $cells[1]
            '件名' = ""
            '本文' = Convert-MarkdownCell $cells[2]
            'CTA' = ""
            '停止・自動処理' = Convert-MarkdownCell $cells[3]
        })
    }
}

if ($rows.Count -ne 149) {
    throw "Expected 149 message rows, found $($rows.Count)."
}

$duplicateIds = $rows | Group-Object ID | Where-Object Count -gt 1
if ($duplicateIds) {
    throw "Duplicate message IDs: $($duplicateIds.Name -join ', ')"
}

$outputDirectory = Split-Path -Parent $Output
if ($outputDirectory) {
    New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
}

$rows | Export-Csv -LiteralPath $Output -NoTypeInformation -Encoding UTF8
Write-Output "Exported $($rows.Count) rows to $Output"
