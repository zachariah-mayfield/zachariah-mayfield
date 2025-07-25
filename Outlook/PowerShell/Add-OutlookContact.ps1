

Function Import-OutlookContact {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
        [Parameter(Mandatory=$false,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [String]$CSVLocation = "C:\Contacts.csv"
        )

Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}

Process {

try {
# This makes the API connection to the Outlook Application. 
    Add-Type -assembly "Microsoft.Office.Interop.Outlook" -ErrorAction Stop -ErrorVariable "OutlookError" 
    $Outlook = New-Object -comobject Outlook.Application -ErrorAction stop -ErrorVariable "ApplicationError"
    $namespace = $Outlook.GetNameSpace("MAPI") 
    $contactObject  = $namespace.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderContacts) 
    $Contactitems = $contactObject.Items;   
} 
         
# Catch all other exceptions thrown by one of those commands 
catch { 
    $OutlookError
    $ApplicationError
}

Function Add-OutlookContact {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
    Param (
        [Parameter(Mandatory=$false,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Switch]$ShowContactInfo,
        [Switch]$Add,
        $Account,
        $Anniversary,
        $AssistantName,
        $AssistantTelephoneNumber,
        $BillingInformation,
        $Birthdate,
        $Body,
        $Business2TelephoneNumber,
        $BusinessAddress,
        $BusinessAddressCity,
        $BusinessAddressCountry,
        $BusinessAddressPostalCode,
        $BusinessAddressPostOfficeBox,
        $BusinessAddressState,
        $BusinessAddressStreet,
        $BusinessFaxNumber,
        $BusinessHomePage,
        $BusinessTelephoneNumber,
        $CallbackTelephoneNumber,
        $CarTelephoneNumber,
        $Categories,
        $Children,
        $Companies,
        $CompanyMainTelephoneNumber,
        $CompanyName,
        $ComputerNetworkName,
        $CustomerID,
        $Department,
        $Email1Address,
        $Email1AddressType,
        $Email1DisplayName,
        $Email2Address,
        $Email2AddressType,
        $Email2DisplayName,
        $Email3Address,
        $Email3AddressType,
        $Email3DisplayName,
        $FileAs,
        $FirstName,
        $FTPSite,
        $FullName,
        $GovernmentIDNumber,
        $Hobby,
        $Home2TelephoneNumber,
        $HomeAddress,
        $HomeAddressCity,
        $HomeAddressCountry,
        $HomeAddressPostalCode,
        $HomeAddressPostOfficeBox,
        $HomeAddressState,
        $HomeAddressStreet,
        $HomeFaxNumber,
        $HomeTelephoneNumber,
        $IMAddress,
        $Initials,
        $InternetFreeBusyAddress,
        $ISDNNumber,
        $JobTitle,
        $Language,
        $LastName,
        $MailingAddress,
        $MailingAddressCity,
        $MailingAddressCountry,
        $MailingAddressPostalCode,
        $MailingAddressPostOfficeBox,
        $MailingAddressState,
        $MailingAddressStreet,
        $ManagerName,
        $MessageClass,
        $MiddleName,
        $Mileage,
        $MobileTelephoneNumber,
        $NetMeetingAlias,
        $NetMeetingServer,
        $NickName,
        $OfficeLocation,
        $OrganizationalIDNumber,
        $OtherAddress,
        $OtherAddressCity,
        $OtherAddressCountry,
        $OtherAddressPostalCode,
        $OtherAddressPostOfficeBox,
        $OtherAddressState,
        $OtherAddressStreet,
        $OtherFaxNumber,
        $OtherTelephoneNumber,
        $PagerNumber,
        $PersonalHomePage,
        $PrimaryTelephoneNumber,
        $Profession,
        $RadioTelephoneNumber,
        $ReferredBy,
        $ReminderSoundFile,
        $Spouse,
        $Subject,
        $Suffix,
        $TaskSubject,
        $TelexNumber,
        $Title,
        $TTYTDDTelephoneNumber,
        $User1,
        $User2,
        $User3,
        $User4,
        $UserCertificate,
        $WebPage,
        $YomiCompanyName,
        $YomiFirstName,
        $YomiLastName
)


Begin{
# This $Global Setting will show all of the output: ($FormatEnumerationLimit=-1)
$Global:FormatEnumerationLimit=-1
}

Process {

# This is a switched parameter that has to be stated to add the Outlook Contact.
IF ($Add){

# This created a $Variable where all of the below properties can be assigned to that Property.
$item = $Outlook.CreateItem(2)

# Below are the IF Statements for each of the properties specified.
# IF any of the properties below are specified then it will assign the value to that property, and the property to the $Variable.     
    IF ($Account){
         $item.Account = $Account
    }
    IF ($Anniversary){
        $item.Anniversary = $Anniversary
    }

    IF ($AssistantName){
         $item.AssistantName = $AssistantName
    }

    IF ($AssistantTelephoneNumber){ 
         $item.AssistantTelephoneNumber = $AssistantTelephoneNumber
    }

    IF ($BillingInformation){
         $item.BillingInformation = $BillingInformation
    }

    IF ($Birthdate){
         $item.Birthday = $Birthdate
    }

    IF ($Body){
         $item.Body = $Body
    }

    IF ($Business2TelephoneNumber){
         $item.Business2TelephoneNumber = $Business2TelephoneNumber
    }

    IF ($BusinessAddress){
         $item.BusinessAddress = $BusinessAddress
    }

    IF ($BusinessAddressCity){
         $item.BusinessAddressCity = $BusinessAddressCity
    }

    IF ($BusinessAddressCountry){
         $item.BusinessAddressCountry = $BusinessAddressCountry
    }

    IF ($BusinessAddressPostalCode){
         $item.BusinessAddressPostalCode = $BusinessAddressPostalCode
    }

    IF ($BusinessAddressPostOfficeBox){
         $item.BusinessAddressPostOfficeBox = $BusinessAddressPostOfficeBox
    }

    IF ($BusinessAddressState){
         $item.BusinessAddressState = $BusinessAddressState
    }

    IF ($BusinessAddressStreet){
         $item.BusinessAddressStreet = $BusinessAddressStreet

    }

    IF ($BusinessFaxNumber){
         $item.BusinessFaxNumber = $BusinessFaxNumber
    }

    IF ($BusinessHomePage){
         $item.BusinessHomePage = $BusinessHomePage
    }

    IF ($BusinessTelephoneNumber){
         $item.BusinessTelephoneNumber = $BusinessTelephoneNumber
    }
    
    IF ($CallbackTelephoneNumber){
         $item.CallbackTelephoneNumber = $CallbackTelephoneNumber
    }
    
    IF ($CarTelephoneNumber){
         $item.CarTelephoneNumber = $CarTelephoneNumber
    }
    
    IF ($Categories){
         $item.Categories = $Categories
    }
    
    IF ($Children){
         $item.Children = $Children
    }
    
    IF ($Companies){
         $item.Companies = $Companies
    }
    
    IF ($CompanyMainTelephoneNumber){
         $item.CompanyMainTelephoneNumber = $CompanyMainTelephoneNumber
    }
    
    IF ($CompanyName){
         $item.CompanyName = $CompanyName
    }
    
    IF ($ComputerNetworkName){
         $item.ComputerNetworkName = $ComputerNetworkName
    }
    
    IF ($CustomerID){
         $item.CustomerID = $CustomerID
    }
    
    IF ($Department){
         $item.Department = $Department
    }
    
    IF ($Email1Address){
         $item.Email1Address = $Email1Address
    }
    
    IF ($Email1AddressType){
         $item.Email1AddressType = $Email1AddressType
    }
    
    IF ($Email1DisplayName){
         $item.Email1DisplayName = $Email1DisplayName
    }
    
    IF ($Email2Address){
         $item.Email2Address = $Email2Address
    }
    
    IF ($Email2AddressType){
         $item.Email2AddressType = $Email2AddressType
    }
    
    IF ($Email2DisplayName){
         $item.Email2DisplayName = $Email2DisplayName
    }
    
    IF ($Email3Address){
         $item.Email3Address = $Email3Address
    }
    
    IF ($Email3AddressType){
         $item.Email3AddressType = $Email3AddressType
    }
    
    IF ($Email3DisplayName){
         $item.Email3DisplayName = $Email3DisplayName
    }
    
    IF ($FileAs){
         $item.FileAs = $FileAs
    }
    
    IF ($FirstName){
         $item.FirstName = $FirstName
    }
    
    IF ($FTPSite){
         $item.FTPSite = $FTPSite
    }
    
    IF ($FullName){
         $item.FullName = $FullName
    }
    
    IF ($GovernmentIDNumber){
         $item.GovernmentIDNumber = $GovernmentIDNumber
    }
    
    IF ($Hobby){
         $item.Hobby = $Hobby
    }
    
    IF ($Home2TelephoneNumber){
         $item.Home2TelephoneNumber = $Home2TelephoneNumber
    }
    
    IF ($HomeAddress){
         $item.HomeAddress = $HomeAddress
    }
    
    IF ($HomeAddressCity){
         $item.HomeAddressCity = $HomeAddressCity
    }
    
    IF ($HomeAddressCountry){
         $item.HomeAddressCountry = $HomeAddressCountry
    }
    
    IF ($HomeAddressPostalCode){
         $item.HomeAddressPostalCode = $HomeAddressPostalCode
    }
    
    IF ($HomeAddressPostOfficeBox){
         $item.HomeAddressPostOfficeBox = $HomeAddressPostOfficeBox
    }
    
    IF ($HomeAddressState){
         $item.HomeAddressState = $HomeAddressState
    }
    
    IF ($HomeAddressStreet){
         $item.HomeAddressStreet = $HomeAddressStreet
    }
    
    IF ($HomeFaxNumber){
         $item.HomeFaxNumber = $HomeFaxNumber
    }
    
    IF ($HomeTelephoneNumber){
         $item.HomeTelephoneNumber = $HomeTelephoneNumber
    }
    
    IF ($IMAddress){
         $item.IMAddress = $IMAddress
    }
    
    IF ($Initials){
         $item.Initials = $Initials
    }
    
    IF ($InternetFreeBusyAddress){
         $item.InternetFreeBusyAddress = $InternetFreeBusyAddress
    }
    
    IF ($ISDNNumber){
         $item.ISDNNumber = $ISDNNumber
    }
    
    IF ($JobTitle){
         $item.JobTitle = $JobTitle
    }
    
    IF ($Language){
         $item.Language = $Language
    }
    
    IF ($LastName){
         $item.LastName = $LastName
    }
    
    IF ($MailingAddress){
         $item.MailingAddress = $MailingAddress
    }
    
    IF ($MailingAddressCity){
         $item.MailingAddressCity = $MailingAddressCity
    }
    
    IF ($MailingAddressCountry){
         $item.MailingAddressCountry = $MailingAddressCountry
    }
    
    IF ($MailingAddressPostalCode){
         $item.MailingAddressPostalCode = $MailingAddressPostalCode
    }
    
    IF ($MailingAddressPostOfficeBox){
         $item.MailingAddressPostOfficeBox = $MailingAddressPostOfficeBox
    }
    
    IF ($MailingAddressState){
         $item.MailingAddressState = $MailingAddressState
    }
    
    IF ($MailingAddressStreet){
         $item.MailingAddressStreet = $MailingAddressStreet
    }
    
    IF ($ManagerName){
         $item.ManagerName = $ManagerName
    }
    
    IF ($MessageClass){
         $item.MessageClass = $MessageClass
    }
    
    IF ($MiddleName){
         $item.MiddleName = $MiddleName
    }
    
    IF ($Mileage){
         $item.Mileage = $Mileage
    }
    
    IF ($MobileTelephoneNumber){
         $item.MobileTelephoneNumber = $MobileTelephoneNumber
    }
    
    IF ($NetMeetingAlias){
         $item.NetMeetingAlias = $NetMeetingAlias
    }
    
    IF ($NetMeetingServer){
         $item.NetMeetingServer = $NetMeetingServer
    }
    
    IF ($NickName){
         $item.NickName = $NickName
    }
    
    IF ($OfficeLocation){
         $item.OfficeLocation = $OfficeLocation
    }
    
    IF ($OrganizationalIDNumber){
         $item.OrganizationalIDNumber = $OrganizationalIDNumber
    }
    
    IF ($OtherAddress){
         $item.OtherAddress = $OtherAddress
    }
    
    IF ($OtherAddressCity){
         $item.OtherAddressCity = $OtherAddressCity
    }
    
    IF ($OtherAddressCountry){
         $item.OtherAddressCountry = $OtherAddressCountry
    }
    
    IF ($OtherAddressPostalCode){
         $item.OtherAddressPostalCode = $OtherAddressPostalCode
    }
    
    IF ($OtherAddressPostOfficeBox){
         $item.OtherAddressPostOfficeBox = $OtherAddressPostOfficeBox
    }
    
    IF ($OtherAddressState){
         $item.OtherAddressState = $OtherAddressState
    }
    
    IF ($OtherAddressStreet){
         $item.OtherAddressStreet = $OtherAddressStreet
    }
    
    IF ($OtherFaxNumber){
         $item.OtherFaxNumber = $OtherFaxNumber
    }
    
    IF ($OtherTelephoneNumber){
         $item.OtherTelephoneNumber = $OtherTelephoneNumber
    }
    
    IF ($PagerNumber){
         $item.PagerNumber = $PagerNumber
    }
    
    IF ($PersonalHomePage){
         $item.PersonalHomePage = $PersonalHomePage 
    }
    
    IF ($PrimaryTelephoneNumber){
         $item.PrimaryTelephoneNumber = $PrimaryTelephoneNumber
    }
    
    IF ($Profession){
         $item.Profession = $Profession
    }
    
    IF ($RadioTelephoneNumber){
         $item.RadioTelephoneNumber = $RadioTelephoneNumber
    }
    
    IF ($ReferredBy){
         $item.ReferredBy = $ReferredBy
    }
    
    IF ($ReminderSoundFile){
         $item.ReminderSoundFile = $ReminderSoundFile
    }
    
    IF ($Spouse){
         $item.Spouse = $Spouse
    }
    
    IF ($Subject){
         $item.Subject = $Subject
    }
    
    IF ($Suffix){
         $item.Suffix = $Suffix
    }
    
    IF ($TaskSubject){
         $item.TaskSubject = $TaskSubject
    }
    
    IF ($TelexNumber){
         $item.TelexNumber = $TelexNumber
    }
    
    IF ($Title){
         $item.Title = $Title
    }
    
    IF ($TTYTDDTelephoneNumber){
         $item.TTYTDDTelephoneNumber = $TTYTDDTelephoneNumber
    }
    
    IF ($User1){
         $item.User1 = $User1
    }
    
    IF ($User2){
         $item.User2 = $User2
    }
    
    IF ($User3){
         $item.User3 = $User3
    }
    
    IF ($User4){
         $item.User4 = $User4
    }
    
    IF ($UserCertificate){
         $item.UserCertificate = $UserCertificate
    }
    
    IF ($WebPage){
         $item.WebPage = $WebPage
    }
    
    IF ($YomiCompanyName){
         $item.YomiCompanyName = $YomiCompanyName
    }

    IF ($YomiFirstName){
         $item.YomiFirstName = $YomiFirstName
    }

    IF ($YomiLastName){
         $item.YomiLastName = $YomiLastName
    }
# This saves the values assigned to each of the properties and assigns them to the $Variable.        
            $Create = $item.Save()
            Write-Host -ForegroundColor Cyan "Creating Outlook contact for:" $item.FullName

        }#END IF ($Add)

}#END Process

End {
}#END END

}#END Function Add-OutlookContact

############ --------->>>>>>>>>>>

# The $Variable $CSVContact will be paramerterized so that the CSV location is not hard coded.
$CSVContacts = ( Import-Csv $CSVLocation )

# This gets a list of current contact email addresses.
$CurrentContacts = ForEach ( $item in $Contactitems ){
    $item.Email1Address
}#END ForEach ( $item in $Contactitems )

# This is a ForEach loop that will take the values of each of the Contacts from the CSV and assign them to the specified properties of the New Contact.
ForEach ( $Contact in $CSVContacts ) {

$FirstName = $Contact."First Name"
$LastName = $Contact."Last Name"
$Suffix = $Contact.Suffix
$CompanyName = $Contact.Company
$Department = $Contact.Department
$JobTitle = $Contact."Job Title"
$HomeAddressStreet = $Contact."Home Street"
$HomeAddressCity = $Contact."Home City"
$HomeAddressState = $Contact."Home State"
$HomeAddressPostalCode = $Contact."Home Postal Code"
$HomeTelephoneNumber = $Contact."Home phone"
$BusinessTelephoneNumber = $Contact."Business phone"
$Business2TelephoneNumber = $Contact."Business phone 2"
$MobileTelephoneNumber = $Contact."Mobile phone"
$Categories = $Contact.Categories
$Email1Address = $Contact."E-mail Address"
$ManagerName = $Contact."Manager's Name"
$Body = $Contact.Notes
$Spouse = $Contact.Spouse
$WebPage = $Contact.WebPage 
$Birthdate = $Contact.Birthday
$Anniversary = $Contact.Anniversary

# This is a check to see if the New Contact already exists in Outlook before it adds it.
IF ( $CurrentContacts -like $Email1Address ) {
        Write-Host  -ForegroundColor Yellow $Email1Address "Already Exists in Outlook"
    }#END IF ( $CurrentContacts -like $Email1Address )
    ELSE {
        Write-Host -ForegroundColor Red $Email1Address "Does Not Exist in Outlook "
        Write-Host -ForegroundColor Cyan "Adding Outlook Contact" $Email1Address

# This is the Function built above that has each of the parameters specified with the properties of each of the new contacts.        
        Add-OutlookContact -Add -FirstName $FirstName -LastName $LastName -Suffix $Suffix -CompanyName $CompanyName -Department $Department -JobTitle $JobTitle -HomeAddressStreet $HomeAddressStreet -HomeAddressCity $HomeAddressCity -HomeAddressState $HomeAddressState -HomeAddressPostalCode $HomeAddressPostalCode -HomeTelephoneNumber $HomeTelephoneNumber -BusinessTelephoneNumber $BusinessTelephoneNumber  -Business2TelephoneNumber $Business2TelephoneNumber -MobileTelephoneNumber $MobileTelephoneNumber -Categories $Categories -Email1Address $Email1Address -ManagerName $ManagerName -Body $Body -Spouse $Spouse -WebPage $WebPage -Birthdate $Birthdate -Anniversary $Anniversary

}#END Else

}#END ForEach ( $Contact in $CSVContacts )



}#END Process

End {
}#END END

}#END Function Import-OutlookContact

Import-OutlookContact


