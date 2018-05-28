function Connect-MAService
{
    param(
        [string] $ServiceName = 'https://cti-taxii.mitre.org/taxii/',
        [switch] $UseTLS12
    )

    begin {
        $HttpHeader = @{ 'Accept' = 'application/vnd.oasis.taxii+json; version=2.0' }

        # If the UseTLS12 switch is given, use TLS 1.2 for requests.
        if ($UseTLS12) {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        }
    }

    process {
        try {
            # Determine the API root for the TAXII endpoint
            $ApiRoot    = Invoke-RestMethod -Uri $ServiceName -Headers $HttpHeader -Method Get | Select-Object -ExpandProperty api_roots

            # Get a list of the collections on this endpoint
            $CollectionURI      = '{0}collections/' -f $ApiRoot
            $Collections        = [System.Collections.ArrayList]::new()
            $CollectionResponse = Invoke-RestMethod -Uri $CollectionURI -Headers $HttpHeader -Method Get | Select-Object -ExpandProperty collections

            # Grab the ID and Title of all collections. Generate a URL for additional queries
            foreach ($Response in $CollectionResponse) {
                $obj    = [PSCustomObject]@{
                              Uri   = '{0}{1}' -f $CollectionURI, $Response.id
                              Id    = $Response.id
                              Title = $Response.title
                          }
                $null = $Collections.Add($obj)
            }

            $Output     = [PSCustomObject] @{
                            ApiRoot = $ApiRoot
                            Collections = $Collections
                          }
            Write-Output $Output
        }
        catch {
            $PSItem
        }
    }
}
