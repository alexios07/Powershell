#========================================================================
#
# Tool Name	: MDT Profile Generator
# Author 	: Damien VAN ROBAEYS
# Date 		: 01/06/2016
# Website	: http://www.systanddeploy.com/
# Twitter	: https://twitter.com/syst_and_deploy
#
#========================================================================

Param
    (
		[Parameter(Mandatory=$true)]
		[AllowEmptyString()]						
		[String]$deploymentshare # Import the deployment share from the first GUI		        
    )

	
	

[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')      | out-null  
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') | out-null


Add-Type -AssemblyName "System.Windows.Forms"
Add-Type -AssemblyName "System.Drawing"

[System.Windows.Forms.Application]::EnableVisualStyles()

#########################################################################
#                        Load Main Panel                                #
#########################################################################

$Global:pathPanel= split-path -parent $MyInvocation.MyCommand.Definition

function LoadXaml ($filename){
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}


$XamlMainWindow=LoadXaml($pathPanel+"\MDT_Profile_Generator.xaml")
$reader = (New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form = [Windows.Markup.XamlReader]::Load($reader)


#########################################################################
#                        HAMBURGER VIEWS                                #
#########################################################################

#******************* Item in the menu  *****************
$Details      		= $Form.FindName("Details") 
$Domain   			= $Form.FindName("Domain")
$Network   			= $Form.FindName("Network") 
$Backup     		= $Form.FindName("Backup") 
$Wizard    			= $Form.FindName("Wizard") 
$Applications     	= $Form.FindName("Applications") 
$Others     		= $Form.FindName("Others") 

#******************* Generral controls  *****************
$TabMenuHamburger 	= $Form.FindName("TabMenuHamburger")
$about 				= $Form.findname("about")
$Clear_All_Button 	= $Form.findname("Clear_All_Button")
$Create_Profile 	= $Form.findname("Create_Profile")
$Load_Profile 		= $Form.findname("Load_Profile")








#******************* Load Other Views  *****************
$viewFolder = $pathPanel +"\views"

$XamlChildWindow = LoadXaml($viewFolder+"\Details.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$Details_Xaml        = [Windows.Markup.XamlReader]::Load($Childreader)

$XamlChildWindow = LoadXaml($viewFolder+"\Domain.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$Domain_Xaml     = [Windows.Markup.XamlReader]::Load($Childreader)

$XamlChildWindow = LoadXaml($viewFolder+"\Network.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$Network_Xaml    = [Windows.Markup.XamlReader]::Load($Childreader)

$XamlChildWindow = LoadXaml($viewFolder+"\Backup.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$Backup_Xaml    = [Windows.Markup.XamlReader]::Load($Childreader)

$XamlChildWindow = LoadXaml($viewFolder+"\Wizard.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$PWizard_Xaml    = [Windows.Markup.XamlReader]::Load($Childreader)

$XamlChildWindow = LoadXaml($viewFolder+"\Applications.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$Applications_Xaml    = [Windows.Markup.XamlReader]::Load($Childreader)


$XamlChildWindow = LoadXaml($viewFolder+"\Others.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$Others_Xaml    = [Windows.Markup.XamlReader]::Load($Childreader) 
 
$Details.Children.Add($Details_Xaml)        	 | Out-Null
$Domain.Children.Add($Domain_Xaml)  			 | Out-Null    
$Network.Children.Add($Network_Xaml)    		 | Out-Null  
$Backup.Children.Add($Backup_Xaml)    			 | Out-Null      
$Wizard.Children.Add($PWizard_Xaml)    			 | Out-Null   
$Applications.Children.Add($Applications_Xaml)   | Out-Null         
$Others.Children.Add($Others_Xaml)    			 | Out-Null         

#******************************************************
# Initialize with the first value of Item Section *****
#******************************************************

$TabMenuHamburger.SelectedItem = $TabMenuHamburger.ItemsSource[0]


$load_test 	= $Form.findname("load_test")




#########################################################################
#                        HAMBURGER EVENTS                               #
#########################################################################

#******************* Items Section  *******************

# $TabMenuHamburger.add_ItemClick({  
   # $TabMenuHamburger.Content = $TabMenuHamburger.SelectedItem
   # $TabMenuHamburger.IsPaneOpen = $false
# })



# Controls for details part
$Profile_Name = $Details_Xaml.findname("Profile_Name")
$Profile_Name_Info = $Details_Xaml.findname("Profile_Name_Info")
$Profile_Path = $Details_Xaml.findname("Profile_Path")
$Profile_Path_TextBox = $Details_Xaml.findname("Profile_Path_TextBox")
$Profile_Path_Info = $Details_Xaml.findname("Profile_Path_Info")
$Choose_TS = $Details_Xaml.findname("Choose_TS")
$Choose_TS_Info = $Details_Xaml.findname("Choose_TS_Info")
$Deployment_Type_NoSet = $Details_Xaml.findname("Deployment_Type_NoSet")
$Deployment_Type_Newcomputer = $Details_Xaml.findname("Deployment_Type_Newcomputer")
$Deployment_Type_Refresh = $Details_Xaml.findname("Deployment_Type_Refresh")
# $Choose_deploy_type = $Details_Xaml.findname("Choose_deploy_type")
$Choose_OSLanguage = $Details_Xaml.findname("Choose_OSLanguage")
$OS_Language_Info = $Details_Xaml.findname("OS_Language_Info")
$Choose_second_OSLanguage = $Details_Xaml.findname("Choose_second_OSLanguage")
$Second_language_none = $Details_Xaml.findname("Second_language_none")
$Second_OS_Language_Info = $Details_Xaml.findname("Second_OS_Language_Info")
$Choose_Timezone = $Details_Xaml.findname("Choose_Timezone")
$Choose_Keyboard_Layout = $Details_Xaml.findname("Choose_Keyboard_Layout")
$Deployment_Type = $Details_Xaml.findname("Deployment_Type")


# Controls for Domain part
$Org_name = $Domain_Xaml.findname("Org_name")
$Computer_Name = $Domain_Xaml.findname("Computer_Name")
$Computer_Name_SN = $Domain_Xaml.findname("Computer_Name_SN")
$Local_Admin_PWD = $Domain_Xaml.findname("Local_Admin_PWD")
$Mode_Workgroup = $Domain_Xaml.findname("Mode_Workgroup")
$Mode_Domain = $Domain_Xaml.findname("Mode_Domain")
# $Choose_mode = $Domain_Xaml.findname("Choose_mode")
$Domaine_Wkg_Label = $Domain_Xaml.findname("Domaine_Wkg_Label")
$Domaine_Wkg_txtbox = $Domain_Xaml.findname("Domaine_Wkg_txtbox")
$OU_name = $Domain_Xaml.findname("OU_name")
$UserName = $Domain_Xaml.findname("UserName")
$Domain_Admin_Pwd = $Domain_Xaml.findname("Domain_Admin_Pwd")
$Choose_Domain_WKG = $Domain_Xaml.findname("Choose_Domain_WKG")
$Domain_Block = $Domain_Xaml.findname("Domain_Block")



# Controls for Network part
$Choose_DHCP = $Network_Xaml.findname("Choose_DHCP")
$Choose_Static = $Network_Xaml.findname("Choose_Static")
$Choose_Network_Type = $Network_Xaml.findname("Choose_Network_Type")
$IPAddress = $Network_Xaml.findname("IPAddress")
$Gateway = $Network_Xaml.findname("Gateway")
$SubnetMask = $Network_Xaml.findname("SubnetMask")
$DNS_Server = $Network_Xaml.findname("DNS_Server")
$IE_home_page = $Network_Xaml.findname("IE_home_page")
$Choose_Network = $Network_Xaml.findname("Choose_Network")
$Network_Block = $Network_Xaml.findname("Network_Block")



# Controls for Backup part
$computerbackup_location_label = $Backup_Xaml.findname("computerbackup_location_label")
$Combox_Computer_Backup_Type = $Backup_Xaml.findname("Combox_Computer_Backup_Type")
$Backup_Computer_No = $Backup_Xaml.findname("Backup_Computer_No")
$Backup_Computer_Auto = $Backup_Xaml.findname("Backup_Computer_Auto")
$Backup_Computer_Specify = $Backup_Xaml.findname("Backup_Computer_Specify")
$Computer_Backup_Location = $Backup_Xaml.findname("Computer_Backup_Location")
$Computer_Backup_Location_TextBox = $Backup_Xaml.findname("Computer_Backup_Location_TextBox")
$Capture_computer = $Backup_Xaml.findname("Capture_computer")
$Combo_Capture_Computer = $Backup_Xaml.findname("Combo_Capture_Computer")
$capture_computer_no = $Backup_Xaml.findname("capture_computer_no")
$capture_computer_yes = $Backup_Xaml.findname("capture_computer_yes")
$sysprep_this_computer = $Backup_Xaml.findname("sysprep_this_computer")
$prepare_to_capture = $Backup_Xaml.findname("prepare_to_capture")
$Choose_capture = $Backup_Xaml.findname("Choose_capture")
$Capture_Location = $Backup_Xaml.findname("Capture_Location")
$Capture_backup_location_textbox = $Backup_Xaml.findname("Capture_backup_location_textbox")
$Capture_backup_location_info = $Backup_Xaml.findname("Capture_backup_location_info")
$Capture_Name = $Backup_Xaml.findname("Capture_Name")
$Capture_file_name = $Backup_Xaml.findname("Capture_file_name")
$Combo_Backup_Type = $Backup_Xaml.findname("Combo_Backup_Type")
$WIM_file = $Backup_Xaml.findname("WIM_file")
$VHD_File = $Backup_Xaml.findname("VHD_File")
$Capture_User_Name = $Backup_Xaml.findname("Capture_User_Name")
$Capture_location_user = $Backup_Xaml.findname("Capture_location_user")
$Capture_location_password = $Backup_Xaml.findname("Capture_location_password")
$Capture_User_Domain = $Backup_Xaml.findname("Capture_User_Domain")
$Capture_location_domain = $Backup_Xaml.findname("Capture_location_domain")
$UserDataLocation_Label = $Backup_Xaml.findname("UserDataLocation_Label")
$Capture_User_Password = $Backup_Xaml.findname("Capture_User_Password")
$user_data_backup_type = $Backup_Xaml.findname("user_data_backup_type")
$Combox_UserData_Backup_Type = $Backup_Xaml.findname("Combox_UserData_Backup_Type")
$Backup_UserData_NO = $Backup_Xaml.findname("Backup_UserData_NO")
$Backup_UserData_Auto = $Backup_Xaml.findname("Backup_UserData_Auto")
$Backup_UserData_Network = $Backup_Xaml.findname("Backup_UserData_Network")
$Backup_Location = $Backup_Xaml.findname("Backup_Location")
$UserData_Backup_location_textbox = $Backup_Xaml.findname("UserData_Backup_location_textbox")
$move_userdata = $Backup_Xaml.findname("move_userdata")
$move_data_yes = $Backup_Xaml.findname("move_data_yes")
$move_data_no = $Backup_Xaml.findname("move_data_no")
$move_data_apply = $Backup_Xaml.findname("move_data_apply")
$restore_user_data = $Backup_Xaml.findname("restore_user_data")
$Combo_restore_UserData = $Backup_Xaml.findname("Combo_restore_UserData")
$restore_user_data_no = $Backup_Xaml.findname("restore_user_data_no")
$restore_user_data_specify_location = $Backup_Xaml.findname("restore_user_data_specify_location")
$Restore_Location = $Backup_Xaml.findname("Restore_Location")
$UserData_restore_location_textbox = $Backup_Xaml.findname("UserData_restore_location_textbox")
$Computer_Backup_type = $Backup_Xaml.findname("Computer_Backup_type")
$Keep_existing_partitions = $Backup_Xaml.findname("Keep_existing_partitions")
$Not_Format = $Backup_Xaml.findname("Not_Format")



# Controls for Others part
$Finish_Action = $Others_Xaml.findname("Finish_Action")
$Finish_Action_DoNothing = $Others_Xaml.findname("Finish_Action_DoNothing")
$Finish_Action_Reboot = $Others_Xaml.findname("Finish_Action_Reboot")
$Finish_Action_Shutdown = $Others_Xaml.findname("Finish_Action_Shutdown")
$Finish_Action_LogOff = $Others_Xaml.findname("Finish_Action_LogOff")
$GPO_Pack_path = $Others_Xaml.findname("GPO_Pack_path")
$GPO_Pack_DoNothing = $Others_Xaml.findname("GPO_Pack_DoNothing")
$GPO_Pack_Info = $Others_Xaml.findname("GPO_Pack_Info")
$Set_WSUS_Server = $Others_Xaml.findname("Set_WSUS_Server")
$Event_Service = $Others_Xaml.findname("Event_Service")
$Logs_SLShare = $Others_Xaml.findname("Logs_SLShare")
$SLShare_Deployroot = $Others_Xaml.findname("SLShare_Deployroot")
$Logs_SLShareDynamicLogging = $Others_Xaml.findname("Logs_SLShareDynamicLogging")
$Hide_Shell = $Others_Xaml.findname("Hide_Shell")
$Not_extra_partition = $Others_Xaml.findname("Not_extra_partition")
$Product_Key = $Others_Xaml.findname("Product_Key")
$No_Product_Key = $Others_Xaml.findname("No_Product_Key")
$Activate_MAK = $Others_Xaml.findname("Activate_MAK")
$specific_product = $Others_Xaml.findname("specific_product")
$Product_Key_Block = $Others_Xaml.findname("Product_Key_Block")
$Key_Label = $Others_Xaml.findname("Key_Label")
$Key_Label_TextBox = $Others_Xaml.findname("Key_Label_TextBox")


# Controls for Applications part
$DataGrid_Applis = $Applications_Xaml.findname("DataGrid_Applis")
$Appli_Name = $Applications_Xaml.findname("Appli_Name")
$Appli_GUID = $Applications_Xaml.findname("Appli_GUID")


# Controls for Wizard part
$Skip_All = $PWizard_Xaml.findname("Skip_All")
$Skip_TS = $PWizard_Xaml.findname("Skip_TS")
$Skip_ProductKey = $PWizard_Xaml.findname("Skip_ProductKey")
$Skip_move_user_data = $PWizard_Xaml.findname("Skip_move_user_data")
$Skip_restore_UserData = $PWizard_Xaml.findname("Skip_restore_UserData")
$Skip_DomainMemberShip = $PWizard_Xaml.findname("Skip_DomainMemberShip")
$Skip_AdminPWD = $PWizard_Xaml.findname("Skip_AdminPWD")
$Skip_Applications = $PWizard_Xaml.findname("Skip_Applications")
$Skip_Capture = $PWizard_Xaml.findname("Skip_Capture")
$Skip_Bitlocker = $PWizard_Xaml.findname("Skip_Bitlocker")
$Skip_Computer_name = $PWizard_Xaml.findname("Skip_Computer_name")
$Skip_Locale_time = $PWizard_Xaml.findname("Skip_Locale_time")
$Skip_Language_packs = $PWizard_Xaml.findname("Skip_Language_packs")
$Skip_Summary = $PWizard_Xaml.findname("Skip_Summary")
$Skip_Final_Summary = $PWizard_Xaml.findname("Skip_Final_Summary")
$Image_Block = $PWizard_Xaml.findname("Image_Block")
$Image_Wizard = $PWizard_Xaml.findname("Image_Wizard")


# $Image_Wizard.Source = ""

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
# 																		VARIABLES INITIALIZATION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################

$object = New-Object -comObject Shell.Application  
$Profile_Name.Text = "Customsettings_MDT.ini" 
$Global:Current_Folder =(get-location).path 

$Mode_Workgroup.IsSelected = $true 
$Domaine_Wkg_Label.Content = "Workgroup name:"
$UserName.IsEnabled = $false 
$Domain_Admin_Pwd.IsEnabled = $false 	
$OU_name.IsEnabled = $false 	
$IPAddress.IsEnabled = $false 
$Gateway.IsEnabled = $false 
$SubnetMask.IsEnabled = $false 		
$DNS_Server.IsEnabled = $false 	
$Profile_Path_TextBox.IsEnabled = $false
$Global:Row_List = $DataGrid_Applis.items
$UserName.IsEnabled = $false 	
#************************************************************************** Capture part ***************************************************************************************
$computerbackup_location_label.Content = "Capture"
$capture_computer_no.IsSelected = $true
$Capture_backup_location_textbox.IsEnabled = $false 	
$Capture_file_name.IsEnabled = $false 	
$Combo_Backup_Type.IsEnabled = $false 
# $Backup_location_user.IsEnabled = $false 	
# $Backup_location_password.IsEnabled = $false 	
# $Backup_location_domain.IsEnabled = $false 
$Capture_location_user.IsEnabled = $false 
$Capture_location_password.IsEnabled = $false 
$Capture_location_domain.IsEnabled = $false 
#************************************************************************** Move and restore User data part ***************************************************************************************
$move_data_no.IsChecked = $true
$Combo_restore_UserData.IsEnabled = $true 	
$UserData_restore_location_textbox.IsEnabled = $false 				
$restore_user_data_no.IsSelected = $true
$Deployment_Type_NoSet.IsSelected = $true
$UserDataLocation_Label.Content = "Move and Restore User Data"	
$move_data_no.IsChecked = $true
$Not_Format.Visibility = "Collapsed"

# Part for Capture or Computer Backup
$Capture_computer.Visibility = "Visible"
$Capture_Location.Visibility = "Visible"
$Capture_Name.Visibility = "Visible"
$Capture_User_Name.Visibility = "Visible"
$Capture_User_Password.Visibility = "Visible"
$Capture_User_Domain.Visibility = "Visible"
$Computer_Backup_type.Visibility = "Collapsed"
$Computer_Backup_Location.Visibility = "Collapsed"	

# Part for Move and restore user data
$user_data_backup_type.Visibility = "Collapsed"
$Backup_Location.Visibility = "Collapsed"
$move_userdata.Visibility = "Visible"
$restore_user_data.Visibility = "Visible"
$Restore_Location.Visibility = "Visible"	

$Mode_Workgroup.IsSelected = $true 
$Domain_Block.Visibility = "Collapsed"


$Choose_DHCP.IsSelected = $true 
$Network_Block.Visibility = "Collapsed"

$Skip_All.IsChecked = $False
$Skip_All.Content = "Skip all wizards"

#************************************************************************** Other part ***************************************************************************************
$No_Product_Key.IsSelected = $True
$Product_Key_Block.Visibility = "Collapsed"
	
########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
# 																		FUNCTIONS INITIALIZATION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################

#************************************************************************** Populate the Keyboard Layout ListBox ***************************************************************************************
Function Populate_KeyBoard 
	{		
		$LanguageUI = "MDT_LanguageUI.xml"						
		$Global:my_LanguageUI_xml = [xml] (Get-Content $LanguageUI)	
		foreach ($data in $my_LanguageUI_xml.selectNodes("LanguageUI/KeyboardLocale/option"))			
			{
				$Choose_Keyboard_Layout.Items.Add($data.innerxml)	| out-null	
			}					
	}	
	
$Choose_Keyboard_Layout.add_SelectionChanged({
	$Global:My_Keyboard_Layout = $Choose_Keyboard_Layout.SelectedItem
	foreach ($data in $my_LanguageUI_xml.selectNodes("LanguageUI/KeyboardLocale/option"))			
		{
			If ($My_Keyboard_Layout -eq $data.innerxml)
				{
					$Global:My_Keyboard = $data.value	
				}
		}		
})			
		
		
	
#************************************************************************** Populate the OS Language ListBox ***********************************************************************************************
Function Populate_OSLanguage
		{
			$Lang_Packages = "$deploymentshare\Control\Packages.xml"						
			$my_Language_xml = [xml] (Get-Content $Lang_Packages)	
			$Global:MUI_packages = $my_Language_xml.packages.package | Where {$_.PackageType -match "LanguagePack"}			
			foreach ($data in $MUI_packages)						
				{
					$Choose_OSLanguage.Items.Add($data.Language)	| out-null						
				}					
		}
$Choose_OSLanguage.add_SelectionChanged({
	$Global:MY_OSLanguage = $Choose_OSLanguage.SelectedItem
	foreach ($data in $MUI_packages)		
		{
			If ($MY_OSLanguage -eq $data.Language)
				{
					$Global:My_Language_Pack_GUID = $data.guid	
					$Global:My_Language_Pack_Language = $data.language													
				}
		}			
})


#************************************************************************** Populate the second OS Language ListBox ***********************************************************************************************
Function Populate_Second_OSLanguage
		{
			$Lang_Packages = "$deploymentshare\Control\Packages.xml"						
			$my_Language_xml = [xml] (Get-Content $Lang_Packages)	
			$Global:MUI_packages = $my_Language_xml.packages.package | Where {$_.PackageType -match "LanguagePack"}			
			foreach ($data in $MUI_packages)						
				{
					$Choose_second_OSLanguage.Items.Add($data.Language)	| out-null	
				}					
		}
$Choose_second_OSLanguage.add_SelectionChanged({
	$Global:MY_Second_OSLanguage = $Choose_second_OSLanguage.SelectedItem
	foreach ($data in $MUI_packages)		
		{
			If ($MY_Second_OSLanguage -eq $data.Language)
				{
					$Global:My_Second_Language_Pack_GUID = $data.guid	
					$Global:My_Second_Language_Pack_Language = $data.language						
				}
		}			
})

#************************************************************************** Populate the TimeZone ListBox ***********************************************************************************************
Function Populate_TimeZone
	{		
		$LanguageUI = "MDT_LanguageUI.xml"										
		$Global:my_LanguageUI_xml = [xml] (Get-Content $LanguageUI)	
		foreach ($data in $my_LanguageUI_xml.selectNodes("LanguageUI/TimeZone/option"))				
			{
				$Choose_Timezone.Items.Add($data.innerxml)	| out-null	
			}					
	}	
	
$Choose_Timezone.add_SelectionChanged({
	$Global:My_Selected_TimeZone = $Choose_Timezone.SelectedItem
	foreach ($data in $my_LanguageUI_xml.selectNodes("LanguageUI/TimeZone/option"))				
		{
			If ($My_Selected_TimeZone -eq $data.innerxml)
				{
					$Global:My_Timezone = $data.value	
				}
		}		
})	
			
			
#************************************************************************** Populate the TaskSequence ListBox ***********************************************************************************************
Function Populate_TaskSequence
	{		
		$TS_xml = "$deploymentshare\Control\TaskSequences.xml"
		$Global:my_TS_xml = [xml] (Get-Content $TS_xml)	
		foreach ($data in $my_TS_xml.selectNodes("tss/ts"))
			{
				$Choose_TS.Items.Add($data.name)	| out-null	
			}					
	}	
	
$Choose_TS.add_SelectionChanged({
    $Global:My_Selected_TS = $Choose_TS.SelectedItem
	foreach ($data in $my_TS_xml.selectNodes("tss/ts"))
		{
			If ($My_Selected_TS -eq $data.name)
				{
					$Global:My_TaskSequence = $data.ID	
				}
		}		
})		
	

#************************************************************************** Populate the Applications DataGrid ***********************************************************************************************
Function Populate_Applis_Datagrid
	{
		$Global:list_applis = ""
		$Global:Input_Applications = ""
					
		$Global:list_applis = "$deploymentshare\Control\Applications.xml"						
		$Input_Applications = [xml] (Get-Content $list_applis)			
		foreach ($data in $Input_Applications.selectNodes("applications/application"))
			{
				$Applis_values = New-Object PSObject
				$Applis_values = $Applis_values | Add-Member NoteProperty Appli_Name $data.Name –passthru
				$Applis_values = $Applis_values | Add-Member NoteProperty Appli_GUID $data.GUID –passthru				
				$DataGrid_Applis.Items.Add($Applis_values) > $null
			}			
	}
	
	
#************************************************************************** Populate the GPO Pack ListBox ***********************************************************************************************
Function Populate_GPOPack
	{
		$Global:GPOPacks_Folder = "$deploymentshare\Templates\GPOPacks"	
		$Global:List_GPOPack_Folder = Get-ChildItem $GPOPacks_Folder | where {$_.Attributes -eq 'Directory'}
		foreach ($GPOPack in $List_GPOPack_Folder)
			{
				$GPO_Pack_path.Items.Add($GPOPack)	| out-null	
			}
			
		$GPO_Pack_path.add_SelectionChanged({
			$Global:My_Selected_GPOPack = $GPO_Pack_path.SelectedItem		
			write-host $My_Selected_GPOPack						
		})			
		
	}		






########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
# 																		SCRIPT INITIALIZATION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################
	
Populate_TimeZone 			# Run the Populate_TimeZone Function
Populate_KeyBoard 			# Run the Populate_KeyBoard Function
Populate_OSLanguage 		# Run the Populate_OSLanguage Function
Populate_Second_OSLanguage  # Run the Populate_Second_OSLanguage Function
Populate_TaskSequence		# Run the Populate_TaskSequence Function
Populate_Applis_Datagrid 	# Run the Populate_Applis_Datagrid Function
Populate_GPOPack      		# Run the Populate_GPOPack Function

$Global:OSDProfile_Name = $Profile_Name.Text.ToString()

If ($deploymentshare -eq "")
	{
		$Profile_Path_Info.Content = "Select a path for your profile file"
		$Profile_Path_Info.Foreground = "red"		
		
		$OS_Language_Info.Content = "No Deployment Share. This field can't be populated."
		$OS_Language_Info.Foreground = "red"	
		
		$Second_OS_Language_Info.Content = "No Deployment Share. This field can't be populated."
		$Second_OS_Language_Info.Foreground = "red"			
		
		$Choose_TS_Info.Content = "No Deployment Share. This field can't be populated."
		$Choose_TS_Info.Foreground = "red"			
		
		$GPO_Pack_Info.Content = "No Deployment Share. This field can't be populated."
		$GPO_Pack_Info.Foreground = "red"		
	}
Else
	{
		$Global:Profile_Location = "Deploymentshare"
		$Profile_Path_Info.Content = "It'll be saved by default in your deploymentshare"
		$Second_OS_Language_Info.Content = "Second language to apply to your OS"
		$GPO_Pack_Info.Content = "List GPO Packs found in the templates folder."
		
	}
	
	
	
	
	

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
# 																		BUTTONS ACTIONS 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################


#************************************************************************** Profile path Button ***********************************************************************************************	
$Profile_Path.Add_Click({	
    $folder = $object.BrowseForFolder(0, $message, 0, 0) 
    If ($folder -ne $null) 
		{ 		
			$global:Profile_Folder = $folder.self.Path 
			$Profile_Path_TextBox.Text =  $Profile_Folder		
			$Profile_Path_Info.Content = "Profile will be saved in $Profile_Folder"
			$Profile_Path_Info.Foreground = "black"			
			$Global:Profile_Location = "Choose"			
		}
})	



#************************************************************************** Choose Deployment type Button ***********************************************************************************************	
$Deployment_Type.Add_SelectionChanged({	
	If ($Deployment_Type_NoSet.IsSelected -eq $true)
		{
			$computerbackup_location_label.Content = "Capture"	
			$UserDataLocation_Label.Content = "Move and Restore User Data"	

			# Part for Capture or Computer Backup
			$Capture_computer.Visibility = "Visible"
			$Capture_Location.Visibility = "Visible"
			$Capture_Name.Visibility = "Visible"
			$Capture_User_Name.Visibility = "Visible"
			$Capture_User_Password.Visibility = "Visible"
			$Capture_User_Domain.Visibility = "Visible"
			$Computer_Backup_type.Visibility = "Collapsed"
			$Computer_Backup_Location.Visibility = "Collapsed"	
			
			# Part for Move and restore user data
			$user_data_backup_type.Visibility = "Collapsed"
			$Backup_Location.Visibility = "Collapsed"
			$move_userdata.Visibility = "Visible"
			$restore_user_data.Visibility = "Visible"
			$Restore_Location.Visibility = "Visible"	
		}
	ElseIf ($Deployment_Type_Newcomputer.IsSelected -eq $true)
		{
			$computerbackup_location_label.Content = "Capture"	
			$UserDataLocation_Label.Content = "Move and Restore User Data"	

			# Part for Capture or Computer Backup
			$Capture_computer.Visibility = "Visible"
			$Capture_Location.Visibility = "Visible"
			$Capture_Name.Visibility = "Visible"
			$Capture_User_Name.Visibility = "Visible"
			$Capture_User_Password.Visibility = "Visible"
			$Capture_User_Domain.Visibility = "Visible"
			$Computer_Backup_type.Visibility = "Collapsed"
			$Computer_Backup_Location.Visibility = "Collapsed"				
			
			# Part for Move and restore user data
			$user_data_backup_type.Visibility = "Collapsed"
			$Backup_Location.Visibility = "Collapsed"
			$move_userdata.Visibility = "Visible"
			$restore_user_data.Visibility = "Visible"
			$Restore_Location.Visibility = "Visible"	
		}	
	ElseIf ($Deployment_Type_Refresh.IsSelected -eq $true)
		{
			$computerbackup_location_label.Content = "Computer backup"	
			$computerbackup_location_label.ToolTip = "Specify where to save a complete computer backup"					
			$UserDataLocation_Label.Content = "User Data"
			$UserDataLocation_Label.ToolTip = "Specify where to save your data and settings"
			
			# Part for Capture or Computer Backup
			$Capture_computer.Visibility = "Collapsed"
			$Capture_Location.Visibility = "Collapsed"
			$Capture_Name.Visibility = "Collapsed"
			$Capture_User_Name.Visibility = "Collapsed"
			$Capture_User_Password.Visibility = "Collapsed"
			$Capture_User_Domain.Visibility = "Collapsed"		
			$Computer_Backup_type.Visibility = "Visible"
			$Computer_Backup_Location.Visibility = "Visible"	
			
			# Part for Move and restore user data			
			$user_data_backup_type.Visibility = "Visible"
			$Backup_Location.Visibility = "Visible"
			$move_userdata.Visibility = "Collapsed"
			$restore_user_data.Visibility = "Collapsed"
			$Restore_Location.Visibility = "Collapsed"
		}	
})	



#************************************************************************** Choose Domain/Workgroup Combo ***********************************************************************************************	

$Choose_Domain_WKG.Add_SelectionChanged({	

    If ($Mode_Workgroup.IsSelected -eq $true) 
		{					
			$Domain_Block.Visibility = "Collapsed"
			$UserName.IsEnabled = $false 
			$Domain_Admin_Pwd.IsEnabled = $false 	
			$OU_name.IsEnabled = $false 	
			$Domaine_Wkg_Label.Content = "Workgroup name"					
		} 
	Else 
		{	
			$Domain_Block.Visibility = "Visible"
			$UserName.IsEnabled = $true 
			$Domain_Admin_Pwd.IsEnabled = $true 	
			$OU_name.IsEnabled = $true 	
			$Domaine_Wkg_Label.Content = "Domain name"				
		}
})	


#************************************************************************** Choose Network type Button ***********************************************************************************************		
$Choose_Network.Add_SelectionChanged({	
	If ($Choose_DHCP.IsSelected -eq $True)		
		{			
			$IPAddress.IsEnabled = $false 
			$Gateway.IsEnabled = $false 
			$SubnetMask.IsEnabled = $false 
			$DNS_Server.IsEnabled = $false 				
			$Network_Block.Visibility = "Collapsed"
		}
	Else
		{
			$IPAddress.IsEnabled = $true 
			$Gateway.IsEnabled = $true 
			$SubnetMask.IsEnabled = $true 
			$DNS_Server.IsEnabled = $true 							
			$Network_Block.Visibility = "Visible"			
		}	
})	
	
#************************************************************************** Do capture Button ***********************************************************************************************	
$Combo_Capture_Computer.Add_SelectionChanged({	
	If ($capture_computer_no.IsSelected -eq $true)
		{
			$Capture_backup_location_textbox.IsEnabled = $false 	
			$Capture_file_name.IsEnabled = $false 		
			$Combo_Backup_Type.IsEnabled = $false 		
			$Capture_location_user.IsEnabled = $false 	
			$Capture_location_password.IsEnabled = $false 	
			$Capture_location_domain.IsEnabled = $false 				
		}		
	ElseIf ($capture_computer_yes.IsSelected -eq $true)
		{
			$Capture_backup_location_textbox.IsEnabled = $true 	
			$Capture_file_name.IsEnabled = $true 		
			$Combo_Backup_Type.IsEnabled = $true 	
			$Capture_location_user.IsEnabled = $true 	
			$Capture_location_password.IsEnabled = $true 	
			$Capture_location_domain.IsEnabled = $true 			
		}		
	ElseIf ($sysprep_this_computer.IsSelected -eq $true)
		{
			$Capture_backup_location_textbox.IsEnabled = $false 	
			$Capture_file_name.IsEnabled = $false 		
			$Combo_Backup_Type.IsEnabled = $false 		
			$Capture_location_user.IsEnabled = $false 	
			$Capture_location_password.IsEnabled = $false 	
			$Capture_location_domain.IsEnabled = $false 	
		}	
	ElseIf ($prepare_to_capture.IsSelected -eq $true)
		{
			$Capture_backup_location_textbox.IsEnabled = $false 	
			$Capture_file_name.IsEnabled = $false 		
			$Combo_Backup_Type.IsEnabled = $false 		
			$Capture_location_user.IsEnabled = $false 	
			$Capture_location_password.IsEnabled = $false 	
			$Capture_location_domain.IsEnabled = $false 		
		}	
})	




#************************************************************************** Move and restore user data Buttons ***********************************************************************************************	
$move_data_yes.Add_Click({
	$Not_Format.Visibility = "Visible"
})

$move_data_no.Add_Click({
	$Not_Format.Visibility = "Collapsed"
})


$Combo_restore_UserData.Add_SelectionChanged({	
	If ($restore_user_data_no.IsSelected -eq $True)		
		{			
			$UserData_restore_location_textbox.IsEnabled = $false 
		}
	ElseIf ($restore_user_data_specify_location.IsSelected -eq $True)	
		{
			$UserData_restore_location_textbox.IsEnabled = $true 		
		}	
})		

#************************************************************************** Skip all wizards Button ***********************************************************************************************	
	
$Skip_All.Add_Click({
    If ($Skip_All.IsChecked -eq $true) 
		{
			$Skip_All.Content = "Unskip all wizards"

			$Skip_TS.IsChecked = $True
			$Skip_ProductKey.IsChecked = $True  
			$Skip_move_user_data.IsChecked = $True    
			$Skip_restore_UserData.IsChecked = $True   
			$Skip_DomainMemberShip.IsChecked = $True  
			
			$Skip_AdminPWD.IsChecked = $True   
			$Skip_Applications.IsChecked = $True    
			$Skip_Capture.IsChecked = $True   
			$Skip_Bitlocker.IsChecked = $True  
			$Skip_Computer_name.IsChecked = $True  
			
			$Skip_Locale_time.IsChecked = $True   
			$Skip_Language_packs.IsChecked = $True   
			$Skip_Summary.IsChecked = $True  
			$Skip_Final_Summary.IsChecked = $True   
		} 
	Else 
		{
			$Skip_All.Content = "Skip all wizards"
			
			$Skip_TS.IsChecked = $False
			$Skip_ProductKey.IsChecked = $False  
			$Skip_move_user_data.IsChecked = $False    
			$Skip_restore_UserData.IsChecked = $False   
			$Skip_DomainMemberShip.IsChecked = $False  
			
			$Skip_AdminPWD.IsChecked = $False   
			$Skip_Applications.IsChecked = $False    
			$Skip_Capture.IsChecked = $False   
			$Skip_Bitlocker.IsChecked = $False  
			$Skip_Computer_name.IsChecked = $False  
			
			$Skip_Locale_time.IsChecked = $False   
			$Skip_Language_packs.IsChecked = $False   
			$Skip_Summary.IsChecked = $False  
			$Skip_Final_Summary.IsChecked = $False  
		}
})		
	
	
$Skip_TS.Add_Click({
    If ($Skip_TS.IsChecked -eq $true) 
		{
			$Image_Wizard.Source = ".\images\Logo_Bleu.png"
		} 
	Else 
		{
			$Image_Wizard.Source = $null
		}		
})			
	

$Skip_ProductKey.Add_Click({
		
    If ($Skip_ProductKey.IsChecked -eq $true) 
		{
			$Image_Wizard.Source = ".\images\Logo_RVB.png"
		} 
	Else 
		{
			$Image_Wizard.Source = $null
		}		
})				
	

	
#************************************************************************** Other part Button ***********************************************************************************************	
	
$Product_Key.Add_SelectionChanged({	
    If ($No_Product_Key.IsSelected -eq $true) 
		{					
			$Product_Key_Block.Visibility = "Collapsed"			
		} 
	ElseIf ($Activate_MAK.IsSelected -eq $true)  
		{	
			$Key_Label_TextBox.Text = "Multiple Activation Key"				
			$Product_Key_Block.Visibility = "Visible"		
		}
	ElseIf ($specific_product.IsSelected -eq $true)  
		{	
			$Key_Label_TextBox.Text = "Product Key"				
			$Product_Key_Block.Visibility = "Visible"				
		}		
})		

	
	

#************************************************************************** About Button ***********************************************************************************************	
$about.Add_Click({	
	powershell "$Current_Folder\About.ps1" 
})		
	
#************************************************************************** Clear Button ***********************************************************************************************	
$Clear_All_Button.Add_Click({	
	$Profile_Name.Text = ""
	$Profile_Path_TextBox.Text = ""
	$Computer_Name.Text = ""
	$Local_Admin_PWD.Text = ""
	$Domaine_Wkg_txtbox.Text = ""
	$OU_name.Text = ""
	$UserName.Text = ""
	$Domain_Admin_Pwd.Text = ""
	$IPAddress.Text = ""
	$Gateway.Text = ""
	$SubnetMask.Text = ""
	$Org_name.Text = ""
	$DNS_Server.Text = ""
	$IE_home_page.Text = ""
	$Capture_file_name.Text = ""
	$Capture_backup_location_textbox.Text = ""
	$UserData_restore_location_textbox.Text = ""
	$restore_user_data_no.IsSelected = $true
	$Capture_no.IsSelected = $true
	
	$UserName.IsEnabled = $false 
	$Capture_backup_location_textbox.IsEnabled = $false 	
	$Capture_file_name.IsEnabled = $false 		
	
	$Skip_All.IsSelected = $false
	$Skip_TS.IsSelected = $false
	$Skip_ProductKey.IsCkecked = $false
	$Skip_move_user_data.IsCkecked = $false
	$Skip_DomainMemberShip.IsCkecked = $false
	$Skip_restore_UserData.IsCkecked = $false
	$Skip_AdminPWD.IsCkecked = $false
	$Skip_Applications.IsCkecked = $false
	$Skip_Capture.IsCkecked = $false
	$Skip_Bitlocker.IsCkecked = $false
	$Skip_Summary.IsCkecked = $false
	$Skip_Locale_time.IsCkecked = $false
	$Skip_Language_packs.IsCkecked = $false
	$Skip_Computer_name.IsCkecked = $false	
})

	
	
	
	


















#************************************************************************** TABCONTROLS ACTIONS ***************************************************************************************	

# $TabMenuHamburger.add_ItemClick({  
   # $TabMenuHamburger.Content = $TabMenuHamburger.SelectedItem
   # $TabMenuHamburger.IsPaneOpen = $false
# })	
	
$Global:Launch_mode = "Details"	
	
$TabMenuHamburger.add_ItemClick({  
   $TabMenuHamburger.Content = $TabMenuHamburger.SelectedItem
   $TabMenuHamburger.IsPaneOpen = $false	
	
	If ($DeploymentShare_Textbox.Text -ne "")
		{
			If ($TabMenuHamburger.SelectedItem.Label -eq "Details")
				{
					$Global:Launch_mode = "Details"	
					# add-content $Log_File  "$(Get-Time) - MUI Tab is selected"	
					# add-content $Log_File  "-----------------------------------------------------------------------------------------------------------------------------------"							
				}	

			ElseIf ($TabMenuHamburger.SelectedItem.Label -eq "Domain")
				{
					$Global:Launch_mode = "Domain"		
					# add-content $Log_File  "$(Get-Time) - Applications Tab is selected"	
					# add-content $Log_File  "-----------------------------------------------------------------------------------------------------------------------------------"						
				}
			
			ElseIf ($TabMenuHamburger.SelectedItem.Label -eq "Network")
				{
					$Global:Launch_mode = "Network"
					# add-content $Log_File  "$(Get-Time) - Security Tab is selected"	
					# add-content $Log_File  "-----------------------------------------------------------------------------------------------------------------------------------"						
				}			

			ElseIf ($TabMenuHamburger.SelectedItem.Label -eq "Backup")
				{
					$Global:Launch_mode = "Backup"
					# add-content $Log_File  "$(Get-Time) - Profiles Tab is selected"		
					# add-content $Log_File  "-----------------------------------------------------------------------------------------------------------------------------------"						
				}			
				
			ElseIf ($TabMenuHamburger.SelectedItem.Label -eq "Wizard")
				{
					$Global:Launch_mode = "Wizard"
					# add-content $Log_File  "$(Get-Time) - Preautoconf Tab is selected"		
					# add-content $Log_File  "-----------------------------------------------------------------------------------------------------------------------------------"						
				}		
				
			ElseIf ($TabMenuHamburger.SelectedItem.Label -eq "Applications")
				{
					$Global:Launch_mode = "Applications"
					# add-content $Log_File  "$(Get-Time) - WIS Tab is selected"		
					# add-content $Log_File  "-----------------------------------------------------------------------------------------------------------------------------------"						
				}	

			ElseIf ($TabMenuHamburger.SelectedItem.Label -eq "Others")
				{
					$Global:Launch_mode = "Others"
					# add-content $Log_File  "$(Get-Time) - WIS Tab is selected"		
					# add-content $Log_File  "-----------------------------------------------------------------------------------------------------------------------------------"						
				}				
				
				
		}
})		
		
		
	








$Load_Profile.Add_Click({	

	$OpenFileDialog1 = New-Object System.Windows.Forms.OpenFileDialog
	$openfiledialog1.Filter = "INI File (.ini)|*.ini;"
	$openfiledialog1.title = "Select the INI file to upload"	
	$openfiledialog1.ShowHelp = $True	
	$OpenFileDialog1.initialDirectory = [Environment]::GetFolderPath("Desktop")
	$OpenFileDialog1.ShowDialog() | Out-Null	
	$Profile_Path_TextBox.Text = $OpenFileDialog1.filename		
	$Global:INI_File_Path = $OpenFileDialog1.filename	
	$global:INI_Name = split-path $openfiledialog1.FileName -leaf -resolve	
	$Profile_Name.Text = $INI_Name	
	# $Profile_Name.Text = "Customsettings_MDT.ini" 

	
	# Get values from the Details TAB
	
	# TaskSequenceID variable 
	$Global:TaskSequenceID_Variable = 'TaskSequenceID='
	# Search TaskSequenceID variable in bootstrap.ini		
	$Global:Search_TSID_String = select-string $INI_File_Path -Pattern $TaskSequenceID_Variable 
	# Get the TaskSequenceID value
	$Global:Search_TSID_Value = $Search_TSID_String.Line
	# Get the KeyboardLocalePE Line number
	$Global:TSID_LineNumber = $Search_TSID_String.Linenumber	
	# Separate the KeyboardLocalePE Line number		
	$Global:TSID_split_Separator = $Search_TSID_Value.split('=')
	$Global:TSID_Value = $TSID_split_Separator[1]
	
	# Select the appropriate TS in the Combobox depeding of the TS value in the INI file
	$TS_xml = "$deploymentshare\Control\TaskSequences.xml"
	$Global:my_TS_xml = [xml] (Get-Content $TS_xml)	
	Foreach($toto in $Choose_TS.Items)
		{
			foreach ($data in $my_TS_xml.selectNodes("tss/ts"))			
				{
			
					$ID = $data.id
					$name = $data.name
					if ($TSID_Value -eq $ID)
						{
							$Choose_TS.Text = $name
							$selected_item = $Choose_TS.SelectedIndex
							# [System.Windows.Forms.MessageBox]::Show("$selected_item") 								
						}
				}
			break				
		}	
	
	
	# Populate the First OS Language ComboBox
	# LanguagePacks1 variable 
	$Global:LanguagePacks1_Variable = 'LanguagePacks1='
	# Search LanguagePacks1 variable in bootstrap.ini		
	$Global:Search_LanguagePacks1_String = select-string $INI_File_Path -Pattern $LanguagePacks1_Variable 
	# Get the LanguagePacks1 value
	$Global:Search_LanguagePacks1_Value = $Search_LanguagePacks1_String.Line
	# Get the LanguagePacks1 Line number
	$Global:LanguagePacks1_LineNumber = $Search_LanguagePacks1_String.Linenumber	
	# Separate the LanguagePacks1 Line number		
	$Global:LanguagePacks1_split_Separator = $Search_LanguagePacks1_Value.split('=')
	$Global:LanguagePacks1_Value = $LanguagePacks1_split_Separator[1]					
					
	# Select the appropriate TS in the Combobox depeding of the TS value in the INI file	
	$Lang_Packages = "$deploymentshare\Control\Packages.xml"						
	$my_Language_xml = [xml] (Get-Content $Lang_Packages)	
	Foreach($toto in $Choose_OSLanguage.Items)
		{
			foreach ($data in $my_Language_xml.packages.package | Where {$_.PackageType -match "LanguagePack"})				
				{
			
					$GUID = $data.guid
					$Lang = $data.language
					if ($LanguagePacks1_Value -eq $GUID)
						{
							$Choose_OSLanguage.Text = $Lang
							$selected_item = $Choose_OSLanguage.SelectedIndex
							# [System.Windows.Forms.MessageBox]::Show("$selected_item") 								
						}
				}
			break				
		}		
		
		
	# Populate the First OS Language ComboBox
	# LanguagePacks2 variable 
	$Global:LanguagePacks2_Variable = 'LanguagePacks2='
	# Search LanguagePacks2 variable in bootstrap.ini		
	$Global:Search_LanguagePacks2_String = select-string $INI_File_Path -Pattern $LanguagePacks2_Variable 
	# Get the LanguagePacks2 value
	$Global:Search_LanguagePacks2_Value = $Search_LanguagePacks2_String.Line
	# Get the LanguagePacks2 Line number
	$Global:LanguagePacks1_LineNumber = $Search_LanguagePacks2_String.Linenumber	
	
	If ($LanguagePacks1_LineNumber -eq $null)
		{
			$Second_language_none.IsSelected = $True
		}
	Else
		{			
			$Global:LanguagePacks2_split_Separator = $Search_LanguagePacks2_Value.split('=')
			$Global:LanguagePacks2_Value = $LanguagePacks2_split_Separator[1]	
			
			# Select the appropriate TS in the Combobox depeding of the TS value in the INI file	
			$Lang_Packages = "$deploymentshare\Control\Packages.xml"						
			$my_Language_xml = [xml] (Get-Content $Lang_Packages)	
			Foreach($toto in $Choose_second_OSLanguage.Items)
				{
					foreach ($data in $my_Language_xml.packages.package | Where {$_.PackageType -match "LanguagePack"})				
						{			
							$GUID = $data.guid
							$Lang = $data.language
							if ($LanguagePacks2_Value -eq $GUID)
								{
									$Choose_second_OSLanguage.Text = $Lang
									$selected_item = $Choose_second_OSLanguage.SelectedIndex
								}
						}
					break				
				}						
		}

		
	# Populate the TimeZone ComboBox
	# TimeZoneName variable 
	$Global:TimeZoneName_Variable = 'TimeZoneName='
	# Search TimeZoneName variable in bootstrap.ini		
	$Global:Search_TimeZoneName_String = select-string $INI_File_Path -Pattern $TimeZoneName_Variable 
	# Get the TimeZoneName value
	$Global:Search_TimeZoneName_Value = $Search_TimeZoneName_String.Line
	# Get the TimeZoneName Line number
	$Global:TimeZoneName_LineNumber = $Search_TimeZoneName_String.Linenumber	
	
	If ($TimeZoneName_LineNumber -ne $null)
		{
			$Global:TimeZoneName_split_Separator = $Search_TimeZoneName_Value.split('=')
			$Global:TimeZoneName_Value = $TimeZoneName_split_Separator[1]	
						
			# Select the appropriate TS in the Combobox depeding of the TS value in the INI file	
			$LanguageUI = "MDT_LanguageUI.xml"										
			$my_Language_xml = [xml] (Get-Content $LanguageUI)	
			Foreach($toto in $Choose_Timezone.Items)
				{
					ForEach ($data in $my_LanguageUI_xml.selectNodes("LanguageUI/TimeZone/option"))				
						{			
							$Value = $data.value
							$Name = $data.innerxml
							if ($TimeZoneName_Value -eq $Value)
								{
									$Choose_Timezone.Text = $Name
									$selected_item = $Choose_Timezone.SelectedIndex
								}
						}
					break				
				}						
		}
	


	# Populate the Keyboard layout ComboBox
	# KeyboardLocale variable 
	$Global:KeyboardLocale_Variable = 'KeyboardLocale='
	# Search KeyboardLocale variable in bootstrap.ini		
	$Global:Search_KeyboardLocale_String = select-string $INI_File_Path -Pattern $KeyboardLocale_Variable 
	# Get the KeyboardLocale value
	$Global:Search_KeyboardLocale_Value = $Search_KeyboardLocale_String.Line
	# Get the KeyboardLocale Line number
	$Global:KeyboardLocale_LineNumber = $Search_KeyboardLocale_String.Linenumber	
	
	If ($KeyboardLocale_LineNumber -ne $null)
		{
			$Global:KeyboardLocale_split_Separator = $Search_KeyboardLocale_Value.split('=')
			$Global:KeyboardLocale_Value = $KeyboardLocale_split_Separator[1]	
						
			# Select the appropriate TS in the Combobox depeding of the TS value in the INI file	
			$LanguageUI = "MDT_LanguageUI.xml"										
			$my_Language_xml = [xml] (Get-Content $LanguageUI)	
			Foreach($toto in $Choose_Keyboard_Layout.Items)
				{
					ForEach ($data in $my_LanguageUI_xml.selectNodes("LanguageUI/KeyboardLocale/option"))								
						{			
							$Value = $data.value
							$Name = $data.innerxml
							if ($KeyboardLocale_Value -eq $Value)
								{
									$Choose_Keyboard_Layout.Text = $Name
									$selected_item = $Choose_Keyboard_Layout.SelectedIndex
								}
						}
					break				
				}						
		}
		
		
		
	# Populate the Deployment type ComboBox
	# DeploymentType variable 
	$Global:DeploymentType_Variable = 'DeploymentType='
	# Search DeploymentType variable in bootstrap.ini		
	$Global:Search_DeploymentType_String = select-string $INI_File_Path -Pattern $DeploymentType_Variable 
	# Get the DeploymentType value
	$Global:Search_DeploymentType_Value = $Search_DeploymentType_String.Line
	# Get the DeploymentType Line number
	$Global:DeploymentType_LineNumber = $Search_DeploymentType_String.Linenumber	
	
	If ($DeploymentType_LineNumber -ne $null)
		{
			$Global:DeploymentType_split_Separator = $Search_DeploymentType_Value.split('=')
			$Global:DeploymentType_Value = $DeploymentType_split_Separator[1]	
						
			If ($DeploymentType_Value -eq "NEWCOMPUTER")
				{
					$Deployment_Type_Newcomputer.IsSelected = $True
				}
			ElseIf ($DeploymentType_Value -eq "REFRESH")
				{
					$Deployment_Type_Refresh.IsSelected = $True
				}				
		}	
	Else
		{
			$Deployment_Type_NoSet.IsSelected = $True		
		}
		
	
	
	
	# GET VALUES FROM THE DOMAIN TAB
	# Value strings to search
	
	# Get Organisation name from the INI file
	$Global:OrgName_Variable = '_SMSTSORGNAME='
	# Search Org name variable 		
	$Global:Search_OrgName_String = select-string $INI_File_Path -Pattern $OrgName_Variable 
	# Get the Orgname value
	$Global:Get_OrgName_Line = $Search_OrgName_String.Line
	# Get the Orgname Line number
	$Global:Orgname_LineNumber = $Search_OrgName_String.Linenumber

	If ($Orgname_LineNumber -ne $null)
		{
			# Separate the Orgname Line number		
			$Global:OrgName_split_Separator = $Get_OrgName_Line.split('=')
			$Global:OrgName_Value = $OrgName_split_Separator[1]
			# Populate the OrName TextBox with value from the INI file
			$Org_name.Text = $OrgName_Value		
		}

	
	# Get Computer name from the INI file
	$Global:ComputerName_Variable = 'OSDComputername='
	# Search Computer name variable 		
	$Global:Search_ComputerName_String = select-string $INI_File_Path -Pattern $ComputerName_Variable 
	# Get the Computer name value
	$Global:Get_ComputerName_Line = $Search_ComputerName_String.Line
	# Separate the Computer name 	
	$Global:ComputerName_split_Separator = $Get_ComputerName_Line.split('=')
	$Global:ComputerName_Value = $ComputerName_split_Separator[1]
	# Populate the Computer name TextBox with value from the INI file
	$Computer_Name.Text = $ComputerName_Value	
	
	# Get Admin password from the INI file
	$Global:AdminPassword_Variable = 'AdminPassword='
	# Search Admin password variable 		
	$Global:Search_AdminPassword_String = select-string $INI_File_Path -Pattern $AdminPassword_Variable 
	# Get the admin password value
	$Global:Get_AdminPassword_Line = $Search_AdminPassword_String.Line
	# Separate the admin password	
	$Global:AdminPassword_split_Separator = $Get_AdminPassword_Line.split('=')
	$Global:AdminPassword_Value = $AdminPassword_split_Separator[1]
	# Populate the local admin password TextBox with value from the INI file
	$Local_Admin_PWD.Text = $AdminPassword_Value	

	# Get workgroup name from the INI file
	$Global:JoinWorkgroup_Variable = 'JoinWorkGroup='
	# Search workgroup name variable 		
	$Global:Search_JoinWorkgroup_String = select-string $INI_File_Path -Pattern $JoinWorkgroup_Variable 
	# Get the workgroup name value
	$Global:Get_JoinWorkgroup_Line = $Search_JoinWorkgroup_String.Line
	# Get the workgroup name Line number
	$Global:Get_JoinWorkgroup_LineNumber = $Search_JoinWorkgroup_String.Linenumber	

	If ($Get_JoinWorkgroup_Line -like "*JoinWorkGroup*")
		{
			$Mode_Workgroup.IsSelected = $True
		
			# Separate the workgroup name
			$Global:JoinWorkgroup_split_Separator = $Get_JoinWorkgroup_Line.split('=')
			$Global:JoinWorkgroup_Value = $JoinWorkgroup_split_Separator[1]
			# Populate the lworkgroup name TextBox with value from the INI file
			$Domaine_Wkg_txtbox.Text = $JoinWorkgroup_Value		
		}


	# Get Domain name from the INI file
	$Global:JoinDomain_Variable = 'JoinDomain='
	# Search workgroup name variable 		
	$Global:Search_JoinDomain_String = select-string $INI_File_Path -Pattern $JoinDomain_Variable 
	# Get the admin password value
	$Global:Get_JoinDomain_Line = $Search_JoinDomain_String.Line
	# Get the admin password Line number
	$Global:Get_JoinDomain_LineNumber = $Search_JoinDomain_String.Linenumber	
	
	# If ($Get_JoinDomain_LineNumber -ne "0")
	If ($Get_JoinDomain_Line -like "*JoinDomain*")
	
		{	
			$Mode_Domain.IsSelected = $True		
		
			# Separate the admin password	
			$Global:JoinDomain_split_Separator = $Get_JoinDomain_Line.split('=')
			$Global:JoinDomain_Value = $JoinDomain_split_Separator[1]
			# Populate the local admin password TextBox with value from the INI file
			$Domaine_Wkg_txtbox.Text = $JoinDomain_Value	
	
			# Get OU path from the INI file
			$Global:MachineObjectOU_Variable = 'MachineObjectOU='
			# Search OU path variable 		
			$Global:Search_MachineObjectOU_String = select-string $INI_File_Path -Pattern $MachineObjectOU_Variable 
			# Get the OU path value
			$Global:Get_MachineObjectOU_Line = $Search_MachineObjectOU_String.Line
			# Get the OU Path Line number
			$Global:Get_MachineObjectOU_LineNumber = $Search_JoinDomain_String.Linenumber	
			# Separate the OU path	
			$Global:MachineObjectOU_split_Separator = $Get_MachineObjectOU_Line.split('=')
			$Global:MachineObjectOU_Value = $MachineObjectOU_split_Separator[1]
			# Populate the OU path TextBox with value from the INI file
			$OU_name.Text = $MachineObjectOU_Value		
			
			# Get User admin domain from the INI file
			$Global:DomainAdmin_Variable = 'DomainAdmin='
			# Search User admin domain variable 		
			$Global:Search_DomainAdmin_String = select-string $INI_File_Path -Pattern $DomainAdmin_Variable 
			# Get the User admin domain value
			$Global:Get_DomainAdmin_Line = $Search_DomainAdmin_String.Line
			# Get the User admin domain Line number
			$Global:Get_DomainAdmin_LineNumber = $Search_DomainAdmin_String.Linenumber	
			# Separate the User admin domain	
			$Global:DomainAdmin_split_Separator = $Get_DomainAdmin_Line.split('=')
			$Global:DomainAdmin_Value = $DomainAdmin_split_Separator[1]
			# Populate the User admin domain TextBox with value from the INI file
			$UserName.Text = $DomainAdmin_Value		
			
			# Get User admin domain password from the INI file
			$Global:DomainAdminPassword_Variable = 'DomainAdminPassword='
			# Search User admin domain password variable 		
			$Global:Search_DomainAdminPassword_String = select-string $INI_File_Path -Pattern $DomainAdminPassword_Variable 
			# Get the User admin domain password value
			$Global:Get_DomainAdminPassword_Line = $Search_DomainAdminPassword_String.Line
			# Get the User admin domain password Line number
			$Global:Get_DomainAdminPassword_LineNumber = $Search_DomainAdminPassword_String.Linenumber	
			# Separate the User admin domain password	
			$Global:DomainAdminPassword_split_Separator = $Get_DomainAdminPassword_Line.split('=')
			$Global:DomainAdminPassword_Value = $DomainAdminPassword_split_Separator[1]
			# Populate the User admin domain password TextBox with value from the INI file
			$Domain_Admin_Pwd.Text = $DomainAdminPassword_Value				
		}

	
	# GET VALUES FROM THE NETWORK TAB
	# Value strings to search	
	
	# Get Enable DHCP value from the INI file
	$Global:OSDAdapter0EnableDHCP_Variable = 'OSDAdapter0EnableDHCP='
	# Search Enable DHCP value variable 		
	$Global:Search_OSDAdapter0EnableDHCP_String = select-string $INI_File_Path -Pattern $OSDAdapter0EnableDHCP_Variable 
	# Get the Enable DHCP value
	$Global:Get_OSDAdapter0EnableDHCP_Line = $Search_OSDAdapter0EnableDHCP_String.Line
	# Get the Enable DHCP value Line number
	$Global:Get_OSDAdapter0EnableDHCP_LineNumber = $Search_OSDAdapter0EnableDHCP_String.Linenumber	
	$Global:OSDAdapter0EnableDHCP_split_Separator = $Get_OSDAdapter0EnableDHCP_Line.split('=')
	$Global:OSDAdapter0EnableDHCP_Value = $OSDAdapter0EnableDHCP_split_Separator[1]
	# Populate the local admin password TextBox with value from the INI file
		
	If ($OSDAdapter0EnableDHCP_Value -eq "TRUE")
		{
			$Choose_DHCP.IsSelected = $True
			$IPAddress.Text = ""		
			$Gateway.Text = ""		
			$SubnetMask.Text = ""		
			$DNS_Server.Text = ""			
		}	
	Else
		{
			$Choose_Static.IsSelected = $True

			# Get IP address value from the INI file
			$Global:OSDAdapter0IPAddressList_Variable = 'OSDAdapter0IPAddressList='
			# Search IP address value variable 		
			$Global:Search_OSDAdapter0IPAddressList_String = select-string $INI_File_Path -Pattern $OSDAdapter0IPAddressList_Variable 
			# Get the IP address value
			$Global:Get_OSDAdapter0IPAddressList_Line = $Search_OSDAdapter0IPAddressList_String.Line
			# Get the IP address value Line number
			$Global:Get_OSDAdapter0IPAddressList_LineNumber = $Search_OSDAdapter0IPAddressList_String.Linenumber	
			# Separate the IP address value	
			$Global:OSDAdapter0IPAddressList_split_Separator = $Get_OSDAdapter0IPAddressList_Line.split('=')
			$Global:OSDAdapter0IPAddressList_Value = $OSDAdapter0IPAddressList_split_Separator[1]
			# Populate the IP address value TextBox with value from the INI file
			$IPAddress.Text = $OSDAdapter0IPAddressList_Value		
			
			# Get Gateway value from the INI file
			$Global:OSDAdapter0Gateways_Variable = 'OSDAdapter0Gateways='
			# Search Gateway value variable 		
			$Global:Search_OSDAdapter0Gateways_String = select-string $INI_File_Path -Pattern $OSDAdapter0Gateways_Variable 
			# Get the Gateway value
			$Global:Get_OSDAdapter0Gateways_Line = $Search_OSDAdapter0Gateways_String.Line
			# Get the Gateway value Line number
			$Global:Get_OSDAdapter0Gateways_LineNumber = $Search_OSDAdapter0Gateways_String.Linenumber	
			# Separate the Gateway value	
			$Global:OSDAdapter0Gateways_split_Separator = $Get_OSDAdapter0Gateways_Line.split('=')
			$Global:OSDAdapter0Gateways_Value = $OSDAdapter0Gateways_split_Separator[1]
			# Populate the Gateway value TextBox with value from the INI file
			$Gateway.Text = $OSDAdapter0Gateways_Value		
			
			# Get Subnet mask value from the INI file
			$Global:OSDAdapter0SubnetMask_Variable = 'OSDAdapter0SubnetMask='
			# Search Subnet mask value variable 		
			$Global:Search_OSDAdapter0SubnetMask_String = select-string $INI_File_Path -Pattern $OSDAdapter0SubnetMask_Variable 
			# Get the Subnet mask value
			$Global:Get_OSDAdapter0SubnetMask_Line = $Search_OSDAdapter0SubnetMask_String.Line
			# Get the Subnet mask value Line number
			$Global:Get_OSDAdapter0SubnetMask_LineNumber = $Search_OSDAdapter0SubnetMask_String.Linenumber	
			# Separate the Subnet mask value	
			$Global:OSDAdapter0SubnetMask_split_Separator = $Get_OSDAdapter0SubnetMask_Line.split('=')
			$Global:OSDAdapter0SubnetMask_Value = $OSDAdapter0SubnetMask_split_Separator[1]
			# Populate the Subnet mask value TextBox with value from the INI file
			$SubnetMask.Text = $OSDAdapter0SubnetMask_Value			

			# Get DNS value from the INI file
			$Global:OSDAdapter0DNSServerList_Variable = 'OSDAdapter0DNSServerList='
			# Search DNS value variable 		
			$Global:Search_OSDAdapter0DNSServerList_String = select-string $INI_File_Path -Pattern $OSDAdapter0DNSServerList_Variable 
			# Get the DNS value
			$Global:Get_OSDAdapter0DNSServerList_Line = $Search_OSDAdapter0DNSServerList_String.Line
			# Get the DNS value Line number
			$Global:Get_OSDAdapter0DNSServerList_LineNumber = $Search_OSDAdapter0DNSServerList_String.Linenumber	
			# Separate the DNS value	
			$Global:OSDAdapter0DNSServerList_split_Separator = $Get_OSDAdapter0DNSServerList_Line.split('=')
			$Global:OSDAdapter0DNSServerList_Value = $OSDAdapter0DNSServerList_split_Separator[1]
			# Populate the DNS value TextBox with value from the INI file
			$DNS_Server.Text = $OSDAdapter0DNSServerList_Value									
		}
		
		# Get Home page value from the INI file
		$Global:Home_Page_Variable = 'Home_Page='
		# Search Home page value variable 		
		$Global:Search_Home_Page_String = select-string $INI_File_Path -Pattern $Home_Page_Variable 
		# Get the Home page value
		$Global:Get_Home_Page_Line = $Search_Home_Page_String.Line
		# Get the Home page value Line number
		$Global:Get_Home_Page_LineNumber = $Search_Home_Page_String.Linenumber			
		If ($Get_Home_Page_LineNumber -ne $null)
			{
				# Separate the Home page value	
				$Global:Home_Page_split_Separator = $Get_Home_Page_Line.split('=')
				$Global:Home_Page_Value = $Home_Page_split_Separator[1]
				# Populate the Home page value TextBox with value from the INI file
				$IE_home_page.Text = $Home_Page_Value				
			}

			
			
	# GET VALUES FROM THE CAPTURE PART 

	# Get DoCapture from the INI file
	$Global:DoCapture_Variable = 'DoCapture='
	# Search DoCapture variable 		
	$Global:Search_DoCapture_String = select-string $INI_File_Path -Pattern $DoCapture_Variable 
	# Get the DoCapturee value
	$Global:Get_DoCapture_Line = $Search_DoCapture_String.Line
	# Get the DoCapture Line number
	$Global:Get_DoCapture_LineNumber = $Search_DoCapture_String.Linenumber	

	If ($Get_DoCapture_LineNumber -ne $null)
		{		
			# Separate the workgroup name
			$Global:DoCapture_split_Separator = $Get_DoCapture_Line.split('=')
			$Global:DoCapture_Value = $DoCapture_split_Separator[1]
			If ($DoCapture_Value -eq "YES")
				{
					$capture_computer_yes.IsSelected = $True				
				}
			ElseIf ($DoCapture_Value -eq "NO")
				{
					$capture_computer_no.IsSelected = $True								
				}
			ElseIf ($DoCapture_Value -eq "SYSPREP")
				{
					$sysprep_this_computer.IsSelected = $True								
				}
			ElseIf ($DoCapture_Value -eq "PREPARE")
				{
					$prepare_to_capture.IsSelected = $True								
				}										
		}	
	Else
		{
			$capture_computer_no.IsSelected = $True
		}
		
		
				
	# Get ComputerBackupLocation from the INI file
	$Global:ComputerBackupLocation_Variable = 'ComputerBackupLocation='
	# Search ComputerBackupLocation variable 		
	$Global:Search_ComputerBackupLocation_String = select-string $INI_File_Path -Pattern $ComputerBackupLocation_Variable 
	# Get the ComputerBackupLocation value
	$Global:Get_ComputerBackupLocation_Line = $Search_ComputerBackupLocation_String.Line
	# Get the ComputerBackupLocation Line number
	$Global:Get_ComputerBackupLocation_LineNumber = $Search_ComputerBackupLocation_String.Linenumber	

	If (($Get_ComputerBackupLocation_LineNumber -ne $null) -and ($DeploymentType_Value -eq "NEWCOMPUTER"))
		{		
			$Global:ComputerBackupLocation_split_Separator = $Get_ComputerBackupLocation_Line.split('=')
			$Global:ComputerBackupLocation_Value = $ComputerBackupLocation_split_Separator[1]
			If ($ComputerBackupLocation_Value -eq "NONE")
				{
					$capture_computer_no.IsSelected = $True
				}
			ElseIf ($ComputerBackupLocation_Value -eq "NETWORK")
				{
					$capture_computer_yes.IsSelected = $True
				}			
		}	
	ElseIf (($Get_ComputerBackupLocation_LineNumber -ne $null) -and ($DeploymentType_Value -eq "REFRESH"))
		{		
			$Global:ComputerBackupLocation_split_Separator = $Get_ComputerBackupLocation_Line.split('=')
			$Global:ComputerBackupLocation_Value = $ComputerBackupLocation_split_Separator[1]
			
			If ($ComputerBackupLocation_Value -eq "NONE")
				{
					$Backup_Computer_No.IsSelected = $True
				}
			ElseIf ($ComputerBackupLocation_Value -eq "AUTO")
				{
					$Backup_Computer_Auto.IsSelected = $True
				}					
			ElseIf (($ComputerBackupLocation_Value -ne "NETWORK") -and ($ComputerBackupLocation_Value -eq "AUTO"))
				{
					$Backup_Computer_Specify.IsSelected = $True
				}							
		}	
		
		
		
		
		
		
	# Get UserDataLocation from the INI file
	$Global:UserDataLocation_Variable = 'UserDataLocation='
	# Search UserDataLocation variable 		
	$Global:Search_UserDataLocation_String = select-string $INI_File_Path -Pattern $UserDataLocation_Variable 
	# Get the UserDataLocation value
	$Global:Get_UserDataLocation_Line = $Search_UserDataLocation_String.Line
	# Get the UserDataLocation Line number
	$Global:Get_UserDataLocation_LineNumber = $Search_UserDataLocation_String.Linenumber	

	If (($Get_UserDataLocation_LineNumber -ne $null) -and ($DeploymentType_Value -eq "NEWCOMPUTER"))
		{		
			$Global:UserDataLocation_split_Separator = $Get_UserDataLocation_Line.split('=')
			$Global:UserDataLocation_Value = $UserDataLocation_split_Separator[1]
			If ($UserDataLocation_Value -eq "NONE")
				{
					$restore_user_data_no.IsSelected = $True
				}
			ElseIf ($UserDataLocation_Value -eq "NETWORK")
				{
					$restore_user_data_specify_location.IsSelected = $True
				}
		}	
	ElseIf (($Get_UserDataLocation_LineNumber -ne $null) -and ($DeploymentType_Value -eq "REFRESH"))
		{		
			$Global:UserDataLocation_split_Separator = $Get_UserDataLocation_Line.split('=')
			$Global:UserDataLocation_Value = $UserDataLocation_split_Separator[1]
			If ($UserDataLocation_Value -eq "NONE")
				{
					$Backup_UserData_NO.IsSelected = $True
				}
			ElseIf ($UserDataLocation_Value -eq "AUTO")
				{
					$Backup_UserData_Auto.IsSelected = $True
				}
			ElseIf (($UserDataLocation_Value -ne "NONE") -and ($UserDataLocation_Value -ne "AUTO"))
				{
					$Backup_UserData_Network.IsSelected = $True
				}				
		}			
		
		
		
		
		
		
		
		
		
		
	# Get UserID from the INI file
	$Global:UserID_Variable = 'UserID='
	# Search UserID variable 		
	$Global:Search_UserID_String = select-string $INI_File_Path -Pattern $UserID_Variable 
	# Get the UserID value
	$Global:Get_UserID_Line = $Search_UserID_String.Line
	# Get the UserID Line number
	$Global:Get_UserID_LineNumber = $Search_UserID_String.Linenumber	

	If ($Get_UserID_LineNumber -ne $null)
		{		
			# Separate the workgroup name
			$Global:UserID_split_Separator = $Get_UserID_Line.split('=')
			$Global:UserID_Value = $UserID_split_Separator[1]
			$Capture_location_user.Text = $UserID_Value									
		}		


	# Get UserPassword from the INI file
	$Global:UserPassword_Variable = 'UserPassword='
	# Search UserPassword variable 		
	$Global:Search_UserPassword_String = select-string $INI_File_Path -Pattern $UserPassword_Variable 
	# Get the UserPassword value
	$Global:Get_UserPassword_Line = $Search_UserPassword_String.Line
	# Get the UserPassword Line number
	$Global:Get_UserPassword_LineNumber = $Search_UserPassword_String.Linenumber	

	If ($Get_UserPassword_LineNumber -ne $null)
		{		
			# Separate the workgroup name
			$Global:UserPassword_split_Separator = $Get_UserPassword_Line.split('=')
			$Global:UserPassword_Value = $UserPassword_split_Separator[1]
			$Capture_location_password.Text = $UserPassword_Value									
		}			
		
		
		
	# Get UserDomain from the INI file
	$Global:UserDomain_Variable = 'UserDomain='
	# Search UserDomain variable 		
	$Global:Search_UserDomain_String = select-string $INI_File_Path -Pattern $UserDomain_Variable 
	# Get the UserDomain value
	$Global:Get_UserDomain_Line = $Search_UserDomain_String.Line
	# Get the UserDomain Line number
	$Global:Get_UserDomain_LineNumber = $Search_UserDomain_String.Linenumber	

	If ($Get_UserDomain_LineNumber -ne $null)
		{		
			# Separate the workgroup name
			$Global:UserDomain_split_Separator = $Get_UserDomain_Line.split('=')
			$Global:UserDomain_Value = $UserDomain_split_Separator[1]
			$Capture_location_domain.Text = $UserDomain_Value									
		}			
			



	# Get USMTOfflineMigration from the INI file
	$Global:USMTOfflineMigration_Variable = 'USMTOfflineMigration='
	# Search USMTOfflineMigration variable 		
	$Global:Search_USMTOfflineMigration_String = select-string $INI_File_Path -Pattern $USMTOfflineMigration_Variable 
	# Get the USMTOfflineMigration value
	$Global:Get_USMTOfflineMigration_Line = $Search_USMTOfflineMigration_String.Line
	# Get the USMTOfflineMigration Line number
	$Global:Get_USMTOfflineMigration_LineNumber = $Search_USMTOfflineMigration_String.Linenumber	

	If ($Get_USMTOfflineMigration_LineNumber -ne $null)
		{		
			$Global:USMTOfflineMigration_split_Separator = $Get_USMTOfflineMigration_Line.split('=')
			$Global:USMTOfflineMigration_Value = $USMTOfflineMigration_split_Separator[1]
			If ($USMTOfflineMigration_Value -eq "True")
				{
					$move_data_yes.IsChecked = $True
				}
			Else
				{
					$move_data_no.IsChecked = $True				
				}
		}			




	# Get UserDataLocation from the INI file
	$Global:UserDataLocation_Variable = 'UserDataLocation='
	# Search UserDataLocation variable 		
	$Global:Search_UserDataLocation_String = select-string $INI_File_Path -Pattern $UserDataLocation_Variable 
	# Get the UserDataLocation value
	$Global:Get_UserDataLocation_Line = $Search_UserDataLocation_String.Line
	# Get the UserDataLocation Line number
	$Global:Get_UserDataLocation_LineNumber = $Search_UserDataLocation_String.Linenumber	

	If (($Get_UserDataLocation_LineNumber -ne $null) -and ($DeploymentType_Value -eq "NEWCOMPUTER"))
		{		
			$Global:UserDataLocation_split_Separator = $Get_UserDataLocation_Line.split('=')
			$Global:UserDataLocation_Value = $UserDataLocation_split_Separator[1]
			If ($UserDataLocation_Value -eq "NONE")
				{
					$restore_user_data_no.IsSelected = $True
				}
			ElseIf ($UserDataLocation_Value -eq "NETWORK")
				{
					$restore_user_data_specify_location.IsSelected = $True
				}
		}	
	ElseIf (($Get_UserDataLocation_LineNumber -ne $null) -and ($DeploymentType_Value -eq "REFRESH"))
		{		
			$Global:UserDataLocation_split_Separator = $Get_UserDataLocation_Line.split('=')
			$Global:UserDataLocation_Value = $UserDataLocation_split_Separator[1]
			If ($UserDataLocation_Value -eq "NONE")
				{
					$Backup_UserData_NO.IsSelected = $True
				}
			ElseIf ($UserDataLocation_Value -eq "AUTO")
				{
					$Backup_UserData_Auto.IsSelected = $True
				}
			ElseIf (($UserDataLocation_Value -ne "NONE") -and ($UserDataLocation_Value -ne "AUTO"))
				{
					$Backup_UserData_Network.IsSelected = $True
				}				
		}	
		

		
			
	# Get DoNotFormatAndPartition value from the INI file
	$Global:DoNotFormatAndPartitionVariable = 'DoNotFormatAndPartition='
	# Search DoNotFormatAndPartition value variable 		
	$Global:Search_DoNotFormatAndPartition_String = select-string $INI_File_Path -Pattern $DoNotFormatAndPartitionVariable 
	# Get the DoNotFormatAndPartition value
	$Global:Get_DoNotFormatAndPartition_Line = $Search_DoNotFormatAndPartition_String.Line
	# Get the DoNotFormatAndPartition value Line number
	$Global:Get_DDoNotFormatAndPartition_LineNumber = $Search_DoNotFormatAndPartition_String.Linenumber	

	If ($Get_DDoNotFormatAndPartition_LineNumber -ne $null)
		{		
			$Global:DoNotFormatAndPartition_split_Separator = $Get_DoNotFormatAndPartition_Line.split('=')
			$Global:DoNotFormatAndPartition_Value = $DoNotFormatAndPartition_split_Separator[1]
			If ($DoNotFormatAndPartition_Value -eq "YES")
				{
					$Keep_existing_partitions.IsChecked = $True
				}
			ElseIf ($DoNotFormatAndPartition_Value -eq "NO")
				{
					$Keep_existing_partitions.IsChecked = $False
				}
		}
	Else
		{
			$Keep_existing_partitions.IsChecked = $False
		}
		

	
	# GET VALUES FROM THE WIZARDS TAB	
	
	# Get Skip all wizard value from the INI file
	$Global:SkipWizard_Variable = 'SkipWizard='
	# Search Skip all wizard value variable 		
	$Global:Search_SkipWizard_String = select-string $INI_File_Path -Pattern $SkipWizard_Variable 
	# Get the Skip all wizard value
	$Global:Get_SkipWizard_Line = $Search_SkipWizard_String.Line
	# Get the Skip all wizard value Line number
	$Global:Get_SkipWizard_LineNumber = $Search_SkipWizard_String.Linenumber	
	$Global:SkipWizard_split_Separator = $Get_SkipWizard_Line.split('=')
	$Global:SkipWizard_Value = $SkipWizard_split_Separator[1]	
		
	If ($Get_SkipWizard_LineNumber -eq $null)
		{
			$Skip_All.IsChecked = $False		
		}	
	Else
		{
			If ($SkipWizard_Value -eq "YES")
				{
					$Skip_All.IsChecked = $True								
				}
		}	
		
		
	# Get Skip Task sequence wizard value from the INI file
	$Global:SkipTaskSequence_Variable = 'SkipTaskSequence='
	# Search Skip Task sequence wizard value variable 		
	$Global:Search_SkipTaskSequence_String = select-string $INI_File_Path -Pattern $SkipTaskSequence_Variable 
	# Get the Skip Task sequence wizard value
	$Global:Get_SkipTaskSequence_Line = $Search_SkipTaskSequence_String.Line
	# Get the Skip Task sequence wizard value Line number
	$Global:Get_SkipTaskSequence_LineNumber = $Search_SkipTaskSequence_String.Linenumber
	$Global:SkipTaskSequence_split_Separator = $Get_SkipTaskSequence_Line.split('=')
	$Global:SkipTaskSequence_Value = $SkipTaskSequence_split_Separator[1]		
	
	If ($Get_SkipTaskSequence_LineNumber -eq $null)
		{
			$Skip_TS.IsChecked = $False		
		}	
	Else
		{
			If ($SkipTaskSequence_Value -eq "YES")
				{
					$Skip_TS.IsChecked = $True				
				}
		}			
		
	
	# Get SkipProductKey wizard value from the INI file
	$Global:SkipProductKey_Variable = 'SkipProductKey='
	# Search SkipProductKey wizard value variable 		
	$Global:Search_SkipProductKey_String = select-string $INI_File_Path -Pattern $SkipProductKey_Variable 
	# Get the SkipProductKey wizard value
	$Global:Get_SkipProductKey_Line = $Search_SkipProductKey_String.Line
	# Get the SkipProductKey wizard value Line number
	$Global:Get_SkipProductKey_LineNumber = $Search_SkipProductKey_String.Linenumber	
	$Global:SkipProductKey_split_Separator = $Get_SkipProductKey_Line.split('=')
	$Global:SkipProductKey_Value = $SkipProductKey_split_Separator[1]	
	
	If ($Get_SkipProductKey_LineNumber -eq $null)
		{
			$Skip_ProductKey.IsChecked = $False		
		}	
	Else
		{
			If ($SkipProductKey_Value -eq "YES")
				{
					$Skip_ProductKey.IsChecked = $True								
				}
		}	

		
	# Get SkipComputerBackup wizard value from the INI file
	$Global:SkipComputerBackup_Variable = 'SkipComputerBackup='
	# Search SkipComputerBackup wizard value variable 		
	$Global:Search_SkipComputerBackup_String = select-string $INI_File_Path -Pattern $SkipComputerBackup_Variable 
	# Get the SkipComputerBackup wizard value
	$Global:Get_SkipComputerBackup_Line = $Search_SkipComputerBackup_String.Line
	# Get the SkipComputerBackup wizard value Line number
	$Global:Get_SkipComputerBackup_LineNumber = $Search_SkipComputerBackup_String.Linenumber	
	$Global:SkipComputerBackup_split_Separator = $Get_SkipComputerBackup_Line.split('=')
	$Global:SkipComputerBackup_Value = $SkipComputerBackup_split_Separator[1]		
	
	If ($Get_SkipComputerBackup_LineNumber -eq $null)
		{
			$Skip_move_user_data.IsChecked = $False		
		}	
	Else
		{
			If($SkipComputerBackup_Value -eq "YES")
				{
					$Skip_move_user_data.IsChecked = $True								
				}
		}		

		
	# Get SkipDomainMembership wizard value from the INI file
	$Global:SkipDomainMembership_Variable = 'SkipDomainMembership='
	# Search SkipDomainMembership wizard value variable 		
	$Global:Search_SkipDomainMembership_String = select-string $INI_File_Path -Pattern $SkipDomainMembership_Variable 
	# Get the SkipDomainMembership wizard value
	$Global:Get_SkipDomainMembership_Line = $Search_SkipDomainMembership_String.Line
	# Get the SkipDomainMembership wizard value Line number
	$Global:Get_SkipDomainMembership_LineNumber = $Search_SkipDomainMembership_String.Linenumber
	$Global:SkipDomainMembership_split_Separator = $Get_SkipDomainMembership_Line.split('=')
	$Global:SkipDomainMembership_Value = $SkipDomainMembership_split_Separator[1]			
	
	If ($Get_SkipDomainMembership_LineNumber -eq $null)
		{
			$Skip_DomainMemberShip.IsChecked = $False		
		}	
	Else
		{
			If ($SkipDomainMembership_Value -eq "YES")
				{
					$Skip_DomainMemberShip.IsChecked = $True								
				}
		}	

		
	# Get SkipUserData wizard value from the INI file
	$Global:SkipUserData_Variable = 'SkipUserData='
	# Search SkipUserData wizard value variable 		
	$Global:Search_SkipUserData_String = select-string $INI_File_Path -Pattern $SkipUserData_Variable 
	# Get the SkipUserData wizard value
	$Global:Get_SkipUserData_Line = $Search_SkipUserData_String.Line
	# Get the SkipUserData wizard value Line number
	$Global:Get_SkipUserData_LineNumber = $Search_SkipUserData_String.Linenumber	
	$Global:SkipUserData_split_Separator = $Get_SkipUserData_Line.split('=')
	$Global:SkipUserData_Value = $SkipUserData_split_Separator[1]	
	
	If ($Get_SkipUserData_LineNumber -eq $null)
		{
			$Skip_restore_UserData.IsChecked = $False		
		}	
	Else
		{
			If ($SkipUserData_Value -eq "YES")
				{
					$Skip_restore_UserData.IsChecked = $True								
				}
		}			


	# Get SkipAdminPassword wizard value from the INI file
	$Global:SkipAdminPassword_Variable = 'SkipAdminPassword='
	# Search SkipAdminPassword wizard value variable 		
	$Global:Search_SkipAdminPassword_String = select-string $INI_File_Path -Pattern $SkipAdminPassword_Variable 
	# Get the SkipAdminPassword wizard value
	$Global:Get_SkipAdminPassword_Line = $Search_SkipAdminPassword_String.Line
	# Get the SkipAdminPassword wizard value Line number
	$Global:Get_SkipAdminPassword_LineNumber = $Search_SkipAdminPassword_String.Linenumber	
	$Global:SkipAdminPassword_split_Separator = $Get_SkipAdminPassword_Line.split('=')
	$Global:SkipAdminPassword_Value = $SkipAdminPassword_split_Separator[1]	
	
	If ($Get_SkipAdminPassword_LineNumber -eq $null)
		{
			$Skip_AdminPWD.IsChecked = $False		
		}	
	Else
		{
			If ($SkipAdminPassword_Value -eq "YES")
				{
					$Skip_AdminPWD.IsChecked = $True								
				}
		}		


	# Get SkipApplications wizard value from the INI file
	$Global:SkipApplications_Variable = 'SkipApplications='
	# Search SkipApplications wizard value variable 		
	$Global:Search_SkipApplications_String = select-string $INI_File_Path -Pattern $SkipApplications_Variable 
	# Get the SkipApplications wizard value
	$Global:Get_SkipApplications_Line = $Search_SkipApplications_String.Line
	# Get the SkipApplications wizard value Line number
	$Global:Get_SkipApplications_LineNumber = $Search_SkipApplications_String.Linenumber	
	$Global:SkipApplications_split_Separator = $Get_SkipApplications_Line.split('=')
	$Global:SkipApplications_Value = $SkipApplications_split_Separator[1]	
	
	If ($Get_SkipApplications_LineNumber -eq $null)
		{
			$Skip_Applications.IsChecked = $False		
		}	
	Else
		{
			If ($SkipApplications_Value -eq "YES")
				{
					$Skip_Applications.IsChecked = $True								
				}
		}		
		
		
	# Get SkipCapture wizard value from the INI file
	$Global:SkipCapture_Variable = 'SkipCapture='
	# Search SkipCapture wizard value variable 		
	$Global:Search_SkipCapture_String = select-string $INI_File_Path -Pattern $SkipCapture_Variable 
	# Get the SkipCapture wizard value
	$Global:Get_SkipCapture_Line = $Search_SkipCapture_String.Line
	# Get the SkipCapture wizard value Line number
	$Global:Get_SkipCapture_LineNumber = $Search_SkipCapture_String.Linenumber	
	$Global:SkipCapture_split_Separator = $Get_SkipCapture_Line.split('=')
	$Global:SkipCapture_Value = $SkipCapture_split_Separator[1]	
	
	If ($Get_SkipCapture_LineNumber -eq $null)
		{
			$Skip_Capture.IsChecked = $False		
		}	
	Else
		{
			If ($SkipCapture_Value -eq "YES")
				{
					$Skip_Capture.IsChecked = $True								
				}
		}		

		
	# Get SkipBitLocker wizard value from the INI file
	$Global:SkipBitLocker_Variable = 'SkipBitLocker='
	# Search SkipBitLocker wizard value variable 		
	$Global:Search_SkipBitLocker_String = select-string $INI_File_Path -Pattern $SkipBitLocker_Variable 
	# Get the SkipBitLocker wizard value
	$Global:Get_SkipBitLocker_Line = $Search_SkipBitLocker_String.Line
	# Get the SkipBitLocker wizard value Line number
	$Global:Get_SkipBitLocker_LineNumber = $Search_SkipBitLocker_String.Linenumber	
	$Global:SkipBitLocker_split_Separator = $Get_SkipBitLocker_Line.split('=')
	$Global:SkipBitLocker_Value = $SkipBitLocker_split_Separator[1]	
	
	If ($Get_SkipBitLocker_LineNumber -eq $null)
		{
			$Skip_Bitlocker.IsChecked = $False		
		}	
	Else
		{
			If ($SkipBitLocker_Value -eq "YES")
				{
					$Skip_Bitlocker.IsChecked = $True								
				}
		}		


	# Get SkipFinalSummary wizard value from the INI file
	$Global:SkipFinalSummary_Variable = 'SkipFinalSummary='
	# Search SkipFinalSummary wizard value variable 		
	$Global:Search_SkipFinalSummary_String = select-string $INI_File_Path -Pattern $SkipFinalSummary_Variable 
	# Get the SkipFinalSummary wizard value
	$Global:Get_SkipFinalSummary_Line = $Search_SkipFinalSummary_String.Line
	# Get the SkipFinalSummary wizard value Line number
	$Global:Get_SkipFinalSummary_LineNumber = $Search_SkipFinalSummary_String.Linenumber	
	$Global:SkipFinalSummary_split_Separator = $Get_SkipFinalSummary_Line.split('=')
	$Global:SkipFinalSummary_Value = $SkipFinalSummary_split_Separator[1]	
	
	If ($Get_SkipFinalSummary_LineNumber -eq $null)
		{
			$Skip_Final_Summary.IsChecked = $False		
		}	
	Else
		{
			If ($SkipFinalSummary_Value -eq "YES")
				{
					$Skip_Final_Summary.IsChecked = $True								
				}
		}		


	# Get SkipPackageDisplay wizard value from the INI file
	$Global:SkipPackageDisplay_Variable = 'SkipPackageDisplay='
	# Search SkipPackageDisplay wizard value variable 		
	$Global:Search_SkipPackageDisplay_String = select-string $INI_File_Path -Pattern $SkipPackageDisplay_Variable 
	# Get the SkipPackageDisplay wizard value
	$Global:Get_SkipPackageDisplay_Line = $Search_SkipPackageDisplay_String.Line
	# Get the SkipPackageDisplay wizard value Line number
	$Global:Get_SkipPackageDisplay_LineNumber = $Search_SkipPackageDisplay_String.Linenumber	
	$Global:SkipPackageDisplay_split_Separator = $Get_SkipPackageDisplay_Line.split('=')
	$Global:SkipPackageDisplay_Value = $SkipPackageDisplay_split_Separator[1]	
	
	If ($Get_SkipPackageDisplay_LineNumber -eq $null)
		{
			$Skip_Language_packs.IsChecked = $False		
		}	
	Else
		{
			If ($SkipPackageDisplay_Value -eq "YES")
				{
					$Skip_Language_packs.IsChecked = $True								
				}
		}			


	# Get SkipComputerName wizard value from the INI file
	$Global:SkipComputerName_Variable = 'SkipComputerName='
	# Search SkipComputerName wizard value variable 		
	$Global:Search_SkipComputerName_String = select-string $INI_File_Path -Pattern $SkipComputerName_Variable 
	# Get the SkipComputerName wizard value
	$Global:Get_SkipComputerName_Line = $Search_SkipComputerName_String.Line
	# Get the SkipComputerName wizard value Line number
	$Global:Get_SkipComputerName_LineNumber = $Search_SkipComputerName_String.Linenumber	
	$Global:SkipComputerName_split_Separator = $Get_SkipComputerName_Line.split('=')
	$Global:SkipComputerName_Value = $SkipComputerName_split_Separator[1]	
	
	If ($Get_SkipComputerName_LineNumber -eq $null)
		{
			$Skip_Computer_name.IsChecked = $False		
		}	
	Else
		{
			If ($SkipComputerName_Value -eq "YES")
				{
					$Skip_Computer_name.IsChecked = $True								
				}
		}		


	# Get SkipLocaleSelection wizard value from the INI file
	$Global:SkipLocaleSelection_Variable = 'SkipLocaleSelection='
	# Search SkipLocaleSelection wizard value variable 		
	$Global:Search_SkipLocaleSelection_String = select-string $INI_File_Path -Pattern $SkipLocaleSelection_Variable 
	# Get the SkipLocaleSelection wizard value
	$Global:Get_SkipLocaleSelection_Line = $Search_SkipLocaleSelection_String.Line
	# Get the SkipLocaleSelection wizard value Line number
	$Global:Get_SkipLocaleSelection_LineNumber = $Search_SkipLocaleSelection_String.Linenumber	
	$Global:SkipLocaleSelection_split_Separator = $Get_SkipLocaleSelection_Line.split('=')
	$Global:SkipLocaleSelection_Value = $SkipLocaleSelection_split_Separator[1]	
	
	If ($Get_SkipLocaleSelection_LineNumber -eq $null)
		{
			$Skip_Locale_time.IsChecked = $False		
		}	
	Else
		{
			If ($SkipLocaleSelection_Value -eq "YES")
				{
					$Skip_Locale_time.IsChecked = $True								
				}
		}		

			
	
	
	
	# GET VALUES FROM THE OTHERS TAB
	# Value strings to search	
	
	# Get Finish Action value from the INI file
	$Global:FinishAction_Variable = 'FinishAction='
	# Search Finish Action value variable 		
	$Global:Search_FinishAction_String = select-string $INI_File_Path -Pattern $FinishAction_Variable 
	# Get the Finish Action value
	$Global:Get_FinishAction_Line = $Search_FinishAction_String.Line
	# Get the Finish Action value Line number
	$Global:Get_FinishAction_LineNumber = $Search_FinishAction_String.Linenumber	
	$Global:FinishAction_split_Separator = $Get_FinishAction_Line.split('=')
	$Global:FinishAction_Value = $FinishAction_split_Separator[1]
	# Populate the Finish Action value TextBox with value from the INI file
		
	If ($FinishAction_Value -eq "REBOOT")
		{
			$Finish_Action_Reboot.IsSelected = $True		
		}	
	ElseIf ($FinishAction_Value -eq "SHUTDOWN")
		{
			$Finish_Action_Shutdown.IsSelected = $True		
		}	
	ElseIf ($FinishAction_Value -eq "LOGOFF")
		{
			$Finish_Action_LogOff.IsSelected = $True		
		}	
	ElseIf ($FinishAction_Value -eq "LOGOFF")
		{
			$Finish_Action_LogOff.IsSelected = $True		
		}
		
	If ($Get_FinishAction_LineNumber -eq $null)
		{
			$Finish_Action_DoNothing.IsSelected = $True		
		}			
		
		
	# Get WSUS value from the INI file
	$Global:WSUSServer_Variable = 'WSUSServer='
	# Search WSUS value variable 		
	$Global:Search_WSUSServer_String = select-string $INI_File_Path -Pattern $WSUSServer_Variable 
	# Get the WSUS value
	$Global:Get_WSUSServer_Line = $Search_WSUSServer_String.Line
	# Get the WSUS value Line number
	$Global:Get_WSUSServer_LineNumber = $Search_WSUSServer_String.Linenumber	
	# Separate the WSUS value	
	$Global:WSUSServer_split_Separator = $Get_WSUSServer_Line.split('=')
	$Global:WSUSServer_Value = $WSUSServer_split_Separator[1]
	# Populate the WSUS value TextBox with value from the INI file
	$Set_WSUS_Server.Text = $WSUSServer_Value					
	
	# Get EventService value from the INI file
	$Global:EventService_Variable = 'EventService='
	# Search EventService value variable 		
	$Global:Search_EventService_String = select-string $INI_File_Path -Pattern $EventService_Variable 
	# Get the EventService value
	$Global:Get_EventService_Line = $Search_EventService_String.Line
	# Get the EventService value Line number
	$Global:Get_EventService_LineNumber = $Search_EventService_String.Linenumber	
	# Separate the EventService value	
	$Global:EventService_split_Separator = $Get_EventService_Line.split('=')
	$Global:WEventService_Value = $EventService_split_Separator[1]
	# Populate the EventService value TextBox with value from the INI file
	$Event_Service.Text = $WEventService_Value		

	# Get SLShare value from the INI file
	$Global:SLShare_Variable = 'SLShare='
	# Search SLShare value variable 		
	$Global:Search_SLShare_String = select-string $INI_File_Path -Pattern $SLShare_Variable 
	# Get the SLShare value
	$Global:Get_SLShare_Line = $Search_SLShare_String.Line
	# Get the EventService value Line number
	$Global:Get_SLShare_LineNumber = $Search_SLShare_String.Linenumber	
	# Separate the SLShare value	
	$Global:SLShare_split_Separator = $Get_SLShare_Line.split('=')
	$Global:SLShare_Value = $SLShare_split_Separator[1]
	# Populate the SLShare value TextBox with value from the INI file
	$Logs_SLShare.Text = $SLShare_Value		

	# Get SLShareDynamicLogging value from the INI file
	$Global:SLShareDynamicLogging_Variable = 'SLShareDynamicLogging='
	# Search SLShareDynamicLogging value variable 		
	$Global:Search_SLShareDynamicLogging_String = select-string $INI_File_Path -Pattern $SLShareDynamicLogging_Variable 
	# Get the SLShareDynamicLogging value
	$Global:Get_SLShareDynamicLogging_Line = $Search_SLShareDynamicLogging_String.Line
	# Get the EventService value Line number
	$Global:Get_SLShareDynamicLogging_LineNumber = $Search_SLShareDynamicLogging_String.Linenumber	
	# Separate the SLShareDynamicLogging value	
	$Global:SLShareDynamicLogging_split_Separator = $Get_SLShareDynamicLogging_Line.split('=')
	$Global:SLShareDynamicLogging_Value = $SLShareDynamicLogging_split_Separator[1]
	# Populate the SLShareDynamicLogging value TextBox with value from the INI file
	$Logs_SLShareDynamicLogging.Text = $SLShareDynamicLogging_Value		
		
	# Get HideShell value from the INI file
	$Global:HideShell_Variable = 'HideShell='
	# Search HideShell value variable 		
	$Global:Search_HideShell_String = select-string $INI_File_Path -Pattern $HideShell_Variable 
	# Get the HideShell value
	$Global:Get_HideShell_Line = $Search_HideShell_String.Line
	# Get the HideShell value Line number
	$Global:Get_HideShell_LineNumber = $Search_SLShareDynamicLogging_String.Linenumber	
	# Separate the HideShell value	
	$Global:HideShell_split_Separator = $Get_HideShell_Line.split('=')
	$Global:HideShell_Value = $HideShell_split_Separator[1]
	# Populate the HideShell value TextBox with value from the INI file
	
	If ($Get_HideShell_LineNumber -eq $null)
		{
			$Hide_Shell.IsChecked = $False		
		}	
	Else
		{
			If ($HideShell_Value -eq "YES")
				{
					$Hide_Shell.IsChecked = $True								
				}
		}

		
	# Get DoNotCreateExtraPartition value from the INI file
	$Global:DoNotCreateExtraPartition_Variable = 'DoNotCreateExtraPartition='
	# Search DoNotCreateExtraPartition value variable 		
	$Global:Search_DoNotCreateExtraPartition_String = select-string $INI_File_Path -Pattern $DoNotCreateExtraPartition_Variable 
	# Get the DoNotCreateExtraPartition value
	$Global:Get_DoNotCreateExtraPartition_Line = $Search_DoNotCreateExtraPartition_String.Line
	# Get the DoNotCreateExtraPartition value Line number
	$Global:Get_DoNotCreateExtraPartition_LineNumber = $Search_DoNotCreateExtraPartition_String.Linenumber	
	$Global:DoNotCreateExtraPartition_split_Separator = $Get_DoNotCreateExtraPartition_Line.split('=')
	$Global:DoNotCreateExtraPartition_Value = $HideShell_split_Separator[1]
	
	If ($Get_DoNotCreateExtraPartition_LineNumber -eq $null)
		{
			$Not_extra_partition.IsChecked = $False		
		}	
	Else
		{
			If ($DoNotCreateExtraPartition_Value -eq "YES")
				{
					$Not_extra_partition.IsChecked = $True				
				
				}
		}
		
		
		
		
	# Get ProductKey value from the INI file
	$Global:ProductKey_Variable = 'ProductKey='
	# Search ProductKey value variable 		
	$Global:Search_ProductKey_String = select-string $INI_File_Path -Pattern $ProductKey_Variable 
	# Get the ProductKey value
	$Global:Get_ProductKey_Line = $Search_ProductKey_String.Line
	# Get the ProductKey value Line number
	$Global:Get_ProductKey_LineNumber = $Search_ProductKey_String.Linenumber	
	$Global:ProductKey_split_Separator = $Get_ProductKey_Line.split('=')
	$Global:ProductKey_Value = $ProductKey_split_Separator[1]
	
	# Get OverrideProductKey value from the INI file
	$Global:OverrideProductKey_Variable = 'OverrideProductKey='
	# Search OverrideProductKey value variable 		
	$Global:Search_OverrideProductKey_String = select-string $INI_File_Path -Pattern $OverrideProductKey_Variable 
	# Get the OverrideProductKey value
	$Global:Get_POverrideProductKey_Line = $Search_OverrideProductKey_String.Line
	# Get the OverrideProductKey value Line number
	$Global:Get_OverrideProductKey_LineNumber = $Search_OverrideProductKey_String.Linenumber	
	$Global:OverrideProductKey_split_Separator = $Get_POverrideProductKey_Line.split('=')
	$Global:OverrideProductKey_Value = $OverrideProductKey_split_Separator[1]	
	
	If (($Get_ProductKey_LineNumber -eq $null) -and ($Get_OverrideProductKey_LineNumber -eq $null))
		{
			$No_Product_Key.IsSelected = $True		
		}	
	Else
		{
			If ($Get_ProductKey_LineNumber -ne $null)
				{
					$specific_product.IsSelected = $True	
					$Key_Label_TextBox.Text = $ProductKey_Value				
				}
			ElseIf ($Get_OverrideProductKey_LineNumber -ne $null)
				{
					$Activate_MAK.IsSelected = $True
					$Key_Label_TextBox.Text = $OverrideProductKey_Value									
				}				
		}		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
})





	
		
		
#************************************************************************** Create profile Button ***********************************************************************************************		
$Create_Profile.Add_Click({	

	$OSDProfile_Name = $Profile_Name.Text.ToString()

	If ($Profile_Location -eq "deploymentshare")
		{
			$Global:Profile_File = "$deploymentshare\Control\$OSDProfile_Name"			
		}
	
	ElseIf ($Profile_Location = "choose")
		{
			$Global:Profile_File = "$Profile_Folder\$OSDProfile_Name"	
		}

	$OSD_ComputerName = $Computer_Name.Text.ToString()
	$OSD_Local_Password = $Local_Admin_PWD.Text.ToString()
	$OSD_IPAddress = $IPAddress.Text.ToString()
	$OSD_Gateway = $Gateway.Text.ToString()
	$OSD_SubnetMask = $SubnetMask.Text.ToString()
	$OSD_DNSServer = $DNS_Server.Text.ToString()
	$OSD_HomePage = $IE_home_page.Text.ToString()
	$OSD_OrgName = $Org_name.Text.ToString()	
	
	$OSD_Domain_Wkg_Name = $Domaine_Wkg_txtbox.Text.ToString()
	$OSD_OU_name = $OU_name.Text.ToString()
	$OSD_UserName = $UserName.Text.ToString()
	$OSD_Domain_Admin_Pwd = $Domain_Admin_Pwd.Text.ToString()
	$OSD_Capture_File_name = $Capture_file_name.Text.ToString()
	$OSD_WSUS_Server = $Set_WSUS_Server.Text.ToString()
	$OSD_Capture_Location = $Capture_backup_location_textbox.Text.ToString()
	$OSD_Event_Service = $Event_Service.Text.ToString()
	$OSD_Logs_SLShareDynamicLogging = $Logs_SLShareDynamicLogging.Text.ToString()
	$OSD_Logs_SLShare = $Logs_SLShare.Text.ToString()
	
	$OSD_Capture_location_user = $Capture_location_user.Text.ToString()	
	$OSD_Capture_location_password = $Capture_location_password.Text.ToString()	
	$OSD_Capture_location_domain = $Capture_location_domain.Text.ToString()	
	
	$OSD_UserData_restore_location = $UserData_restore_location_textbox.Text.ToString()	

	$OSD_Computer_Backup_Location_TextBox = $Computer_Backup_Location_TextBox.Text.ToString()
	$OSD_UserData_Backup_location_textbox = $UserData_Backup_location_textbox.Text.ToString()
	
	$Product_Key_Value = $Key_Label_TextBox.Text.ToString()	
	
	$Test_Profile_File = Test-Path $Profile_File
	If ($Test_Profile_File -eq $true)
		{		
			$Profile_Name_Info.Content = "The file $OSDProfile_Name already exists"
			$Profile_Name_Info.Foreground = "red"
			[System.Windows.Forms.MessageBox]::Show("The file $OSDProfile_Name already exists") 			
		}
	Else
		{
			New-Item $Profile_File -type file
			Add-Content $Profile_File ";------------------------------------------------------------------------------------------"			
			Add-Content $Profile_File ";$OSDProfile_Name - This file has been generated with MDT Profile Generator"
			Add-Content $Profile_File ";------------------------------------------------------------------------------------------"		
					
			Add-Content $Profile_File "[Settings]"
			Add-Content $Profile_File "Priority=Default"
			Add-Content $Profile_File "Properties=MyCustomProperty"
			If ($OSD_OrgName -ne "")
				{
					Add-Content $Profile_File "_SMSTSORGNAME=$OSD_OrgName"							
				}
			Add-Content $Profile_File ""
			Add-Content $Profile_File "[Default]"
			
			If($Computer_Name_SN.IsChecked -eq $true)
				{
					Add-Content $Profile_File "OSDComputername=%SerialNumber%"					
				}
			Else	
				{
					Add-Content $Profile_File "OSDComputername=$OSD_ComputerName"				
				}

			Add-Content $Profile_File "AdminPassword=$OSD_Local_Password"	
			Add-Content $Profile_File "TaskSequenceID=$My_TaskSequence"	

			Add-Content $Profile_File ""						
			Add-Content $Profile_File ";------------------------------------------------------------------------------------------"			
			Add-Content $Profile_File ";NETWORK SELECTION"					
			Add-Content $Profile_File ";------------------------------------------------------------------------------------------"		
			If ($OSD_HomePage -ne "")
				{
					Add-Content $Profile_File "Home_Page=$OSD_HomePage"			
				}
			
			If ($Choose_DHCP.IsSelected -eq $true)
				{
					Add-Content $Profile_File "OSDAdapterCount=1"	
					Add-Content $Profile_File "OSDAdapter0EnableDHCP=TRUE"		
				}
				
			Else
				{			
					Add-Content $Profile_File "OSDAdapterCount=1"	
					Add-Content $Profile_File "OSDAdapter0EnableDHCP=FALSE"	
					Add-Content $Profile_File "OSDAdapter0IPAddressList=$OSD_IPAddress"	
					Add-Content $Profile_File "OSDAdapter0Gateways=$OSD_Gateway"	
					Add-Content $Profile_File "OSDAdapter0SubnetMask=$OSD_SubnetMask"	
					Add-Content $Profile_File "OSDAdapter0DNSServerList=$OSD_DNSServer"							
				}	

				
			Add-Content $Profile_File ""						
			Add-Content $Profile_File ";------------------------------------------------------------------------------------------"			
			Add-Content $Profile_File ";BACKUP SELECTION - CAPTURE AND COMPUTER BACKUP PART"					
			Add-Content $Profile_File ";------------------------------------------------------------------------------------------"			

#---------------------------------------------------------  Deployment Type PART ---------------------------------------------------------				
			
			If (($Deployment_Type_Newcomputer.IsSelected -eq $true) -or ($Deployment_Type_NoSet.IsSelected -eq $true))
				{
					Add-Content $Profile_File "DeploymentType=NEWCOMPUTER"		
#---------------------------------------------------------  Capture PART ---------------------------------------------------------				
					If ($VHD_File.IsSelected -eq $true)
						{
							$Backup_File_extension = "vhd"
						}
					ElseIf ($WIM_file.IsSelected -eq $true)
						{
							$Backup_File_extension = "wim"				
						}	

					If ($capture_computer_no.IsSelected -eq $true)
						{
							Add-Content $Profile_File "DoCapture=NO"	
							Add-Content $Profile_File "ComputerBackupLocation=NONE"	
						}					
					ElseIf ($capture_computer_yes.IsSelected -eq $true)
						{
							Add-Content $Profile_File "DoCapture=YES"	
							Add-Content $Profile_File "ComputerBackupLocation=$OSD_Capture_Location"		
							Add-Content $Profile_File "BackupFile=$OSD_Capture_File_name.$Backup_File_extension"	
							Add-Content $Profile_File "UserID=$OSD_Capture_location_user"		
							Add-Content $Profile_File "UserDomain=$OSD_Capture_location_domain"		
							Add-Content $Profile_File "UserPassword=$OSD_Capture_location_password"							
						}					
					ElseIf ($sysprep_this_computer.IsSelected -eq $true)
						{
							Add-Content $Profile_File "DoCapture=SYSPREP"							
						}						
					ElseIf ($prepare_to_capture.IsSelected -eq $true)
						{
							Add-Content $Profile_File "DoCapture=PREPARE"							
						}			
#---------------------------------------------------------  Move User Data and Settings PART ---------------------------------------------------------				
					Add-Content $Profile_File ""						
					Add-Content $Profile_File ";------------------------------------------------------------------------------------------"			
					Add-Content $Profile_File ";BACKUP SELECTION - RESTORE USER DATA PART"					
					Add-Content $Profile_File ";------------------------------------------------------------------------------------------"		

					If ($move_data_yes.IsChecked -eq $True)	
						{
							Add-Content $Profile_File "USMTOfflineMigration=True"	
							
							If ($Keep_existing_partitions.IsChecked -eq $True)	
								{
									Add-Content $Profile_File "DoNotFormatAndPartition=YES"									
								}							
						}
#---------------------------------------------------------  Restore User Data and Settings PART ---------------------------------------------------------				
					Add-Content $Profile_File ""						
					Add-Content $Profile_File ";------------------------------------------------------------------------------------------"			
					Add-Content $Profile_File ";BACKUP SELECTION - RESTORE USER DATA PART"					
					Add-Content $Profile_File ";------------------------------------------------------------------------------------------"					
				
					If ($restore_user_data_no.IsSelected -eq $true)
						{
							Add-Content $Profile_File "UserDataLocation=NONE"	
						}		
					ElseIf ($restore_user_data_specify_location.IsSelected -eq $true)
						{
							Add-Content $Profile_File "UserDataLocation=NETWORK"	
							Add-Content $Profile_File "UserDataLocation=$OSD_UserData_restore_location"							
						}						
				}
				
			ElseIf ($Deployment_Type_Refresh.IsSelected -eq $true)   # REFRESH PART
				{
					Add-Content $Profile_File "DeploymentType=REFRESH"	
#---------------------------------------------------------  Computer Backup PART ---------------------------------------------------------				
					If ($Backup_Computer_No.IsSelected -eq $true)
						{
							Add-Content $Profile_File "ComputerBackupLocation=NONE"	
						}	
					ElseIf ($Backup_Computer_Auto.IsSelected -eq $true)
						{
							Add-Content $Profile_File "ComputerBackupLocation=AUTO"	
						}					
					ElseIf ($Backup_Computer_Specify.IsSelected -eq $true)
						{
							Add-Content $Profile_File "ComputerBackupLocation=$OSD_Computer_Backup_Location_TextBox"							
						}					
		
#---------------------------------------------------------  Move User Data and Settings PART ---------------------------------------------------------				
					Add-Content $Profile_File ""						
					Add-Content $Profile_File ";------------------------------------------------------------------------------------------"			
					Add-Content $Profile_File ";BACKUP SELECTION - BACKUP USER DATA PART"					
					Add-Content $Profile_File ";------------------------------------------------------------------------------------------"		

					If ($Backup_UserData_NO.IsSelected -eq $true)
						{
							Add-Content $Profile_File "UserDataLocation=NONE"								
						}	
					ElseIf ($Backup_UserData_Auto.IsSelected -eq $true)
						{
							Add-Content $Profile_File "UserDataLocation=AUTO"	
						}					
					ElseIf ($Backup_UserData_Network.IsSelected -eq $true)
						{
							Add-Content $Profile_File "UserDataLocation=$OSD_UserData_Backup_location_textbox"							
						}				
				}		
		
			
			
			Add-Content $Profile_File ""							
			Add-Content $Profile_File ";------------------------------------------------------------------------------------------"			
			Add-Content $Profile_File ";DOMAIN/WORKGROUP SELECTION"					
			Add-Content $Profile_File ";------------------------------------------------------------------------------------------"			
				
			If ($Mode_Workgroup.IsSelected -eq $true)
				{
					Add-Content $Profile_File "JoinWorkGroup=WorkGroup"	
				}
				
			Else
				{			
					Add-Content $Profile_File "JoinDomain=$OSD_Domain_Wkg_Name"	
					Add-Content $Profile_File "DomainAdminDomain=$OSD_Domain_Wkg_Name"						
					Add-Content $Profile_File "MachineObjectOU=$OSD_OU_name"	
					Add-Content $Profile_File "DomainAdmin=$OSD_UserName"	
					Add-Content $Profile_File "DomainAdminPassword=$OSD_Domain_Admin_Pwd"	
				}			
			Add-Content $Profile_File ""					
			Add-Content $Profile_File ";------------------------------------------------------------------------------------------"			
			Add-Content $Profile_File ";LOCALE AND TIME SELECTION"					
			Add-Content $Profile_File ";------------------------------------------------------------------------------------------"			
				
			Add-Content $Profile_File "LanguagePacks1=$My_Language_Pack_GUID"	
			
			If ($Second_language_none.IsSelected -ne $true)
				{
					Add-Content $Profile_File "LanguagePacks2=$My_Second_Language_Pack_GUID"								
				}
				
			Add-Content $Profile_File "UILanguage=$My_Language_Pack_Language"		
			Add-Content $Profile_File "TimeZoneName=$My_Timezone"	
			Add-Content $Profile_File "KeyboardLocale=$My_Keyboard"	# Keyboard Layout
			Add-Content $Profile_File "UserLocale=$My_Language_Pack_Language"	 # Time and currency format
		
			Add-Content $Profile_File ""							
			Add-Content $Profile_File ";------------------------------------------------------------------------------------------"			
			Add-Content $Profile_File ";APPLICATION SELECTION"					
			Add-Content $Profile_File ";------------------------------------------------------------------------------------------"			
					
			If ($DataGrid_Applis.SelectedIndex -ne "-1") # Check if a row is selected in the datagrid
				{
					$Global:Selected_Applications = $DataGrid_Applis.SelectedItems # All selected applications
					$All_Row_count = $DataGrid_Applis.items.count					
					$Global:Selected_Applis_count = $Selected_Applications.count	

					$i=0
					While ($i -lt $Selected_Applis_count)
						{			
							ForEach ($Global:Appli in $Selected_Applications)
								{						
									foreach ($data in $Appli)
										{
											$Global:My_Values = New-Object -TypeName PSObject -Property @{
												GUID = $data.Appli_GUID} 
												$Global:appli_values = $My_Values | select guid
												$Global:guid = $appli_values.guid
											$i++													
											Add-Content $Profile_File "MandatoryApplications$i=$guid"	
										}
								}
						}									
				}
			Else
				{
					Add-Content $Profile_File ";No applications selected"						
				}					
			
			Add-Content $Profile_File ""						
			Add-Content $Profile_File ";------------------------------------------------------------------------------------------"			
			Add-Content $Profile_File ";WIZARD SELECTION"					
			Add-Content $Profile_File ";------------------------------------------------------------------------------------------"			
			Add-Content $Profile_File "SkipBDDWelcome=YES"			

			If ($Skip_All.IsChecked -eq $true)
				{
					Add-Content $Profile_File "SkipWizard=YES"			
				}
			
			If ($Skip_TS.IsChecked -eq $true)
				{
					Add-Content $Profile_File "SkipTaskSequence=YES"			
				}
				
			If ($Skip_ProductKey.IsChecked -eq $true)
				{
					Add-Content $Profile_File "SkipProductKey=YES"			
				}	
				
			If ($Skip_move_user_data.IsChecked -eq $true)
				{
					Add-Content $Profile_File "SkipComputerBackup=YES"			
				}	
				
			If ($Skip_DomainMemberShip.IsChecked -eq $true)
				{
					Add-Content $Profile_File "SkipDomainMembership=YES"			
				}
				
			If ($Skip_restore_UserData.IsChecked -eq $true)
				{
					Add-Content $Profile_File "SkipUserData=YES"			
				}

			If ($Skip_AdminPWD.IsChecked -eq $true)
				{
					Add-Content $Profile_File "SkipAdminPassword=YES"			
				}		
				
			If ($Skip_Applications.IsChecked -eq $true)
				{
					Add-Content $Profile_File "SkipApplications=YES"			
				}	

			If ($Skip_Capture.IsChecked -eq $true)
				{
					Add-Content $Profile_File "SkipCapture=YES"			
				}				
			
			If ($Skip_Bitlocker.IsChecked -eq $true)
				{
					Add-Content $Profile_File "SkipBitLocker=YES"			
				}

			If ($Skip_Summary.IsChecked -eq $true)
				{
					Add-Content $Profile_File "SkipFinalSummary=YES"			
				}
				
			If ($Skip_Locale_time.IsChecked -eq $true)
				{
					Add-Content $Profile_File "SkipLocaleSelection=YES"		
					Add-Content $Profile_File "SkipTimeZone=YES"					
				}
				
			If ($Skip_Language_packs.IsChecked -eq $true)
				{
					Add-Content $Profile_File "SkipPackageDisplay=YES"			
				}	
				
			If ($Skip_Language_packs.IsChecked -eq $true)
				{
					Add-Content $Profile_File "SkipComputerName=YES"			
				}				

			Add-Content $Profile_File ""						
			Add-Content $Profile_File ";------------------------------------------------------------------------------------------"			
			Add-Content $Profile_File ";OTHER PART"					
			Add-Content $Profile_File ";------------------------------------------------------------------------------------------"	
			
			If ($GPO_Pack_DoNothing.IsSelected -eq $true)
				{
					Add-Content $Profile_File "ApplyGPOPack=NO"															
				}
			Else
				{
					Add-Content $Profile_File "ApplyGPOPack=YES"										
					Add-Content $Profile_File "GPOPackPath=$My_Selected_GPOPack"						
				}			
			
			If ($Finish_Action_Reboot.IsSelected -eq $true)
				{
					Add-Content $Profile_File "FinishAction=REBOOT"										
				}
			ElseIf ($Finish_Action_Shutdown.IsSelected -eq $true)
				{
					Add-Content $Profile_File "FinishAction=SHUTDOWN"										
				}
				
			ElseIf ($Finish_Action_LogOff.IsSelected -eq $true)
				{
					Add-Content $Profile_File "FinishAction=LOGOFF"										
				}			

			If ($Set_WSUS_Server.Text -ne "")
				{
					Add-Content $Profile_File "WSUSServer=$OSD_WSUS_Server"														
				}
				
			If ($Event_Service.Text -ne "")
				{
					Add-Content $Profile_File "EventService=$OSD_Event_Service"														
				}		

			If ($Logs_SLShareDynamicLogging.Text -ne "")
				{
					Add-Content $Profile_File "SLShareDynamicLogging=$OSD_Logs_SLShareDynamicLogging"														
				}		
		
			If($SLShare_Deployroot.IsChecked -eq $true)
				{
					Add-Content $Profile_File "SLShare=%DeployRoot%\Logs\$OSD_ComputerName"					
				}
			Else	
				{
					If ($Logs_SLShare.Text -ne "")		
						{
							Add-Content $Profile_File "SLShare=$OSD_Logs_SLShare"														
						}			
				}			
			
			If ($Hide_Shell.IsChecked -eq $true)
				{
					Add-Content $Profile_File "HideShell=YES"			
				}				
				
			If ($Not_extra_partition.IsChecked -eq $true)
				{
					Add-Content $Profile_File "DoNotCreateExtraPartition=YES"			
				}		


			If ($Activate_MAK.IsSelected -eq $true)
				{
					Add-Content $Profile_File "ProductKey =$Product_Key_Value"										
				}			
			ElseIf ($specific_product.IsSelected -eq $true)
				{
					Add-Content $Profile_File "OverrideProductKey=$Product_Key_Value"										
				}					

					
			invoke-item $Profile_File			
		}	
})			

		
		
		
		
		
		
		
		
		
		
		
		



$Form.ShowDialog() | Out-Null
	 
	 