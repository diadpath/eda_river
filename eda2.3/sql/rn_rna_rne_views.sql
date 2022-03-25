DROP VIEW IF EXISTS dbeel_rivers.rn_rna CASCADE;
CREATE  VIEW dbeel_rivers.rn_rna AS 
 SELECT rn.idsegment,
    rn.source,
    rn.target,
    rn.lengthm,
    rn.nextdownidsegment,
    rn.path,
    rn.isfrontier,
    rn.issource,
    rn.seaidsegment,
    rn.issea,
    rn.geom,
    rn.isendoreic,
    rn.isinternational,
    rn.country,
    rna.altitudem,
    rna.distanceseam,
    rna.distancesourcem,
    rna.cumnbdam,
    rna.medianflowm3ps,
    rna.surfaceunitbvm2,
    rna.surfacebvm2,
    rna.strahler,
    rna.shreeve,
    rna.codesea,
    rna.name,
    rna.pfafriver,
    rna.pfafsegment,
    rna.basin,
    rna.riverwidthm,
    rna.riverwidthmsource,
    rna.temperature,
    rna.temperaturejan,
    rna.temperaturejul,
    rna.wettedsurfacem2,
    rna.wettedsurfaceotherm2,
    rna.lengthriverm,
    rna.emu,
    rna.cumheightdam,
    rna.slope,
    rna.dis_m3_pyr_riveratlas,
    rna.dis_m3_pmn_riveratlas,
    rna.dis_m3_pmx_riveratlas,
    rna.drought,
    rna.drought_type_calc
   FROM dbeel_rivers.rn
     JOIN dbeel_rivers.rna ON rna.idsegment = rn.idsegment;


drop view if exists portugal.rn_rna CASCADE;
create view portugal.rn_rna AS (
 SELECT rn.idsegment,
    rn.source,
    rn.target,
    rn.lengthm,
    rn.nextdownidsegment,
    rn.path,
    rn.isfrontier,
    rn.issource,
    rn.seaidsegment,
    rn.issea,
    rn.geom,
    rn.isendoreic,
    rn.isinternational,
    rn.country,
    rna.altitudem,
    rna.distanceseam,
    rna.distancesourcem,
    rna.cumnbdam,
    rna.medianflowm3ps,
    rna.surfaceunitbvm2,
    rna.surfacebvm2,
    rna.strahler,
    rna.shreeve,
    rna.codesea,
    rna.name,
    rna.pfafriver,
    rna.pfafsegment,
    rna.basin,
    rna.riverwidthm,
    rna.riverwidthmsource,
    rna.temperature,
    rna.temperaturejan,
    rna.temperaturejul,
    rna.wettedsurfacem2,
    rna.wettedsurfaceotherm2,
    rna.lengthriverm,
    rna.emu,
    rna.cumheightdam,
    rna.slope,
    rna.dis_m3_pyr_riveratlas,
    rna.dis_m3_pmn_riveratlas,
    rna.dis_m3_pmx_riveratlas,
    drought,
    drought_type_calc
    

from portugal.rn join portugal.rna 
on rna.idsegment=rn.idsegment);


drop view if exists spain.rn_rna  CASCADE;

create view spain.rn_rna AS (
 SELECT rn.idsegment,
    rn.source,
    rn.target,
    rn.lengthm,
    rn.nextdownidsegment,
    rn.path,
    rn.isfrontier,
    rn.issource,
    rn.seaidsegment,
    rn.issea,
    rn.geom,
    rn.isendoreic,
    rn.isinternational,
    rn.country,
    rna.altitudem,
    rna.distanceseam,
    rna.distancesourcem,
    rna.cumnbdam,
    rna.medianflowm3ps,
    rna.surfaceunitbvm2,
    rna.surfacebvm2,
    rna.strahler,
    rna.shreeve,
    rna.codesea,
    rna.name,
    rna.pfafriver,
    rna.pfafsegment,
    rna.basin,
    rna.riverwidthm,
    rna.riverwidthmsource,
    rna.temperature,
    rna.temperaturejan,
    rna.temperaturejul,
    rna.wettedsurfacem2,
    rna.wettedsurfaceotherm2,
    rna.lengthriverm,
    rna.emu,
    rna.cumheightdam,
    rna.slope,
    rna.dis_m3_pyr_riveratlas,
    rna.dis_m3_pmn_riveratlas,
    rna.dis_m3_pmx_riveratlas,
    drought,
    drought_type_calc

FROM spain.rn join spain.rna 
on rna.idsegment=rn.idsegment);



