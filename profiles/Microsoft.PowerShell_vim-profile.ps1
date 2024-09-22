# 1.0.7936.41014 - Version number or identifier

# Set the VIM_HOME environment variable to the path of the Git usr\bin directory
$__VIM_HOME = Join-Path -Path (Split-Path (Split-Path -Path (Get-Command "git").Source)) -ChildPath "usr\bin"

# Add the VIM_HOME directory to the system PATH environment variable
Add-DirectoryToPath -Path $__VIM_HOME

# Define a function named vim to run the vim.exe command with the provided arguments
function vim { . vim.exe $args }

# Create an alias 'vi' for the vim function
Set-Alias -Name vi -Value vim