[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$draftRoot = $PSScriptRoot
$exportRoot = Join-Path $draftRoot 'exports'
$assetRoot = Join-Path $draftRoot 'assets'

$expected = @(
    @{ File = 'youtube-yukkuri-ai-20260810.csv'; Rows = 199; Columns = 22; Type = 'YouTube'; Tag = 'src_youtube_yukkuri_ai' },
    @{ File = 'youtube-satori-20260810.csv'; Rows = 199; Columns = 22; Type = 'YouTube'; Tag = 'src_youtube_satori' },
    @{ File = 'youtube-yuru-ai-20260810.csv'; Rows = 199; Columns = 22; Type = 'YouTube'; Tag = 'src_youtube_yuruai' },
    @{ File = 'instagram-10benefits-20260810.csv'; Rows = 145; Columns = 27; Type = 'Instagram'; ImageFormulas = 15; UniqueImages = 13; Actions = 19 },
    @{ File = 'meta-seminar-direct-20260810.csv'; Rows = 118; Columns = 27; Type = 'Meta'; ImageFormulas = 29; UniqueImages = 22; Actions = 12 }
)

$failures = [System.Collections.Generic.List[string]]::new()
$reports = [System.Collections.Generic.List[object]]::new()
$actionType = ([char]0x30A2).ToString() + [char]0x30AF + [char]0x30B7 + [char]0x30E7 + [char]0x30F3
$deprecatedIds = @(
    'bvZVJd3EkGg5',
    'CQ6G6Icjx77d',
    'ifotTltN9ImD',
    'OndQwf3kv8kl',
    'ivBKWMlrnLV6',
    'bnlTD8AAv6rX'
)

function Get-Values {
    param([Parameter(Mandatory)]$Row)
    return @($Row.PSObject.Properties | ForEach-Object { $_.Value })
}

foreach ($spec in $expected) {
    $path = Join-Path $exportRoot $spec.File
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $failures.Add("Missing CSV: $($spec.File)")
        continue
    }

    $rows = @(Import-Csv -LiteralPath $path -Encoding UTF8)
    $columns = @($rows[0].PSObject.Properties).Count
    if ($rows.Count -ne $spec.Rows) {
        $failures.Add("$($spec.File): expected $($spec.Rows) rows, got $($rows.Count)")
    }
    if ($columns -ne $spec.Columns) {
        $failures.Add("$($spec.File): expected $($spec.Columns) columns, got $columns")
    }

    for ($i = 0; $i -lt $rows.Count; $i++) {
        $values = Get-Values -Row $rows[$i]
        if ([int]$values[2] -ne ($i + 1)) {
            $failures.Add("$($spec.File): sequence mismatch at index $i")
            break
        }
    }

    $raw = Get-Content -Raw -Encoding UTF8 -LiteralPath $path
    if ($raw.Contains('offer_vsl_confirmation_active')) {
        $failures.Add("$($spec.File): legacy VSL confirmation token remains")
    }

    if ($spec.Type -eq 'YouTube') {
        $actions = 0
        $deprecated = 0
        foreach ($item in $rows) {
            $values = Get-Values -Row $item
            if ($values[5] -eq $actionType) {
                $actions++
            }
            if (($values[21] -in $deprecatedIds) -and ($values[11] -like '*UTAGE*')) {
                $deprecated++
            }
        }
        if ($actions -ne 16) { $failures.Add("$($spec.File): expected 16 actions, got $actions") }
        if ($deprecated -ne 6) { $failures.Add("$($spec.File): expected 6 deprecated rows, got $deprecated") }
        if (-not $raw.Contains($spec.Tag)) { $failures.Add("$($spec.File): missing tag $($spec.Tag)") }
    }
    else {
        $actions = 0
        $imageFormulas = 0
        $imageUrls = [System.Collections.Generic.HashSet[string]]::new()
        $noShowNames = [System.Collections.Generic.HashSet[string]]::new()

        foreach ($item in $rows) {
            $values = Get-Values -Row $item
            if ($values[4] -eq $actionType) {
                $actions++
            }
            if ($values[23] -match 'IMAGE\(') { $imageFormulas++ }
            if ($values[22]) { [void]$imageUrls.Add([string]$values[22]) }
            if ($values[12] -in @('NS-01', 'NS-02', 'NS-03')) {
                [void]$noShowNames.Add([string]$values[12])
            }
        }

        if ($actions -ne $spec.Actions) {
            $failures.Add("$($spec.File): expected $($spec.Actions) actions, got $actions")
        }
        if ($imageFormulas -ne $spec.ImageFormulas) {
            $failures.Add("$($spec.File): expected $($spec.ImageFormulas) image formulas, got $imageFormulas")
        }
        if ($imageUrls.Count -ne $spec.UniqueImages) {
            $failures.Add("$($spec.File): expected $($spec.UniqueImages) unique images, got $($imageUrls.Count)")
        }
        if ($noShowNames.Count -ne 3) {
            $failures.Add("$($spec.File): missing NS-01..03 rows")
        }
    }

    $reports.Add([pscustomobject]@{
        File = $spec.File
        Rows = $rows.Count
        Columns = $columns
        Status = 'checked'
    })
}