drop view if exists france.rn_rna  CASCADE;
create view france.rn_rna AS
 SELECT rn.idsegment,
    rn.source,
    rn.target,
    rn.lengthm,
    rn.nextdownidsegment,
    rn.path,
    rn.isfrontier,
    rn.issource,
    rn.seaidsegment,
    rn.issea,
    rn.geom,
    rn.isendoreic,
    rn.isinternational,
    rn.country,
    rna.altitudem,
    rna.distanceseam,
    rna.distancesourcem,
    rna.cumnbdam,
    rna.medianflowm3ps,
    rna.surfaceunitbvm2,
    rna.surfacebvm2,
    rna.strahler,
    rna.shreeve,
    rna.codesea,
    rna.name,
    rna.pfafriver,
    rna.pfafsegment,
    rna.basin,
    rna.riverwidthm,
    rna.riverwidthmsource,
    rna.temperature,
    rna.temperaturejan,
    rna.temperaturejul,
    rna.wettedsurfacem2,
    rna.wettedsurfaceotherm2,
    rna.lengthriverm,
    rna.emu,
    rna.cumheightdam,
    rna.slope,
    rna.dis_m3_pyr_riveratlas,
    rna.dis_m3_pmn_riveratlas,
    rna.dis_m3_pmx_riveratlas,
    drought,
    drought_type_calc
from france.rn join france.rna 
on rna.idsegment=rn.idsegment;

DROP VIEW IF EXISTS dbeel_rivers.rn_rne;
CREATE VIEW dbeel_rivers.rn_rne AS 
SELECT 
row_number() over() AS _uid_,
rne.*
,  
rn.geom, rn.country
FROM dbeel_rivers.rn
JOIN dbeel_rivers.rne ON 
rn.idsegment = rne.idsegment
;


DROP VIEW IF EXISTS france.rn_rne;
CREATE VIEW france.rn_rne AS 
SELECT 
row_number() over() AS _uid_,
rne.*
,  
rn.geom, rn.country
FROM france.rn
JOIN france.rne ON 
rn.idsegment = rne.idsegment
;

DROP VIEW IF EXISTS spain.rn_rne;
CREATE VIEW spain.rn_rne AS 
SELECT 
row_number() over() AS _uid_,
rne.*
,  
rn.geom, rn.country
FROM spain.rn
JOIN spain.rne ON 
rn.idsegment = rne.idsegment
;

DROP VIEW IF EXISTS portugal.rn_rne;
CREATE VIEW portugal.rn_rne AS 
SELECT 
row_number() over() AS _uid_,
rne.*
,  
rn.geom, rn.country
FROM portugal.rn
JOIN portugal.rne ON 
rn.idsegment = rne.idsegment
;

/**
 * Views for all
 */
DROP VIEW IF EXISTS dbeel_rivers.rn_rna_rne;
CREATE VIEW dbeel_rivers.rn_rna_rne AS 
SELECT 
row_number() over() AS _uid_,
rne.*,
codesea,
"name",
basin,
emu,
rn.country,
rn.geom, 
rna.altitudem,
rna.distanceseam,
rna.cumheightdam,
rna.riverwidthm,
rna.wettedsurfacem2,
rna.wettedsurfaceotherm2,
rna.lengthriverm,
rna.slope
FROM dbeel_rivers.rn
JOIN dbeel_rivers.rne ON 
rn.idsegment = rne.idsegment
JOIN dbeel_rivers.rna ON 
rn.idsegment = rna.idsegment
;


DROP VIEW IF EXISTS spain.rn_rna_rne;
CREATE VIEW spain.rn_rna_rne AS 
SELECT 
row_number() over() AS _uid_,
rne.*,
codesea,
"name",
basin,
emu,
rn.geom, rn.country
FROM spain.rn
JOIN spain.rne ON 
rn.idsegment = rne.idsegment
JOIN spain.rna ON 
rn.idsegment = rna.idsegment
;

DROP VIEW IF EXISTS portugal.rn_rna_rne;
CREATE VIEW portugal.rn_rna_rne AS 
SELECT 
row_number() over() AS _uid_,
rne.*,
codesea,
"name",
basin,
emu,
rn.geom, rn.country
FROM portugal.rn
JOIN portugal.rne ON 
rn.idsegment = rne.idsegment
JOIN portugal.rna ON 
rn.idsegment = rna.idsegment
;

DROP VIEW IF EXISTS france.rn_rna_rne;
CREATE VIEW france.rn_rna_rne AS 
SELECT 
row_number() over() AS _uid_,
rne.*,
codesea,
"name",
basin,
emu,
rn.geom, rn.country
FROM france.rn
JOIN france.rne ON 
rn.idsegment = rne.idsegment
JOIN france.rna ON 
rn.idsegment = rna.idsegment
;


