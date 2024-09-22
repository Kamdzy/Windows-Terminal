# 1.0.8066.20885 - Version number or identifier

[CmdletBinding()]
param( 
    # Define a switch parameter named 'completions'
    [switch]$completions 
)

# Add specified directory to the system PATH environment variable
"C:\Portable Apps\Helm" | Add-DirectoryToPath

# Set the DOCKER_HOST environment variable to use TCP on localhost port 2375
$Env:DOCKER_HOST = "tcp://localhost:2375"

# Define a function to start Docker
Function Start-Docker {
    # Get the IP address of the WSL Ubuntu Docker instance
    $ip = (wsl -d ubuntu-docker sh -c "hostname -I").Split(" ")[0]
    # Display the netsh command to add a port proxy
    Write-Host "netsh interface portproxy add v4tov4 listenport=2375 connectport=2375 connectaddress=$ip"
    # Set the arguments for the netsh command
    $arguments = "interface portproxy add v4tov4 listenport=2375 connectport=2375 connectaddress=$ip" 
    # Run the netsh command with elevated privileges
    Start-Process netsh -ArgumentList $arguments -Verb RunAs
    # Start the Docker daemon in a background job
    Start-Job { param([string]$ip) wsl -d ubuntu-docker sh -c "sudo dockerd -H tcp://$ip" } -ArgumentList $ip | Out-Null
}
# Create an alias 'dockerd' for the Start-Docker function
Set-Alias -Name dockerd -Value Start-Docker

# Define a function to stop Docker
Function Stop-Docker { wsl --terminate ubuntu-docker }
# Create an alias 'rmdocker' for the Stop-Docker function
Set-Alias -Name rmdocker -Value Stop-Docker

# Define a function to start Kubernetes
Function Start-Kubernetes { wsl -d ubuntu-minikube sh -c "/home/kube/minikube.sh start --embed-certs" }
# Create an alias 'k8s' for the Start-Kubernetes function
Set-Alias -Name k8s -Value Start-Kubernetes

# Define a function to stop Kubernetes
Function Stop-Kubernetes { wsl --terminate ubuntu-minikube }
# Create aliases 'rmkube' and 'rmk8s' for the Stop-Kubernetes function
Set-Alias -Name rmkube -Value Stop-Kubernetes
Set-Alias -Name rmk8s -Value Stop-Kubernetes

# Define a function to start the Kubernetes control center dashboard
Function kontrol { Start-Job { kubectl confluent dashboard controlcenter --namespace confluent } }
# Define a function to run minikube commands
Function minikube { wsl -d ubuntu-minikube sh -c "/home/kube/minikube.sh $args" }

# If the 'completions' switch is present, register argument completers
if ($completions.IsPresent) {

    Write-Host "Loading CLI completions for docker | helm | kubectl." -ForegroundColor Cyan

    # Define a function to check if a module is available
    Function Has-Module {
        param([string]$name)
        return [bool] (Get-Module -ListAvailable | Where-Object { $_.Name -eq $name })
    }

    # Define a function to get PowerShell expressions from a file
    Function Get-PwshExpression {
        param([string]$path)

        # Read the content of the file
        $content = [IO.File]::ReadAllText($path)
        # Replace function and filter definitions to make them global
        $content = $content -replace "(?<!\-)[Ff]unction\ +([_A-Za-z]+)", 'Function global:$1'
        $content = $content -replace "(?<!\-)[Ff]ilter\ +([_A-Za-z]+)", 'Filter global:$1'
        $content = $content -replace "[Ss][Ee][Tt]\-[Aa][Ll][Ii][Aa][Ss]\ +(.*)", 'Set-Alias -Scope Global $1'

        Write-Output $content
    }

    # Define a function to install Docker CLI completions
    Function Install-DockerCompletion {
        Install-Module DockerCompletion -Scope CurrentUser -Force
    }

    # Define a function to install Kubernetes CLI completions
    Function Install-KubeCompletion {
        [CmdletBinding()]
        param([Alias("CompletionsPath")][string]$path)

        # Check if kubectl version is 1.23.x or later
        $version = ConvertFrom-JSON -InputObject (kubectl version).Replace("Client Version: version.Info", "")
        if ($version.Minor -lt 23) {
            Write-Host "kubectl CLI completion requires v1.23.0 or later. Please, upgrade kubectl.exe." -ForegroundColor Red
            Write-Host "Please, refer to the following instructions to install kubectl:" -ForegroundColor Yellow
            Write-Host "   https://kubernetes.io/docs/tasks/tools/install-kubectl-windows" -ForegroundColor DarkGray
            return
        }

        # Create the completions directory if it does not exist
        New-Item -Path $path -ItemType Directory -EA SilentlyContinue | Out-Null
        # Generate kubectl completions and save them to a file
        kubectl completion powershell | Out-String | Set-Content -Encoding ASCII -NoNewline -Path $path/kubectl.ps1
    }

    # Define a function to install Helm CLI completions
    Function Install-HelmCompletion {
        [CmdletBinding()]
        param([Alias("CompletionsPath")][string]$path)
        # Create the completions directory if it does not exist
        New-Item -Path $path -ItemType Directory -EA SilentlyContinue | Out-Null
        # Generate Helm completions and save them to a file
        helm completion powershell | Out-String | Set-Content -Encoding ASCII -NoNewline -Path $path/helm.ps1
    }

    # Set the path for completions
    $completionsPath = Join-Path (Split-Path -Parent $PROFILE) Completions
    # Install Docker completions if not already installed
    if (-not (Has-Module DockerCompletion)) { Install-DockerCompletion }
    # Install Helm completions if the file does not exist
    if (-not (Test-Path $completionsPath/helm.ps1)) {
        Install-HelmCompletion -Completions $completionsPath
    }
    # Install Kubernetes completions if the file does not exist
    if (-not (Test-Path $completionsPath/kubectl.ps1)) {
        Install-KubeCompletion -Completions $completionsPath
    }

    # Import DockerCompletion module
    Import-Module DockerCompletion

    # Load Helm completions if the file exists
    if (Test-Path $completionsPath/helm.ps1) {
        Get-PwshExpression -Path "$completionsPath/helm.ps1" | Invoke-Expression
    }
    # Load Kubernetes completions if the file exists
    if (Test-Path $completionsPath/kubectl.ps1) {
        Get-PwshExpression -Path "$completionsPath/kubectl.ps1" | Invoke-Expression
    }
}

# Define a function to run docker compose commands
Function compose { docker compose $args }

# Create aliases for kubectl
Set-Alias -Name "kube" -Value kubectl
Set-Alias -Name "kc" -Value kubectl