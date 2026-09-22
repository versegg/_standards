# Test variations
Write-Host "Test A: Simple"
$a = @('a', 'b', 'c')
"a count: $($a.Count)"

Write-Host "Test B: Sub-expression with -join"
$b = @(
    'a',
    'b',
    ('x', 'y', 'z') -join "|"
)
"b count: $($b.Count)"
$b | ForEach-Object { Write-Host "  [$_]" }

Write-Host "Test C: Just -join"
$c = ('p', 'q', 'r') -join "|"
"c: [$c] count: $($c.Count)"

Write-Host "Test D: Sub-expression alone"
$d = ('x', 'y', 'z')
"d type: $($d.GetType().Name)"
"d count: $($d.Count)"

Write-Host "Test E: @ with sub-expression"
$e = @(
    'a',
    'b',
    $c   # explicit variable
)
"e count: $($e.Count)"
$e | ForEach-Object { Write-Host "  [$_]" }
