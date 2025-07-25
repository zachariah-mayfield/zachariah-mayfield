

$Replace_OG_Build_Step = $true #$false #$true
$Disable_OG_Build_Step = $true #$false #$true
$ReName_OG_Build_Step = $true #$false #$true
$Create_New_Smoke_Build_Config = $true #$false #$true

$TeamCity_Win_Cred_UserName = (Get-StoredCredential -Target 'TeamCity_API_Token' -Type Generic -AsCredentialObject).UserName
$TeamCity_Token = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # This is the TeamCity API Token.
$Token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $($TeamCity_Win_Cred_UserName), $($TeamCity_Token))))
$Header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$Header = @{authorization = "Basic $Token"}
$Header.Add('Accept','application/json')
$TeamCity_API_Instance = ('ci.Company.org'  + '/app/rest')

#region Import CSV
$CSV_Path = "C:\TEST.csv"
$CSV_Data = Import-Csv -Path $CSV_Path
$CSVRowNumber = $CSV_Data.count
$Values = @(0..$CSVRowNumber)
#endregion Import CSV

ForEach ($V in $Values) {
    IF ($null -ne $CSV_Data[$v]) {
        
        $Build_Configuration_ID = ($CSV_Data[$V].Build_Configuration_ID).Split('=')[-1]      #EXAMPLE: 
        $Step_Name = $CSV_Data[$V].Step_Name      #EXAMPLE: 
        $Script_Name = $CSV_Data[$V].Script_Name      #EXAMPLE: 
        
        $Method = 'Get'
        $TeamCity_Build_Steps_URL = "http://$($TeamCity_API_Instance)/buildTypes/$($Build_Configuration_ID)/steps/"

        $OG_Build_Steps_Responses = (Invoke-RestMethod -Uri $TeamCity_Build_Steps_URL -Method $Method -Headers $Header)
        $OG_Build_Step = ($OG_Build_Steps_Responses.step | Where-Object -Property name -EQ $Step_Name)

        [string]$OG_Build_Step_ID = ($OG_Build_Steps_Responses.step | Where-Object -Property name -EQ $Step_Name).ID

        $Method = 'GET'
        $TeamCity_Build_URL = "http://$($TeamCity_API_Instance)/buildTypes/$($Build_Configuration_ID)/"
        $OG_Build_Responses = (Invoke-RestMethod -Uri $TeamCity_Build_URL -Method $Method -Headers $Header)

        $Method = 'GET'
        $TeamCity_OG_Dependency_Build_URL = "http://$($TeamCity_API_Instance)/buildTypes/$($Build_Configuration_ID)/snapshot-dependencies"
        $OG_Dependency_Responses = (Invoke-RestMethod -Uri $TeamCity_OG_Dependency_Build_URL -Method $Method -Headers $Header)

#region Replace_OG_Build_Step
        If ($Replace_OG_Build_Step -eq $true) {
            $OG_ScriptParameters = (($OG_Build_Step.properties.property | Where-Object -Property name -EQ 'jetbrains_powershell_scriptArguments').value)
            
            $line = $null
            $lines = $null

            $Lines = $OG_ScriptParameters -split '\n'

            $New_Script_Name = $Script_Name.Split('.')[0]

            Foreach ($line in $lines){
                $New_OG_ScriptParameters += "$($line) "
            }

            $New_Build_Step = @{
                'name' = $Step_Name;
                'type' ='PsGalleryRunner';
                'disabled' = 'true';
            }

            $property = New-Object System.Collections.ArrayList
            $property.Add(@{
            'name' = 'PsGalleryName';
            'value' = 'Powershell-Enterprise';})
            $property.Add(@{
            'name' = 'PsGalleryUrl';
            'value' = 'https://pkgs.Company.org/nuget/Powershell-Enterprise/';})
            $property.Add(@{
            'name' = 'ScriptName';
            'value' = $New_Script_Name;})
            $property.Add(@{
            'name' = 'ScriptParameters';
            'value' = $New_OG_ScriptParameters;})

            $Count = $property.Count

            $properties = @{
            'Count' = $Count;
            'property' = $property;
            }

            $New_Build_Step.Add('properties',$properties)

            If (-not [string]::IsNullOrEmpty($TeamCity_Build_Steps_URL) -and `
                -not [string]::IsNullOrWhiteSpace($TeamCity_Build_Steps_URL) -and `
                -not [string]::IsNullOrWhiteSpace($New_Build_Step) -and `
                -not [string]::IsNullOrEmpty($New_Build_Step) -and `
                -not [string]::IsNullOrWhiteSpace($OG_ScriptParameters) -and `
                -not [string]::IsNullOrEmpty($OG_ScriptParameters)) {
                Try {
                    $New_Build_Step_JSON_POST_Data = $($New_Build_Step| ConvertTo-Json -Compress -Depth 100) 
                    $Build_Step_Replacement = (Invoke-RestMethod -Uri $TeamCity_Build_Steps_URL -Method Post -Body $New_Build_Step_JSON_POST_Data -Headers $Header -ContentType 'application/json')
                    $Build_Step_Replacement   ##### Uncomment this to view the modified cloned Build Step.
                }
                Catch {
                    If (-not [string]::IsNullOrEmpty($Error[0].Exception.Message) -and `
                        -not [string]::IsNullOrWhiteSpace($Error[0].Exception.Message)) {
                        $_.Exception | Select-Object *
                    }
                }
            }
        }
