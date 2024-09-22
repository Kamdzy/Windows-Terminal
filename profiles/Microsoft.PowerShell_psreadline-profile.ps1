# 1.0.8053.38379 - Version number or identifier

# Set the PSReadLine editing mode to Vi
Set-PSReadLineOption -EditMode Vi

# Get the version of the PSReadLine module and convert it to an integer
$psReadLineVersion = [int]"$((Get-Module PSReadLine).Version.ToString())".Replace(".", "")
# If the PSReadLine version is 2.1.0 or higher, configure additional options
if ($psReadLineVersion -ge 210) {
    # Define a prompt character
    $promptChar = [char]0xe0b0
    # Define options for the prompt text with different colors
    $options = @{
        PromptText = `
            "`e[38;2;88;88;88m${promptChar}`e[0m ", # Gray prompt character
        "`e[91m${promptChar}`e[0m " `              # Red prompt character
        ;
    }
    # Set the PSReadLine options for the prompt text
    Set-PSReadLineOption @options
    # Set the continuation prompt with a gray background and prompt character
    Set-PSReadLineOption -ContinuationPrompt "`e[48;2;88;88;88m `e[0m`e[38;2;88;88;88m$([char]0xE0B0)`e[0m "

    # Set the prediction source to history
    Set-PSReadLineOption -PredictionSource History
    # Set a key handler for Vi insert mode to accept the next suggestion word with Ctrl+)
    Set-PSReadLineKeyHandler -ViMode Insert -Chord "Ctrl+)" -Function AcceptNextSuggestionWord

    # Define a script block to handle Vi mode changes
    $HandleViModeChanged = [scriptblock] {
        if ($args[0] -eq 'Command') {
            # Set the cursor to a blinking block in command mode
            Write-Host -NoNewLine "`e[1 q"
        }
        else {
            # Set the cursor to a blinking line in insert mode
            Write-Host -NoNewLine "`e[5 q"
        }
    }

    # Set the Vi mode indicator to use the script block for mode changes
    Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $HandleViModeChanged
}

# Set a key handler to use menu completion with the Tab key
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Set key handlers for reverse and forward search history in Vi insert mode
Set-PSReadLineKeyHandler -Chord "Ctrl+r" -ViMode Insert -Function ReverseSearchHistory
Set-PSReadLineKeyHandler -Chord "Ctrl+s" -ViMode Insert -Function ForwardSearchHistory

# Remap keys from the French AZERTY layout to the new keys from the French AZERTY-NF layout
Set-PSReadLineKeyHandler -Key '+' -ViMode Command -Function MoveToEndOfLine
Set-PSReadLineKeyHandler -Key "’" -ViMode Command -Function GotoFirstNonBlankOfLine