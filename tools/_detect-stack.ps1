$root = "C:\src\products"
$products = @("academy","amb","bigart","cafe","gym","hotel","realty","salon","shop","veterinary")
$results = @{}
foreach ($p in $products) {
  $path = Join-Path $root $p

  $csprojs = @(Get-ChildItem $path -Filter "*.csproj" -Recurse -ErrorAction SilentlyContinue)
  $backend = ""
  if ($csprojs.Count -gt 0) {
    $csprojContent = Get-Content $csprojs[0].FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
    if ($csprojContent -match '<TargetFramework>([^<]+)</TargetFramework>') {
      $backend = ".NET " + $Matches[1]
    } else { $backend = ".NET" }
  }
  elseif (Test-Path (Join-Path $path "requirements.txt")) { $backend = "Python" }
  elseif (Test-Path (Join-Path $path "pyproject.toml"))   { $backend = "Python" }

  $pj = Get-ChildItem $path -Filter "package.json" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
  $frontend = ""
  if ($pj) {
    try {
      $pkg = Get-Content $pj.FullName -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction SilentlyContinue
      $d = $pkg.dependencies
      if ($d) {
        $f = ""
        if ($d.vue -or $d.Vue) { $f = "Vue 3" }
        elseif ($d.React)      { $f = "React" }
        elseif ($d.Svelte)     { $f = "Svelte" }
        else                    { $f = "Node.js" }
        $frontend = "$f + Vite"
      }
    } catch {}
  }
  if (-not $frontend) { $frontend = "no dedicated frontend" }

  $modules = @()
  foreach ($src in @("src","backend","frontend")) {
    $sp = Join-Path $path $src
    if (Test-Path $sp) {
      Get-ChildItem $sp -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notmatch "^\.|bin|obj|node_modules|dist" } |
        ForEach-Object { $modules += "$src/$($_.Name)" }
    }
  }

  $results[$p] = @{
    Backend = $backend
    Frontend = $frontend
    Modules = ($modules | Select-Object -Unique)
  }
}
$results | ConvertTo-Json -Depth 3 | Set-Content "C:\src\products\_standards\tools\stack-detection.json" -Encoding UTF8
Get-Content "C:\src\products\_standards\tools\stack-detection.json" -Encoding UTF8
