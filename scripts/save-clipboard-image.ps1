$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms

if ([System.Windows.Forms.Clipboard]::ContainsImage()) {
    $image = [System.Windows.Forms.Clipboard]::GetImage()
    if ($null -eq $image) {
        throw 'The Windows clipboard image could not be read.'
    }

    try {
        $directory = Join-Path $env:TEMP 'herdr-clipboard-images'
        New-Item -ItemType Directory -Path $directory -Force | Out-Null

        $name = $env:HERDR_CLIPBOARD_PNG_NAME
        if ([string]::IsNullOrWhiteSpace($name)) {
            $name = "herdr-clipboard-$([DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss-fff')).png"
        }

        $path = Join-Path $directory $name
        $image.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
        [Console]::Out.WriteLine($path)
    }
    finally {
        $image.Dispose()
    }
    exit 0
}

# Some capture tools save directly to Pictures\Screenshots without putting a
# Bitmap on the Windows clipboard. Use only a very recent file so Ctrl+V never
# pastes an unrelated old capture.
$screenshotsDirectory = Join-Path $env:USERPROFILE 'Pictures\Screenshots'
$recentScreenshot = Get-ChildItem -LiteralPath $screenshotsDirectory -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Extension -in '.png', '.jpg', '.jpeg', '.bmp', '.webp' } |
    Sort-Object LastWriteTimeUtc -Descending |
    Select-Object -First 1

if ($null -eq $recentScreenshot) {
    throw 'The Windows clipboard does not contain an image, and no screenshot file was found.'
}

$ageSeconds = ([DateTime]::UtcNow - $recentScreenshot.LastWriteTimeUtc).TotalSeconds
if ($ageSeconds -gt 300) {
    throw "The Windows clipboard does not contain an image, and the newest screenshot is $([math]::Round($ageSeconds)) seconds old."
}

[Console]::Out.WriteLine($recentScreenshot.FullName)
