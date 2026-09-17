$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms

if (-not [System.Windows.Forms.Clipboard]::ContainsImage()) {
    throw 'The Windows clipboard does not contain an image.'
}

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
