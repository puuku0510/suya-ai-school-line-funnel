[CmdletBinding()]
param(
    [string]$SpreadsheetId = '1DylkYidyekEIZlBhlWnz5n-pGRCXiadgGGWqmCusME0',
    [datetime]$TargetDate = [datetime]::MinValue,
    [string]$JsonOutputPath,
    [switch]$WarningsAsErrors
)

$ErrorActionPreference = 'Stop'
$script:Findings = [System.Collections.Generic.List[object]]::new()

function Add-Finding {
    param(
        [ValidateSet('ERROR', 'WARN', 'INFO')][string]$Severity,
        [string]$Sheet,
        [int]$Row,
        [string]$Field,
        [string]$Message
    )

    $script:Findings.Add([pscustomobject]@{
        Severity = $Severity
        Sheet = $Sheet
        Row = $Row
        Field = $Field
        Message = $Message
    })
}

function Get-SheetRows {
    param(
        [Parameter(Mandatory)][string]$SheetName,
        [Parameter(Mandatory)][string]$Range
    )

    $sheet = [uri]::EscapeDataString($SheetName)
    $encodedRange = [uri]::EscapeDataString($Range)
    $url = "https://docs.google.com/spreadsheets/d/$SpreadsheetId/gviz/tq?tqx=out:csv&sheet=$sheet&range=$encodedRange"

    try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri $url -TimeoutSec 30
    }
    catch {
        throw "Google Spreadsheetの取得に失敗しました（$SheetName!$Range）: $($_.Exception.Message)"
    }

    if ($response.StatusCode -ne 200) {
        throw "Google Spreadsheetの取得に失敗しました（HTTP $($response.StatusCode): $SheetName!$Range）"
    }

    return @($response.Content | ConvertFrom-Csv)
}

function Get-Values {
    param([Parameter(Mandatory)]$Row)
    return @($Row.PSObject.Properties | ForEach-Object { [string]$_.Value })
}

function Get-DateValue {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) { return $null }
    $parsed = [datetime]::MinValue
    if ([datetime]::TryParse($Value, [ref]$parsed)) { return $parsed }
    return $null
}

function Test-NonNegativeInteger {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    $normalized = $Value.Replace(',', '').Trim()
    $number = 0L
    return [int64]::TryParse($normalized, [ref]$number) -and $number -ge 0
}

function Get-CountValue {
    param([string]$Value)
    if (-not (Test-NonNegativeInteger $Value)) { return 0L }
    return [int64]$Value.Replace(',', '').Trim()
}

function Test-DateHasTime {
    param([string]$Value)
    return -not [string]::IsNullOrWhiteSpace($Value) -and $Value -match '\d{1,2}:\d{2}'
}

function Test-FormulaError {
    param([string[]]$Values)
    return @($Values | Where-Object { $_ -match '^#(?:REF!|N/A|VALUE!|NAME\?|DIV/0!|NUM!|NULL!)$' }).Count -gt 0
}

function Require-Value {
    param(
        [string[]]$Values,
        [int]$Index,
        [string]$Sheet,
        [int]$Row,
        [string]$Field
    )
    if ($Index -ge $Values.Count -or [string]::IsNullOrWhiteSpace($Values[$Index])) {
        Add-Finding ERROR $Sheet $Row $Field '空欄です。指定された値を入力してください。'
        return $false
    }
    return $true
}

function Require-Count {
    param(
        [string[]]$Values,
        [int]$Index,
        [string]$Sheet,
        [int]$Row,
        [string]$Field
    )
    if ($Index -ge $Values.Count -or [string]::IsNullOrWhiteSpace($Values[$Index])) {
        Add-Finding ERROR $Sheet $Row $Field '空欄です。0件の場合も「0」を入力してください。'
        return $false
    }
    if (-not (Test-NonNegativeInteger $Values[$Index])) {
        Add-Finding ERROR $Sheet $Row $Field "0以上の整数ではありません: $($Values[$Index])"
        return $false
    }
    return $true
}

$routeRows = Get-SheetRows -SheetName 'ルート設定' -Range 'A4:P14'
$lineRows = Get-SheetRows -SheetName 'LINE日次' -Range 'A4:Q2004'
$funnelRows = Get-SheetRows -SheetName 'ファネル日次' -Range 'A4:AG2004'
$initialLineRows = Get-SheetRows -SheetName '初期棚卸し' -Range 'A4:I14'
$initialFunnelRows = Get-SheetRows -SheetName '初期棚卸し' -Range 'A21:I41'

