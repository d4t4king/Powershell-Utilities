# Powershell-Utilities
Basic utilities written in powershell.

### Compare-Groups.ps1
> Compares the group membership for the 2 specified users.

### Compare-MD5Sum.ps1
> Similar to the linux `md5sum` utility, this script gets the MD5 hash of a file and/or compares the hash with the *.asc/.md5 file.

### Dump-GroupMembers.ps1
> Dumps the members of the specified EntraID group.  

### Get-OSVersion.ps1
> Gets the OS version for the device on which the script is run. Currently displays the numberical version number.
* TODO: Show the human readable name: Windows 11, Windows Server 2025, etc.

### Get-SIDFromUser.ps1
> Gets the AD SID for a specified user in the specified domain.  (See detailed documentation.)
* TODO: Make it work with EntraID.

### Get-UserFromSID.ps1
> Gets the user name from the specified SID in the specirfied domain.  (See detaied documentation.)
* TODO: Make it work with EntraID.

#### TODO
* [ ] Update the README
* [ ] List groups for which a specified user (ID?) is a member
* [ ] Search a list of groups for a member (name)
* [x] Get User from Entra Object ID