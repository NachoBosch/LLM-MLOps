param(
    [string]$Environment = "dev",   # dev | test | prod
    [string]$ProjectName = "twin"
)
$ErrorActionPreference = "Stop"

Write-Host "Deploying $ProjectName to $Environment ..." -ForegroundColor Green

# 1. Build Lambda package
$twinRoot = Split-Path $PSScriptRoot -Parent   # twin directory
Set-Location $twinRoot
Write-Host "Building Lambda package..." -ForegroundColor Yellow
Set-Location backend
uv run deploy.py
Set-Location ..

# 2. Read OpenAI API key from .env file
$envFile = "backend\.env"
$openaiApiKey = ""
if (Test-Path $envFile) {
    $envContent = Get-Content $envFile | Where-Object { $_ -match "^OPENAI_API_KEY=" }
    if ($envContent) {
        $openaiApiKey = ($envContent -split "=", 2)[1].Trim()
        Write-Host "Found OpenAI API key in .env file" -ForegroundColor Green
    }
}

if (-not $openaiApiKey) {
    Write-Host "Warning: OPENAI_API_KEY not found in backend\.env. You may need to set it manually." -ForegroundColor Yellow
    $openaiApiKey = Read-Host "Enter OpenAI API Key (or press Enter to skip)"
}

# 3. Terraform workspace & apply
Set-Location terraform
terraform init -input=false

if (-not (terraform workspace list | Select-String $Environment)) {
    terraform workspace new $Environment
} else {
    terraform workspace select $Environment
}

# Eliminar recurso de Bedrock del estado si existe (migración de Bedrock a OpenAI)
Write-Host "Verificando estado de Terraform..." -ForegroundColor Yellow
$bedrockState = terraform state list 2>$null | Select-String "lambda_bedrock"
if ($bedrockState) {
    Write-Host "Eliminando recurso de Bedrock del estado..." -ForegroundColor Yellow
    terraform state rm aws_iam_role_policy_attachment.lambda_bedrock 2>$null
}

# Construir argumentos de Terraform usando array para evitar problemas con espacios
$terraformArgs = @(
    "-var", "project_name=$ProjectName",
    "-var", "environment=$Environment"
)

if ($openaiApiKey) {
    $terraformArgs += "-var"
    $terraformArgs += "openai_api_key=$openaiApiKey"
}

$terraformArgs += "-auto-approve"

if ($Environment -eq "prod") {
    terraform apply -var-file=prod.tfvars $terraformArgs
} else {
    terraform apply $terraformArgs
}

# Verificar que terraform apply fue exitoso
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: terraform apply falló. Revisa los errores arriba." -ForegroundColor Red
    exit 1
}

# Obtener outputs de Terraform
Write-Host "Obteniendo outputs de Terraform..." -ForegroundColor Yellow
$ApiUrl = terraform output -raw api_gateway_url 2>$null
$FrontendBucket = terraform output -raw s3_frontend_bucket 2>$null
try { 
    $CustomUrl = terraform output -raw custom_domain_url 2>$null
    if (-not $CustomUrl) { $CustomUrl = "" }
} catch { 
    $CustomUrl = "" 
}

if (-not $ApiUrl -or -not $FrontendBucket) {
    Write-Host "ERROR: No se pudieron obtener los outputs de Terraform. El despliegue puede haber fallado." -ForegroundColor Red
    exit 1
}

# 4. Build + deploy frontend
Set-Location ..\frontend

# Create production environment file with API URL
Write-Host "Setting API URL for production..." -ForegroundColor Yellow
"NEXT_PUBLIC_API_URL=$ApiUrl" | Out-File .env.production -Encoding utf8

npm install
npm run build
aws s3 sync .\out "s3://$FrontendBucket/" --delete
Set-Location ..

# 5. Final summary
Set-Location terraform
$CfUrl = terraform output -raw cloudfront_url
Set-Location ..
Write-Host "Deployment complete!" -ForegroundColor Green
Write-Host "CloudFront URL : $CfUrl" -ForegroundColor Cyan
if ($CustomUrl) {
    Write-Host "Custom domain  : $CustomUrl" -ForegroundColor Cyan
}
Write-Host "API Gateway    : $ApiUrl" -ForegroundColor Cyan