$routeMap = @{}
$officialLineNames = [System.Collections.Generic.HashSet[string]]::new()
for ($i = 0; $i -lt $routeRows.Count; $i++) {
    $values = Get-Values $routeRows[$i]
    if ([string]::IsNullOrWhiteSpace($values[0])) { continue }
    $routeMap[$values[0]] = [pscustomobject]@{
        Name = $values[0]
        OfficialLine = $values[1]
        Source = $values[2]
        StartDate = Get-DateValue $values[5]
        EndDate = Get-DateValue $values[6]
        Monitoring = $values[7]
        Zoom = $values[8]
        Seminar = $values[9]
        DirectInterview = $values[10]
        Vsl = $values[11]
        OpenChat = $values[12]
    }
    if (-not [string]::IsNullOrWhiteSpace($values[1])) { [void]$officialLineNames.Add($values[1]) }
}

if ($TargetDate -eq [datetime]::MinValue) {
    try {
        $japanTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById('Tokyo Standard Time')
    }
    catch {
        $japanTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById('Asia/Tokyo')
    }
    $japanNow = [System.TimeZoneInfo]::ConvertTimeFromUtc([datetime]::UtcNow, $japanTimeZone)
    $TargetDate = $japanNow.Date.AddDays(-1)
}
$TargetDate = $TargetDate.Date

# 初期棚卸し: 公式LINE開始残高
$initialLineNames = [System.Collections.Generic.HashSet[string]]::new()
for ($i = 0; $i -lt $initialLineRows.Count; $i++) {
    $rowNumber = 5 + $i
    $values = Get-Values $initialLineRows[$i]
    if ($values.Count -lt 2 -or [string]::IsNullOrWhiteSpace($values[1])) { continue }

    if (-not $initialLineNames.Add($values[1])) {
        Add-Finding ERROR '初期棚卸し' $rowNumber '公式LINE正式名' "重複しています: $($values[1])"
    }
    if (-not $officialLineNames.Contains($values[1])) {
        Add-Finding ERROR '初期棚卸し' $rowNumber '公式LINE正式名' "ルート設定・ダッシュボードに未登録の名称です: $($values[1])"
    }
    [void](Require-Value $values 0 '初期棚卸し' $rowNumber '基準日時')
    [void](Require-Count $values 2 '初期棚卸し' $rowNumber '現在友だち数')
    [void](Require-Count $values 3 '初期棚卸し' $rowNumber '累計ブロック')
    if (-not (Test-DateHasTime $values[0])) {
        Add-Finding WARN '初期棚卸し' $rowNumber '基準日時' '日付だけです。実際に確認した時刻まで記録してください。'
    }
    if ($values.Count -gt 4 -and $values[4] -ne '入力完了') {
        Add-Finding ERROR '初期棚卸し' $rowNumber '入力状態' "入力完了ではありません: $($values[4])"
    }
}

# 初期棚卸し: ファネル開始残高
$initialRouteNames = [System.Collections.Generic.HashSet[string]]::new()
for ($i = 0; $i -lt $initialFunnelRows.Count; $i++) {
    $rowNumber = 22 + $i
    $values = Get-Values $initialFunnelRows[$i]
    if ($values.Count -lt 2 -or [string]::IsNullOrWhiteSpace($values[1])) { continue }

    if (Test-FormulaError $values) {
        Add-Finding ERROR '初期棚卸し' $rowNumber '数式' '数式エラーがあります。灰色セルは触らず管理者へ報告してください。'
    }
    if (-not $routeMap.ContainsKey($values[1])) {
        Add-Finding ERROR '初期棚卸し' $rowNumber 'ファネル管理名' "正式なファネル管理名ではありません: $($values[1])"
        continue
    }
    if (-not $initialRouteNames.Add($values[1])) {
        Add-Finding ERROR '初期棚卸し' $rowNumber 'ファネル管理名' "重複しています: $($values[1])"
    }
    [void](Require-Value $values 0 '初期棚卸し' $rowNumber '基準日時')
    foreach ($spec in @(@(2,'現在自動配信中'), @(3,'手動対応中（ファネル途中）'), @(4,'手動対応中（完走後）'), @(6,'オプチャ案内済み（累計）'), @(7,'遷移・滞留エラー'))) {
        [void](Require-Count $values $spec[0] '初期棚卸し' $rowNumber $spec[1])
    }
    if ($routeMap[$values[1]].Zoom -eq '対象') {
        [void](Require-Count $values 5 '初期棚卸し' $rowNumber '現在Zoomサポート会案内中')
    }
    if (-not (Test-DateHasTime $values[0])) {
        Add-Finding WARN '初期棚卸し' $rowNumber '基準日時' '日付だけです。実際に確認した時刻まで記録してください。'
    }
    if ($values.Count -gt 8 -and $values[8] -ne '入力完了') {
        Add-Finding ERROR '初期棚卸し' $rowNumber '入力状態' "入力完了ではありません: $($values[8])"
    }
}
foreach ($routeName in $routeMap.Keys) {
    if (-not $initialRouteNames.Contains($routeName)) {
        Add-Finding ERROR '初期棚卸し' 0 'ファネル開始残高' "開始残高の行がありません: $routeName"
    }
}

