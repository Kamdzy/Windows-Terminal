# Define a function named b64 to encode a string to Base64
Function b64 {
    [cmdletBinding()]
    param(
        # Define a parameter named 'inputObject' which is a string and is the first positional parameter
        [Parameter(Position = 0)]
        [string]$inputObject
    )
    PROCESS {
        # Convert the input string to a byte array using UTF8 encoding
        # Then convert the byte array to a Base64 string
        $base64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($inputObject))
        # Output the Base64 encoded string
        Write-Output $base64
    }
}

# Define a function named ub64 to decode a Base64 string to a regular string
Function ub64 {
    [cmdletBinding()]
    param(
        # Define a parameter named 'inputObject' which is a string and is the first positional parameter
        [Parameter(Position = 0)]
        [string]$inputObject
    )
    PROCESS {
        # Convert the Base64 string to a byte array
        $buffer = [Convert]::FromBase64String($inputObject)
        # Convert the byte array to a string using UTF8 encoding
        $text = [Text.Encoding]::UTF8.GetString($buffer)
        # Output the decoded string
        Write-Output $text
    }
}