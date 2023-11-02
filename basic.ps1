Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False #disable firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True #enable firewall
New-NetFirewallRule -DisplayName "allow ICMP" -Direction Inbound -Protocol ICMPv4 -Action Allow #autorise ping

/* setup profile Private*/
$index=(Get-NetConnectionProfile).InterfaceIndex[0]
Set-NetConnectionProfile -InterfaceIndex $index -NetworkCategory "Private" #mettre profile privée 

/* firewall stuff */
Get-NetFirewallRule
Get-NetFirewallRule | findstr DisplayGroup
Get-NetFirewallRule -DisplayGroup "Partage de fichiers et d?imprimantes"

/* activez tout les règle de fichier et imprimante */
Get-NetFirewallRule -DisplayGroup "Partage de fichiers et d?imprimantes" | Enable-NetFirewallRule # en 1 commande

Enable-NetFirewallRule -DisplayGroup "Partage de fichiers et d?imprimantes" # changement règle de DisplayGroup "Partage de fichiers et d?imprimantes" à vrai

#je suis obliger de ajouter sa car on mis un règle qui était pas la par défault avant
New-NetFirewallRule -DisplayName "allow ICMP" -Direction Inbound -Protocol ICMPv4 -Action Block #interdit ping

/* create user */
net user util1 util1 /comment:"compte de test" /add

#powershell
$mdp = ConvertTo-SecureString -String 'user1' -AsPlainText -Force
$params = @{
    Name        = 'user1'
    Password    = $mdp
		Description = ''
}
New-LocalUser @params -AccountNeverExpires

/* info about user */
net user

#powershell version
Get-LocalUser


/* user/group */
function remGroup($group, $user) {
	/* cette fonction supprime un utilisateur à un groupe */
	Remove-LocalGroupMember -Group $group -Member $user
}

function addGroup($group, $user) {
	/* cette fonction ajoute un utilisateur dans un groupe */
	Add-LocalGroupMember -Group $group -Member $user
}

function createUser($user) {
	/* cette fonction crée un utilisateur*/
	$mdp = ConvertTo-SecureString -String "$user" -AsPlainText -Force
	$params = @{
		Name = "$user"
		Password = $mdp
	}
	New-LocalUser @params -AccountNeverExpires
}

# Créer user1 à user4
for ($i = 1; $i -le 4; $i++) {
	createUser("user" + $i)
}

# Créer util2
createUser("util2")

#création des groupes
New-LocalGroup projet1_rw
New-LocalGroup projet1_r

#ajout des userX à groupe demandé
addGroup("projet1_rw", "user1")
addGroup("projet1_rw", "user3")
addGroup("projet1_r", "user2")
addGroup("projet1_r", "user4")

mkdir c:\projet1
Get-Acl "c:\projet1" | Format-List
#icacls "c:\projet1"
/* group */
net localgroup

#powershell version
Get-LocalGroup
Get-LocalGroupMember -Name "Administrateurs" #affiche ceux qui appartienne au group
Get-LocalGroupMember -Name "Utilisateurs"

#ajout au groupe
Add-LocalGroupMember -Group “Administrators” -Member $user
Remove-LocalGroupMember -Group “Administrators” -Member $user

/* get group of user */
#obtenir group utilisateur avec net
$user = "administrateur"
write-Host $user
net user $user | findstr groupes

# groupe d'un utilisateur
whoami /groups

/* icalcls or Get-Acl  */
icalcls $file #get perm
Get-Acl $file | Format-List # print in a list

icacls "c:\projet1" /inheritance:d /grant *S:(OI)(CI)RX 
# permet de désactiver l’héritage tout en copiant les permission
# /inheritance:d => désactive héritage
# /grant *S:(OI)(CI)RX => donne permission (*S tout le monde) conservé avant le l'arret de l'héritage
icacls "c:\projet1" /remove "BUILTIN\Utilisateur1"
#/remove "BUILTIN\User1" => supprime user1 de ses permissions
icacls "CheminVersLeFichierOuDossier" /remove "AUTORITE NT\Utilisateurs"
#/remove "BUILTIN\User1" => supprime group Utilisateur de ses permissions
icacls "c:\projet1" /grant "projet1_rw:(OI)(CI)M"
#/grant "projet1_rw:(OI)(CI)M" => M: droit modifier au group projet1_rw
icacls "c:\projet1" /grant "projet1_r:(OI)(CI)RX"
# /grant "projet1_r:(OI)(CI)RX" => RX: read et execution à group projet1_r

/* domain or  work group*/
$systemInfo = Get-WmiObject -Class Win32_ComputerSystem
$domainStatus = $systemInfo.Domain
$workgroupStatus = $systemInfo.Workgroup

if ($domainStatus -ne $null) { #rappel: -ne => not equal
    Write-Host "Le mode de fonctionnement est : Domaine ($domainStatus)"
} elseif ($workgroupStatus -ne $null) {
    Write-Host "Le mode de fonctionnement est : Groupe de Travail ($workgroupStatus)"
} else {
    Write-Host "Le mode de fonctionnement n'a pas pu être déterminé."
}