# LINE日次
$targetLineRows = @()
for ($i = 0; $i -lt $lineRows.Count; $i++) {
    $values = Get-Values $lineRows[$i]
    $date = Get-DateValue $values[0]
    if ($null -ne $date -and $date.Date -eq $TargetDate -and $values.Count -gt 3 -and -not [string]::IsNullOrWhiteSpace($values[3])) {
        $targetLineRows += [pscustomobject]@{ Row = 5 + $i; Values = $values }
    }
}

$lineKeys = @{}
foreach ($item in $targetLineRows) {
    $rowNumber = $item.Row
    $values = $item.Values
    $name = $values[3]

    if (-not $officialLineNames.Contains($name)) {
        Add-Finding ERROR 'LINE日次' $rowNumber '公式LINE正式名' "ルート設定・ダッシュボードに未登録の名称です: $name"
    }
    if ([string]::IsNullOrWhiteSpace($values[1])) {
        Add-Finding ERROR 'LINE日次' $rowNumber '集計対象期間（自動）' '自動計算式が空欄です。手入力せず管理者へ報告してください。'
    }
    [void](Require-Value $values 2 'LINE日次' $rowNumber 'データ確認日時')
    if (-not (Test-DateHasTime $values[2])) {
        Add-Finding WARN 'LINE日次' $rowNumber 'データ確認日時' '日付だけです。実際に確認した時刻まで記録してください。'
    }
    foreach ($spec in @(@(4,'本日新規LINE登録'), @(5,'本日ブロック増加'), @(6,'現在友だち数'), @(7,'累計ブロック'), @(9,'現在自動配信中'), @(10,'手動対応中（ファネル途中）'), @(11,'手動対応中（完走後）'))) {
        [void](Require-Count $values $spec[0] 'LINE日次' $rowNumber $spec[1])
    }
    [void](Require-Value $values 12 'LINE日次' $rowNumber '異常種別')
    [void](Require-Value $values 14 'LINE日次' $rowNumber '対応状況')
    if ($values[12] -eq '問題なし' -and $values[14] -ne '対応不要') {
        Add-Finding ERROR 'LINE日次' $rowNumber '対応状況' '異常種別が「問題なし」の場合は「対応不要」にしてください。'
    }
    if (-not [string]::IsNullOrWhiteSpace($values[12]) -and $values[12] -ne '問題なし') {
        [void](Require-Count $values 13 'LINE日次' $rowNumber '影響人数')
        if ($values[14] -eq '対応不要') {
            Add-Finding ERROR 'LINE日次' $rowNumber '対応状況' '異常があるため「対応不要」は選べません。'
        }
    }
    if ($values.Count -gt 16 -and $values[16] -ne '入力完了') {
        Add-Finding ERROR 'LINE日次' $rowNumber '入力状態' "入力完了ではありません: $($values[16])"
    }
    $key = "$($TargetDate.ToString('yyyyMMdd'))|$name"
    if ($lineKeys.ContainsKey($key)) {
        Add-Finding ERROR 'LINE日次' $rowNumber 'レコードキー' "同じ日・公式LINEの行が重複しています（先行行: $($lineKeys[$key])）。"
    }
    else { $lineKeys[$key] = $rowNumber }
}
foreach ($lineName in $officialLineNames) {
    if (-not $lineKeys.ContainsKey("$($TargetDate.ToString('yyyyMMdd'))|$lineName")) {
        Add-Finding ERROR 'LINE日次' 0 '公式LINE正式名' "対象日の行がありません: $lineName"
    }
}

