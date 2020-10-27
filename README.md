Enable AHB benefit (Vcore) in Azure SQL DB, Elastic Pools and Managed instance
==============================================================================

            

 

 

 


This powershell script will enable the AHB benefit on the subscription ID that you want. The requirements are:


Az module


Create a folder called TEMP on the C drive: The directory must be C:\Temp


The steps to excute this scrip are:


  *  Copy AHBVcore.ps1 and Subscriptionid.txt files to C:\temp folder 
  *  Create a Subscriptionid.txt file with the subscription ids that you want to process (put the subscription ids without a coma, one by one) 

  *  Open a powershell windows with Administrator rights 
  *  Go to C:\temp folder 
  *  Write .\ AHBVcore.ps1 and click enter 
  *  A log file called execution.txt will be created on on C:\temp folder 
  *  a prompt window will appear to log in into Azure and then the subscriptions IDs will be executed.


Only the impacted objects will be logged on this file as well as the errors with SubscriptionID not processed message. 


        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
