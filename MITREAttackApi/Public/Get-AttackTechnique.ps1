function Get-AttackTechnique
{
    [CmdletBinding()]
    param(
        [AttackDisplayOption] $heck
    )

    process {
        $BaseURL = 'https://attack.mitre.org/api.php?action=ask&format=json&query='
        $Query   = [system.uri]::EscapeDataString(('[[Category:Technique]]|?Has tactic|?Has ID|?Has display name|limit=9999'))
        $Uri     = '{0}{1}' -f $BaseURL, $Query
        Write-Verbose $Uri
        $Results  = Invoke-RestMethod -Uri $Uri -Method Get -Verbose:$VerbosePreference -ContentType 'Application/Json'

        $O = [System.Collections.ArrayList]::new()
        # Proces Results
        foreach ($Result in $Results.query.results.psobject.Members) {
            if ($Result.MemberType -eq 'NoteProperty') {
                $null = $O.Add([ATTACKTechniqueResult]::New($Result))
            }
        }
        Write-Output $O
    }
}