# combine_text_files_PowerShell5

## Introduction

I needed a script to combine (potentially) numerous and (potentially) large base64 text files.

Inspired by the following Stack Overflow article:

* Memory errors merging multiple large csv files with Powershell
  `https://stackoverflow.com/questions/48064363/memory-errors-merging-multiple-large-csv-files-with-powershell`

... and the answer from David Martin (`https://stackoverflow.com/users/1035521/david-martin`):

* `https://stackoverflow.com/a/48065203`

## Usage

This PowerShell script was created and tested with version 5.1 on Windows 10.

If/when/maybe I have time I will test on other platforms such as Ubuntu.

## Execution

These examples asume the above PowerShell session. Note that the script requires that the output file does NOT exist.

### Combine multiple text files in the current folder. The `-inFile` parameter is a file filter using the wildcard character astricks (*). The wildcard character question mark (?) is also valid.

`.\Combine_Files.ps1 -inFile textfile??.txt`

### Combine multiple text files in the current folder and specify the output file.

`.\Combine_Files.ps1 -inFile textfile??.txt -outFile foobar.txt`

## Author

Andrew Nagy

https://www.linkedin.com/in/andrew-e-nagy/
