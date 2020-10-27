   ##Creating Log file
   
   $filepath = "C:\temp\execution.txt"  
   New-Item -Path $filepath  -ItemType file -Force
   
   ##Connecting to Azure account

   Connect-AzAccount

   ##Getallsubscriptions that will be impacted from TXT file
   $subscriptionid=Get-Content -path "C:\temp\subscriptionid.txt"
   Write-Output "There are around $($subscriptionid.Count) subscriptions in the text file.."

   $subscriptionid = Get-AzSubscription | Where{$_.Id -in $subscriptionid}
   Write-Output "There are around $($subscriptionid.Count) subscriptions in the selected tenant.."
TRY
{

   ##Processing all of the subscriptions that the user has permissions
   FOR($S = 0; $S -lt $subscriptionid.Count; $S++)
   {
      $subscriptionidtbp = $subscriptionid[$S].Id
  
      Write-Output "Processing subscription $subscriptionidtbp"
      ##Change context for each subscription

      Select-AzSubscription -Subscription $subscriptionidtbp
      
      
      IF ($error.Count -gt 0)
      {
        $message = "$subscriptionidtbp not processed"
        $message | Out-File "C:\temp\execution.txt" -append
        $error.clear()
      }

      ##AzureSQLDB Managed instance

      ##Get all managed instance inside the subscription

      $Managedinstances=Get-AzSqlInstance
      Write-Output "There are around $($Managedinstances.Count) managed instance for update.."

      ## Get the managed instances that need to be updated 

      IF(-not ([string]::IsNullOrEmpty($Managedinstances)))
      {
        FOREACH($getmanagedinstances in $Managedinstances)
        {
            Write-Output "Reading Managed Instance $($getmanagedinstances.Managedinstancename)"
              
            $Managedinstancetoproceed=Get-AzSqlInstance -ResourceGroupName $getmanagedinstances.resourcegroupname -name $getmanagedinstances.Managedinstancename | select-object -property Managedinstancename,resourcegroupname,licensetype | where -property Licensetype -in -value "LicenseIncluded" 
            IF(-not ([string]::IsNullOrEmpty($Managedinstancetoproceed)))
            {            
               Set-AzSqlInstance -ResourceGroupName $Managedinstancetoproceed.resourcegroupname -name $Managedinstancetoproceed.Managedinstancename -LicenseType "BasePrice" -Force | Out-File -FilePath $filepath -append
                Write-output "Managed instance $($getmanagedinstances.Managedinstancename) update is success"
            } 
         }
      }
      ##AzureSQLDB

      ## Getting all Azure SQL DB virtual servers 
	  
      $AzureSQLDBLogicalservers = Get-AzSqlserver
      Write-Output "There are around $($AzureSQLDBLogicalservers.Count) SQL servers for update.."

      ## Get all Azure SQL DB databases that needs to be updated 
      IF(-not ([string]::IsNullOrEmpty($AzureSQLDBLogicalservers)))	
      {  
        FOR($LS = 0; $LS -lt $AzureSQLDBLogicalservers.Count; $LS++)
        {
            $getazuresqldb = $AzureSQLDBLogicalservers[$LS]
          
            Write-Output "Reading SQL DB $($getazuresqldb.Servername).."      
            $AzureSQLDBtoproceed=Get-AzSqlDatabase -ResourceGroupName $getazuresqldb.Resourcegroupname -ServerName $getazuresqldb.Servername | select-object -property databasename,edition,servername,resourcegroupname,licensetype | where -property Licensetype -in -value "LicenseIncluded"
            FOREACH($ItemToProceed in $AzureSQLDBtoproceed){
                IF(-not ([string]::IsNullOrEmpty($ItemToProceed)))
                {            
                   Set-AzSqlDatabase -ResourceGroupName $ItemToProceed.resourcegroupname -DatabaseName $ItemToProceed.databasename -ServerName $ItemToProceed.servername -LicenseType "BasePrice" | Out-File -FilePath $filepath -append
                   Write-output "SQLDB logical server $($ItemToProceed.databasename) update is success"
                } 
            }
            
         }

         ##Elastic Pools

         ## Get all elastic pools to be updated 	 
         FOREACH($getelasticpools in $AzureSQLDBLogicalservers)
         {
            Write-Output "Reading elastic pool $($getelasticpools.Servername).."  
            $ElasticPools=Get-AzSqlElasticPool -ResourceGroupName $getelasticpools.Resourcegroupname -ServerName $getelasticpools.Servername | select ElasticPoolName,edition,servername,resourcegroupname,licensetype | where -property Licensetype -in -value "LicenseIncluded"
            IF(-not ([string]::IsNullOrEmpty($ElasticPools)))
            {            
               Set-AzSqlElasticPool -ResourceGroupName $ElasticPools.resourcegroupname -ElasticPoolName $ElasticPools.ElasticPoolName -ServerName $ElasticPools.servername -LicenseType "BasePrice" | Out-File -FilePath $filepath -append
                Write-Output "Elastic pool $($ElasticPools.ElasticPoolName) update is success.."
            }            
         }
       }
   }
}
CATCH
{
   $message = $_.Exception.Message
   $message | Out-File "C:\temp\execution.txt" -append
   
}