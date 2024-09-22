# 1.0.8036.30867 - Version number or identifier

[CmdletBinding()]
param( 
    # Define a switch parameter named 'completions'
    [switch] $completions 
)

# Add specified directories to the system PATH environment variable
"C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE", `
    "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\amd64", `
    "C:\Portable Apps\dnSpy\original", `
    "C:\Program Files\GitHub CLI" | Add-DirectoryToPath

# If the 'completions' switch is present, register argument completer for dotnet CLI
if ($completions.IsPresent) {
    Write-Host "Loading CLI completions for dotnet." -Foreground Darkgray 

    # PowerShell parameter completion shim for the dotnet CLI 
    Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
        param($commandName, $wordToComplete, $cursorPosition)
        # Use dotnet complete to get completions and format them as PowerShell completion results
        dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# Set the PROJECT_DIRECTORY environment variable to the Projects directory in the user's root
$Env:PROJECT_DIRECTORY = Join-Path -Path ([IO.Path]::GetPathRoot($Env:USERPROFILE)) -ChildPath "Projects"

# Define a function 'me' to navigate to the 'kamdzy' directory within PROJECT_DIRECTORY
Function me { Push-Location ([IO.Path]::Combine($Env:PROJECT_DIRECTORY, "kamdzy")) }

# Define a function 'pro' to navigate to the PROJECT_DIRECTORY
Function pro { Set-Location $Env:PROJECT_DIRECTORY }

# Define a function 'run-tests' to run dotnet tests for projects matching a specified pattern
Function run-tests {
    param([string]$pattern = "*Tests.csproj")
    # Recursively find and run dotnet tests for projects matching the pattern
    Get-ChildItem -Path $PATH -Recurse -Filter $pattern | ForEach-Object { dotnet test $_.FullName }
}

# Define a function 'vs' to open a Visual Studio solution or project
Function vs {
    [CmdletBinding()]
    param(
        # Define a parameter 'path' which can be provided via pipeline or property name
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Solution")]
        [Alias("Fullname")]
        [Alias("PSPath")]
        [string]$path = $null
    )

    # If no path is provided, find the first solution file in the current directory
    if (-not $path) {
        $solution = Get-ChildItem -Path $PWD -Filter "*.sln" | Select-Object -First 1
    }
    else {
        # Otherwise, get the item at the provided path
        $solution = Get-Item -Path $path
    }

    Write-Host $solution

    # If a solution is found, open it in Visual Studio
    if ($solution) { & devenv.exe $solution.FullName }
    else {
        # If no solution is found, find the first project file in the current directory
        $project = Get-ChildItem -Path $PWD -Filter "*.csproj" | Select-Object -First 1
        Write-Host $project
        if ($project) { & devenv.exe $project.FullName }
        else {
            # If no project is found, launch Visual Studio without a specific file
            Write-Host "Launching Visual Studio"
            & devenv.exe $args 
        }
    }
}