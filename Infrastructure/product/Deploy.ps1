param (
	[Parameter(Mandatory=$true)]
    [string]    $ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]    $ResourceLocation,

    [Parameter(Mandatory=$true)]
    [string]    $ApiManagementName,

    [Parameter(Mandatory=$true)]
    [ValidateScript({[system.uri]::IsWellFormedUriString($_,[System.UriKind]::Absolute)})]
    [string]    $primaryBackendUrl

)  

$GlobalKeyPolicy = Get-Content -Raw -Path ".\policies\GlobalKeyPolicy.xml"
$CreateKeyPolicy = Get-Content -Raw -Path ".\policies\CreateKeyPolicy.xml"
$RateLimitPolicy = Get-Content -Raw -Path ".\policies\RateLimitPolicy.xml"
$MockPolicy = Get-Content -Raw -Path ".\policies\MockPolicy.xml"

$opts = @{
    Name                = ("Deployment-{0}-{1}" -f $ResourceGroupName, $(Get-Date).ToString("yyyyMMddhhmmss"))
    ResourceGroupName   = $ResourceGroupName
    TemplateFile        = (Join-Path -Path $PWD.Path -ChildPath "azuredeploy.json")
    apiManagementName   = $ApiManagementName
    primaryBackendUrl   = $PrimaryBackendUrl
    globalKeyPolicy     = $GlobalKeyPolicy
    createKeyPolicy     = $CreateKeyPolicy
    rateLimitPolicy     = $RateLimitPolicy
    mockPolicy          = $MockPolicy
}

New-AzResourcegroup -Name $ResourceGroupName -Location $ResourceLocation -Verbose
New-AzResourceGroupDeployment @opts -verbose   