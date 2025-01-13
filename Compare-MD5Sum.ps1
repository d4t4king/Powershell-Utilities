<#
    .SYNOPSIS
    This script is intended to behave like the linux md5sum.  When specified without any additional parameters, 
    will calculate the MD5 hash of the specified file.

    .DESCRIPTION
    This script is intended to behave like the linux md5sum.  When specified without any additional parameters, 
    will calculate the MD5 hash of the specified file.

    .INPUTS

    .OUTPUTS

    .PARAMETERS

    .EXAMPLE

#>

Param(
    [parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True)]
    [string] $Path,

    [parameter(Mandatory=$False,
        ValueFromPipeline = $False,
        ValueFromPipelineByPropertyName = $False)]
    [switch] $Check,

    [parameter(Mandatory = $False,
        ValueFromPipeline = $False,
        ValueFromPipelineByPropertyName=$False)]
    [string] $SumFile
)

Write-Verbose "Getting hash of file specified by -Path parameter..."
$calculated = (Get-FileHash -Path $Path -Algorithm MD5).Hash
$baseName = (Get-Item $Path).Name

if ($Check) {
    if ($SumFile) {
        $filename, $expected = (Get-Content -Path $SumFile) -Split " "
        Write-Verbose "$($expected), $($filename)"
        if ($calculated -eq $expected) {
            Write-Host "$($filename): OK"
        } else {
            Write-Host "$($filename): Not OK"
        }
    } else {
        throw Exception("File containing the expected hash should be specified using the -SumFile paramter.")
    }
} else {
    Write-Output "$($baseName) $($calculated)"
}