[CmdletBinding()]
param(
    [string]$BaseUrl = 'https://raw.githubusercontent.com/puuku0510/suya-youtube-line-dashboard/main'
)

$ErrorActionPreference = 'Stop'
$expected = @{
    'funnel-current.csv' = @('snapshot_at','line_id','line_name','source','funnel_id','funnel_name','stage_id','stage_name','status_id','status_name','count','quality','source_system')
    'funnel-cohort.csv' = @('registration_date','line_id','line_name','source','funnel_id','funnel_name','channel_id','channel_name','video_id','video_title','registered','zoom_applied','seminar_applied','vsl_offered','vsl_started','vsl_completed','meeting_applied','meeting_from_vsl','meeting_from_seminar','openchat_offered','openchat_clicked','snapshot_at','quality')
    'funnel-sync-health.csv' = @('snapshot_at','configured_reader_records','unique_readers','labels_available_readers','unclassified_readers','label_coverage_rate','status','note')
}
$forbidden = @('name','display_name','email','phone','line_user_id','common_reader_id','reader_id')
$issues = [System.Collections.Generic.List[string]]::new()
$health = $null

foreach ($file in $expected.Keys) {
    $url = "$($BaseUrl.TrimEnd('/'))/$file"
    try {
        $text = (Invoke-WebRequest -UseBasicParsing -Uri $url).Content
    } catch {
        $issues.Add("Download failed: $file ($($_.Exception.Message))")
        continue
    }
    $lines = @($text -split "`r?`n" | Where-Object { $_ -ne '' })
    if ($lines.Count -eq 0) {
        $issues.Add("Empty file: $file")
        continue
    }
    $headers = @($lines[0] -split ',')
    if (($headers -join '|') -ne ($expected[$file] -join '|')) {
        $issues.Add("Header mismatch: $file")
    }
    foreach ($column in $headers) {
        if ($forbidden -contains $column) { $issues.Add("Forbidden personal-data column: $file / $column") }
    }
    if ($file -eq 'funnel-sync-health.csv' -and $lines.Count -ge 2) {
        $health = @($text | ConvertFrom-Csv)[0]
    }
}

if ($health) {
    Write-Host "Snapshot: $($health.snapshot_at)"
    Write-Host "Status: $($health.status)"
    Write-Host "Unique readers: $($health.unique_readers)"
    Write-Host "Unclassified: $($health.unclassified_readers)"
    Write-Host "Label coverage: $($health.label_coverage_rate)"
    if ($health.status -eq 'pending') { $issues.Add('The first sync after GitHub publication has not run yet.') }
}

if ($issues.Count) {
    Write-Host 'FAIL' -ForegroundColor Red
    $issues | ForEach-Object { Write-Host "- $_" }
    exit 1
}

Write-Host 'PASS' -ForegroundColor Green
Write-Host 'CSV structure, sync health, and personal-data columns were checked.'
exit 0
