#initial Get-ChooseFolder script.
#this will steal a LOT from Get-ChooseFile

function Get-ChooseFileName {
	<#
	.SYNOPSIS
	This script is a bridge between PowerShell and the AppleScript Choose File Name UI primitive. It allows the use of the standard macOS Choose File Name dialog inside a PowerShell script and returns a string for the Posix Path of the new file name you pick.

	Yes the syntax is very similar to Get-ChooseFolder. If you look at the AppleScript commands I'm using for this module and Get-ChooseFolder, you'll see the same similarity.
	.DESCRIPTION
	This module takes advantage of piping commands to /usr/bin/osascript to allow powershell to use AppleScript's Choose File function,
	(https://developer.apple.com/library/archive/documentation/LanguagesUtilities/Conceptual/MacAutomationScriptingGuide/PromptforaFileName.html#//apple_ref/doc/uid/TP40016239-CH82-SW1 for more details)

	As with some of the other modules in this series, this attempts to plug a hole in PowerShell on macOS by allowing access to things that are useful in a GUI, like user input, or choosing a folder/folders.

	This module takes advantage of osascript's ability to run AppleScript from the Unix shell environment. There are a number of parameters you can use with this, (in -Detailed) to customize the dialog. There is no required parameter, so just running Get-ChooseFileName will give you a basic Choose File Name dialog.

	Use Get-Help Get-ChooseFileName - Detailed for Parameter List

	"Normally", there's one error that is thrown by design: if you hit "Cancel" in the choose file dialog, the script will return userCancelError. It's not returned as an *error* but as a string because it's not an error per se. The user hitting cancel is a viable correct option, so returning userCancelError allows you to manage that better.

	Note that PowerShell is case insensitive, so the parameters are as well

	.INPUTS
	None, there's nothing you can pipe to this

	.OUTPUTS
	A string representing a POSIX path or a string reading userCancelError

	.EXAMPLE
	Basic Choose Folder: Get-ChooseFileName
	That will give you a dialog that lets you choose a single folder
	.EXAMPLE
	Choose File Name with custom prompt:

		Get-ChooseFileName -chooseFileNamePrompt "My Custom Prompt"

	.EXAMPLE
	Choose file name starting in a specified folder:

		Get-ChooseFileName -defaultLocation "Some unix path"

	Note that with the default location parameter, you shouldn't have to escape spaces, single quotes etc. Since this is expecting double quotes around the string, if you use a double quote in the file path, you'd have to escape it. HOWEVER, this is WHERE IT GETS WEIRD, because you have to combine unix AND PowerShell escaping.

	For Example, say the path you want to pass is: /Users/username/Pictures/Bill"s amazing pictures - to get that to work, you'd have to enter: "/Users/username/Pictures/Bill\`"s amazing pictures" because that will allow PowerShell to escape the double quote and pass the string: "/Users/username/Pictures/Bill\"s amazing pictures" to the unix command

	Try to avoid this, but if you can't, then the order is "PowerShell escape the string so Powershell passes a Unix-escaped string to the Unix command". If it makes your head hurt, JOIN THE CLUB

	ALSO IMPORTANT: avoid ~. It doesn't work. There's probably some escape magic that makes it work, but I'm too lazy to try to find it.

	.EXAMPLE
	Choose file name with a default file name:

		Get-ChooseFileName -defaultFileName "some file name" 

	This is something you'd probably only use in a script you're building for someone else to run. Like you still have to type the filename anyway. But it's an option in the command, so it's in here too

	

	.LINK
	https://github.com/johncwelch/Get-PSChooseFileName

	#>
	Param (
		#we do the params this way so the help shows the description
		[Parameter(Mandatory = $false)][string]
		#optional, default is nothing, a prompt for the dialog
		$chooseFileNamePrompt,
		[Parameter(Mandatory = $false)][string]
		#the dictionary says this has to be an alias, setting it to POSIX file works too. Enter this as a unix file path.
		$defaultLocation,
		[Parameter(Mandatory = $false)][string]
		#default filename for the dialog
		$defaultFileName
	)

	if (-Not $IsMacOS) {
		Write-Output "This module only runs on macOS, exiting"
		Exit
	}
	
	$chooseFileNameCommand = "choose file name "

	#prompt processing
	if(-not [string]::IsNullOrEmpty($chooseFileNamePrompt)) {
		$chooseFileNameCommand = $chooseFileNameCommand + "with prompt `"$chooseFileNamePrompt`" "
	}

	#default locatin processing
	if(-not [string]::IsNullOrEmpty($defaultLocation)) {
		#we have a location, but we have to be clever. Since we can't convert the path string to a POSIX file in a variable
		#we do the conversion in the command itself. Yes we need the quotes in the command once it's expanded, so we escape them

		$chooseFileNameCommand = $chooseFileNameCommand + "default location (`"$defaultLocation`" as POSIX file) "
	}

	#default file name processing
	if(-not [string]::IsNullOrEmpty($defaultFileName)) {
		$chooseFileNameCommand = $chooseFileNameCommand + "default name `"$defaultFileName`" "
	}

	##run the command
	#since we have to get this path back as a unix filepath, we splice in an posix path statement
	$chooseFileNameCommand = "POSIX path of ($chooseFileNameCommand)"
	
	#now we run the command
	$chooseFileNameString = $chooseFileNameCommand|/usr/bin/osascript -so

	#deal with cancel
	if($chooseFileNameString.Contains("execution error: User canceled. `(-128`)")) {
		#Write-Output "user hit cancel button"
		return "userCancelError"
	}

	return $chooseFileNameString
}