# ファネル日次
$targetFunnelRows = @()
for ($i = 0; $i -lt $funnelRows.Count; $i++) {
    $values = Get-Values $funnelRows[$i]
    $date = Get-DateValue $values[0]
    if ($null -ne $date -and $date.Date -eq $TargetDate -and $values.Count -gt 3 -and -not [string]::IsNullOrWhiteSpace($values[3])) {
        $targetFunnelRows += [pscustomobject]@{ Row = 5 + $i; Values = $values }
    }
}

$funnelKeys = @{}
foreach ($item in $targetFunnelRows) {
    $rowNumber = $item.Row
    $values = $item.Values
    $routeName = $values[3]

    if (-not $routeMap.ContainsKey($routeName)) {
        Add-Finding ERROR 'ファネル日次' $rowNumber 'ファネル管理名' "ルート設定にない名称です: $routeName"
        continue
    }
    $route = $routeMap[$routeName]
    if ($values[4] -ne $route.OfficialLine) {
        Add-Finding ERROR 'ファネル日次' $rowNumber '公式LINE正式名' "自動参照値が不一致です。期待値: $($route.OfficialLine) / 実値: $($values[4])"
    }
    if ($values[5] -ne $route.Source) {
        Add-Finding ERROR 'ファネル日次' $rowNumber '流入元' "自動参照値が不一致です。期待値: $($route.Source) / 実値: $($values[5])"
    }
    if ([string]::IsNullOrWhiteSpace($values[1])) {
        Add-Finding ERROR 'ファネル日次' $rowNumber '集計対象期間（自動）' '自動計算式が空欄です。手入力せず管理者へ報告してください。'
    }
    [void](Require-Value $values 2 'ファネル日次' $rowNumber 'データ確認日時')
    if (-not (Test-DateHasTime $values[2])) {
        Add-Finding WARN 'ファネル日次' $rowNumber 'データ確認日時' '日付だけです。実際に確認した時刻まで記録してください。'
    }
    [void](Require-Count $values 6 'ファネル日次' $rowNumber '本日ファネル流入')
    [void](Require-Count $values 26 'ファネル日次' $rowNumber '遷移・滞留エラー')
    [void](Require-Value $values 27 'ファネル日次' $rowNumber '異常種別')
    [void](Require-Value $values 29 'ファネル日次' $rowNumber '対応状況')

    $stageSpecs = @(
        @{ Enabled = $route.Zoom -eq '対象'; Columns = @([pscustomobject]@{ Index = 7; Field = 'Zoomオファー流入' }, [pscustomobject]@{ Index = 8; Field = 'Zoom申込' }, [pscustomobject]@{ Index = 9; Field = 'Zoom段階ブロック' }) },
        @{ Enabled = $route.Seminar -eq '対象'; Columns = @([pscustomobject]@{ Index = 11; Field = 'セミナーオファー流入' }, [pscustomobject]@{ Index = 12; Field = 'セミナー申込' }, [pscustomobject]@{ Index = 13; Field = 'セミナー段階ブロック' }) },
        @{ Enabled = $route.DirectInterview -eq '対象'; Columns = @([pscustomobject]@{ Index = 15; Field = 'セミナー後面談申込' }) },
        @{ Enabled = $route.Vsl -eq '対象'; Columns = @([pscustomobject]@{ Index = 17; Field = 'VSLオファー流入' }, [pscustomobject]@{ Index = 18; Field = 'VSL経由面談申込' }, [pscustomobject]@{ Index = 19; Field = 'VSL段階ブロック' }) },
        @{ Enabled = $route.OpenChat -eq '対象'; Columns = @([pscustomobject]@{ Index = 22; Field = 'オプチャオファー' }, [pscustomobject]@{ Index = 23; Field = 'オプチャ移行' }, [pscustomobject]@{ Index = 24; Field = 'オプチャ段階ブロック' }) }
    )
    foreach ($stage in $stageSpecs) {
        if ($stage.Enabled) {
            foreach ($spec in $stage.Columns) {
                [void](Require-Count $values $spec.Index 'ファネル日次' $rowNumber $spec.Field)
            }
        }
    }
    if ($values[27] -eq '問題なし' -and $values[29] -ne '対応不要') {
        Add-Finding ERROR 'ファネル日次' $rowNumber '対応状況' '異常種別が「問題なし」の場合は「対応不要」にしてください。'
    }
    if (-not [string]::IsNullOrWhiteSpace($values[27]) -and $values[27] -ne '問題なし') {
        [void](Require-Count $values 28 'ファネル日次' $rowNumber '影響人数')
        if ($values[29] -eq '対応不要') {
            Add-Finding ERROR 'ファネル日次' $rowNumber '対応状況' '異常があるため「対応不要」は選べません。'
        }
    }
    if ($values.Count -gt 32 -and $values[32] -ne '入力完了') {
        Add-Finding ERROR 'ファネル日次' $rowNumber '入力状態' "入力完了ではありません: $($values[32])"
    }

    $activityColumns = @(6,7,8,9,11,12,13,15,17,18,19,22,23,24,26)
    $activity = 0L
    foreach ($column in $activityColumns) { $activity += Get-CountValue $values[$column] }
    $outsidePeriod = ($null -ne $route.StartDate -and $TargetDate -lt $route.StartDate.Date) -or ($null -ne $route.EndDate -and $TargetDate -gt $route.EndDate.Date)
    if ($outsidePeriod -and $activity -gt 0) {
        Add-Finding ERROR 'ファネル日次' $rowNumber '対象日' "ルートの適用期間外なのに実績があります: $routeName"
    }
    elseif ($outsidePeriod) {
        Add-Finding WARN 'ファネル日次' $rowNumber '対象日' "ルートの適用期間外の0件行です: $routeName"
    }

    $key = "$($TargetDate.ToString('yyyyMMdd'))|$routeName"
    if ($funnelKeys.ContainsKey($key)) {
        Add-Finding ERROR 'ファネル日次' $rowNumber 'レコードキー' "同じ日・ファネルの行が重複しています（先行行: $($funnelKeys[$key])）。"
    }
    else { $funnelKeys[$key] = $rowNumber }
}