#endregion Replace_OG_Build_Step

#region Create_New_Smoke_Build_Config        
        If ($Create_New_Smoke_Build_Config -eq $true){
            $Smoke_Test_Build_Config_Name = ('Company_Smoke_Testing_' + $Build_Configuration_ID)           # = ($CSV_Data[$V].Build_Configuration_ID).Split('=')[-1]
            $Project_Locator = 'TeamCity Tests'
            $Method = 'POST'
            $New_Build_Configuration_URL = "http://$($TeamCity_API_Instance)/projects/$($Project_Locator)/buildTypes"
            $New_Build_Configuration_Responses = (Invoke-RestMethod -Uri $New_Build_Configuration_URL -Body $Smoke_Test_Build_Config_Name -Method $Method -Headers $Header -ContentType 'text/plain')
            $New_Build_Configuration_Responses
            
            $Method = 'POST'
            $New_Smoke_Build_Configuration_ID = $New_Build_Configuration_Responses.id
            $New_Dependency_JSON_Body = $OG_Dependency_Responses.'snapshot-dependency' | ConvertTo-Json -Depth 100
            $TeamCity_New_Dependency_Builds_URL = "http://$($TeamCity_API_Instance)/buildTypes/$($New_Smoke_Build_Configuration_ID)/snapshot-dependencies"

            If (-not [string]::IsNullOrEmpty($New_Smoke_Build_Configuration_ID) -and `
                -not [string]::IsNullOrWhiteSpace($New_Smoke_Build_Configuration_ID) -and `
                -not [string]::IsNullOrWhiteSpace($New_Dependency_JSON_Body) -and `
                -not [string]::IsNullOrEmpty($New_Dependency_JSON_Body)) {
                Try {
                    $New_Dependency_Responses = (Invoke-RestMethod -Uri $TeamCity_New_Dependency_Builds_URL -Method $Method -Body $New_Dependency_JSON_Body -Headers $Header -ContentType 'application/json')
                    $New_Dependency_Responses
                }
                Catch {
                    If (-not [string]::IsNullOrEmpty($Error[0].Exception.Message) -and `
                        -not [string]::IsNullOrWhiteSpace($Error[0].Exception.Message)) {
                        $_.Exception | Select-Object *
                    }
                }
            }

