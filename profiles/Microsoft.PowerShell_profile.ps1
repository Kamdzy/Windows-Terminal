# 1.0.8030.24604 - Version number or identifier

## $Env:PATH management
Function Add-DirectoryToPath {
    [CmdletBinding()]
    param(
        # Define a mandatory parameter named 'path' which can be provided via pipeline or property name
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("FullName")]
        [string] $path,
        # Define a parameter named 'variable' with a default value of "PATH"
        [string] $variable = "PATH",

        # Define switch parameters for additional options
        [switch] $clear,
        [switch] $force,
        [switch] $prepend,
        [switch] $whatIf
    )

    BEGIN {
        ## Normalize paths

        $count = 0
        $paths = @()

        # If the 'clear' switch is not present, load the current PATH environment variable
        if (-not $clear.IsPresent) {
            $environ = Invoke-Expression "`$Env:$variable"
            $environ.Split(";") | ForEach-Object {
                if ($_.Length -gt 0) {
                    $count = $count + 1
                    $paths += $_.ToLowerInvariant()
                }
            }
            Write-Verbose "Currently $($count) entries in `$env:$variable"
        }

        # Define a helper function to check if an array contains a specific item
        Function Array-Contains {
            param(
                [string[]] $array,
                [string] $item
            )
            $any = $array | Where-Object -FilterScript {
                $_ -eq $item
            }
            Write-Output ($null -ne $any)
        }
    }

    PROCESS {
        ## Using [IO.Directory]::Exists() instead of Test-Path for performance purposes

        # Check if the directory exists or if the 'force' switch is present
        if ([IO.Directory]::Exists($path) -or $force.IsPresent) {
            $path = $path.Trim()
            $newPath = $path.ToLowerInvariant()

            # If the path is not already in the list, add it
            if (-not (Array-Contains -Array $paths -Item $newPath)) {
                if ($whatIf.IsPresent) {
                    Write-Host $path
                }

                # Prepend or append the path based on the 'prepend' switch
                if ($prepend.IsPresent) { $paths = , $path + $paths }
                else { $paths += $path }

                Write-Verbose "Adding $($path) to `$env:$variable"
            }
        }
        else {
            Write-Host "Invalid entry in `$Env:$($variable): ``$path``" -ForegroundColor Yellow
        }
    }

    END {
        ## Re-create PATH environment variable

        $separator = [IO.Path]::PathSeparator
        $joinedPaths = [string]::Join($separator, $paths)

        # If the 'whatIf' switch is present, output the new PATH
        if ($whatIf.IsPresent) {
            Write-Output $joinedPaths
        }
        else {
            # Update the PATH environment variable
            Invoke-Expression " `$env:$variable = `"$joinedPaths`" "
        }
    }
}

## Well-known profiles script
Function Get-DefaultProfile {
    # Get the path to the default profile script
    $___profile = Join-Path -Path (Split-Path -Path $profile -Parent) -ChildPath "profile.ps1"
    Write-Output $___profile
}

Function Remove-DefaultProfile {
    # Get the path to the default profile script
    $___profile = Get-DefaultProfile
    # If the default profile script exists, remove it
    if (Test-Path $___profile) { 
        Write-Host "Removing default profile file." -ForegroundColor Yellow
        Remove-Item $___profile -Force
    }
}

## Check if the 'Pwsh-Profile-Kam-New' module is available
if (-not (Get-Module -Name Pwsh-Profile-Kam-New -ListAvailable)) {
    Write-Host "Missing required 'Pwsh-Profile-Kam-New' module." -ForegroundColor Yellow
    Write-Host "Please, install this module once using the following command:" -ForegroundColor Yellow
    Write-Host "  Install-Module -Name Pwsh-Profile-Kam-New -Repository PSGallery -Scope CurrentUser -Force" -ForegroundColor DarkGray
    return
}
else {
    # Check for updates to the 'Pwsh-Profile-Kam-New' module
    $update8030 = Join-Path -Path (Get-CachedPowerShellProfileFolder) -ChildPath "pwsh_profile_8030"
    if (-not (Test-Path $update8030)) {
        \
        $online = Find-Module -Name Pwsh-Profile-Kam-New -Repository PSGallery
        $current = Get-module -Name Pwsh-Profile-Kam-New -ListAvailable
        if ($online.Version -gt $current.Version) {
            Write-Host "Required 'Pwsh-Profile-Kam-New' module has updates." -ForegroundColor Yellow
            Write-Host "Please, update this module using the following command:" -ForegroundColor Yellow
            Write-Host "  Update-Module -Name Pwsh-Profile-Kam-New -Force" -ForegroundColor DarkGray
        }
        Set-Content -Path $update8030 -Value $null
    }
}

# Check for profile updates and load the "profiles" profile quietly
CheckFor-ProfileUpdate | Out-Null
Load-Profile "profiles" -Quiet