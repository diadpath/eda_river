#----------------------------------------------------------------------------
# script de création de la base à partir d'un batch command
# @author cedric pour memo
# attention compatibilité postgres 8.3 
#---------------------------------------------------------------
REM il faut d'abord transformer les couches en shape et les placer dans un répertoire.
REM changement du répertoire de travail
cd C:\Documents and Settings\cedric\Mes documents\Migrateur\eda\couches_SIG\coucheccm\CCM France
REM  à partir du programme shp2pqsql création d'un fichier sql (ci dessous un exemple)
REM C:\PostgresPlus\8.3\bin\shp2pgsql -? 
C:\PostgresPlus\8.3\bin\shp2pgsql -s 3035 CATCHMENTS catchments > catchments.sql
C:\PostgresPlus\8.3\bin\psql -d CCM -h localhost -U postgres -f catchments.sql 
C:\PostgresPlus\8.3\bin\shp2pgsql -s 3035 COAST coast > coast.sql
C:\PostgresPlus\8.3\bin\psql -d CCM -h localhost -U postgres -f coast.sql 
C:\PostgresPlus\8.3\bin\shp2pgsql -s 3035 ISLANDS islands > islands.sql
C:\PostgresPlus\8.3\bin\psql -d CCM -h localhost -U postgres -f islands.sql 
C:\PostgresPlus\8.3\bin\shp2pgsql -s 3035 LAKES lakes > lakes.sql
C:\PostgresPlus\8.3\bin\psql -d CCM -h localhost -U postgres -f lakes.sql 
C:\PostgresPlus\8.3\bin\shp2pgsql -s 3035 MAINRIVERS mainrivers > mainrivers.sql
C:\PostgresPlus\8.3\bin\psql -d CCM -h localhost -U postgres -f mainrivers.sql 
C:\PostgresPlus\8.3\bin\shp2pgsql -s 3035 NAMEDRIVERS namedrivers > namedrivers.sql
C:\PostgresPlus\8.3\bin\psql -d CCM -h localhost -U postgres -f namedrivers.sql 
C:\PostgresPlus\8.3\bin\shp2pgsql -s 3035 RIVERNODES rivernodes > rivernodes.sql
C:\PostgresPlus\8.3\bin\psql -d CCM -h localhost -U postgres -f rivernodes.sql 
C:\PostgresPlus\8.3\bin\shp2pgsql -s 3035 RIVERSEGMENTS riversegments > riversegments.sql
C:\PostgresPlus\8.3\bin\psql -d CCM -h localhost -U postgres -f riversegments.sql 
C:\PostgresPlus\8.3\bin\shp2pgsql -s 3035 SEAOUTLETS seaoutlets > seaoutlets.sql
C:\PostgresPlus\8.3\bin\psql -d CCM -h localhost -U postgres -f seaoutlets.sql 
C:\PostgresPlus\8.3\bin\pg_dump -F c -U postgres -p 5432 CCM>CCM.dump
REM restoration using the create database command
C:\PostgresPlus\8.3\bin\pg_restore -C -U postgres -d CCM  db.dump