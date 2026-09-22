$arr = @(
    'line1',
    'line2',
    ('one', 'two', 'three') -join "`n"
)
Write-Host "arr count: $($arr.Count)"
Write-Host "arr type: $($arr.GetType().FullName)"
$arr | ForEach-Object {
    Write-Host "Element type: $($_.GetType().FullName)"
    Write-Host "Element value: [$_]"
    Write-Host "Element length: $($_.Length)"
}
Write-Host "---"
# Without sub-expression
$arr2 = @(
    'line1',
    'line2',
    'line3'
)
Write-Host "arr2 count: $($arr2.Count)"
Write-Host "arr2 element 0: [$($arr2[0])]"
Write-Host "arr2 element 1: [$($arr2[1])]"
Write-Host "arr2 element 2: [$($arr2[2])]"
