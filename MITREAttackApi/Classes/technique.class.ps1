class AttackResult {

}

class AttackTechniqueResult {
    [string] $Name
    [string] $ID
    [string] $Url
    [string] $DisplayName
    [string] $Tactic
    [string] $TacticUrl
    hidden [System.Management.Automation.PSNoteProperty] $Raw

    ATTACKTechniqueResult ([PSCustomObject] $Result) {
        $this.Name        = $Result.Name
        $this.ID          = $Result.Value.printouts.'Has ID'
        $this.Url         = $Result.Value.fullurl
        $this.DisplayName = $Result.Value.displaytitle
        $this.Tactic      = $Result.Value.printouts.'Has tactic'.fulltext
        $this.TacticUrl   = $Result.Value.printouts.'Has tactic'.fullurl
        $this.Raw         = $Result
    }
}