#region New_Smoke_Build_Step
            $Smoke_ScriptParameters = (($OG_Build_Step.properties.property | Where-Object -Property name -EQ 'jetbrains_powershell_scriptArguments').value)
            
            $line = $null
            $lines = $null

            $Lines = $Smoke_ScriptParameters -split '\n'
            
            $New_Script_Name = $Script_Name.Split('.')[0]

            Foreach ($line in $lines){
                $New_Smoke_ScriptParameters += "$($line) "
            }

            $New_Smoke_Build_Step = @{  
                'name' = $Step_Name;
                'type' ='PsGalleryRunner';
                'disabled' = 'true';
            }

            $property = New-Object System.Collections.ArrayList
            $property.Add(@{
            'name' = 'PsGalleryName';
            'value' = 'Powershell-Enterprise';})
            $property.Add(@{
            'name' = 'PsGalleryUrl';
            'value' = 'https://pkgs.Company.org/nuget/Powershell-Enterprise/';})
            $property.Add(@{
            'name' = 'ScriptName';
            'value' = $New_Script_Name;})
            $property.Add(@{
            'name' = 'ScriptParameters';
            'value' = $New_Smoke_ScriptParameters;})

            $Count = $property.Count

            $properties = @{
            'Count' = $Count;
            'property' = $property;
            }

            $New_Smoke_Build_Step.Add('properties',$properties)

            $New_Smoke_Build_Configuration_ID = $New_Build_Configuration_Responses.id
            $New_Smoke_Build_JSON_POST_Data = $($New_Smoke_Build_Step| ConvertTo-Json -Compress -Depth 100)
            $TC_New_Smoke_Build_Step_URL = "http://$($TeamCity_API_Instance)/buildTypes/$($New_Smoke_Build_Configuration_ID)/steps/"

            If (-not [string]::IsNullOrEmpty($New_Smoke_Build_Configuration_ID) -and `
                -not [string]::IsNullOrWhiteSpace($New_Smoke_Build_Configuration_ID) -and `
                -not [string]::IsNullOrWhiteSpace($New_Smoke_Build_JSON_POST_Data) -and `
                -not [string]::IsNullOrEmpty($New_Smoke_Build_JSON_POST_Data)-and `
                -not [string]::IsNullOrWhiteSpace($Smoke_ScriptParameters) -and `
                -not [string]::IsNullOrEmpty($Smoke_ScriptParameters)) {
                Try {
                    $New_Smoke_Build_Step_Response = (Invoke-RestMethod -Uri $TC_New_Smoke_Build_Step_URL -Method Post -Body $New_Smoke_Build_JSON_POST_Data -Headers $Header -ContentType 'application/json')
                    $New_Smoke_Build_Step_Response
                }
                Catch {
                    If (-not [string]::IsNullOrEmpty($Error[0].Exception.Message) -and `
                        -not [string]::IsNullOrWhiteSpace($Error[0].Exception.Message)) {
                        $_.Exception | Select-Object *
                    }
                }
            }
#endregion New_Smoke_Build_Step

