<#
    Abstract class: AttackReply
    This is the interface that generated classes will implement
#>

class AttackReply
{
    [string[]] $Printouts
    [System.Collections.ArrayList] $Result

    AttackReply([PSCustomObject] $Printrequests, [PSCustomObject] $ReplyBody) {
        $type = $this.GetType()

        <#if ($type -eq [AttackReply])
        {
            throw("Class $type must be inherited.")
        }#>

        # Unwrap the objects
        $this.Printouts = @($Printrequests | Where-Object { -not ([string]::IsNullOrEmpty($PSItem.label)) } | Select-Object -ExpandProperty key)
        $this.ReplyBody = $ReplyBody.Members | Where-Object MemberType -eq 'NoteProperty' | ForEach-Object { $ReplyBody.($PSItem.Name) }
    }

    AttackReply([PSCustomObject] $Reply) {
        $type = $this.GetType()
        $Results = [System.Collections.ArrayList]::new()

        <#if ($type -eq [AttackReply])
        {
            throw("Class $type must be inherited.")
        }#>

        # If $Reply doesn't have a NoteProperty named 'query', throw an error
        # cuz nothing will work.
        if (($Reply.psobject.Members | Where-Object MemberType -eq 'NoteProperty' | Select-Object Name).Name -notcontains 'query') {
            throw("Input object does not contain a 'query' property. Unable to proceed.")
        }

        # Expand out the data from the SMW response
        $this.Printouts = $Reply.query.printrequests | Where-Object { -not ([string]::IsNullOrEmpty($PSItem.label)) } | Select-Object key
        #$this.ReplyBody = $Reply.query.results.psobject.Members | Where-Object MemberType -eq 'NoteProperty' | ForEach-Object { $Reply.query.results.($PSItem.Name) }

        foreach ($item in $Reply.query.results.psobject.Members) {
            if ($item.MemberType -eq 'NoteProperty') {
                $null = $Results.Add($Reply.query.results.($item.Name))
            }
        }

        $this.Result = $Results
    }
}


class AttackReplyFactory
{
    # Store and fetch
    static [AttackReply[]] $Replies

    static [Object] getByType([Object] $Object) {
        return [AttackReplyFactory]::Replies.Where({ $PSItem -is $Object})
    }

    # Create new instances
    [AttackReply] makeReply() {
        return [AttackReply]::new()
    }
}