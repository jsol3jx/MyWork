CreatedBy:John Stephen
Date: 
Purpose: Pulls the password out of a SecureString\



1. $cred = Get-Credential
2. Example:
            $cred
            UserName                     Password
            --------                     --------
            test     System.Security.SecureString

3. $test = $cred.Password
4. $pass = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($test))
5. Example:
            $pass
            test
