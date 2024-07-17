param(
  # Number of files to create (default 2)
  [Parameter(Mandatory = $True)]
  [Int] $Count = 2,

  # Base name for the student (default student)
  [Parameter(Mandatory = $false)]
  [String] $Name = "student",

  # Path to the input file (mandatory)
  [Parameter(Mandatory = $false)]
  [String] $InputFilePath = '.\scripts\vm-windows-template'
)

for ($i = 1; $i -le $Count; $i++) {
    $studentNumber = $i
    $newFileName = "vm-windows-$($Name)$studentNumber.tf"

    # Read the input file content line by line
    $fileContent = Get-Content $InputFilePath

    # Initialize an array to store modified content
    $modifiedContent = @()

    # Initialize a hashtable to store variable replacements
    $variablesToUpdate = @{}

    foreach ($line in $fileContent) {
        # Match and capture resource or data lines with the second quoted variable
        if ($line -match '^(resource|data)\s+"([^"]+)"\s+"([^"]+)"') {
            $type = $matches[1]
            $resourceType = $matches[2]
            $secondQuotedVariable = $matches[3]

            # Store the updated variable name
            $newVariableName = "$secondQuotedVariable$studentNumber"
            $variablesToUpdate[$secondQuotedVariable] = $newVariableName

            # Update the line with the new variable name
            $line = $line -replace '"^(resource|data)\s+\"([^"]+)\"\s+\"([^"]+)\""', "`$type` `"$resourceType`" `"$newVariableName`""
        }

        # Add the line to the modified content
        $modifiedContent += $line
    }

    # Replace occurrences of the variables across all lines
    $finalContent = $modifiedContent | ForEach-Object {
        $modifiedLine = $_
        foreach ($key in $variablesToUpdate.Keys) {
            $modifiedLine = $modifiedLine -replace "\b$key\b", $variablesToUpdate[$key]
        }

        # Replace 'windows_hostname' with the updated name
        $modifiedLine = $modifiedLine -replace 'student}', "$($Name)$studentNumber}"
        $modifiedLine
    }

    # Write the modified content to a new file
    Set-Content -Path $newFileName -Value $finalContent -Encoding UTF8

    Write-Host "Successfully created file: $newFileName"
}