/**
 * Mediterranean view
 */
DROP VIEW IF EXISTS dbeel_rivers.rn_rna_rne_med;
CREATE VIEW dbeel_rivers.rn_rna_rne_med AS 
SELECT 
row_number() over() AS _uid_,
rne.*,
codesea,
"name",
basin,
emu,
rn.geom, rn.country
FROM dbeel_rivers.rn
JOIN dbeel_rivers.rne ON 
rn.idsegment = rne.idsegment
JOIN dbeel_rivers.rna ON 
rn.idsegment = rna.idsegment
where codesea = 'M'
;



/**
 * GT6 pilot basins
 * 
 * Creating a view of rn_rna from the pilot basins to use in Shiny
**/

/*
PT32156		Miño
PT56183		Mondego
SP188069	Ulla
SP224290	Oria
SP234982	Nalon
SP128132	Ter
FR119788	Nivelle
SP109916	Guadalquivir
SP118297	Guadiaro
FR23750 	Bages-Sigean
*/

DROP VIEW IF EXISTS dbeel_rivers.rn_rna_gt6;
CREATE VIEW dbeel_rivers.rn_rna_gt6 AS 
SELECT 
row_number() over() AS _uid_,
codesea,
"name",
basin,
emu,
rn.geom, rn.country, rn.idsegment 
FROM dbeel_rivers.rn
JOIN dbeel_rivers.rna ON 
rn.idsegment = rna.idsegment
where seaidsegment in ('PT32156', 'PT56183', 'SP188069', 'SP224290', 'SP234982', 'SP128132', 'FR119788', 'SP109916', 'SP118297', 'FR23750')
;


CREATE TABLE france.tr_bages_sigean AS 
  SELECT *
  FROM france.tr_lagunes
  WHERE lag_id = 6;



/**
* Geo Schema with simple tables to Geoserver
**/

-- CREATE TABLESPACE geoserver LOCATION '/data/dbs';
CREATE SCHEMA geo;

--	EEL ATLAS
drop table if exists geo.delta;
CREATE table geo.delta AS (
 SELECT rn.idsegment, delta, st_transform(geom,4326) geom  FROM dbeel_rivers.rne JOIN dbeel_rivers.rn ON rn.idsegment = rne.idsegment); 
-- tablespace geoserver; -- 515011 rows

drop table if exists geo.gamma;
CREATE table geo.gamma AS (
 SELECT rn.idsegment, gamma, st_transform(geom,4326) geom  FROM dbeel_rivers.rne JOIN dbeel_rivers.rn ON rn.idsegment = rne.idsegment); 
-- tablespace geoserver; -- 515011 rows

drop table if exists geo.density;
CREATE table geo.density AS (
 SELECT rn.idsegment, density, st_transform(geom,4326) geom  FROM dbeel_rivers.rne JOIN dbeel_rivers.rn ON rn.idsegment = rne.idsegment); 
-- tablespace geoserver; -- 515011 rows

drop table if exists geo.neel;
CREATE table geo.neel AS (
 SELECT rn.idsegment, neel, st_transform(geom,4326) geom  FROM dbeel_rivers.rne JOIN dbeel_rivers.rn ON rn.idsegment = rne.idsegment); 
-- tablespace geoserver; -- 515011 rows

drop table if exists geo.nsilver;
CREATE table geo.nsilver AS (
 SELECT rn.idsegment, nsilver, st_transform(geom,4326) geom  FROM dbeel_rivers.rne JOIN dbeel_rivers.rn ON rn.idsegment = rne.idsegment); 
-- tablespace geoserver; -- 515011 rows

 drop table if exists geo.beel;
CREATE table geo.beel AS (
 SELECT rn.idsegment, beel, st_transform(geom,4326) geom  FROM dbeel_rivers.rne JOIN dbeel_rivers.rn ON rn.idsegment = rne.idsegment); 
-- tablespace geoserver; -- 515011 rows

drop table if exists geo.bsilver;
CREATE table geo.bsilver AS (
 SELECT rn.idsegment, bsilver, st_transform(geom,4326) geom  FROM dbeel_rivers.rne JOIN dbeel_rivers.rn ON rn.idsegment = rne.idsegment); 
-- tablespace geoserver; -- 515011 rows


--	OBSTACLES TO MIGRATION
drop table if exists geo.altitudem;
CREATE table geo.altitudem AS (
 SELECT rn.idsegment, altitudem, st_transform(geom,4326) geom  FROM dbeel_rivers.rna JOIN dbeel_rivers.rn ON rn.idsegment = rna.idsegment); 