#what the module shows the world
Export-ModuleMember -Function Get-ChooseFileName



# SIG # Begin signature block
# MIIMgAYJKoZIhvcNAQcCoIIMcTCCDG0CAQMxDTALBglghkgBZQMEAgEwewYKKwYB
# BAGCNwIBBKBtBGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCC22RqTGpAXJ8s7
# apAqbr10Sdc/FQw8E2S+Ga5HD0TOtqCCCaswggQEMIIC7KADAgECAggYeqmowpYh
# DDANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzETMBEGA1UEChMKQXBwbGUg
# SW5jLjEmMCQGA1UECxMdQXBwbGUgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkxFjAU
# BgNVBAMTDUFwcGxlIFJvb3QgQ0EwHhcNMTIwMjAxMjIxMjE1WhcNMjcwMjAxMjIx
# MjE1WjB5MS0wKwYDVQQDDCREZXZlbG9wZXIgSUQgQ2VydGlmaWNhdGlvbiBBdXRo
# b3JpdHkxJjAkBgNVBAsMHUFwcGxlIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MRMw
# EQYDVQQKDApBcHBsZSBJbmMuMQswCQYDVQQGEwJVUzCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAIl2TwZbmkHupSMrAqNf13M/wDWwi4QKPwYkf6eVP+tP
# DpOvtA7QyD7lbRizH+iJR7/XCQjk/1aYKRXnlJ25NaMKzbTA4eJg9MrsKXhFaWlg
# a1+KkvyeI+Y6wiKzMU8cuvK2NFlC7rCpAgMYkQS2s3guMx+ARQ1Fb7sOWlt/OufY
# CNcLDjJt+4Y25GyrxBGKcIQmqp9E0fG4xnuUF5tI9wtYFrojxZ8VOX7KXcMyXw/g
# Un9A6r6sCGSVW8kanOWAyh9qRBxsPsSwJh8d7HuvXqBqPUepWBIxPyB2KG0dHLDC
# ThFpJovL1tARgslOD/FWdNDZCEtmeKKrrKfi0kyHWckCAwEAAaOBpjCBozAdBgNV
# HQ4EFgQUVxftos/cfJihEOD8voctLPLjF1QwDwYDVR0TAQH/BAUwAwEB/zAfBgNV
# HSMEGDAWgBQr0GlHlHYJ/vRrjS5ApvdHTX8IXjAuBgNVHR8EJzAlMCOgIaAfhh1o
# dHRwOi8vY3JsLmFwcGxlLmNvbS9yb290LmNybDAOBgNVHQ8BAf8EBAMCAYYwEAYK
# KoZIhvdjZAYCBgQCBQAwDQYJKoZIhvcNAQELBQADggEBAEI5dGuh3MakjzcqjLMd
# CkS8lSx/vFm4rGH7B5CSMrnUvzvBUDlqRHSi7FsfcOWq3UtsHCNxLV/RxZO+7puK
# cGWCnRbjGhAXiS2ozf0MeFhJDCh/M+4Aehu0dqy2tbtP36gbncgZl0oLVmcvwj62
# s8SDOvB3bXTELiNR7pqlA29g9KVIpwbCu1riHx9GRX7kl/UnELcgInJvctrGUHXF
# PSWPXaMA6Z82jEg5j7M76pCALpWaYPR4zvQOClM+ovpP2B6uhJWNMrxWTYnpeBjg
# rJpCunpGG4Siic4U6IjRWIv2rlbELAUqRa8L2UupAg80rIjHYVWJRMkncwfuguVO
# 9XAwggWfMIIEh6ADAgECAggGHmabX9eOKjANBgkqhkiG9w0BAQsFADB5MS0wKwYD
# VQQDDCREZXZlbG9wZXIgSUQgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkxJjAkBgNV
# BAsMHUFwcGxlIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MRMwEQYDVQQKDApBcHBs
# ZSBJbmMuMQswCQYDVQQGEwJVUzAeFw0yMDA5MTYwMzU4MzBaFw0yNTA5MTcwMzU4
# MzBaMIGNMRowGAYKCZImiZPyLGQBAQwKNzk2NDg4Vkc5NTE4MDYGA1UEAwwvRGV2
# ZWxvcGVyIElEIEluc3RhbGxlcjogSm9obiBXZWxjaCAoNzk2NDg4Vkc5NSkxEzAR
# BgNVBAsMCjc5NjQ4OFZHOTUxEzARBgNVBAoMCkpvaG4gV2VsY2gxCzAJBgNVBAYT
# AlVTMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAw0uP+x8FCIpcy4DJ
# xqWRX3Pdtr55nnka0f22c7Ko+IAC//91iQxQLuz8fqbe4b3pEyemzfDB0GSVyhnY
# AYLVYMjVaUamr2j7apX8M3QxIcxrlHAJte1Mo+ntsQic4+syz5HZm87ew4R/52T3
# zzvtsjaKRIfy0VT35E9T4zVhpq3vdJkUCuQrHrXljxXhOEzJrJ9XllDDJ2QmYZc0
# K29YE9pVPFiZxkbf5xmtx1CZhiUulCI0ypnj7dGxLJxRtJhsFChzeSflkOBtn9H/
# RVuBjb0DaRib/mEK7FCbYgEbcIL5QcO3pUlIyghXaQoZsNaViszg7Xzfdh16efby
# y+JLaQIDAQABo4ICFDCCAhAwDAYDVR0TAQH/BAIwADAfBgNVHSMEGDAWgBRXF+2i
# z9x8mKEQ4Py+hy0s8uMXVDBABggrBgEFBQcBAQQ0MDIwMAYIKwYBBQUHMAGGJGh0
# dHA6Ly9vY3NwLmFwcGxlLmNvbS9vY3NwMDMtZGV2aWQwNzCCAR0GA1UdIASCARQw
# ggEQMIIBDAYJKoZIhvdjZAUBMIH+MIHDBggrBgEFBQcCAjCBtgyBs1JlbGlhbmNl
# IG9uIHRoaXMgY2VydGlmaWNhdGUgYnkgYW55IHBhcnR5IGFzc3VtZXMgYWNjZXB0
# YW5jZSBvZiB0aGUgdGhlbiBhcHBsaWNhYmxlIHN0YW5kYXJkIHRlcm1zIGFuZCBj
# b25kaXRpb25zIG9mIHVzZSwgY2VydGlmaWNhdGUgcG9saWN5IGFuZCBjZXJ0aWZp
# Y2F0aW9uIHByYWN0aWNlIHN0YXRlbWVudHMuMDYGCCsGAQUFBwIBFipodHRwOi8v
# d3d3LmFwcGxlLmNvbS9jZXJ0aWZpY2F0ZWF1dGhvcml0eS8wFwYDVR0lAQH/BA0w
# CwYJKoZIhvdjZAQNMB0GA1UdDgQWBBRdVgk/6FL+2RJDsLeMey31Hn+TBzAOBgNV
# HQ8BAf8EBAMCB4AwHwYKKoZIhvdjZAYBIQQRDA8yMDE5MDIwNjAwMDAwMFowEwYK
# KoZIhvdjZAYBDgEB/wQCBQAwDQYJKoZIhvcNAQELBQADggEBAHdfmGHh7XOchb/f
# reKxq4raNtrvb7DXJaubBNSwCjI9GhmoAJIQvqtAHSSt4CHsffoekPkWRWaJKgbk
# +UTCZLMy712KfWtRcaSNNzOp+5euXkEsrCurBm/Piua+ezeQWt6RzGNM86bOa34W
# 4r6jdYm8ta9ql4So07Z4kz3y5QN7fI20B8kG5JFPeN88pZFLUejGwUpshXFO+gbk
# GrojkwbpFuRAsiEZ1ngeqtObaO8BRKHahciFNpuTXk1I0o0XBZ2JmCUWzx3a6T4u
# fME1heNtNLRptGYMtZXH4tboV39Wf5lgHc4KR85Mbw52srsRU22NE8JWAvgFp/Qz
# qX5rmVIxggIrMIICJwIBATCBhTB5MS0wKwYDVQQDDCREZXZlbG9wZXIgSUQgQ2Vy
# dGlmaWNhdGlvbiBBdXRob3JpdHkxJjAkBgNVBAsMHUFwcGxlIENlcnRpZmljYXRp
# b24gQXV0aG9yaXR5MRMwEQYDVQQKDApBcHBsZSBJbmMuMQswCQYDVQQGEwJVUwII
# Bh5mm1/XjiowCwYJYIZIAWUDBAIBoHwwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZI
# hvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcC
# ARUwLwYJKoZIhvcNAQkEMSIEIElSukL9JB6VfQuXdVAIYvfQ9P7W74Nl1CvNj6/R
# DxdbMAsGCSqGSIb3DQEBAQSCAQCN7S09gFE209sKPqJVPODlRPA84viUSGWyAOyK
# hKUEeMY9BXLrifuytsXuRYlEI5kZMmzEzsoQp2dxGQop3mvtn/iCH2ym03UcvcC9
# Z7/ZlPw95dPeK2Ncahwmaah7gl2GiY5WGB4xc9wHKo6vLo/2sk/CmTS0ImSiIcdh
# Rom5QVkUXJDGMq2if/6q27eWDFc6aXMS4S7MS74I0tVdhUDXHC1FVZCMWsvFZGN4
# gCCY3CwT93NP8+HN9raJE44j7v2T480fJe8INnPt92Aa8GMndllKCzzlEWF07Pkp
# /PGgQLwEJTP5J9ebef3E9zwDEcKrJqU2/7DiaSkf+InUe5jS
# SIG # End signature block
