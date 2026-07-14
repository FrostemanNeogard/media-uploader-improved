param(
    [Parameter(Mandatory=$true)]
    [string[]]$FilePaths,

    [Parameter(Mandatory=$false)]
    [string]$Destination = "",

    [Parameter(Mandatory=$false)]
    [string]$JellyfinUrl = "http://localhost:8096",

    [Parameter(Mandatory=$false)]
    [string]$ApiKey = "f5e9519d0d9b42649d77b76a82d8e46f"
)

$uploadUrl = "$($JellyfinUrl.TrimEnd('/'))/Plugins/MediaUploaderImproved/Upload"

foreach ($fp in $FilePaths) {
    if (-not (Test-Path -Path $fp -PathType Leaf)) {
        Write-Error "Datei nicht gefunden: $fp"
        return
    }
}

$headers = @{}
if (-not [string]::IsNullOrEmpty($ApiKey)) {
    $headers.Add("X-Emby-Token", $ApiKey)
    Write-Host "Verwende API Key zur Authentifizierung."
} else {
    Write-Host "Versuche Upload ohne API Key."
}

if (-not [string]::IsNullOrEmpty($Destination)) {
    Write-Host "Ziel (relativ): $Destination"
}

Write-Host "Versuche $($FilePaths.Count) Datei(en) nach '$uploadUrl' hochzuladen..."

$boundary = "---------------------------$([System.Guid]::NewGuid().ToString())"
$contentType = "multipart/form-data; boundary=$boundary"
$LF = "`r`n"

$bodyBytes = [System.Collections.Generic.List[byte]]::new()

if (-not [string]::IsNullOrEmpty($Destination)) {
    $destHeader = @(
        "--$boundary",
        "Content-Disposition: form-data; name=`"destination`"",
        "",
        $Destination
    ) -join $LF
    $bodyBytes.AddRange([System.Text.Encoding]::UTF8.GetBytes($destHeader + $LF))
}

foreach ($fp in $FilePaths) {
    $fileItem = Get-Item -Path $fp
    try {
        $fileBytes = [System.IO.File]::ReadAllBytes($fp)
    } catch {
         Write-Error "Fehler beim Lesen der Datei '$fp': $($_.Exception.Message)"
         return
    }

    $mimeType = switch ($fileItem.Extension.ToLower()) {
        ".mkv"  { "video/x-matroska" }
        ".mp4"  { "video/mp4" }
        ".avi"  { "video/x-msvideo" }
        ".mov"  { "video/quicktime" }
        ".wmv"  { "video/x-ms-wmv" }
        ".ts"   { "video/mp2t" }
        ".webm" { "video/webm" }
        ".mp3"  { "audio/mpeg" }
        ".flac" { "audio/flac" }
        ".wav"  { "audio/wav" }
        default { "application/octet-stream" }
    }

    $fileHeader = @(
        "--$boundary",
        "Content-Disposition: form-data; name=`"files`"; filename=`"$($fileItem.Name)`"",
        "Content-Type: $mimeType",
        ""
    ) -join $LF

    $bodyBytes.AddRange([System.Text.Encoding]::UTF8.GetBytes($fileHeader + $LF))
    $bodyBytes.AddRange($fileBytes)
    $bodyBytes.AddRange([System.Text.Encoding]::UTF8.GetBytes($LF))
}

$bodyBytes.AddRange([System.Text.Encoding]::UTF8.GetBytes("--$boundary--" + $LF))

$finalBody = $bodyBytes.ToArray()

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $response = Invoke-RestMethod -Uri $uploadUrl -Method Post -Headers $headers -ContentType $contentType -Body $finalBody

    $stopwatch.Stop()
    Write-Host "`n--- Server Antwort (Dauer: $($stopwatch.Elapsed.TotalSeconds)s) ---"
    $response | ConvertTo-Json -Depth 5 | Write-Host
    Write-Host "----------------------------------"
    Write-Host "Upload Befehl erfolgreich gesendet (Status 2xx). Prüfe Server-Logs und Dateisystem!" -ForegroundColor Green

} catch {
    $stopwatch.Stop()
    Write-Error "Fehler während der Web-Anfrage (Dauer: $($stopwatch.Elapsed.TotalSeconds)s):"
    Write-Error $_.Exception.Message

    $statusCode = $null
    $errorContent = $null
    if ($_.Exception.Response) {
         try { $statusCode = [int]$_.Exception.Response.StatusCode } catch {}
         try {
             $stream = $_.Exception.Response.GetResponseStream()
             $reader = New-Object System.IO.StreamReader($stream)
             $errorContent = $reader.ReadToEnd()
         } catch {
             $errorContent = "Fehlerinhalt konnte nicht gelesen werden."
         }
    }
    if ($statusCode) { Write-Error "HTTP Status Code: $statusCode" }
    if ($errorContent) { Write-Error "Fehler Antwort Inhalt: $errorContent" }
}

Write-Host "`nSkript beendet."
