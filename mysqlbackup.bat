:: Auto MySQL Backup For Windows Servers By Matt Moeller  v.1.5
:: RED OLIVE INC.  - www.redolive.com

:: Follow us on twitter for updates to this script  twitter.com/redolivedesign
:: coming soon:  email admin a synopsis of the backup with total file size(s) and time it took to execute

:: FILE HISTORY ----------------------------------------------
:: UPDATE 11.7.2012  Added setup all folder paths into variables at the top of the script to ease deployment
:: UPDATE 7.16.2012  Added --routines, fix for dashes in filename, and fix for regional time settings
:: UPDATE 3.30.2012  Added error logging to help troubleshoot databases backup errors.   --log-error="D:\temp\bms_bkp\dumperrors.txt"
:: UPDATE 12.29.2011 Added time bug fix and remote FTP options - Thanks to Kamil Tomas 
:: UPDATE 5.09.2011  v 1.0 


:: If the time is less than two digits insert a zero so there is no space to break the filename

:: If you have any regional date/time issues call this include: getdate.cmd  credit: Simon Sheppard for this cmd - untested
:: call getdate.cmd

set year=%DATE:~10,4%
set day=%DATE:~7,2%
set mnt=%DATE:~4,2%
set hr=%TIME:~0,2%
set min=%TIME:~3,2%

IF %day% LSS 10 SET day=0%day:~1,1%
IF %mnt% LSS 10 SET mnt=0%mnt:~1,1%
IF %hr% LSS 10 SET hr=0%hr:~1,1%
IF %min% LSS 10 SET min=0%min:~1,1%

::set backuptime=%year%-%day%-%mnt%-%hr%-%min%
set backuptime=%year%-%mnt%-%day%-%hr%-%min%
echo %backuptime%



:: SETTINGS AND PATHS 
:: Note: Do not put spaces before the equal signs or variables will fail

:: Name of the database user with rights to all tables
set dbuser=root

:: Password for the database user
set dbpass=09C42tUc1Z

:: Error log path - Important in debugging your issues
set errorLogPath="C:\Users\Administrator\Desktop\BMS_DB_bkp\%backuptime%\dumperrors.txt"

:: MySQL EXE Path
set mysqldumpexe="C:\BMS4\infrastructure\mysql\bin\mysqldump.exe"

:: Error log path
set backupfldr=C:\Users\Administrator\Desktop\BMS_DB_bkp\%backuptime%\
set zipfldr=C:\Users\Administrator\Desktop\BMS_DB_bkp\%backuptime%
set targetfldr=C:\googleSync\backups\%backuptime%
set targetfldr7Z=C:\googleSync\backups\%backuptime%.7z
echo %targetfldr7z%

mkdir %backupfldr%

timeout 10 > NUL

:: Path to data folder which may differ from install dir
set datafldr="C:\BMS4\data"


:: DONE WITH SETTINGS



:: GO FORTH AND BACKUP EVERYTHING!

:: Switch to the data directory to renumerate the folders
pushd %datafldr%

echo "Pass each name to mysqldump.exe and output an individual .sql file for each"

:: Thanks to Radek Dolezel for adding the support for dashes in the db name
:: Added --routines thanks for the suggestion Angel

:: turn on if you are debugging
@echo off

FOR /D %%F IN (*) DO (

IF NOT [%%F]==[performance_schema] (
SET %%F=!%%F:@002d=-!
%mysqldumpexe% --user=%dbuser% --password=%dbpass% --port 43306 --databases --routines --log-error=%errorLogPath% %%F > "%backupfldr%%%F.%backuptime%.sql"
) ELSE (
echo Skipping DB backup for performance_schema
)
)



echo "done"

::return to the main script dir on end
popd

echo "Zip start"
echo "%zipfldr%"
echo "Target file %targetfldr%"
7z a "%targetfldr%" %zipfldr%
echo "Zip end"

echo "Deleting unzipped file"
echo "%zipfldr%"
rmdir %zipfldr% /s /q
echo "Deleted unzipped file"

echo "Starting backup to git"
set bmsOrgFolder="C:\Users\Administrator\Desktop\BMS_DB_bkp\BMS_backup\BMS_ORG"
cd /d %bmsOrgFolder%
for /F "delims=" %%i in ('dir /b') do (rmdir "%%i" /s/q || del "%%i" /s/q)	
xcopy "%targetfldr7Z%" "%bmsOrgFolder%"
set folder="C:\Users\Administrator\Desktop\BMS_DB_bkp"
cd /d %folder%
bash git.sh
echo "Completed backup to git"