-- tablespace geoserver; -- 515011 rows

 drop table if exists geo.distanceseam;
CREATE table geo.distanceseam AS (
 SELECT rn.idsegment, distanceseam, st_transform(geom,4326) geom  FROM dbeel_rivers.rna JOIN dbeel_rivers.rn ON rn.idsegment = rna.idsegment); 
-- tablespace geoserver; -- 515011 rows

drop table if exists geo.cumnbdam;
CREATE table geo.cumnbdam AS (
 SELECT rn.idsegment, cumnbdam, st_transform(geom,4326) geom  FROM dbeel_rivers.rna JOIN dbeel_rivers.rn ON rn.idsegment = rna.idsegment); 
-- tablespace geoserver; -- 515011 rows

drop table if exists geo.cumheightdam;
CREATE table geo.cumheightdam AS (
 SELECT rn.idsegment, cumheightdam, st_transform(geom,4326) geom  FROM dbeel_rivers.rna JOIN dbeel_rivers.rn ON rn.idsegment = rna.idsegment); 
-- tablespace geoserver; -- 515011 rows

drop table if exists geo.drought;
CREATE table geo.drought AS (
 SELECT rn.idsegment, drought, st_transform(geom,4326) geom  FROM dbeel_rivers.rna JOIN dbeel_rivers.rn ON rn.idsegment = rna.idsegment); 
-- tablespace geoserver; -- 515011 rows
 

--	SAMPLING NETWORK
 drop table if exists geo.rn_gt6;
CREATE table geo.rn_rna_gt6 AS (
 SELECT idsegment, st_transform(geom,4326) geom  FROM dbeel_rivers.rn where seaidsegment in 
 ('PT32156', 'PT56183', 'SP188069', 'SP224290', 'SP234982', 'SP128132', 'FR119788', 'SP109916', 'SP118297', 'FR23750'));
-- tablespace geoserver; -- 71029 rows


SELECT st_srid(geom) FROM geo.altitudem;


--	Exporting surfaces of Basque Country
select * from spain.rn_rna where seaidsegment = 'SP224290';
select * from spain.waterbody_unitbv limit 10;

select idsegment, basin, wettedsurfacem2 as sum(wettedsurfacem2), wettedsurfaceotherm2 as sum(wettedsurfaceotherm2) from spain.rn_rna where emu = 'ES_Basq' group by basin, idsegment;

select seaidsegment, sum(wettedsurfacem2) as wettedsurfacem2, sum(wettedsurfaceotherm2) as wettedsurfaceotherm2 from spain.rn_rna 
	where seaidsegment in ('SP224290', 'SP224731', 'SP224959', 'SP225156', 'SP225412', 'SP225539', 'SP225829', 'SP225867', 'SP225961', 'SP225992', 'SP4452') group by seaidsegment;

--	Exporting eel information of Basque Country
select seaidsegment, year, sum(nsilver) as nsilver, sum(nyellow) as nyellow, sum(nsilver_r) as nsilver_r,
	sum(nsilver_o) as nsilver_o, sum(byellow) as byellow, sum(bsilver) as bsilver from dbeel_rivers.rne_annual 
	where seaidsegment in ('SP224290', 'SP224731', 'SP224959', 'SP225156', 'SP225412', 'SP225539', 'SP225829', 'SP225867', 
	'SP225961', 'SP225992', 'SP4452') group by seaidsegment, year;


select * from dbeel_rivers.rne_annual limit 10;
select * from spain.rn_rna_rne rr limit 10;
select distinct emu from spain.rn_rna_rne;

/**
 * Galicia view for Fernando Pazos who is checking the data for postevaluation
 */
DROP VIEW IF EXISTS spain.rn_rna_rne_galicia;
CREATE VIEW spain.rn_rna_rne_galicia AS 
SELECT 
row_number() over() AS _uid_,
rn.seaidsegment,
rna."name",
rna.basin,
rna.emu,
rna.lengthriverm, 
rna.altitudem, 
rna.riverwidthm, 
rna.wettedsurfacem2, 
rna.wettedsurfaceotherm2,
rne.delta,
rne.neel,
rne.beel,
rne.nsilver,
rne.bsilver,
rne.cnsilver,
rne.neel_wd,
rne.beel_wd,
rne.nsilver_wd,
rne.bsilver_wd,
rne.is_current_distribution_area,
rne.is_pristine_distribution_area_1985,
rn.geom
FROM spain.rn
JOIN spain.rne ON 
rn.idsegment = rne.idsegment
JOIN spain.rna ON 
rn.idsegment = rna.idsegment
where emu = 'ES_Gali'
;
