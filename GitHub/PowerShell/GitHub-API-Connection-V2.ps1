Clear-Host


$GitHub_Win_Cred_PassWord = (Get-StoredCredential -Target 'GitHub_Pat' -Type Generic -AsCredentialObject).Password
$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Header.Add('Authorization', "Token $GitHub_Win_Cred_PassWord")
$Header.Add('Accept','application/vnd.github.v3+json')
$GitHub_Instance = 'zackmayfield'
function FetchRepoList()
{
    $uri = "https://api.github.com/users/$($GitHub_Instance)/repos?page=&per_page=100"
    
    $all = @()
    $page = 0
    
    $any = $TRUE
    while($any)
    {
        $any = $FALSE

        $page += 1      
        $urin = $uri.replace("?page=","?page="+$page)

        $repositories = (Invoke-RestMethod -Uri $urin -Method GET -Headers $Header)

        Foreach($repo IN $repositories)
        {
            $all += $repo
            $any = $TRUE
        }
    }
    
    Write-Host("Found " + $All.Count + " repositories")
    
    return $all | Sort-Object -property Name
}
$repos = FetchRepoList

$repos