#region Copy all Parameters over from Original Build
            $Method = 'PUT'
            $Build_Type_Locator = $New_Build_Configuration_Responses.id
            $parameter_Data = ($OG_Build_Responses.parameters.property ) #| Where-Object -Property inherited -NE $Responses_3.parameters.property
            $parameter_Count = ($parameter_Data.count)
            $Modified_OG_Header = $Header
            $Modified_OG_Header.Remove('Accept')
            $Modified_OG_Header.Add('ContentType','text/plain')
            For ($Count = 0; $Count -lt $parameter_Count; $Count++) {
                $property = $null
                $parameter_name = $null
                $parameter_value = $null
                $parameter_name = ($parameter_Data.name[$Count])
                $parameter_value = ($parameter_Data.value[$Count])
                $property = New-Object System.Collections.ArrayList
                If (-not [string]::IsNullOrEmpty($parameter_value) -and `
                    -not [string]::IsNullOrWhiteSpace($parameter_value)) {
                    $Parameters = @{
                        $parameter_name = $parameter_value
                    }
                }

                If (-not [string]::IsNullOrEmpty($Parameters.values) -and `
                    -not [string]::IsNullOrWhiteSpace($Parameters.values) -and `
                    -not [string]::IsNullOrWhiteSpace($Build_Type_Locator) -and `
                    -not [string]::IsNullOrEmpty($Build_Type_Locator)) {
                    Try {
                        $Parameters
                        $New_Smoke_Build_Configuration_Parameters_URL = "http://$($TeamCity_API_Instance)/buildTypes/$($Build_Type_Locator)/parameters/$($Parameters.keys)/value"
                        $New_Smoke_Build_Configuration_Parameter_Response = (Invoke-RestMethod -Uri $New_Smoke_Build_Configuration_Parameters_URL -Method $Method -Body $Parameters.values -Headers $Modified_OG_Header -ContentType 'text/plain')
                        $New_Smoke_Build_Configuration_Parameter_Response
                    }
                    Catch {
                        If (-not [string]::IsNullOrEmpty($Error[0].Exception.Message) -and `
                            -not [string]::IsNullOrWhiteSpace($Error[0].Exception.Message)) {
                            $_.Exception | Select-Object *
                        }
                    }
                }         
            }
#endregion Copy all Parameters over from Original Build
        }# END IF Create_New_Smoke_Build_Config

#region Disable_OG_Build_Step
        If ($Disable_OG_Build_Step -eq $true) {
            $Disable_OG_Build_Step = 'true'
            $Modified_OG_Header = $Header
            $Modified_OG_Header.Remove('Accept')
            $Method = 'PUT'
            $Disable_OG_TeamCity_Builds_URL = "http://$($TeamCity_API_Instance)/buildTypes/$($Build_Configuration_ID)/steps/$($OG_Build_Step_ID)/disabled"

            If (-not [string]::IsNullOrEmpty($OG_Build_Step_ID) -and `
                -not [string]::IsNullOrWhiteSpace($OG_Build_Step_ID) -and `
                -not [string]::IsNullOrWhiteSpace($Build_Configuration_ID) -and `
                -not [string]::IsNullOrEmpty($Build_Configuration_ID)) {
                Try {
                    $Disable_Build_Step_Response = (Invoke-RestMethod -Uri $Disable_OG_TeamCity_Builds_URL -Method $Method -Body $Disable_OG_Build_Step -Headers $Modified_OG_Header -ContentType 'text/plain' -Verbose)
                    $Disable_Build_Step_Response
                }
                Catch {
                    If (-not [string]::IsNullOrEmpty($Error[0].Exception.Message) -and `
                        -not [string]::IsNullOrWhiteSpace($Error[0].Exception.Message)) {
                        $_.Exception | Select-Object *
                    }
                }
            }
        }
#endregion Disable_OG_Build_Step

#region ReName_OG_Build_Step
        If ($ReName_OG_Build_Step -eq $true) {
            # This was put in to fix the deletion of all build steps when ran with a blank ID.
            $New_OG_Build_Step_Name = ('OLD_' + $OG_Build_Step.name)
            $New_OG_Build_Step_Type = ($OG_Build_Step.type)
            If (-not [string]::IsNullOrEmpty($New_OG_Build_Step_Name) -and `
                -not [string]::IsNullOrWhiteSpace($New_OG_Build_Step_Name) -and `
                -not [string]::IsNullOrWhiteSpace($New_OG_Build_Step_Type) -and `
                -not [string]::IsNullOrEmpty($New_OG_Build_Step_Type)) {    
                $property = $null
                $properties = $null
                $Count = $null

                $Rename_Build_Step_Data = @{
                    'name'= $New_OG_Build_Step_Name;
                    'type'= $New_OG_Build_Step_Type;
                }

                $property = New-Object System.Collections.ArrayList
                $property = $OG_Build_Step.properties.property            ####################
    
                $Count = $property.Count
    
                $properties = @{
                'Count' = $Count;
                'property' = $property;
                }

                $Rename_Build_Step_Data.Add('properties',$properties)

                $Rename_Build_Step_JSON_Data = $($Rename_Build_Step_Data | ConvertTo-Json -Compress -Depth 100)
                $Method = 'PUT'

                If (-not [string]::IsNullOrEmpty($OG_Build_Step_ID) -and `
                    -not [string]::IsNullOrWhiteSpace($OG_Build_Step_ID) -and `
                    -not [string]::IsNullOrEmpty($Build_Configuration_ID) -and `
                    -not [string]::IsNullOrWhiteSpace($Build_Configuration_ID) -and `
                    -not [string]::IsNullOrEmpty($Rename_Build_Step_JSON_Data) -and `
                    -not [string]::IsNullOrWhiteSpace($Rename_Build_Step_JSON_Data)) {
                    Try {
                        $OG_TeamCity_Build_Step_URL = "http://$($TeamCity_API_Instance)/buildTypes/$($Build_Configuration_ID)/steps/$($OG_Build_Step_ID)"
                        $Rename_Build_Step_Response = (Invoke-RestMethod -Uri $OG_TeamCity_Build_Step_URL -Method $Method -Body $Rename_Build_Step_JSON_Data -Headers $Header -ContentType 'application/json' -Verbose)
                        $Rename_Build_Step_Response
                    }
                    Catch {
                        If (-not [string]::IsNullOrEmpty($Error[0].Exception.Message) -and `
                            -not [string]::IsNullOrWhiteSpace($Error[0].Exception.Message)) {
                            $_.Exception | Select-Object *
                        }
                    }
                }
            }
            Else {
                Write-Warning "The orgiinal build step has already been renamed to $($New_OG_Build_Step_Name)"
            }
        }
#endregion ReName_OG_Build_Step       
    }
}
