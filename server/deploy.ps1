$ErrorActionPreference = "Stop"

Write-Host "Reading environment variables from env.yaml..."
$envContent = Get-Content "env.yaml"
$envVars = @()

foreach ($line in $envContent) {
    # Match lines like KEY: "VALUE" or KEY: VALUE
    if ($line -match "^([^:]+):\s*(.*)$") {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        
        # Remove surrounding quotes if present
        if ($value.StartsWith('"') -and $value.EndsWith('"')) {
            $value = $value.Substring(1, $value.Length - 2)
        }
        
        if ($key -and $value) {
            $envVars += "$key=$value"
        }
    }
}

$envString = $envVars -join ","

Write-Host "Deploying to Cloud Run..."
# Using --source . builds the container using Cloud Build automatically
# Added --project argument placeholder if needed, referencing current config
gcloud run deploy kayaone-backend `
    --source . `
    --project medinest-41066 `
    --region us-central1 `
    --allow-unauthenticated `
    --clear-base-image `
    --set-env-vars $envString
