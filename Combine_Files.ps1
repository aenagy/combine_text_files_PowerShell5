<#
This is the complement to:

* split_text_file_PowerShell5
  `https://github.com/aenagy/split_text_file_PowerShell5`

Inspired by the following Stack Overflow article:

* Memory errors merging multiple large csv files with Powershell
  `https://stackoverflow.com/questions/48064363/memory-errors-merging-multiple-large-csv-files-with-powershell`

... and this answer from David Martin (`https://stackoverflow.com/users/1035521/david-martin`)

* `https://stackoverflow.com/a/48065203`

#>



Param(
    [Parameter(Mandatory=$true)]
    [ValidateScript(
        {Test-Path -Path $_ -PathType Leaf}
    )]
    [string]$inFile
    ,
    [string]$outFile
)

$inputFileList = $null
$fileExtensionDivider = "."
$folderPathDivider = "\"
$encoding = [System.Text.Encoding]::UTF8

if ( Split-Path -Path $inFile -IsAbsolute )
{
    $inputFilFolder  = [System.IO.Path]::GetDirectoryName( $inFile )
    $inputFileFilter = [System.IO.Path]::GetFileName( $inFile ) + [System.IO.Path]::GetExtension( $inFile )
} else {
    $inputFilFolder  = $PWD
    $inputFileFilter = $inFile
}
$inputFileList = Get-ChildItem -Path $inputFilFolder -Filter $inputFileFilter

if ($inputFileList -and $inputFileList -is [array] )
{
    # don't do anything
} else {
    $inputFileList = @($inputFileList)
}
Write-Information "inputFileList.Length = $($inputFileList.Length)"
Write-Information "inputFileList        = '$($inputFileList)'"

if ( $outFile -and $outFile.Length -gt 0)
{
    if ( Split-Path -Path $outFile -IsAbsolute )
    {
        [string]$outputFileFolder    = $inputFile.DirectoryName

    } else {
        # https://superuser.com/questions/1660757/how-to-get-current-path-in-powershell-into-a-variable
        [string]$outputFileFolder    = $PWD.Path
    }
    # https://stackoverflow.com/a/9788998
    [string]$outputFileBaseName      = [System.IO.Path]::GetFileNameWithoutExtension( $outFile )
    [string]$outputFileExtension     = [System.IO.Path]::GetExtension( $outFile ).Replace( $fileExtensionDivider , "" )
} else {
    Write-Information "`$outFile is either null nor empty. Using 'inFile' name for 'outFile'. Continuing."
    # https://stackoverflow.com/a/9788998
    [string]$outputFileFolder        = $inputFileList[0].DirectoryName
    [string]$outputFileBaseName      = [System.IO.Path]::GetFileNameWithoutExtension( $inFile  ).Replace( "*" , "" ).Replace( "?" , "" )
    [string]$outputFileExtension     = [System.IO.Path]::GetExtension( $inFile ).Replace( "*" , "" ).Replace( "?" , "" ).Replace( $fileExtensionDivider , "" )
}

$outputFile = $outputFileFolder + $folderPathDivider + $outputFileBaseName + $fileExtensionDivider + $outputFileExtension 
if ( Test-Path -Path $outputFile )
{
    Write-Error "`nERROR: output file '$outputFile' exists. Delete or rename this file and retry. Aborting script.`n"
    exit 2
}
Write-Information "Output file            '$outputFile' does not exist. Continuing."

Write-Host     "Opening output file    '$outputFile'."
$outputFileIo = New-Object System.IO.StreamWriter( $outputFile, $true, $encoding )

foreach ( $individualInputFile in $inputFileList )
{
    Write-Host "individualInputFile  = '$($individualInputFile.Fullname)'"
    try {
        $inputFileIo = New-Object System.IO.StreamReader( $individualInputFile.Fullname, $encoding )
    }
    catch {
        $inputFileIo.Close()
        $inputFileIo.Dispose()
        Write-Error "`nCaught exception while opening file '$individualInputFile.Fullname'.`nERROR: $_"
        exit 1
    }
    while ( ($line = $inputFileIo.ReadLine() ) -ne $null )
    {
        try {
            $outputFileIo.WriteLine($line)
        }
        catch {$outputFileIo
            Write-Error "`nERROR: Caught exception while writing line '$line' fom file '$($individualInputFile.Fullname)' to output file '$outputFile'.`n$_`n"
            Write-Host     "Closeing output file   '$outputFile'."
            $outputFileIo.close()
            Write-Host     "Disposeing output file '$outputFile'."
            $outputFileIo.Dispose()
            exit 3
        }
    }
    $inputFileIo.Close()
    $inputFileIo.Dispose()
}

Write-Host     "Closeing output file   '$outputFile'."
$outputFileIo.close()
Write-Host     "Disposeing output file '$outputFile'."
$outputFileIo.Dispose()
Write-Host     "Done."