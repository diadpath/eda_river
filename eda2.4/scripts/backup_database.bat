@echo off
   for /f "tokens=1-3 delims=- " %%i in ("%date%") do (
     set year=%%i
     set month=%%j
     set day=%%k
   )
   echo day is %day%
   set datestr=%year%_%month%_%day%
   echo datestr is %datestr%
    
   set BACKUP_FILE_WORK=worksweden%datestr%.backup
   echo backup file name is %BACKUP_FILE_WORK%
   set BACKUP_FILE_RAWDATA=rawdata%datestr%.backup
   echo backup file name is %BACKUP_FILE_RAWDATA%
   SET PGPASSWORD=postgres
   echo on
   
pg_dump -U postgres -f L:\EDA_database\%BACKUP_FILE_WORK% -Fc --schema sweden eda2.4
pg_dump -U postgres -f C:\Torbjorn_R\Projects\EDA\eda_rivers\eda2.4\database_backup\%BACKUP_FILE_WORK% -Fc --schema sweden eda2.4
pg_dump -U postgres -f L:\EDA_database\%BACKUP_FILE_RAWDATA% -Fc --schema rawdata eda2.4
pg_dump -U postgres -f C:\Torbjorn_R\Projects\EDA\eda_rivers\eda2.4\database_backup\%BACKUP_FILE_RAWDATA% -Fc --schema rawdata eda2.4