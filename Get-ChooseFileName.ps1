#initial Get-ChooseFolder script.
#this will steal a LOT from Get-ChooseFile

function Get-ChooseFileName {
	Param (
		#we do the params this way so the help shows the description
		[Parameter(Mandatory = $false)][string]
		#optional, default is nothing, a prompt for the dialog
		$chooseFileNamePrompt,
		[Parameter(Mandatory = $false)][string]
		#the dictionary says this has to be an alias, setting it to POSIX file works too.
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

$theFilePath = Get-ChooseFileName -chooseFileNamePrompt "Please choose a name for the new file" -defaultFileName "test.txt" -defaultLocation "/Users/jwelch"
$theFilePath
