class MitreConnection
{
    [string] $StixBaseUrl      = "https://cti-taxii.mitre.org/taxii/"
    [string] $StixAcceptString = 'application/vnd.oasis.taxii+json; version=2.0'
    [Net.SecurityProtocolType] $TlsVersion

    hidden [string] $ApiRoot
    hidden [hashtable] $HttpHeader

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
    }

    GetCollections()
    {

    }
}