foreach ($route in $routeMap.Values) {
    $active = ($null -eq $route.StartDate -or $TargetDate -ge $route.StartDate.Date) -and ($null -eq $route.EndDate -or $TargetDate -le $route.EndDate.Date)
    if ($active -and $route.Monitoring -eq '毎日監視') {
        $key = "$($TargetDate.ToString('yyyyMMdd'))|$($route.Name)"
        if (-not $funnelKeys.ContainsKey($key)) {
            Add-Finding ERROR 'ファネル日次' 0 'ファネル管理名' "毎日監視対象の行がありません: $($route.Name)"
        }
    }
}

$errors = @($script:Findings | Where-Object Severity -eq 'ERROR')
$warnings = @($script:Findings | Where-Object Severity -eq 'WARN')
$status = if ($errors.Count -eq 0 -and (-not $WarningsAsErrors -or $warnings.Count -eq 0)) { 'PASS' } else { 'FAIL' }

$report = [pscustomobject]@{
    SpreadsheetId = $SpreadsheetId
    SpreadsheetUrl = "https://docs.google.com/spreadsheets/d/$SpreadsheetId/edit"
    TargetDate = $TargetDate.ToString('yyyy-MM-dd')
    Status = $status
    CheckedAt = (Get-Date).ToString('s')
    LineRows = $targetLineRows.Count
    FunnelRows = $targetFunnelRows.Count
    ErrorCount = $errors.Count
    WarningCount = $warnings.Count
    Findings = @($script:Findings)
}

Write-Output "兼子さん日報チェック: $status"
Write-Output "対象日: $($report.TargetDate) / LINE日次: $($report.LineRows)行 / ファネル日次: $($report.FunnelRows)行"
Write-Output "エラー: $($report.ErrorCount)件 / 警告: $($report.WarningCount)件"
if ($script:Findings.Count -gt 0) {
    $script:Findings | Sort-Object @{ Expression = { if ($_.Severity -eq 'ERROR') { 0 } elseif ($_.Severity -eq 'WARN') { 1 } else { 2 } } }, Sheet, Row | Format-Table -AutoSize -Wrap
}

if (-not [string]::IsNullOrWhiteSpace($JsonOutputPath)) {
    $parent = Split-Path -Parent $JsonOutputPath
    if (-not [string]::IsNullOrWhiteSpace($parent) -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $report | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $JsonOutputPath -Encoding UTF8
    Write-Output "JSONレポート: $JsonOutputPath"
}

if ($status -ne 'PASS') { exit 1 }
exit 0
