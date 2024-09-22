# 1.0.8734.26968 - Version number or identifier

[CmdletBinding()]
param( 
    # Define a switch parameter named 'completions'
    [switch]$completions 
)

# Check if the 'completions' switch is present
if ($completions.IsPresent) {

    Write-Host "Loading CLI completions for git." -ForegroundColor Cyan

    ## CLI completions require Git bash

    # Set the GIT_HOME environment variable to the Git bin directory
    $__GIT_HOME = Join-Path -Path (Split-Path (Split-Path -Path (Get-Command "git").Source)) -ChildPath "bin"
    # Prepend the GIT_HOME to the system PATH
    $__GIT_HOME | Add-DirectoryToPath -Prepend

    # Define a function to check if a module is available
    Function Has-Module {
        param([string]$name)
        return [bool] (Get-Module -ListAvailable | Where-Object { $_.Name -eq $name })
    }

    # Define a function to install Git completions
    Function Install-GitCompletion {
        [CmdletBinding()]
        param([Alias("CompletionsPath")][string]$path)
        # Install the PSBashCompletions module
        Install-Module -Name PSBashCompletions -Scope CurrentUser -Force
        # Create the completions directory if it does not exist
        New-Item -Path $path -ItemType Directory -EA SilentlyContinue | Out-Null
        # Download the git-completion.bash script
        $completions = "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"
        Invoke-WebRequest -Method Get $completions -OutFile $path/git.sh
    }

    # Set the path for completions
    $completionsPath = Join-Path (Split-Path -Parent $PROFILE) Completions
    # Install Git completions if not already installed
    if ((-not (Has-Module PSBashCompletions)) -or (-not (Test-Path $completionsPath/git.sh))) {
        Install-GitCompletion -Completions $completionsPath
    }

    # If the completions path exists, import the PSBashCompletions module and register the Git argument completer
    if (Test-Path $completionsPath) {
        if (Get-Module -Name PSBashCompletions -ListAvailable) {
            Import-Module -Name PSBashCompletions
            Register-BashArgumentCompleter git "$completionsPath/git.sh"
        }
    }
}

# Define a function to add files to the Git staging area
Function add { git add $args }

# Define a function to amend the last commit
Function amend { git commit --amend $args }

# Define a function to amend the last commit without changing the commit message
Function append { git commit --amend --no-edit $args }

# Define a function to clone a Git repository
Function clone {
    [CmdletBinding()]
    param(
        [switch]$personal,
        [switch]$noSetLocation,
        [Parameter(ValueFromRemainingArguments = $true)]$remainingArgs
    )
    $path = ""
    # Clone the repository and capture the output
    & git clone --progress --recurse-submodules $remainingArgs 2>&1 | % {
        if ($_ -match "^Cloning into '(?<folder>[^']+)'") { $path = $matches["folder"] }
        if ($_ -match "[1-9]?[1-9]%") {}
        else { Write-Host $_ }
    }
    # If the personal switch is present, configure the local Git user
    if ($personal.IsPresent) {
        Push-Location $path
        git config --local user.email kamdzy@users.noreply.github.com
        git config --local user.name Kamdzy
        Pop-Location
    }
    # If the noSetLocation switch is not present, change the current directory to the cloned repository
    if (-not $noSetLocation.IsPresent) {
        Set-Location $path
    }
}

# Define a function to commit changes
Function commit { git commit $args }

# Define a function to manage Git flow features
Function feature {
    param(
        [string]$feature
    )

    if ($feature.Length -gt 0) {
        if ($feature -eq "publish") { & feature-publish }
        if ($feature -eq "finish") { & feature-finish }
        else { feature-start -feature $feature }
    }
    else {
        $branch = $(git rev-parse --abbrev-ref HEAD)
        $feature = $branch.Replace("feature/", "")
        Write-Output $feature
    }
}

# Define a function to start a Git flow feature
Function feature-start {
    param(
        [string]$feature
    )
    git flow feature start $feature
}

# Define a function to publish a Git flow feature
Function feature-publish {
    $branch = $(git rev-parse --abbrev-ref HEAD)
    $feature = $branch.Replace("feature/", "")
    git flow feature publish $feature
}

# Define a function to finish a Git flow feature
Function feature-finish {
    $branch = $(git rev-parse --abbrev-ref HEAD)
    $feature = $branch.Replace("feature/", "")
    git flow feature finish $feature
}

# Define a function to fetch all branches and prune deleted branches
Function fetch { git fetch --all -p $args }

# Define a function to display the Git status
Function g { git status }

# Define a function to display a decorated Git log graph
Function lol { git log --oneline --decorate --graph $args }

# Define a function to pull changes from the remote repository
Function pull { git fetch -p; git merge --ff-only }

# Define a function to push changes to the remote repository
Function push { git push $args }

# Define a function to push the current branch to the remote repository and set upstream
Function pushup {
    param(
        [string]$remote = "origin",
        [switch]$force
    )
    $branch = $(git rev-parse --abbrev-ref HEAD)
    if ($force.IsPresent) {
        git push --set-upstream $remote $branch --force
    }
    else {
        git push --set-upstream $remote $branch
    }
}

# Define a function to start a Git flow release
Function release-start {
    param(
        [string]$release
    )
    git flow release start $release
}

# Define a function to publish a Git flow release
Function release-publish {
    $branch = $(git rev-parse --abbrev-ref HEAD)
    $release = $branch.Replace("release/", "")
    git flow release publish $release
}

# Define a function to finish a Git flow release
Function release-finish {
    $branch = $(git rev-parse --abbrev-ref HEAD)
    $release = $branch.Replace("release/", "")
    git flow release finish $release
}

# Define a function to manage Git remotes
Function remote {

    if (($args.Length -eq 1) -and (Test-Path -Path $args[0])) {
        $path = $args[0]
        pushd $path; iex ". remote"; popd
        return
    }
    
    if (-not $args) {
        git remote -v | ? { $_ -match "(fetch)" } | `
            Select-Object -First 1 | % {
            $_ -replace "^(?<remote>[^\t\ ]+)\t+(?<uri>[^\ ]+)\ \(fetch\)`$", "`$2"
        }
    }
    else {
        git remote $args
    }
}

# Define a function to reset a file to the last commit
Function reset {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [Alias("FullName")]
        [string]$path
    )
    PROCESS {
        git checkout HEAD -- $path
    }
}

# Define a function to undo and redo changes to a file
Function undo_redo {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [Alias("FullName")]
        [string]$path,
        [string]$comment = "undo"
    )
    PROCESS {
        git checkout HEAD^1 -- "$path"
        git add $path
        git commit -m "$($comment): $($path)"
    }
}

# Define a function to undo changes to a file
Function undo {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [Alias("FullName")]
        [string]$path
    )
    PROCESS { undo_redo -path $path }
}

# Define a function to redo changes to a file
Function redo {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
        [Alias("FullName")]
        [string]$path
    )
    PROCESS { undo_redo -path $path -comment "redo" }
}