$masterPath = Join-Path $draftRoot 'kaneko-three-funnels-all-scenarios.csv'
if (-not (Test-Path -LiteralPath $masterPath -PathType Leaf)) {
    $failures.Add('Missing master scenario CSV')
}
else {
    $master = @(Import-Csv -LiteralPath $masterPath -Encoding UTF8)
    $masterColumns = @($master[0].PSObject.Properties).Count
    if ($master.Count -ne 860) {
        $failures.Add("Expected 860 master rows, got $($master.Count)")
    }
    if ($masterColumns -ne 32) {
        $failures.Add("Expected 32 master columns, got $masterColumns")
    }

    $sheetCounts = @{}
    foreach ($item in $master) {
        $values = Get-Values -Row $item
        $key = [string]$values[1]
        if (-not $sheetCounts.ContainsKey($key)) { $sheetCounts[$key] = 0 }
        $sheetCounts[$key]++
    }
    $actualCounts = @($sheetCounts.Values | Sort-Object)
    $expectedCounts = @(118, 145, 199, 199, 199)
    if (($actualCounts -join ',') -ne ($expectedCounts -join ',')) {
        $failures.Add("Unexpected master sheet counts: $($actualCounts -join ',')")
    }
}

$manifestPath = Join-Path $draftRoot 'assets-manifest.csv'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    $failures.Add('Missing asset manifest')
}
else {
    $manifest = @(Import-Csv -LiteralPath $manifestPath -Encoding UTF8)
    if ($manifest.Count -ne 35) {
        $failures.Add("Expected 35 assets, got $($manifest.Count)")
    }

    $hashes = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($item in $manifest) {
        $values = Get-Values -Row $item
        $relativePath = [string]$values[1]
        $expectedBytes = [int64]$values[2]
        $expectedHash = [string]$values[5]
        [void]$hashes.Add($expectedHash)

        $path = Join-Path $assetRoot $relativePath
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            $failures.Add("Missing asset: $relativePath")
            continue
        }
        $actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLowerInvariant()
        if ($actualHash -ne $expectedHash) {
            $failures.Add("Hash mismatch: $relativePath")
        }
        if ((Get-Item -LiteralPath $path).Length -ne $expectedBytes) {
            $failures.Add("Size mismatch: $relativePath")
        }
    }
    if ($hashes.Count -ne 35) {
        $failures.Add('Asset hashes are not unique')
    }
}

$reports | Format-Table -AutoSize
Write-Output 'Assets checked: 35'

if ($failures.Count -gt 0) {
    $nl = [Environment]::NewLine
    Write-Error ('Handoff verification failed:' + $nl + '- ' + ($failures -join ($nl + '- ')))
}

Write-Output 'Handoff verification passed.'
