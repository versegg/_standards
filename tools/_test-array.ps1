$arr = @(
    'line1',
    'line2',
    ('one', 'two', 'three') -join "`n"
)
Write-Host "arr count: $($arr.Count)"
$arr | ForEach-Object { Write-Host "  |$_|" }

$arr3 = @(
    'line1',
    '',
    ('one', 'two', 'three') -join "`n",
    'line4'
)
Write-Host "arr3 count: $($arr3.Count)"
$arr3 | ForEach-Object { Write-Host "  |$_|" }
