class AttackQuery
{
    [string] $QueryString
    [string] $Category
    [string] $Format = 'json'
    [string[]] $DisplayOptions
    [string] $TechniqueCode
    [int32] $Limit = 9999

    hidden [string] $BaseURL = 'https://attack.mitre.org/api.php?action=ask&format={0}&query='
    hidden [string] $URI    # Calculated URI after QueryString is converted
    hidden [System.Collections.ArrayList] $Results = [System.Collections.ArrayList]::new()

    AttackQuery () {
        $this.BaseURL = $this.BaseURL -f $this.Format
    }

    [void] CreateQueryString() {
        $Query = [System.Text.StringBuilder]::New()

        if ($this.Category -ne 'None') {
            $Query.Append(('[[Category:{0}]]' -f $this.Category))
        }
        if ($this.TCode) {
            $Query.Append(('[[Has ID::{0}]]' -f $this.TCode))
        }

        # Join the Display Options, and append to the query
        $Query.Append(('|?{0}' -f ($this.DisplayOptions -join '|?')))
        $Query.Append(('|limit={0}' -f $this.Limit))
        $this.QueryString = [System.Net.WebUtility]::UrlEncode($Query.ToString())
        $this.URI = '{0}{1}' -f $this.BaseURL, $this.QueryString

        #$this.URI = [system.uri]::EscapeDataString($Query.ToString())
        #return $null
    }

    [System.Collections.ArrayList] ExecuteQuery() {
        $Reply = Invoke-RestMethod -Uri $this.URI -Method Get

        foreach ($Result in $Reply.query.results.psobject.Members) {
            if ($Result.MemberType -eq 'NoteProperty') {
                $null = $this.Results.Add($Reply.query.results.($Result.Name))
            }
        }
        return $this.Results
    }

    [string] CreateQuery([string] $QueryString) {
        $DataString = [System.Text.StringBuilder]::new()
        $null = $DataString.Append(($this.BaseURL -f $this.Format))
        $null = $DataString.Append(([System.Net.WebUtility]::UrlEncode($QueryString)))
        $this.URI = $DataString.ToString()

        return $this.URI
    }

    static [string] EscapeQuery([string] $Query) {
        return [System.Net.WebUtility]::UrlEncode($Query)
    }

}