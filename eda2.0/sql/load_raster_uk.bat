REM Nécessite postgis 2.0 et python

REM transformation du raster en sql
c:\python27\python e:\postgresql\9.1\bin\raster2pgsql.py -r "E:\Mes documents\Mes dossiers\ANGUILLE\EDA\20110622\River width UK\w001001.adf" -t uk.raster_uk -o raster_uk.sql -v -s 27700 -k 50x50 -b 1 -I -M
REM chargement du sql dans postgresql
e:\postgresql\9.1\bin\psql -f raster_uk.sql -h localhost -p 5433 -d essai_raster -U postgres 

REM pour admirer le travail ... et éviter que la fenêtre DOS ne se ferme avant d'avoir pu voir un éventuel message d'erreur
pause