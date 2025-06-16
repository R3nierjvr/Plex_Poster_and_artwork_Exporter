Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# === FORM ===
$form = New-Object System.Windows.Forms.Form
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.ShowIcon = $fals
$form.Text = "Plex Poster Exporter"
$form.Size = New-Object System.Drawing.Size(420, 420)
$form.StartPosition = "CenterScreen"

# === LABELS & TEXTBOXES ===
$labelUrl = New-Object System.Windows.Forms.Label
$labelUrl.Text = "Plex Server URL:"
$labelUrl.Location = "10,20"
$form.Controls.Add($labelUrl)

$textBoxUrl = New-Object System.Windows.Forms.TextBox
$textBoxUrl.Text = "http://localhost:32400"
$textBoxUrl.Size = "280,20"
$textBoxUrl.Location = "120,20"
$form.Controls.Add($textBoxUrl)

$labelToken = New-Object System.Windows.Forms.Label
$labelToken.Text = "Plex Token:"
$labelToken.Location = "10,60"
$form.Controls.Add($labelToken)

$textBoxToken = New-Object System.Windows.Forms.TextBox
$textBoxToken.Size = "280,20"
$textBoxToken.Location = "120,60"
$form.Controls.Add($textBoxToken)

$labelLibrary = New-Object System.Windows.Forms.Label
$labelLibrary.Text = "Library Name:"
$labelLibrary.Location = "10,100"
$form.Controls.Add($labelLibrary)

$textBoxLibrary = New-Object System.Windows.Forms.TextBox
$textBoxLibrary.Size = "280,20"
$textBoxLibrary.Location = "120,100"
$form.Controls.Add($textBoxLibrary)

# === OUTPUT WINDOW ===
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.BackColor = [System.Drawing.Color]::White
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.ReadOnly = $true
$outputBox.Size = "380,130"
$outputBox.Location = "10,140"
$form.Controls.Add($outputBox)

# === PROGRESS BAR ===
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = "10,280"
$progressBar.Size = "380,10"
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Value = 0
$form.Controls.Add($progressBar)

# === BUTTONS ===
$scanButton = New-Object System.Windows.Forms.Button
$scanButton.Text = "Scan Library"
$scanButton.Size = "100,30"
$scanButton.Location = "40,310"
$form.Controls.Add($scanButton)

$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = "Start Export"
$startButton.Size = "100,30"
$startButton.Location = "260,310"
$form.Controls.Add($startButton)

# === FUNCTION TO RUN PYTHON SCRIPT ===
function Run-PythonScript {
    param (
        [string]$scriptContent,
        [switch]$CaptureOutput = $true
    )
    $tempFile = [System.IO.Path]::GetTempFileName().Replace(".tmp", ".py")
    Set-Content -Path $tempFile -Value $scriptContent -Encoding UTF8
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "python"
    $psi.Arguments = "`"$tempFile`""
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    $proc.Start() | Out-Null

    while (-not $proc.HasExited) {
        Start-Sleep -Milliseconds 100
        $output = $proc.StandardOutput.ReadLine()
        if ($output) {
            if ($output -like "PROGRESS:*") {
                $progress = $output -replace "PROGRESS:", ""
                $progressBar.Value = [math]::Min(100, [int]$progress)
            } else {
                $outputBox.AppendText("$output`r`n")
            }
        }
    }

    while (-not $proc.StandardOutput.EndOfStream) {
        $line = $proc.StandardOutput.ReadLine()
        if ($line -like "PROGRESS:*") {
            $progress = $line -replace "PROGRESS:", ""
            $progressBar.Value = [math]::Min(100, [int]$progress)
        } else {
            $outputBox.AppendText($line + "`r`n")
        }
    }

    while (-not $proc.StandardError.EndOfStream) {
        $outputBox.AppendText("[ERROR] " + $proc.StandardError.ReadLine() + "`r`n")
    }

    Remove-Item $tempFile -ErrorAction SilentlyContinue
}

# === SCAN LIBRARY EVENT ===
$scanButton.Add_Click({
    $url = $textBoxUrl.Text.Trim()
    $token = $textBoxToken.Text.Trim()
    $library = $textBoxLibrary.Text.Trim()
    $outputBox.AppendText("Scanning library: $library ...`r`n")
    $progressBar.Value = 0

    $scanScript = @"
from plexapi.server import PlexServer
plex = PlexServer('$url', '$token')
section = plex.library.section('$library')
count = len(section.all())
print(f'Library \"{section.title}\" contains {count} items.')
"@

    Run-PythonScript -scriptContent $scanScript
})

# === EXPORT BUTTON EVENT ===
$startButton.Add_Click({
    $url = $textBoxUrl.Text.Trim()
    $token = $textBoxToken.Text.Trim()
    $library = $textBoxLibrary.Text.Trim()
    $outputBox.AppendText("Starting export for: $library ...`r`n")
    $progressBar.Value = 0

    $exportScript = @"
from plexapi.server import PlexServer
import os, requests

PLEX_URL = '$url'
PLEX_TOKEN = '$token'
LIBRARY_NAME = '$library'
EXPORT_POSTER_NAME = 'poster.jpg'
EXPORT_FANART_NAME = 'fanart.jpg'

plex = PlexServer(PLEX_URL, PLEX_TOKEN)
library = plex.library.section(LIBRARY_NAME)
items = library.all()
total = len(items)

def download_image(url, path):
    headers = {'X-Plex-Token': PLEX_TOKEN}
    r = requests.get(url, headers=headers, stream=True)
    if r.status_code == 200:
        with open(path, 'wb') as f:
            for chunk in r.iter_content(1024):
                f.write(chunk)
        print(f"[OK] Saved: {path}")
    else:
        print(f"[FAILED] Could not download from {url}")

for index, item in enumerate(items):
    try:
        media_path = item.media[0].parts[0].file
        base = os.path.dirname(media_path)

        poster_url = f"{PLEX_URL}{item.thumb}"
        fanart_url = f"{PLEX_URL}{item.art}"

        print(f"Processing: {item.title}")
        download_image(poster_url, os.path.join(base, EXPORT_POSTER_NAME))
        download_image(fanart_url, os.path.join(base, EXPORT_FANART_NAME))
    except Exception as e:
        print(f"[ERROR] {item.title} -> {e}")
    
    percent = int(((index + 1) / total) * 100)
    print(f"PROGRESS:{percent}")
"@


    Run-PythonScript -scriptContent $exportScript
})

$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
