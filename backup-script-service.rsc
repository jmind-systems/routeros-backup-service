##############################
# RouterOS full-backup script                     
# github.com/jmind-systems/RouterOS-Scripts  
# t.me/olkovin
# INFO: Generates full .rsc export and backup file and send it to specified e-mail and/or ftp server and/or sync-directory
##############################

## ToDo and etc module
:local SendToEmail true
:local SendToFTP false
:local PutToSyncFolder false
:local AdditionalInfo true

## Variables module 
:local timedate ([:pick [/system clock get time] 0 2].[:pick [/system clock get time] 3 5].[:pick [/system clock get time] 6 8]."_".[:pick [/system clock get date] 4 6].[:pick [/system clock get date] 0 3].[:pick [/system clock get date] 7 12])
:local identity [/system identity get name];
:local model [/system routerboard get value-name=model]
:local SN [/system routerboard get value-name=serial-number]
:local RBC [/system routerboard get value-name=routerboard]
:local EVfilename [("export-verbose_".$identity."_".$timedate)]
:local BCKPfilename [("backup_".$identity."_".$timedate)]

## e-mail params module
:local bodyformated [("Name: ".$identity."\n"."Model: ".$model."\n"."SN: ".$SN."\n"."RouterBoard: ".$RBC)]
:local sendto "set@your.email"
:local subject "$timedate $identity files"

## export module
:do {/export verbose file=$EVfilename;
:delay 10;
} on-error={:log error "Failed to create export-verbose file"}

## backup module
:do {/system backup save dont-encrypt=yes name=$BCKPfilename;
:delay 10;
} on-error={:log error "Failed to create backup file"}


## e-mail module
:if ($SendToEmail) do={
:do {:log warning "Sending export-verbose file via e-mail..";
/tool e-mail send to=$sendto subject="$subject" body="$bodyformated" file=$EVfilename;} on-error={:log error "Failed when sending export-verbose file via e-mail"};
:do {:log warning "Sending backup-file via e-mail..";
/tool e-mail send to=$sendto subject="$subject" body=$bodyformated file=$BCKPfilename;} on-error={:log error "Failed when sending backup file via e-mail"}
:log warning "Waiting, until all e-mails will be sended..."
:delay 15
:log warning "E-mail was sent!"
}

## ftp module
:if ($SendToFTP) do={
:do {:log warning "Backups will be sended via FTP"} on-error={:log error "Error while sending Backup via FTP"}
}

## SyncFolder module
:if ($PutToSyncFolder) do={
:do {:log warning "Backups will be puted in SYNC folder"} on-error={:log error "Error while trying to put Backup in sync folder"}
}

##Cleaning up module
:do {
:log warning "Removing files..."
/file remove "$EVfilename"
/file remove "$BCKPfilename"
:log warning "Files removed."
} on-error={:log error "Failed to clean-up files";}

## debug module
#:log warning "export done"
#:log info "$timedate"
#:log info "$identity"
#:log info "$model ($SN)"
#:log info "RouterBoard: $RBC"
#:log info "$EVfilename"
#:log info "$ECfilename"
#:log info "$BCKPfilename"
#:log info $filesgroup