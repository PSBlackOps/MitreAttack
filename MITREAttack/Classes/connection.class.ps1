enum MitreCollection
{
    EnterpriseAttack = 1
    PreAttack        = 2
    MobileAttack     = 3
}

class MitreConnection
{
    [string] $StixBaseUrl      = "https://cti-taxii.mitre.org/taxii/"
    [string] $StixAcceptString = 'application/vnd.oasis.taxii+json; version=2.0'
    [Net.SecurityProtocolType] $TlsVersion

    [string] $ApiRoot
    [string] $CollectionsRoot
    [MitreCollection] $DefaultCollectionType = [MitreCollection]::EnterpriseAttack
    [string] $DefaultCollectionId
    [string] $DefaultCollectionUri
    [hashtable] $DefaultCollectionHeader
    [pscustomobject] $AllCollections
    [hashtable] $HttpHeader

    MitreConnection()
    {
        $this.Init()
    }

    MitreConnection([Net.SecurityProtocolType] $TlsVersion)
    {
        $this.TlsVersion = $TlsVersion
        $this.Init()
    }

    MitreConnection([string] $StixBaseUrl, [string] $StixAcceptString, [Net.SecurityProtocolType] $TlsVersion)
    {
        $this.StixBaseUrl      = $StixBaseUrl
        $this.StixAcceptString = $StixAcceptString
        $this.TlsVersion       = $TlsVersion
        $this.Init()
    }

    hidden Init()
    {
        # If a specific TLS version/versions were
        if ($null -ne $this.TlsVersion) {
            [Net.ServicePointManager]::SecurityProtocol = $this.TlsVersion
        }

        $this.HttpHeader = @{ 'Accept' = $this.StixAcceptString }
        $this.ApiRoot = Invoke-RestMethod -Uri $this.StixBaseUrl -Headers $this.HttpHeader -Method Get | Select-Object -ExpandProperty api_roots
        $this.CollectionsRoot = '{0}collections/' -f $this.ApiRoot
        $this.GetCollections()
    }

    hidden GetCollections()
    {
        $Response = Invoke-RestMethod -Uri $this.CollectionsRoot -Headers $this.HttpHeader -Method Get | Select-Object -ExpandProperty collections
        $this.AllCollections = $Response

        foreach ($Collection in $Response) {
            $SearchTitle = ($Collection.Title -replace 'ATT&CK','Attack') -replace ' |\-',''
            if ($SearchTitle -eq $this.DefaultCollectionType) {
                $this.DefaultCollectionHeader   = @{ Accept = ($Collection | Select-Object -ExpandProperty media_types) }
                $this.DefaultCollectionId       = $Collection.Id
                $this.DefaultCollectionUri      = '{0}{1}' -f $this.CollectionsRoot,$this.DefaultCollectionId
            }
        }
    }
}