$output = Join-Path (Get-Location) 'contents.txt'

# Write directory structure.
"===== DIRECTORY STRUCTURE =====" | Out-File $output -Encoding utf8
tree /F /A | Out-File $output -Append -Encoding utf8

"`r`n===== FILE CONTENTS =====`r`n" | Out-File $output -Append -Encoding utf8

# Collect text files, excluding the output file.
$files = Get-ChildItem -Recurse -File | Where-Object {
    $_.FullName -ne $output -and (
        $_.Extension -in @('.cmd', '.spec', '.desktop', '.xml', '.txt', '.sh', '.conf', '.ini') -or
        $_.Name -in @('control', 'postinst', 'debian-binary')
    )
}

# Write file contents.
foreach ($file in $files) {
    "===== $($file.FullName) =====" | Out-File $output -Append -Encoding utf8
    Get-Content $file.FullName | Out-File $output -Append -Encoding utf8
    "`r`n" | Out-File $output -Append -Encoding utf8
}