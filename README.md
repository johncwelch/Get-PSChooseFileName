# Get-PSChooseFileName
A bridge to AppleScript's Choose File Name command  

## SYNOPSIS
This script is a bridge between PowerShell and the AppleScript Choose File Name UI primitive. It allows the use of the standard macOS Choose File Name dialog inside a PowerShell script and returns a string for the Posix Path of the new file name you pick.  

Yes the syntax is very similar to Get-ChooseFolder. If you look at the AppleScript commands I'm using for this module and Get-ChooseFolder, you'll see the same similarity.  
	
## DESCRIPTION
This module takes advantage of piping commands to /usr/bin/osascript to allow powershell to use AppleScript's Choose File function, (https://developer.apple.com/library/archive/documentation/LanguagesUtilities/Conceptual/MacAutomationScriptingGuide/PromptforaFileName.html#//apple_ref/doc/uid/TP40016239-CH82-SW1 for more details)  

As with some of the other modules in this series, this attempts to plug a hole in PowerShell on macOS by allowing access to things that are useful in a GUI, like user input, or choosing a folder/folders.  

This module takes advantage of osascript's ability to run AppleScript from the Unix shell environment. There are a number of parameters you can use with this, (in -Detailed) to customize the dialog. There is no required parameter, so just running Get-ChooseFileName will give you a basic Choose File Name dialog.  

Use Get-Help Get-ChooseFileName - Detailed for Parameter List  

"Normally", there's one error that is thrown by design: if you hit "Cancel" in the choose file dialog, the script will return userCancelError. It's not returned as an *error* but as a string because it's not an error per se. The user hitting cancel is a viable correct option, so returning userCancelError allows you to manage that better.  

Note that PowerShell is case insensitive, so the parameters are as well  

## INPUTS
None, there's nothing you can pipe to this 

## OUTPUTS
A string representing a POSIX path or a string reading userCancelError

## EXAMPLE
Basic Choose Folder: Get-ChooseFileName  
	That will give you a dialog that lets you choose a single folder  
## EXAMPLE
Choose Folder with custom prompt:  

	Get-ChooseFileName -chooseFileNamePrompt "My Custom Prompt"  

## EXAMPLE
Choose file name starting in a specified folder:  

	Get-ChooseFolder -defaultLocation "/Some/unix/path"  

Note that with the default location parameter, you shouldn't have to escape spaces, single quotes etc. Since this is expecting double quotes around the string, if you use a double quote in the file path, you'd have to escape it. HOWEVER, this is WHERE IT GETS WEIRD, because you have to combine unix AND PowerShell escaping.  

For Example, say the path you want to pass is: /Users/username/Pictures/Bill"s amazing pictures - to get that to work, you'd have to enter: "/Users/username/Pictures/Bill\`"s amazing pictures" because that will allow PowerShell to escape the double quote and pass the string: "/Users/username/Pictures/Bill\"s amazing pictures" to the unix command  

Try to avoid this, but if you can't, then the order is "PowerShell escape the string so Powershell passes a Unix-escaped string to the Unix command". If it makes your head hurt, JOIN THE CLUB  

ALSO IMPORTANT: avoid ~. It doesn't work. There's probably some escape magic that makes it work, but I'm too lazy to try to find it.  

## EXAMPLE  
Choose file name with a default file name:  

	Get-ChooseFolder -defaultFileName "some file name"  
 
This is something you'd probably only use in a script you're building for someone else to run. Like you still have to type the filename anyway. But it's an option in the command, so it's in here too  
