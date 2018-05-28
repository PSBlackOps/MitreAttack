# Deploy to the .\Build folder
Deploy 'Copy module to build folder' {
    By Filesystem {
        FromSource '.\MITREAttack\'
        To 'MITREAttack\Build'
    }
}

