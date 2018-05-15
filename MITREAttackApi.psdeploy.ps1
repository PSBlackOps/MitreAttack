# Deploy to the .\Build folder
Deploy 'Copy module to build folder' {
    By Filesystem {
        FromSource '.\MITREAttackApi\'
        To 'MITREAttackApi\Build'
    }
}

