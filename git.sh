#!/bin/sh
cd /c/Users/Administrator/Desktop/BMS_DB_bkp/BMS_backup
git status
git reset --soft 1e6a5ba45e6facf8df3c9da1ff5634728fe6170e
git add .
git commit -m "`date`"
git push --force origin master
