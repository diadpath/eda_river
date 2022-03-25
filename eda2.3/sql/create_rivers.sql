/*

CREATION OF FRENCH NETWORK on eda 2.2 and then dump
there is no reason to use varchar() use text instead https://www.depesz.com/2010/03/02/charx-vs-varcharx-vs-varchar-vs-text/
*/



CREATE TABLE spain.temp_correct_path AS SELECT idsegment, PATH  FROM spain.rn;

/*
CREATE THIS TABLE in EDA2.2 then dump it and copy it to a new French schema in eda2.0
*/
/*-----------------------------------------
               FRANCE
-----------------------------------------*/
create schema france;

-- this table is the mother table, that will be inherited by other. We need to copy it later to dbeel
-- constraints in mother table are useless !!!
DROP TABLE if exists france.rn0 CASCADE;
CREATE TABLE france.rn0 (gid integer,
			idsegment text,
			source integer,
			target integer,
			length numeric,
			nextdownidsegment text,
			path ltree,
			international boolean,
			frontiertarget integer,
			frontiersource integer,
			issource boolean,
			seaidsegment text,
			issea boolean,
			CONSTRAINT c_pk_idsegment primary key (idsegment),
			CONSTRAINT c_uk_source unique (source),
			CONSTRAINT c_fk_frontiersource FOREIGN KEY (frontiersource) references france.rn0(source),
			CONSTRAINT c_fk_seaidsegment FOREIGN KEY (seaidsegment) references france.rn0(idsegment)

			); --ok
SELECT AddGeometryColumn ('france','rn0','geom',3035,'MULTILINESTRING',2); --251 ms


CREATE INDEX indexrngeom
  ON france.rn0
  USING gist
  (geom);

CREATE INDEX indexpathbtree
  ON france.rn0
  USING btree
  (path);

 CREATE INDEX indexpathgist
  ON france.rn0
  USING gist
  (path);

  CREATE INDEX indexidsegmentrno
  ON france.rn0
  USING btree
  (idsegment);




CREATE TABLE france.rn (
			CONSTRAINT c_pk_rnidsegment primary key (idsegment),
			CONSTRAINT c_uk_rnsource unique (source),
			CONSTRAINT c_fk_rnfrontiersource FOREIGN KEY (frontiersource) references france.rn (source),
			CONSTRAINT c_fk_rnseaidsegment FOREIGN KEY (seaidsegment) references france.rn(idsegment))

			INHERITS (france.rn0); -- 54 ms
/*
trials
select id_drain,text2ltree('FR'||replace(ltree2text(chemin),'.','.FR'))  from rht.rhtvs2 where id_drain in (24171,24172,24173)
select nlevel(chemin) from rht.rhtvs2 where id_drain in (24171,24172,24173)
*/


CREATE INDEX indexrngeorn
  ON france.rn
  USING gist
  (geom);

CREATE INDEX indexpathbtreern
  ON france.rn
  USING btree
  (path);



  CREATE INDEX indexidsegmentrrn
  ON france.rn
  USING btree
  (idsegment);
				   
insert into france.rn 				
SELECT  gid,
	'FR'||rhtvs2.id_drain::text as idsegment,
	rhtvs2.fnode as source,
	rhtvs2.tnode as target,
	rhtvs2.length as length,
	CASE WHEN rhtvs2.nextdownid=-9999 THEN NULL
	ELSE 'FR'||rhtvs2.nextdownid end as nextdownidsegment,
	text2ltree('FR'||replace(ltree2text(chemin),'.','.FR')) as path,
	FALSE as international,
	NULL as frontiertarget,	
	NULL as frontiersource,	
	rhtvs2.noeudsource as issource,
	'FR'||id_drainmer AS seaidsegment,
	rhtvs2.noeudmer as issea,	  
	st_transform(rhtvs2.the_geom, 3035) as geom
	from rht.rhtvs2; -- 114564

select * from france.rn limit 10;
select * from france.rn0 limit 10;

DROP TABLE france.rna0 CASCADE;
CREATE TABLE france.rna0 (idsegment text primary key,
			altitudem numeric,
			distanceseam numeric,
			distancesourcem numeric,
			cumnbdam numeric,
			medianflowm3ps numeric,
			surfaceunitbvm2 numeric,
			surfacebvm2 numeric,
			strahler integer,
			shreeve integer,
			codesea text,
			name text,
			pfafriver text,
			pfafsegment text,
			basin text,
			riverwidthm numeric,
			temperature numeric,
			temperaturejan numeric,
			temperaturejul numeric,
			wettedsurfacem2 numeric,
			wettedsurfaceotherm2 numeric,
			delta numeric,
			gamma numeric,
			density numeric,
			nyellow numeric,
			pyellow150 numeric,
			pyellow150300 numeric,
			pyellow300450 numeric,
			pyellow450600 numeric,
			pyellow600750 numeric,
			pyellow750 numeric,
			nsilver numeric,
			nsilver300450 numeric,
			nsilver450600 numeric,
			nsilver600750 numeric,
			nsilver750 numeric,
			turbinemortalitynsilver numeric,
			turbinemortalityrate numeric);
create table france.rna (
	CONSTRAINT c_fk_rnaidsegment FOREIGN KEY (idsegment) references france.rn(idsegment)
) inherits (france.rna0);

insert into france.rna(idsegment, 
  altitudem, 
  distanceseam, 
  distancesourcem, 
  cumnbdam, 
  medianflowm3ps, 
  surfaceunitbvm2, 
  surfacebvm2, 
  strahler, 
  riverwidthm, 
  temperature, 
  temperaturejan, 
  temperaturejul, 
  wettedsurfacem2, 
  delta, 
  gamma, 
  density,
  nyellow,
  nsilver, 
  nsilver300450,
  nsilver450600,
  nsilver600750,
  nsilver750,
  turbinemortalitynsilver, 
  turbinemortalityrate)
	select 
  rn.idsegment, 
  a.altitude::numeric as altitudem, 
  r.dmer as distanceseam, 
  r.dsource*1000 as distancesourcem, 
  r.cumnbbar as cumnbdam, 
  a.module as medianflowm3ps, 
  a.sfbvu*1000000 as surfaceunitbvm2, 
  a.surf_bv*1000000 as surfacebvm2, 
  a.strahler, 
  c.largeur as riverwidthm, 
  r.temp_cru_2000 as temperature, 
  a.tjan_moy as temperaturejan, 
  a.tjuil_moy as temperaturejul, 
  c.surface as wettedsurfacem2, 
  c.delta, 
  c.gamma, 
  c.densite as density,
  c.abondance as nyellow,
  s.total as nsilver, 
  s."300_450" as nsilver300450,
  s."450_600" as nsilver450600,
  s."600_750" as nsilver600750,
  s."750" as nsilver750,
  c.nb_ar_mort_turb as turbinemortalitynumber  , 
  c.tx_mort_turb  as  turbinemortalityrate
  from france.rn 
  left join
  rht.rhtvs2 r on 'FR'||r.id_drain=idsegment 
  left join 
  rht.attributs_rht_fev_2011_vs2 a on 'FR'||a.id_drain=idsegment 
  left join
  rht.crosstab_rhtvs2 c  on 'FR'||c.id_drain=idsegment 
  left join
  rht.silver2017 s on 'FR'||s.id_drain=idsegment ;--114564
  --limit 10


/*
pg_dump -U postgres -f "france.sql" --verbose --schema france eda2.2
psql -U postgres -f "france.sql" eda2.0

pg_dump -U postgres -f "francerna.sql" --verbose --table france.rna0 --table france.rna eda2.2
psql -U postgres -f "francerna.sql" eda2.0
*/

/*
Now the "master table will be located into the dbeel schema
*/

alter table france.rn0 set schema dbeel
alter table dbeel_rivers.rn0 rename to rn;
alter table dbeel_rivers.rn add column isendoreic boolean; --NOTICE:  assemblage de la définition de la colonne « isendoreic » pour le fils « rn »
alter table dbeel_rivers.rn rename column international to isfrontier;
-- constraint in mother table are useless, they don't work, I drop them
ALTER TABLE dbeel_rivers.rn drop constraint c_uk_source;
ALTER TABLE dbeel_rivers.rn DROP CONSTRAINT c_fk_frontiersource;
ALTER TABLE dbeel_rivers.rn DROP CONSTRAINT c_fk_seaidsegment;
ALTER TABLE dbeel_rivers.rn rename column length to lengthm;
alter table france.rna0 set schema dbeel;
alter table dbeel_rivers.rna0 rename to rna;
select * from france.rn limit 1
select * from spain.rn limit 1

alter table dbeel_rivers.rn add column country Character varying(2);
update france.rn set country='FR';
update spain.rn set country='SP';
update portugal.rn set country='PT';

CREATE INDEX indexcountry
  ON france.rn
  USING btree
  (country);
CREATE INDEX indexcountry
  ON spain.rn
  USING btree
  (country);
 CREATE INDEX indexcountry
  ON portugal.rn
  USING btree
  (country); 

/* Some seanode are not real seanodes in the rht */
-- below I'm using the ccm to get the distance from the CCM and then get real sea nodes

/* adding some indexes in head tables 
this is useless, indexes must be in child tables
*/


CREATE INDEX indexrngeorn
  ON dbeel_rivers.rn
  USING gist
  (geom);


/*
gist index don't work in spain, values are too long

drop index spain.index_path_gist 
create index index_path_gist 
on spain.rn 
using gist (path);
*/

CREATE INDEX indexidsegmentrrn
  ON dbeel_rivers.rn
  USING btree
  (idsegment);

CREATE INDEX indexsourcern
  ON dbeel_rivers.rn
  USING btree
  (source);

CREATE INDEX indextargetrn
  ON dbeel_rivers.rn
  USING btree
  (target);
  



update france.rn set international= FALSE ;
with join_frontier as (
select idsegment,
	wso1_id,
	cum_len_sea,
	st_distance(ccm.the_geom,rn.geom) as distance
from france.rn 
join ccm21.riversegments ccm on st_dwithin(ccm.the_geom,rn.geom,500)
where issea 
order by idsegment, distance),
join_frontier_unique as
(
select distinct on (idsegment) idsegment, wso1_id,cum_len_sea
from  join_frontier
)
update france.rn set international= TRUE 
from join_frontier_unique jfu  where cum_len_sea> 10000
and jfu.idsegment = rn.idsegment



comment on COLUMN france.rn.idsegment is 'originated from column id_drain';

/*
One segments is located in the pyrenean montains with no outflow
*/
begin;
update france.rn set (isendoreic,international,issea) = (TRUE,FALSE,FALSE) where idsegment ='FR24081';
commit;


CREATE INDEX indexsourcern
  ON france.rn
  USING btree
  (source);

CREATE INDEX indextargetrn
  ON france.rn
  USING btree
  (target);
/*
Additional table
*/
DROP TABLE IF EXISTS dbeel_rivers.rna CASCADE;
CREATE TABLE dbeel_rivers.rna (idsegment text primary key,
			altitudem numeric,
			distanceseam numeric,
			distancesourcem numeric,
			cumnbdam numeric,
			medianflowm3ps numeric,
			surfaceunitbvm2 numeric,
			surfacebvm2 numeric,
			strahler integer,
			shreeve integer,
			codesea text,
			name text,
			pfafriver text,
			pfafsegment text,
			basin text,
			riverwidthm numeric,
			temperature numeric,
			temperaturejan numeric,
			temperaturejul numeric,
			wettedsurfacem2 numeric,
			wettedsurfaceotherm2 numeric,
			delta numeric,
			gamma numeric,
			density numeric,
			nyellow numeric,
			pyellow150 numeric,
			pyellow150300 numeric,
			pyellow300450 numeric,
			pyellow450600 numeric,
			pyellow600750 numeric,
			pyellow750 numeric,
			nsilver numeric,
			turbinemortalityn numeric,
			turbinemortalityrate numeric);
			
select * from dbeel_rivers.rna
comment on table dbeel_rivers.rna is 'Table of river network additional data';			
comment on column dbeel_rivers.rna.idsegment is 'Identifier (primay key) of the segment';
comment on column dbeel_rivers.rna.altitudem is 'altitude (in metre) of the segment';
comment on column dbeel_rivers.rna.distanceseam is 'Distance to the sea (in metre)';
comment on column dbeel_rivers.rna.distancesourcem is 'Distance to the farthest source (in metre)';
comment on column dbeel_rivers.rna.medianflowm3ps is 'Median flow (module) in the river (in m3 s-1), collected from rht (in France)';
comment on column dbeel_rivers.rna.surfaceunitbvm2 is 'Surface of the unit bv arround the segment in m2';
comment on column dbeel_rivers.rna.surfacebvm2 is 'Surface of basin upstream from the riversegment in m2';
comment on column dbeel_rivers.rna.strahler is 'Strahler rank';
comment on column dbeel_rivers.rna.shreeve is 'Shreeve rank (addition of the ranks where e.g. 1+3=4)';
comment on column dbeel_rivers.rna.codesea is 'Code of the sea';
comment on column dbeel_rivers.rna.name is 'Name of the river if exists';
comment on column dbeel_rivers.rna.pfafriver is 'code of the main river according to the  Pfafstetter hierarchichal coding system ';
comment on column dbeel_rivers.rna.pfafsegment is 'code of the segment according to the  Pfafstetter hierarchichal coding system ';
comment on column dbeel_rivers.rna.basin is 'Name of the hydrographic basin';
comment on column dbeel_rivers.rna.riverwidthm is 'River with as modelled from rht';
comment on column dbeel_rivers.rna.temperature is 'Mean river temperature in degree C from CCM';
comment on column dbeel_rivers.rna.temperaturejan is 'Mean january river temperature in degree C from RHT';
comment on column dbeel_rivers.rna.temperaturejul is 'Mean july river temperature in degree C from RHT';
comment on column dbeel_rivers.rna.wettedsurfacem2 is '(River width * length) in m2 * percentage not covered by water surface polygons';
comment on column dbeel_rivers.rna.wettedsurfaceotherm2 is 'Wetted surface from other layers projected by idsegment in m2';
alter table dbeel_rivers.rna add column lengthriverm numeric;
comment on column dbeel_rivers.rna.lengthriverm is 'Total length of the river from the farthest source';

/* TODO
delta
density
nyellow
pyellow150
pyellow150300
pyellow300450
pyellow450600
pyellow600750
pyellow750
nsilver
turbinemortalityn
turbinemortalityrate
*/
drop table if exists france.rna;

  
/*-----------------------------------------
               SPAIN
-----------------------------------------*/
DROP TABLE IF EXISTS spain.rn;
CREATE TABLE spain.rn (
			CONSTRAINT c_pk_rnidsegment primary key (idsegment),
			--CONSTRAINT c_uk_rnsource unique (source),
			--CONSTRAINT c_fk_rnfrontiersource FOREIGN KEY (frontiersource) references spain.rn (source),-- I have duplicated sources so I have to drop the constraint on source
			CONSTRAINT c_fk_rnseaidsegment FOREIGN KEY (seaidsegment) references spain.rn(idsegment))

			INHERITS (dbeel_rivers.rn); -- 54 ms
 			
/*
trials
select id_drain,text2ltree('FR'||replace(ltree2text(chemin),'.','.FR'))  from rht.rhtvs2 where id_drain in (24171,24172,24173)
select nlevel(chemin) from rht.rhtvs2 where id_drain in (24171,24172,24173)
*/


CREATE INDEX indexrngeorn
  ON spain.rn
  USING gist
  (geom);


/*
gist index don't work in spain, values are too long

drop index spain.index_path_gist 
create index index_path_gist 
on spain.rn 
using gist (path);
*/

CREATE INDEX indexidsegmentrrn
  ON spain.rn
  USING btree
  (idsegment);

CREATE INDEX indexsourcern
  ON spain.rn
  USING btree
  (source);

CREATE INDEX indextargetrn
  ON spain.rn
  USING btree
  (target);
  
				   
insert into spain.rn 				
SELECT  gid,
	'SP'||gid::text as idsegment,
	source,
	rivers.target,
	lngtramo_m as lengthm,	
	'SP'||nextdownid as nextdownidsegment,
	text2ltree('SP'||replace(ltree2text(chemin),'.','.SP')) as path,
	FALSE as international,
	CASE WHEN downstream_points.target is null then null-- pas de point
	     WHEN downstream_points.target is not null and frontier then downstream_points.target
	     END as frontiertarget,	
	NULL as frontiersource,	 --todo later
	sourcenode as issource,
	CASE WHEN downstream_points.target is null then null-- pas de point
	     WHEN downstream_points.target is not null and at_sea then 'SP'||gid
	     END as seaidsegment,
	case when at_sea is null	then false 
	else at_sea end as issea,	  
	st_transform(geom, 3035) as geom
	from spain.rivers
	left join spain.downstream_points on rivers.target=downstream_points.target ;-- 325607 


begin;
update spain.rn set isendoreic = TRUE where target in (
select target from  spain.downstream_points
 where at_sea=FALSE and frontier=FALSE);--275
commit; 


select target from  spain.downstream_points
 where at_sea=FALSE and frontier=FALSE


create table spain.temppoly (gid serial);
SELECT AddGeometryColumn ('spain','temppoly','geom',3035,'POLYGON',2); --251 ms


-- creation d'un polygone à la main pour les noeuds mer et correction des endoreics

begin;
update spain.rn set (isendoreic,issea)=(FALSE, TRUE) where idsegment in (
SELECT idsegment from  spain.temppoly  join spain.rn on st_intersects(temppoly.geom, rn.geom) where rn.isendoreic=TRUE); --41 + 21
commit;

Comment on COLUMN spain.rn.idsegment is 'originated from column gid';


-- 10/10/2109 Problèmes de parcours aval


CREATE INDEX indexnextdownidsegment
  ON spain.rn
  USING btree
  (nextdownidsegment COLLATE pg_catalog."default");

SELECT nextdownidsegment, idsegment from spain.rn 
EXCEPT 
select rn.nextdownidsegment, rn.idsegment from spain.rn join
spain.rn rn2 on  rn.nextdownidsegment=rn.idsegment

-- additional table
create table spain.rna (
	CONSTRAINT c_fk_rnaidsegment FOREIGN KEY (idsegment) references france.rn(idsegment)
) inherits (dbeel_rivers.rna);


insert into spain.rna
(idsegment, 
  altitudem, 
  distanceseam, 
  distancesourcem, 
  cumnbdam, 
  medianflowm3ps, 
  surfaceunitbvm2, 
  surfacebvm2, 
  strahler, 
  riverwidthm, 
  temperature, 
  temperaturejan, 
  temperaturejul, 
  wettedsurfacem2, 
  delta, 
  gamma, 
  density,
  nyellow,
  nsilver, 
  nsilver300450,
  nsilver450600,
  nsilver600750,
  nsilver750,
  turbinemortalitynsilver, 
  turbinemortalityrate,
  codesea,
  name,
  pfafriver,
  pfafsegment,
  lengthriverm,
  basin)
  SELECT 
  rn.idsegment, 
  NULL as altitudem, 
  r.dmer as distanceseam, 
  NULL distancesourcem, -- TODO CALCULATE DISTANCE SOURCE
  NULL as cumnbdam, 
  NULL as medianflowm3ps, 
  b2.shape_area as surfaceunitbvm2, -- this is the surface of the whole basin
  b1.shape_area as surfacebvm2, -- this is the surface of the lowest level basin (the might be serveral pfafcuen for one pfafrio
  NULL AS strahler, 
  r.riverwidth as riverwidthm, -- first raw model NOT TO BE USED !!!
  NULL as temperature,   -- TODO update temperatures
  NULL as temperaturejan, 
  NULL as temperaturejul, 
  NULL as wettedsurfacem2, 
  NULL AS delta, 
  NULL AS gamma, 
  NULL as density,
  NULL as nyellow,
  dens_silver_pred as nsilver, --ATTENTION TEMPORARY
  NULL as nsilver300450,
  NULL as nsilver450600,
  NULL as nsilver600750,
  NULL as nsilver750,
  NULL as turbinemortalitynumber  , 
  NULL  as  turbinemortalityrate,
  r.code_mar AS codesea,
  r.nom_rio AS name,
  r.pfafrio AS pfafriver,
  r.pfafsegment AS pfafsegment,
  r.lengthriverm AS lengthriverm,
  r.basin AS basin
  from spain.rn 
  left join
  spain.rivers r on 'SP'||r.gid::text =idsegment 
  left join 
  spain.basins b1 on b1.cod_uni=rivers.cod_uni
   LEFT JOIN 
   spain.basins b2 ON b2.pfafrio=r.pfafrio -- this join corresponds to several segments (eg ebro is 2004)
   limit 10

  -- some mistakes on the first round, to be corrected now
SELECT * from spain.rna JOIN spain.rivers r on 'SP'||r.gid::text =idsegment  join spain.basins on basins.cod_uni= r.cod_uni limit 10
/*--------------------------------------------------------------------------------
                            PORTUGAL
----------------------------------------------------------------------------------*/
DROP TABLE IF EXISTS portugal.rn;
CREATE TABLE portugal.rn (
			CONSTRAINT c_pk_rnidsegment primary key (idsegment),
			--CONSTRAINT c_uk_rnsource unique (source),
			--CONSTRAINT c_fk_rnfrontiersource FOREIGN KEY (frontiersource) references portugal.rn (source),-- I have duplicated sources so I have to drop the constraint on source
			CONSTRAINT c_fk_rnseaidsegment FOREIGN KEY (seaidsegment) references portugal.rn(idsegment))

			INHERITS (dbeel_rivers.rn); -- 54 ms
 			
/*
trials
select id_drain,text2ltree('FR'||replace(ltree2text(chemin),'.','.FR'))  from rht.rhtvs2 where id_drain in (24171,24172,24173)
select nlevel(chemin) from rht.rhtvs2 where id_drain in (24171,24172,24173)
*/


CREATE INDEX indexrngeorn
  ON portugal.rn
  USING gist
  (geom);

/*
drop index portugal.index_path_gist 
create index index_path_gist 
on portugal.rn 
using gist (path);
*/

CREATE INDEX indexidsegmentrrn
  ON portugal.rn
  USING btree
  (idsegment);


  CREATE INDEX indexsourcern
  ON portugal.rn
  USING btree
  (source);

CREATE INDEX indextargetrn
  ON portugal.rn
  USING btree
  (target);

/*
verif if portugal hydroid is unique ... OK

select hydroid, count(*) as count
from (
select *
from portugal.rivers
) as a
group by hydroid
having count(*) >= 2
*/

insert into portugal.rn 				
SELECT  rivers.gid,
	'PT'||rivers.gid::text as idsegment,
	rivers.source,
	rivers.target,
	rivers.st_length_ as lengthm,	
	'PT'||r2.gid as nextdownidsegment,
	text2ltree('PT'||replace(ltree2text(rivers.chemin),'.','.PT')) as path,
	FALSE as international,
        NULL as frontiertarget,	
	NULL as frontiersource,	 
	NULL as sourcenode, --TODO
	CASE WHEN downstream_points.target is null then null-- pas de point
	     WHEN downstream_points.target is not null and at_sea then 'PT'||rivers.gid
	     END as seaidsegment,
	case when at_sea is null	then false 
	else at_sea end as issea,	  
	st_transform(rivers.geom, 3035) as geom
	from portugal.rivers
	left join portugal.rivers r2 on rivers.target=r2.source
	left join portugal.downstream_points on rivers.target=downstream_points.target 
	
	where not rivers.in_spain;-- 75679 on 101231 17s

Comment on COLUMN portugal.rn.idsegment is 'originated from column hydroid';

ALTER TABLE france.rna ADD PRIMARY KEY (idsegment);
ALTER TABLE spain.rna ADD PRIMARY KEY (idsegment);
drop table if exists portugal.rna;
create table portugal.rna (
	CONSTRAINT c_fk_rnaidsegment FOREIGN KEY (idsegment) references portugal.rn(idsegment),
	CONSTRAINT c_pk_rnaidsegment PRIMARY KEY (idsegment)
) inherits (dbeel_rivers.rna);


insert into portugal.rna
(idsegment, 
  altitudem, 
  distanceseam, 
  distancesourcem, 
  cumnbdam, 
  medianflowm3ps, 
  surfaceunitbvm2, 
  surfacebvm2, 
  strahler, 
  riverwidthm, 
  temperature, 
  temperaturejan, 
  temperaturejul, 
  wettedsurfacem2, 
  delta, 
  gamma, 
  density,
  nyellow,
  nsilver, 
  nsilver300450,
  nsilver450600,
  nsilver600750,
  nsilver750,
  turbinemortalitynsilver, 
  turbinemortalityrate,
  codesea,
  name,
  pfafriver,
  pfafsegment,
  lengthriverm,
  basin)
  SELECT 
  rn.idsegment, 
  NULL as altitudem, 
  r.dmer as distanceseam, 
  NULL distancesourcem, -- TODO CALCULATE DISTANCE SOURCE
  NULL as cumnbdam, 
  NULL as medianflowm3ps, 
  b.area_*10000 as surfaceunitbvm2, 
  NULL as surfacebvm2, -- todo calculate this
  r.streamorde::numeric AS strahler, 
  NULL as riverwidthm, -- nothing
  NULL as temperature,   -- TODO update temperatures
  NULL as temperaturejan, 
  NULL as temperaturejul, 
  NULL as wettedsurfacem2, 
  NULL AS delta, 
  NULL AS gamma, 
  NULL as density,
  NULL as nyellow,
  NULL as nsilver, 
  NULL as nsilver300450,
  NULL as nsilver450600,
  NULL as nsilver600750,
  NULL as nsilver750,
  NULL as turbinemortalitynumber  , 
  NULL  as  turbinemortalityrate,
  'A' AS codesea,
  r.nome AS name,
  NULL AS pfafriver,
  NULL AS pfafsegment,
  NULL AS lengthriverm,
  NULL AS basin
  from portugal.rn 
  left join
  portugal.rivers r on 'PT'||r.gid::text =rn.idsegment 
  left join
  portugal.vw_baccod_25k_ptcont b on rn.idsegment=b.idsegment; --75679

with counts as 
(select count(*) over (partition by idsegment), idsegment from portugal.vw_baccod_25k_ptcont)
select * from counts where idsegment is not null order by count desc ,idsegment asc

/*
Functions for upstream segments calculation
*/
DROP function if exists spain.upstream_segments_rn(text);
CREATE FUNCTION spain.upstream_segments_rn(text)
RETURNS TABLE(_idsegment text) AS
$$
BEGIN
RETURN QUERY
	WITH RECURSIVE parcours AS(
		SELECT
			r0.idsegment,
			r0.source,
			r0.target
		FROM
			spain.rn r0  
		WHERE
			r0.idsegment = $1
	       
	       
	       UNION SELECT
	               r1.idsegment,
		       r1.source,
		       r1.target
		FROM
			parcours
		JOIN spain.rn r1 
		ON  parcours.source = r1.target)
          SELECT idsegment FROM parcours;
END
$$
  LANGUAGE plpgsql VOLATILE;
  

Comment on function spain.upstream_segments_rn(TEXT) IS 'Function to calculate upstream segments idsegment';

-- the problem below, the query returns a record instead of a query when not using select * from
-- and I cannot use select * from because then I can't query from another table.
-- so I have to find a way to extract record => the solution has been to simplify the function to return only the gid, not a record (gid, source, target)
-- CREATE TABLE t (gid integer, source integer, target integer);
select target from spain.rn where idsegment='SP19158' -- 123183

select spain.upstream_segments_rn('SP19158') 

/*
below this example works and no longer returns any record
with table_gid as (select gid, idsegment from spain.rn limit 2),
     returned_record as (
		select idsegment, spain.upstream_segments_rn(idsegment) uu from table_gid)
--select * from returned_record
select * from returned_record
*/

/* Same fonction for Portugal: TODO international basins

-- Functions for upstream segments calculation

DROP function if exists portugal.upstream_segments_rn(text);
CREATE FUNCTION portugal.upstream_segments_rn(text)
RETURNS TABLE(_idsegment text) AS
$$
BEGIN
RETURN QUERY
	WITH RECURSIVE parcours AS(
		SELECT
			r0.idsegment,
			r0.source,
			r0.target
		FROM
			portugal.rn r0  
		WHERE
			r0.idsegment = $1
	       
	       
	       UNION SELECT
	               r1.idsegment,
		       r1.source,
		       r1.target
		FROM
			parcours
		JOIN portugal.rn r1 
		ON  parcours.source = r1.target)
          SELECT idsegment FROM parcours;
END
$$
  LANGUAGE plpgsql VOLATILE;
  

Comment on function spain.upstream_segments_rn(TEXT) IS 'Function to calculate upstream segments idsegment';
*/



/*---------------------------------
Frontier segments with spain
--------------------------------*/



--select  * from portugal.rn limit 100

--select * from spain.join_portugal_spain join portugal.rn on rn.gid=join_portugal_spain.gid
comment on column portugal.rn.frontiertarget is 'frontiertarget corresponds to the target of the rivers in foreign upstream rivernetwork';
comment on column france.rn.frontiertarget is 'frontiertarget corresponds to the target of the rivers in foreign upstream rivernetwork';
comment on column spain.rn.frontiertarget is  'frontiertarget corresponds to the target of the rivers in foreign upstream rivernetwork';
comment on column dbeel_rivers.rn.frontiertarget is 'frontiertarget corresponds to the target of the rivers in foreign upstream rivernetwork';

comment on column portugal.rn.frontiersource is 'frontiersource corresponds to the source of the river in foreign downstream rivernetwork';
comment on column france.rn.frontiersource is 'frontiersource corresponds to the target of the river in foreign downstream rivernetwork';
comment on column spain.rn.frontiersource is 'frontiersource corresponds to the target of the river in foreign downstream rivernetwork';
comment on column dbeel_rivers.rn.frontiersource is 'frontiersource corresponds to the target of the river in foreign downstream rivernetwork';


--Changing values from portugal when downstream

begin;
update portugal.rn set (frontiertarget, frontiersource, isfrontier)= (jsp.target,NULL,TRUE) from
spain.join_portugal_spain jsp  where rn.gid=jsp.gid;
commit; --97


update portugal.rna set basin="name"  --75679

Update portugal.rn set issea=TRUE where seaidsegment=path::text;--419

select * from  portugal.rna where idsegment='PT64953';
begin;
update portugal.rna set basin='Ribeiras do Oeste' where idsegment in (
select idsegment from portugal.rn where seaidsegment='PT64953');
COMMIT;--403

-- changing values from spain when upstream
-- the join_portugal_spain represents the target in spain. So it's always Spain flowing to Portugal
begin;
update spain.rn set (frontiertarget, frontiersource, isfrontier,nextdownidsegment,path)= (NULL,sub.source_portugal,TRUE,sub.idsegment_portugal,sub.path) from
(select
rns.idsegment as idsegment_spain,
rnp.idsegment as idsegment_portugal,
rnp.path||rns.path as path, -- path from portugal || path in spain
rnp.source as source_portugal -- the source in portugal

from
spain.join_portugal_spain jsp  join 
portugal.rn rnp on jsp.gid=rnp.gid join
spain.rn rns on rns.gid=jsp.gid_spain) sub
where idsegment=idsegment_spain
commit; --108







/* 
There are still unconnected nodes
*/

-- this part extract path from 1 to n-1 (remove spain)
SELECT subpath(path,1-3,nlevel(path)-1) from spain.rn WHERE isfrontier limit 1

select path from spain.rn limit 10
select *  from spain.rn where path is not null and subpath(path,0,1)<@ 'SP225829' limit 10 

-- below I can only work line by line. This returns all ancestor from SP7577
select *  from spain.rn where path is not null and path<@ (select 'SP'||gid_spain from spain.join_portugal_spain limit 1)::ltree 



alter table dbeel_rivers.rn add column isinternational boolean;
alter table spain.join_portugal_spain add column isinternational boolean;


-- I will modify  this to get access to portugese path ... the problem is that the query below only works row by row, 
-- so it's not efficient. I'm replacing it with a query based on chaining which allowed to work on a basis larger than row by row
/*
with upstream_from_first as (

	select *  from spain.rn where path is not null and path<@ (
	select 'SP'||gid_spain from spain.join_portugal_spain 
	where isinternational is null limit 1)::ltree

	),
   portugal_spain as (
   
	select 
	rns.idsegment as idsegment_spain,
	rnp.idsegment as idsegment_portugal,
	rns.path as spainpath
	from
	spain.join_portugal_spain jsp  join 
	portugal.rn rnp on jsp.gid=rnp.gid join
	spain.rn rns on rns.gid=jsp.gid_spain
	where rns.idsegment=(select subpath(path,0,1)::text from upstream_from_first limit 1)

	), 

final_table as (
	select idsegment,spainpath||path as path from portugal_spain ,
	upstream_from_first
     )
--select * from final_table
     ,
     --here I update rivers
updated_values as (
	update spain.rn set (path, isinternational) =(final_table.path, TRUE) from final_table where final_table.idsegment=rn.idsegment
	RETURNING *)
    --here I update spain.join_portugal_spain to avoid it in the upstream_from_first query
update spain.join_portugal_spain set isinternational=TRUE where gid in (
  select j.gid from spain.rn join spain.join_portugal_spain j on rn.nextdownidsegment = 'SP'||gid_spain and rn.isinternational);
--1845 1

-- J'ai noté isinternational=TRUE en amont de ma requete
*/

/*
this query updates all riversegments upstream from frontier segments in pain.join_portugal_spain
*/

with 
   portugal_spain as (
   
	select 
	jsp.isinternational,
	rns.idsegment as idsegment_spain,
	rnp.idsegment as idsegment_portugal,
	-- subpath(rns.path,nlevel(rns.path)-3,nlevel(rns.path)) as spainpath
	rnp.path as portugese_path	
	from
	spain.join_portugal_spain jsp  join 
	portugal.rn rnp on jsp.gid=rnp.gid join
	spain.rn rns on rns.gid=jsp.gid_spain
	where jsp.isinternational is null -- I have already updated one segment

	),
	-- here nearly one hour to find the way not to return a resultset, the solution is to remove source and target from the returned table
	-- so here we have the source column from the join portugal spain table (path at the frontier), the id_segmentspain at the frontier (corresponds to the farthest downstream
	-- point in  spain not used) and the gid of the segment to join with)
   query_joined_with_resultset as (
		select portugese_path,idsegment_spain, spain.upstream_segments_rn(idsegment_spain) as idsegment from portugal_spain),
--select * from    query_joined_with_resultset 

-- here I need to get the path in spain, and the final path is portugese_path||spain_path
final_table as (
	select rn.idsegment,portugese_path||path as path from query_joined_with_resultset join spain.rn on rn.idsegment=query_joined_with_resultset.idsegment
     )
update spain.rn set (path,isinternational)=(final_table.path,true) from final_table where rn.idsegment=final_table.idsegment -- 109489 02:06
     



--- still missing SP320306 SP217285 ... it is the double segments, the correct query was run on Maria's computer ?
-- below I'm selecting those rows by a new join, on nextdownidsegment. First I set the missing nextdownidsegments manually
update spain.rn set (nextdownidsegment,isfrontier)=('PT43284',TRUE) where idsegment='SP320306'; 
update spain.rn set (nextdownidsegment,isfrontier)=('PT61591',TRUE) where idsegment='SP217285'; 
update spain.rn set (nextdownidsegment,isfrontier)=('PT72019',TRUE) where idsegment='SP119029'; 
update spain.rn set (nextdownidsegment,isfrontier)=('PT84922',TRUE) where idsegment='SP153204'; 
update spain.rn set (nextdownidsegment,isfrontier)=('PT2654',TRUE) where idsegment='SP293610'; 


--------------------------------------------
-- This query updates the path upstream all frontier segments between spain and portugal, i.e. rivers flows from spain to portugal
-------------------------------------------
with 
   portugal_spain as (
   
	select 
	rns.idsegment as idsegment_spain,
	rnp.idsegment as idsegment_portugal,
	-- subpath(rns.path,nlevel(rns.path)-3,nlevel(rns.path)) as spainpath
	rnp.path as portugese_path	
	from
	spain.rn rns join
	portugal.rn rnp on rnp.idsegment=rns.nextdownidsegment
	where rns.isfrontier and rns.isinternational is null -- I have already updated one segment

	),
	-- here nearly one hour to find the way not to return a resultset, the solution is to remove source and target from the returned table
	-- so here we have the source column from the join portugal spain table (path at the frontier), the id_segmentspain at the frontier (corresponds to the farthest downstream
	-- point in  spain not used) and the gid of the segment to join with)
   query_joined_with_resultset as (
		select portugese_path,idsegment_spain, spain.upstream_segments_rn(idsegment_spain) as idsegment from portugal_spain),
--select * from    query_joined_with_resultset 

-- here I need to get the path in spain, and the final path is portugese_path||spain_path
final_table as (
	select rn.idsegment,portugese_path||path as path from query_joined_with_resultset join spain.rn on rn.idsegment=query_joined_with_resultset.idsegment
     )
--select * from final_table

update spain.rn set (path,isinternational)=(final_table.path,true) from final_table where rn.idsegment=final_table.idsegment -- 4163

-- frontiernode and frontiertarget are not used they can be replaced by source and target

alter table dbeel_rivers.rn drop column frontiersource
alter table dbeel_rivers.rn drop column frontiertarget
select * from spain.rn limit 10;


-- UPDATE SEANODES EVERYWHERE
-- the segments downstream need to have is_international=TRUE, those have the same sea drain. So i first calculate the sea drain then I use it to set
-- all portugese segments to international.
/*
ERREUR: une instruction insert ou update sur la table « rn » viole la contrainte de clé
étrangère « c_fk_rnseaidsegment »
État SQL :23503
Détail :La clé (seaidsegment)=(PT7494) n'est pas présente dans la table « rn ».
OK I need to drop that constraint
*/
alter table spain.rn drop constraint c_fk_rnseaidsegment;
alter table france.rn drop constraint c_fk_rnseaidsegment;
alter table portugal.rn drop constraint c_fk_rnseaidsegment;
update spain.rn set seaidsegment = subpath(path,0,1) where not isendoreic ; --105
update spain.rn set seaidsegment = subpath(path,0,1) where isendoreic is null; --325332 01:36

update portugal.rn set seaidsegment=subpath(path,0,1) where (not isendoreic or isendoreic is null); --75679
update portugal.rn set isendoreic = FALSE where isendoreic is null;
update portugal.rn set isinternational = FALSE;
update portugal.rn set isinternational=TRUE where seaidsegment in (
 select distinct seaidsegment from spain.rn where isinternational);--48179

 update portugal.rn set isinternational=FALSE where isinternational is null;

select * from spain.downstream_points 
alter table spain.downstream_points rename the_geom to geom;
alter table spain.downstream_points drop column distance;
SELECT UpdateGeometrySRID('spain','downstream_points','geom',3035);

spain.oria_a_rios_v2_vertices_pgr

update spain.downstream_points set geom = ST_Transform(ST_SetSRID(geom,25830),3035) ;
alter table spain.join_portugal_spain drop column isinternational --  no longer used






--TODO LATER RASTER ALTITUDES

-------------------------------------------------------------------
---------------------- FRANCE - SPAIN -----------------------------
-------------------------------------------------------------------



alter table spain.downstream_points add column idsegment text;
update spain.downstream_points set idsegment=rn.idsegment from spain.rn where rn.target=downstream_points.target; 2095
select * from spain.downstream_points limit 10;

-- attention there might be two segments for the same downstream node

-- first deal with rivers flowing from spain to france

drop table if exists spain.join_spain_france;
create table spain.join_spain_france as (
with frontier_segments as (
	select idsegment as idsegment_node, geom from spain.downstream_points where not issea 
),
    projected_point as (
	select idsegment_node, st_distance(p.geom, f.geom) as dist, p.idsegment as idsegment_downstream,f.geom
	from france.rn p join frontier_segments f on st_dwithin(p.geom, f.geom, 500) 
	
),
    ordered_by_distance as (
		select idsegment_node, idsegment_downstream, dist, distanceseam, p.geom from projected_point p
		join france.rna on idsegment=idsegment
		order by idsegment_downstream, dist)

select  distinct on (idsegment_downstream) idsegment_downstream, idsegment_node, distanceseam, geom from ordered_by_distance 
); -- 11 rows, 05:34 min

select * from spain.join_spain_france order by idsegment_node ;

-- 10 lignes normal, one idsegmentnode is repeated, but the same data would have been written
begin;
update spain.rn set (nextdownidsegment,isfrontier,path)=(idsegment_downstream,true,idsegment::ltree) from spain.join_spain_france where idsegment_node = idsegment; --10
commit;


comment on column spain.join_spain_france.idsegment_downstream is 'idsegement of the segment selected downstream as the closest to the node';
comment on column spain.join_spain_france.idsegment_node is 'idsegment of the segment whose target is the point used a node for joining';

-- path are not calculated for spain in the pyreneaan moutains


update spain.rn set (issea,isfrontier)=(FALSE,TRUE) where idsegment in (
select idsegment from spain.temppoly 
join spain.downstream_points on st_intersects(temppoly.geom, downstream_points.geom)
where gid=3); --60


alter table spain.downstream_points rename column at_sea to issea;
update spain.downstream_points set issea=FALSE where idsegment in (
select idsegment from spain.temppoly 
join spain.downstream_points on st_intersects(temppoly.geom, downstream_points.geom)
where gid=3); --60

-- path is missing for those segments

select idsegment_node from spain.join_spain_france;


with sub as(
select idsegment_node, spain.upstream_segments_rn(idsegment_node) as uu from spain.join_spain_france)
select string_agg(uu,'.')::ltree as path from sub group by idsegment_node


-- Before updating I needed to have the correct path in spain
-- This has also been done by a script in R
-- Which was run using the function distance_sea(rios_dist,datafrontier=datafrontier)
-- where datafrontier is spain.join_spain_france (ie the calculation has been made on subsection of 10 nodes at the frontier between Spain an France
-- a temporary table has been created  spain.temp_rios_frontier_france


-- updating path in spain


update spain.rn set (path)=(trff.path::ltree) from
spain.temp_rios_frontier_france trff where trff.idsegment=rn.idsegment;--451

-- again for bidassoa

update spain.rn set (path, isinternational)=(trff.path::ltree,TRUE) from
spain.temp_rios_frontier_france trff where trff.idsegment=rn.idsegment; --478


update france.rn 

-- Now use the path in spain to paste them with path from france at the frontier
with 
   spain_france as (
   
	select 
	rns.idsegment as idsegment_spain,
	rnf.idsegment as idsegment_france,
	-- subpath(rns.path,nlevel(rns.path)-3,nlevel(rns.path)) as spainpath
	rnf.path as france_path, 
	rns.path as spain_path
	from
	spain.rn rns join
	france.rn rnf on rnf.idsegment=rns.nextdownidsegment
	where rns.isfrontier and rns.isinternational is null -- I have already updated one segment

	),
	-- here nearly one hour to find the way not to return a resultset, the solution is to remove source and target from the returned table
	-- so here we have the source column from the join france spain table (path at the frontier), the id_segmentspain at the frontier (corresponds to the farthest downstream
	-- point in  spain not used) and the gid of the segment to join with)
   query_joined_with_resultset as (
		select france_path,idsegment_spain, spain.upstream_segments_rn(idsegment_spain) as idsegment from spain_france),
--select * from    query_joined_with_resultset 

-- here I need to get the path in spain, and the final path is france_path||spain_path
final_table as (
	select rn.idsegment,france_path||rn.path as path 
	--rn.path as path0, 
	--france_path 
	from query_joined_with_resultset join spain.rn on rn.idsegment=query_joined_with_resultset.idsegment
     )
--select * from final_table

update spain.rn set (path,isinternational)=(final_table.path,true) from final_table where rn.idsegment=final_table.idsegment --451


-- reconnecté la bidassoa a la mano

-- Refaire R pour SP234058 -- OK


select rn.seaidsegment from france.rn limit 10; 

update france.rn set isendoreic = FALSE where isendoreic is null; --114563

select count(*), isinternational from france.rn group by isinternational;
update france.rn set isinternational = FALSE ;
--TODO HERE

update spain.rn set seaidsegment = subpath(path,0,1) where isendoreic is FALSE and seaidsegment is null; --105+7942
update spain.rn set isendoreic=FALSE where isendoreic is null;--325332
select count(*), isendoreic from spain.rn group by  isendoreic; --170 t

update france.rn set isinternational=TRUE where seaidsegment in (
 select distinct seaidsegment from spain.rn where isinternational);--19586

/*
index rna and rn. MARIA run this please !
*/


ALTER INDEX spain.indexrngeorn rename to rn_geom_ix;
-- The ANALYZE command asks PostgreSQL to traverse the table and update its internal statistics used for query plan estimation. 
-- The VACUUM command asks PostgreSQL to reclaim any unused space in the table pages left by updates or deletes to records
VACUUM ANALYZE spain.rn;
ALTER INDEX portugal.indexrngeorn rename to rn_geom_ix;
VACUUM ANALYZE portugal.rn;
--The table is essentially completely rewritten from an initial unordered state into an ordered state. This ensures that records with similar attributes have a high likelihood of being found in the same page, reducing the number of pages that must be read into memory for some types of queries. This is harder to visualise for spatial data since the index doesn’t have a simple linear ordering, 
-- but the effect is the same. Geometries that are near each other in space are near each other on disk.
CLUSTER spain.rn USING rn_geom_ix; --  01:18
CLUSTER portugal.rn USING rn_geom_ix; -- 9s

VACUUM ANALYZE france.rn; --6.1s
ALTER INDEX france.indexrngeorn rename to rn_geom_ix;
CLUSTER france.rn USING rn_geom_ix; --19.4s

CREATE INDEX indexidsegmentrna
  ON spain.rna
  USING btree
  (idsegment) ; --2s
VACUUM ANALYZE spain.rna; --1.4s  
CREATE INDEX indexidsegmentrna
  ON portugal.rna
  USING btree
  (idsegment) ;
VACUUM ANALYZE portugal.rna; 
CREATE INDEX indexidsegmentrna
  ON france.rna
  USING btree
  (idsegment) ; 
VACUUM ANALYZE france.rna; 



-- this is gonna mess up all qgis connextions but we have to do it at some point

ALTER DATABASE eda2.0 RENAME TO eda2.3;

-- save to maria
/*
pg_dump -U postgres -f "dbeel_rn.sql" --table dbeel_rivers.rn --table dbeel_rivers.rna
dbeel_rivers.rn, france.rn, portugal.rn, spain.rn, 
dbeel_rivers.rna, france.rna, portugal.rna, spain.rna

-- save and replace for maria

spain.downstream_points
portugal.vw_baccod_25k_ptcont

-- restore function 
spain.upstream_segments_rn

*/

/*
20/05/2019 adding EMU
*/

ALTER TABLE dbeel_rivers.rna ADD column emu text;

/*
RUNONCE INSTALL DBLINK
*/
--CREATE EXTENSION dblink;

with emu as (
  SELECT *
    FROM dblink('dbname=wgeel host=localhost user=postgres password=postgres',
                'SELECT emu_nameshort, emu_cou_code, st_transform(geom,3035) from ref.tr_emu_emu where emu_wholecountry=FALSE')
    AS t1(emu_nameshort text, emu_cou_code TEXT, geom geometry)
    ),
joined_emu as (
SELECT emu_nameshort, emu_cou_code,idsegment from emu 
JOIN spain.rn on st_intersects(rn.geom, emu.geom))

update spain.rna set emu=joined_emu.emu_nameshort from joined_emu where 
joined_emu.idsegment = rna.idsegment; --325253




-- TODO ticket #134

-- create table EMU
CREATE TABLE dbeel_rivers.tr_emu_emu AS (
  SELECT *
    FROM dblink('dbname=wgeel host=localhost user=postgres password=postgres',
                'SELECT emu_nameshort, emu_cou_code, st_transform(geom,3035) from ref.tr_emu_emu where emu_wholecountry=FALSE')
    AS t1(emu_nameshort text, emu_cou_code TEXT, geom geometry)
    );
CREATE INDEX idx_gist_geom ON dbeel_rivers.tr_emu_emu  USING gist(geom);


With faulty_segments as (
select idsegment, geom from spain.rn_rna where emu is NULL),
      joined_emu AS (
SELECT idsegment, 
  (SELECT
      emu_nameshort 
      FROM dbeel_rivers.tr_emu_emu
      WHERE emu_cou_code='ES'
      ORDER BY tr_emu_emu.geom <#> faulty_segments.geom    -- bounding box distance calculation
     LIMIT 1)
     FROM faulty_segments)

update spain.rna set emu=joined_emu.emu_nameshort from joined_emu where 
joined_emu.idsegment = rna.idsegment; --338

DROP TABLE dbeel_rivers.tr_emu_emu;




-- France
with emu as (
  SELECT *
    FROM dblink('dbname=wgeel host=localhost user=postgres password=postgres',
                'SELECT emu_nameshort, emu_cou_code, st_transform(geom,3035) from ref.tr_emu_emu where emu_wholecountry=FALSE')
    AS t1(emu_nameshort text, emu_cou_code TEXT, geom geometry)
    ),
joined_emu as (
SELECT emu_nameshort, emu_cou_code,idsegment from emu 
JOIN france.rn on st_intersects(rn.geom, emu.geom))

update france.rna set emu=joined_emu.emu_nameshort from joined_emu where 
joined_emu.idsegment = rna.idsegment; --114456


-- Portugal
with emu as (
  SELECT *
    FROM dblink('dbname=wgeel host=localhost user=postgres password=postgres',
                'SELECT emu_nameshort, emu_cou_code, st_transform(geom,3035) from ref.tr_emu_emu where emu_wholecountry=FALSE')
    AS t1(emu_nameshort text, emu_cou_code TEXT, geom geometry)
    ),
joined_emu as (
SELECT emu_nameshort, emu_cou_code,idsegment from emu 
JOIN portugal.rn on st_intersects(rn.geom, emu.geom))

update portugal.rna set emu=joined_emu.emu_nameshort from joined_emu where 
joined_emu.idsegment = rna.idsegment; --75679



ALTER TABLE dbeel_rivers.rna add column cumheightdam numeric;


begin;
UPDATE portugal.rna SET basin="name"
COMMIT; --75679


/*
The basins are not all correctly set in portugal and they are inconsistent with 

*/

begin;
with basin_for_sea as (
select basin, seaidsegment, count(*)  from portugal.rna join portugal.rn ON rna.idsegment=rn.idsegment  
 group by seaidsegment,basin  order by seaidsegment,count desc ),
unique_basin as(
select distinct on (seaidsegment) seaidsegment, basin as newbasin from basin_for_sea
),
getbackidsegment as(
SELECT rn.seaidsegment, newbasin,  rn.idsegment, rna.basin from unique_basin join dbeel_rivers.rn on unique_basin.seaidsegment=rn.seaidsegment
JOIN dbeel_rivers.rna on rna.idsegment=rn.idsegment)
--SELECT * from getbackidsegment where getbackidsegment.seaidsegment='PT99836'
UPDATE portugal.rna SET basin=getbackidsegment.newbasin
FROM getbackidsegment
where rna.idsegment=getbackidsegment.idsegment ; 
--select * from portugal.rna where basin='Arade';
COMMIT; --75455


/*
create view
*/


DROP MATERIALIZED VIEW IF EXISTS spain.pbdam;
CREATE materialized view spain.pbdam as select idsegment, cumheightdam-altitudem as delta, geom from spain.rn_rna;--325607
DROP MATERIALIZED VIEW IF EXISTS portugal.pbdam;
CREATE materialized view portugal.pbdam as select idsegment,cumheightdam-altitudem as delta, geom from portugal.rn_rna;--75830
select * from portugal.pbdam limit 10;



/* 
Missing distance mer from spain
*/

-- SP7577 this one has one 

select st_geometrytype(geom) from spain.rn
SELECT COUNT(
        CASE WHEN ST_NumGeometries(geom) > 1 THEN 1 END
    ) AS multi, COUNT(geom) AS total 
FROM spain.rn;
-- il y a 4 vrais multi

/*
searching for frontier points with pb
*/
drop table if exists spain.frontier;
 create table spain.frontier as select rn.idsegment,nextdownidsegment, distanceseam, target, lengthm, geom as geom_line from spain.rn 
	join spain.rna on rn.idsegment=rna.idsegment 
	where isfrontier and (distanceseam is null or distanceseam=0); --66
select addgeometrycolumn('spain','frontier','geom_point',3035,'POINT',2);

-- test pour voir si j'ai des multilinestring https://gis.stackexchange.com/questions/116414/take-from-multilinestring-the-start-and-end-points
SELECT  COUNT(
        CASE WHEN ST_NumGeometries(geom_line) > 1 THEN 1 END
    ) AS multi, COUNT(geom_line) AS total 
FROM spain.frontier; -- 3 je suis dans la merde....
-- finalement je vais les chercher dans les nodes de la table source

Update spain.frontier set geom_point= st_transform(the_geom, 3035)
from spain.rivers_vertices_pgr where id=target;--


-- some have a nextdownidsegment, some not... let's try to get the idsegment first

with sub1 as(
select * from spain.frontier where nextdownidsegment is not null)
select rn_rna.distanceseam+sub1.lengthm, sub1.idsegment from sub1 join portugal.rn_rna on sub1.nextdownidsegment=rn_rna.nextdownidsegment
/*?column?;idsegment
251543.86756231000;SP217285
208622.02183519900;SP153204
221516.90130738300;SP320306
222137.20987979200;SP320306
271552.94118596800;SP293610*/

begin;
with sub1 as(
select * from spain.frontier where nextdownidsegment is not null)
update spain.rna set distanceseam= sub2.distanceseam
 FROM (SELECT sub1.idsegment, rn_rna.distanceseam+sub1.lengthm as distanceseam 
	FROM sub1
	join portugal.rn_rna on sub1.nextdownidsegment=rn_rna.nextdownidsegment
	) sub2
where sub2.idsegment=rna.idsegment; --4 (dont un double .... OK)
COMMIT;

-- to check
-- select * from spain.rna where idsegment in ('SP217285','SP153204','SP320306','SP320306','SP293610')


-- MARIA TODO START HERE
-- restore table using psql -U postgres -f "temp_missing_rios_frontier_portugal.sql" eda2.3
begin;
update spain.rna set distanceseam= tmp.distanceseam from spain.temp_missing_rios_frontier_portugal tmp
where tmp.idsegment=rna.idsegment and rna.distanceseam is NULL; --2306
COMMIT;

-- je refais la table frontier avec tous

drop table if exists spain.frontier;
 create table spain.frontier as select rn.idsegment,nextdownidsegment, distanceseam, target, lengthm, geom as geom_line from spain.rn 
	join spain.rna on rn.idsegment=rna.idsegment 
	where isfrontier ; --66
select addgeometrycolumn('spain','frontier','geom_point',3035,'POINT',2);

Update spain.frontier set geom_point= st_transform(the_geom, 3035)
from spain.rivers_vertices_pgr where id=target;--175


select count(*), basin from spain.rn_rna where seaidsegment='PT7494' group by basin

begin;
update spain.rna set basin='DUERO' where idsegment in (
select idsegment from spain.rn_rna where seaidsegment='PT7494');--43998
--SELECT count(*) from  spain.rn_rna where seaidsegment='PT7494'
commit;


--GUADIANA
select count(*), basin from spain.rn_rna where seaidsegment='PT99274' group by basin
select count(*), basin from portugal.rn_rna where seaidsegment='PT99274' group by basin -- un seul

/-- MARIA TODO HERE 17/05
begin;
update spain.rna set basin='GUADIANA' where idsegment in (
select idsegment from spain.rn_rna where seaidsegment='PT99274');--43998
commit;


--45 wrong sea idsegments in Portugal Guadiana....
-- select * from portugal.rn_rna where issea and basin='Guadiana';
-- MARIA TODO HERE 17/05
begin;
update portugal.rn set issea=FALSE where idsegment in (
select idsegment from portugal.rn_rna where issea and basin='Guadiana')
and idsegment != 'PT99274';
COMMIT;

/* ON the guadiana we are missing bits
TODO MARIA
*/

-- this segment is the most upstream
BEGIN;
with
t as (
	select ltree2text(path) t from portugal.rn where idsegment= 'PT76518'
),
should_be_in_path as(
select regexp_split_to_table(t.t, '\.') as idsegment from t),

not_in_path as (
select idsegment from should_be_in_path 
	EXCEPT (
	SELECT idsegment FROM portugal.rn
	)
),
--SELECT * from not_in_path	--49 +21 segments


missing_rivers as (
SELECT * from portugal.rivers where gid in (select regexp_replace(idsegment ,'PT','')::integer from not_in_path)
)
INSERT into portugal.rn (  
 gid, 
 idsegment, 
 source, 
 target, 
 lengthm, 
 nextdownidsegment, 
 path, 
 isfrontier, 
 issource, 
 seaidsegment, 
 issea, 
 geom, 
 isendoreic, 
 isinternational, 
 country) 				
SELECT  rivers.gid,
	'PT'||rivers.gid::text as idsegment,
	rivers.source,
	rivers.target,
	rivers.st_length_ as lengthm,	
	'PT'||r2.gid as nextdownidsegment,
	text2ltree('PT'||replace(ltree2text(rivers.chemin),'.','.PT')) as path,
        NULL as isfrontier,	
	NULL as issource,	 
	CASE WHEN downstream_points.target is null then null-- pas de point
	     WHEN downstream_points.target is not null and at_sea then 'PT'||rivers.gid
	     END as seaidsegment,
	case when at_sea is null	then false 
	else at_sea end as issea,	  
	st_transform(rivers.geom, 3035) as geom,
	NULL as isendoreic,
	null as isinternational,
	'PT' as country
	from missing_rivers as rivers
	left join missing_rivers r2 on rivers.target=r2.source
	left join portugal.downstream_points on rivers.target=downstream_points.target; --49 +21rows

COMMIT;



BEGIN;
with missing_rna as (select * from portugal.rn where idsegment not in (select idsegment from portugal.rna))

insert into portugal.rna
(idsegment, 
  altitudem, 
  distanceseam, 
  distancesourcem, 
  cumnbdam, 
  medianflowm3ps, 
  surfaceunitbvm2, 
  surfacebvm2, 
  strahler, 
  riverwidthm, 
  temperature, 
  temperaturejan, 
  temperaturejul, 
  wettedsurfacem2, 
  delta, 
  gamma, 
  density,
  nyellow,
  nsilver, 
  nsilver300450,
  nsilver450600,
  nsilver600750,
  nsilver750,
  turbinemortalitynsilver, 
  turbinemortalityrate,
  codesea,
  "name",
  pfafriver,
  pfafsegment,
  lengthriverm,
  basin)

  SELECT 
  rn.idsegment, 
  NULL as altitudem, 
  r.dmer as distanceseam, 
  NULL distancesourcem, -- TODO CALCULATE DISTANCE SOURCE
  NULL as cumnbdam, 
  NULL as medianflowm3ps, 
  b.area_*10000 as surfaceunitbvm2, -- this is the surface of the whole basin
  NULL as surfacebvm2, -- todo calculate this
  r.streamorde::numeric AS strahler, 
  NULL as riverwidthm, -- nothing
  NULL as temperature,   -- TODO update temperatures
  NULL as temperaturejan, 
  NULL as temperaturejul, 
  NULL as wettedsurfacem2, 
  NULL AS delta, 
  NULL AS gamma, 
  NULL as density,
  NULL as nyellow,
  NULL as nsilver, 
  NULL as nsilver300450,
  NULL as nsilver450600,
  NULL as nsilver600750,
  NULL as nsilver750,
  NULL as turbinemortalitynumber  , 
  NULL  as  turbinemortalityrate,
  'A' AS codesea,
  r.nome AS name,
  NULL AS pfafriver,
  NULL AS pfafsegment,
  NULL AS lengthriverm,
  'Guadiana' AS basin
  from missing_rna rn
  left join
  portugal.rivers r on 'PT'||r.gid::text =rn.idsegment 
  left join
  portugal.vw_baccod_25k_ptcont b on rn.idsegment=b.idsegment;
  COMMIT; --49 +21

/*
The downstream and sea idsegments are missing
*/
/*
create table portugal.temp_segment_pb as select * from portugal.rn_rna where nextdownidsegment is null and seaidsegment is null  and basin is null; --13
begin;
update portugal.rn set seaidsegment = subpath(path,0,1) where idsegment in (select idsegment from portugal.temp_segment_pb); --13
COMMit;
-- select idsegment, subpath(path,nlevel(path)-2,1) from portugal.temp_segment_pb
begin;
update portugal.rn set nextdownidsegment = subpath(path,nlevel(path)-2,1) where idsegment in (select idsegment from portugal.temp_segment_pb); --13
COMMit;
begin;
update portugal.rna set basin='Guadiana' where idsegment in (select idsegment from portugal.temp_segment_pb); --13
COMMit; --13
begin;
update portugal.rna set emu='PT_Port' where idsegment in (select idsegment from portugal.temp_segment_pb); --13
COMMit; --13
*/
DROP TABLE IF EXISTS portugal.temp_segment_pb2;
create table portugal.temp_segment_pb2 AS 
select * from portugal.rn_rna where altitudem is null and seaidsegment is null and subpath(path,0,1)='PT99274' --36+21+13

begin;
update portugal.rn set seaidsegment = subpath(path,0,1) where idsegment in (select idsegment from portugal.temp_segment_pb2); --??36+21+13 ???
update portugal.rn set nextdownidsegment = subpath(path,nlevel(path)-2,1) where idsegment in (select idsegment from portugal.temp_segment_pb2);
update portugal.rna set basin='Guadiana' where idsegment in (select idsegment from portugal.temp_segment_pb2);
update portugal.rna set emu='PT_Port' where idsegment in (select idsegment from portugal.temp_segment_pb2); 
COMMit; --13


-- segments frontier with spain upstream in Guadiana (currently flowing in river network 'in spain' in portugal ... changing to spain
Update portugal.rn set isfrontier=TRUE where idsegment in ('PT74726','PT74554','PT74553','PT19664','PT19678');

Begin;
with spj as (
select  rnp.idsegment as idsegmentp,
	rns.idsegment as idsegments,
	st_distance(rns.geom, rnp.geom) as distance	
 from portugal.rn rnp 
JOIN spain.rn rns on st_dwithin(rnp.geom, rns.geom, 100)
where rnp.idsegment in ('PT74726','PT74554','PT74553','PT19664','PT19678')
order by idsegmentp, distance),
  odj as (
  select distinct on (idsegmentp) idsegmentp, idsegments from spj
  )
update portugal.rn set nextdownidsegment = idsegments from odj
where idsegmentp=idsegment; --5
commit;

BEGIN;
update portugal.rn set issea = FALSE where issea is null;
update portugal.rn set isfrontier = FALSE where isfrontier is null;
COMMIT;
  
  

BEGIN;
UPDATE portugal.rn set issea=FALSE from (SELECT idsegment from portugal.rn_rna where distanceseam>1000) sub
where sub.idsegment = rn.idsegment;
-- select * from portugal.rn where issea=TRUE; --420 OK
COMMIT;

/*--------------------------
Tejo
---------------------------------*/

select * from portugal.rn_rna where basin='Tejo'; 21473
SELECT count (*), seaidsegment from portugal.rn_rna where basin = 'Tejo' group by seaidsegment


--317 missing segments at the frontier of the Tajo necessary to compute portugese rivers
BEGIN;
with
t as (
	select ltree2text(path) t from portugal.rn where idsegment= 'PT12493'
),
should_be_in_path as(
select regexp_split_to_table(t.t, '\.') as idsegment from t),

not_in_path as (
select idsegment from should_be_in_path 
	EXCEPT (
	SELECT idsegment FROM portugal.rn
	)
),
--SELECT * from not_in_path	--317 segments


missing_rivers as (
SELECT * from portugal.rivers where gid in (select regexp_replace(idsegment ,'PT','')::integer from not_in_path)
)
INSERT into portugal.rn (  
 gid, 
 idsegment, 
 source, 
 target, 
 lengthm, 
 nextdownidsegment, 
 path, 
 isfrontier, 
 issource, 
 seaidsegment, 
 issea, 
 geom, 
 isendoreic, 
 isinternational, 
 country) 				
SELECT  rivers.gid,
	'PT'||rivers.gid::text as idsegment,
	rivers.source,
	rivers.target,
	rivers.st_length_ as lengthm,	
	'PT'||r2.gid as nextdownidsegment,
	text2ltree('PT'||replace(ltree2text(rivers.chemin),'.','.PT')) as path,
        NULL as isfrontier,	
	NULL as issource,	 
	CASE WHEN downstream_points.target is null then null-- pas de point
	     WHEN downstream_points.target is not null and at_sea then 'PT'||rivers.gid
	     END as seaidsegment,
	case when at_sea is null	then false 
	else at_sea end as issea,	  
	st_transform(rivers.geom, 3035) as geom,
	NULL as isendoreic,
	null as isinternational,
	'PT' as country
	from missing_rivers as rivers
	left join missing_rivers r2 on rivers.target=r2.source
	left join portugal.downstream_points on rivers.target=downstream_points.target; --51 rows

COMMIT;



BEGIN;
with missing_rna as (select * from portugal.rn where idsegment not in (select idsegment from portugal.rna))

insert into portugal.rna
(idsegment, 
  altitudem, 
  distanceseam, 
  distancesourcem, 
  cumnbdam, 
  medianflowm3ps, 
  surfaceunitbvm2, 
  surfacebvm2, 
  strahler, 
  riverwidthm, 
  temperature, 
  temperaturejan, 
  temperaturejul, 
  wettedsurfacem2, 
  delta, 
  gamma, 
  density,
  nyellow,
  nsilver, 
  nsilver300450,
  nsilver450600,
  nsilver600750,
  nsilver750,
  turbinemortalitynsilver, 
  turbinemortalityrate,
  codesea,
  "name",
  pfafriver,
  pfafsegment,
  lengthriverm,
  basin)

  SELECT 
  rn.idsegment, 
  NULL as altitudem, 
  r.dmer as distanceseam, 
  NULL distancesourcem, 
  NULL as cumnbdam, 
  NULL as medianflowm3ps, 
  b.area_*10000 as surfaceunitbvm2, -- this is the surface of the whole basin
  NULL as surfacebvm2, -- todo calculate this
  r.streamorde::numeric AS strahler, 
  NULL as riverwidthm, -- nothing
  NULL as temperature,   -- TODO update temperatures
  NULL as temperaturejan, 
  NULL as temperaturejul, 
  NULL as wettedsurfacem2, 
  NULL AS delta, 
  NULL AS gamma, 
  NULL as density,
  NULL as nyellow,
  NULL as nsilver, 
  NULL as nsilver300450,
  NULL as nsilver450600,
  NULL as nsilver600750,
  NULL as nsilver750,
  NULL as turbinemortalitynumber  , 
  NULL  as  turbinemortalityrate,
  'A' AS codesea,
  r.nome AS name,
  NULL AS pfafriver,
  NULL AS pfafsegment,
  NULL AS lengthriverm,
  'Tejo' AS basin
  from missing_rna rn
  left join
  portugal.rivers r on 'PT'||r.gid::text =rn.idsegment 
  left join
  portugal.vw_baccod_25k_ptcont b on rn.idsegment=b.idsegment;
  COMMIT; --51


DROP TABLE IF EXISTS portugal.temp_tejo;
create table portugal.temp_tejo AS 
select * from portugal.rn_rna where altitudem is null and seaidsegment is null and subpath(path,0,1)='PT80631' --51

begin;
update portugal.rn set seaidsegment = subpath(path,0,1) where idsegment in (select idsegment from portugal.temp_tejo); --51
update portugal.rn set nextdownidsegment = subpath(path,nlevel(path)-2,1) where idsegment in (select idsegment from portugal.temp_tejo);
update portugal.rna set basin='Tejo' where idsegment in (select idsegment from portugal.temp_tejo);
update portugal.rna set emu='PT_Port' where idsegment in (select idsegment from portugal.temp_tejo); 
COMMit; --51

-- Tejo southern small part of the basin, one riversegment missing


BEGIN;
with
t as (
	select ltree2text(path) t from portugal.rn where idsegment= 'PT66411'
),
should_be_in_path as(
select regexp_split_to_table(t.t, '\.') as idsegment from t),

not_in_path as (
select idsegment from should_be_in_path 
	EXCEPT (
	SELECT idsegment FROM portugal.rn
	)
),
--SELECT * from not_in_path	--317 segments


missing_rivers as (
SELECT * from portugal.rivers where gid in (select regexp_replace(idsegment ,'PT','')::integer from not_in_path)
)
INSERT into portugal.rn (  
 gid, 
 idsegment, 
 source, 
 target, 
 lengthm, 
 nextdownidsegment, 
 path, 
 isfrontier, 
 issource, 
 seaidsegment, 
 issea, 
 geom, 
 isendoreic, 
 isinternational, 
 country) 				
SELECT  rivers.gid,
	'PT'||rivers.gid::text as idsegment,
	rivers.source,
	rivers.target,
	rivers.st_length_ as lengthm,	
	'PT'||r2.gid as nextdownidsegment,
	text2ltree('PT'||replace(ltree2text(rivers.chemin),'.','.PT')) as path,
        NULL as isfrontier,	
	NULL as issource,	 
	CASE WHEN downstream_points.target is null then null-- pas de point
	     WHEN downstream_points.target is not null and at_sea then 'PT'||rivers.gid
	     END as seaidsegment,
	case when at_sea is null	then false 
	else at_sea end as issea,	  
	st_transform(rivers.geom, 3035) as geom,
	NULL as isendoreic,
	null as isinternational,
	'PT' as country
	from missing_rivers as rivers
	left join missing_rivers r2 on rivers.target=r2.source
	left join portugal.downstream_points on rivers.target=downstream_points.target; --7 rows

COMMIT;



BEGIN;
with missing_rna as (select * from portugal.rn where idsegment not in (select idsegment from portugal.rna))

insert into portugal.rna
(idsegment, 
  altitudem, 
  distanceseam, 
  distancesourcem, 
  cumnbdam, 
  medianflowm3ps, 
  surfaceunitbvm2, 
  surfacebvm2, 
  strahler, 
  riverwidthm, 
  temperature, 
  temperaturejan, 
  temperaturejul, 
  wettedsurfacem2, 
  delta, 
  gamma, 
  density,
  nyellow,
  nsilver, 
  nsilver300450,
  nsilver450600,
  nsilver600750,
  nsilver750,
  turbinemortalitynsilver, 
  turbinemortalityrate,
  codesea,
  "name",
  pfafriver,
  pfafsegment,
  lengthriverm,
  basin)

  SELECT 
  rn.idsegment, 
  NULL as altitudem, 
  r.dmer as distanceseam, 
  NULL distancesourcem, 
  NULL as cumnbdam, 
  NULL as medianflowm3ps, 
  b.area_*10000 as surfaceunitbvm2, -- this is the surface of the whole basin
  NULL as surfacebvm2, -- todo calculate this
  r.streamorde::numeric AS strahler, 
  NULL as riverwidthm, -- nothing
  NULL as temperature,   -- TODO update temperatures
  NULL as temperaturejan, 
  NULL as temperaturejul, 
  NULL as wettedsurfacem2, 
  NULL AS delta, 
  NULL AS gamma, 
  NULL as density,
  NULL as nyellow,
  NULL as nsilver, 
  NULL as nsilver300450,
  NULL as nsilver450600,
  NULL as nsilver600750,
  NULL as nsilver750,
  NULL as turbinemortalitynumber  , 
  NULL  as  turbinemortalityrate,
  'A' AS codesea,
  r.nome AS name,
  NULL AS pfafriver,
  NULL AS pfafsegment,
  NULL AS lengthriverm,
  'Tejo' AS basin
  from missing_rna rn
  left join
  portugal.rivers r on 'PT'||r.gid::text =rn.idsegment 
  left join
  portugal.vw_baccod_25k_ptcont b on rn.idsegment=b.idsegment;
  COMMIT; --7


DROP TABLE IF EXISTS portugal.temp_tejo;
create table portugal.temp_tejo AS 
select * from portugal.rn_rna where altitudem is null and seaidsegment is null and subpath(path,0,1)='PT80631' --3

begin;
update portugal.rn set seaidsegment = subpath(path,0,1) where idsegment in (select idsegment from portugal.temp_tejo); --51
update portugal.rn set nextdownidsegment = subpath(path,nlevel(path)-2,1) where idsegment in (select idsegment from portugal.temp_tejo);
update portugal.rna set basin='Tejo' where idsegment in (select idsegment from portugal.temp_tejo);
update portugal.rna set emu='PT_Port' where idsegment in (select idsegment from portugal.temp_tejo); 
COMMit; --7


-- Lima



BEGIN;
with
t as (
	select ltree2text(path) t from portugal.rn where idsegment= 'PT483'
),
should_be_in_path as(
select regexp_split_to_table(t.t, '\.') as idsegment from t),

not_in_path as (
select idsegment from should_be_in_path 
	EXCEPT (
	SELECT idsegment FROM portugal.rn
	)
),
--SELECT * from not_in_path	--317 segments


missing_rivers as (
SELECT * from portugal.rivers where gid in (select regexp_replace(idsegment ,'PT','')::integer from not_in_path)
)
INSERT into portugal.rn (  
 gid, 
 idsegment, 
 source, 
 target, 
 lengthm, 
 nextdownidsegment, 
 path, 
 isfrontier, 
 issource, 
 seaidsegment, 
 issea, 
 geom, 
 isendoreic, 
 isinternational, 
 country) 				
SELECT  rivers.gid,
	'PT'||rivers.gid::text as idsegment,
	rivers.source,
	rivers.target,
	rivers.st_length_ as lengthm,	
	'PT'||r2.gid as nextdownidsegment,
	text2ltree('PT'||replace(ltree2text(rivers.chemin),'.','.PT')) as path,
        NULL as isfrontier,	
	NULL as issource,	 
	CASE WHEN downstream_points.target is null then null-- pas de point
	     WHEN downstream_points.target is not null and at_sea then 'PT'||rivers.gid
	     END as seaidsegment,
	case when at_sea is null	then false 
	else at_sea end as issea,	  
	st_transform(rivers.geom, 3035) as geom,
	NULL as isendoreic,
	null as isinternational,
	'PT' as country
	from missing_rivers as rivers
	left join missing_rivers r2 on rivers.target=r2.source
	left join portugal.downstream_points on rivers.target=downstream_points.target; -3 rows

COMMIT;



BEGIN;
with missing_rna as (select * from portugal.rn where idsegment not in (select idsegment from portugal.rna))

insert into portugal.rna
(idsegment, 
  altitudem, 
  distanceseam, 
  distancesourcem, 
  cumnbdam, 
  medianflowm3ps, 
  surfaceunitbvm2, 
  surfacebvm2, 
  strahler, 
  riverwidthm, 
  temperature, 
  temperaturejan, 
  temperaturejul, 
  wettedsurfacem2, 
  delta, 
  gamma, 
  density,
  nyellow,
  nsilver, 
  nsilver300450,
  nsilver450600,
  nsilver600750,
  nsilver750,
  turbinemortalitynsilver, 
  turbinemortalityrate,
  codesea,
  "name",
  pfafriver,
  pfafsegment,
  lengthriverm,
  basin)

  SELECT 
  rn.idsegment, 
  NULL as altitudem, 
  r.dmer as distanceseam, 
  NULL distancesourcem, 
  NULL as cumnbdam, 
  NULL as medianflowm3ps, 
  b.area_*10000 as surfaceunitbvm2, -- this is the surface of the whole basin -- error corrected later this was km2 not ha so must multiply by 100
  NULL as surfacebvm2, -- todo calculate this
  r.streamorde::numeric AS strahler, 
  NULL as riverwidthm, -- nothing
  NULL as temperature,   -- TODO update temperatures
  NULL as temperaturejan, 
  NULL as temperaturejul, 
  NULL as wettedsurfacem2, 
  NULL AS delta, 
  NULL AS gamma, 
  NULL as density,
  NULL as nyellow,
  NULL as nsilver, 
  NULL as nsilver300450,
  NULL as nsilver450600,
  NULL as nsilver600750,
  NULL as nsilver750,
  NULL as turbinemortalitynumber  , 
  NULL  as  turbinemortalityrate,
  'A' AS codesea,
  r.nome AS name,
  NULL AS pfafriver,
  NULL AS pfafsegment,
  NULL AS lengthriverm,
  'Lima' AS basin
  from missing_rna rn
  left join
  portugal.rivers r on 'PT'||r.gid::text =rn.idsegment 
  left join
  portugal.vw_baccod_25k_ptcont b on rn.idsegment=b.idsegment;
  COMMIT; --3


DROP TABLE IF EXISTS portugal.temp_lima;
create table portugal.temp_lima AS 
select * from portugal.rn_rna where altitudem is null and seaidsegment is null and subpath(path,0,1)='PT35710' --3

begin;
update portugal.rn set seaidsegment = subpath(path,0,1) where idsegment in (select idsegment from portugal.temp_lima); --51
update portugal.rn set nextdownidsegment = subpath(path,nlevel(path)-2,1) where idsegment in (select idsegment from portugal.temp_lima);
update portugal.rna set basin='Lima' where idsegment in (select idsegment from portugal.temp_lima);
update portugal.rna set emu='PT_Port' where idsegment in (select idsegment from portugal.temp_lima); 
COMMit; --7


--Minho

PT31226


BEGIN;
with
t as (
	select ltree2text(path) t from portugal.rn where idsegment= 'PT31226'
),
should_be_in_path as(
select regexp_split_to_table(t.t, '\.') as idsegment from t),

not_in_path as (
select idsegment from should_be_in_path 
	EXCEPT (
	SELECT idsegment FROM portugal.rn
	)
),
--SELECT * from not_in_path	--317 segments


missing_rivers as (
SELECT * from portugal.rivers where gid in (select regexp_replace(idsegment ,'PT','')::integer from not_in_path)
)
INSERT into portugal.rn (  
 gid, 
 idsegment, 
 source, 
 target, 
 lengthm, 
 nextdownidsegment, 
 path, 
 isfrontier, 
 issource, 
 seaidsegment, 
 issea, 
 geom, 
 isendoreic, 
 isinternational, 
 country) 				
SELECT  rivers.gid,
	'PT'||rivers.gid::text as idsegment,
	rivers.source,
	rivers.target,
	rivers.st_length_ as lengthm,	
	'PT'||r2.gid as nextdownidsegment,
	text2ltree('PT'||replace(ltree2text(rivers.chemin),'.','.PT')) as path,
        NULL as isfrontier,	
	NULL as issource,	 
	CASE WHEN downstream_points.target is null then null-- pas de point
	     WHEN downstream_points.target is not null and at_sea then 'PT'||rivers.gid
	     END as seaidsegment,
	case when at_sea is null	then false 
	else at_sea end as issea,	  
	st_transform(rivers.geom, 3035) as geom,
	NULL as isendoreic,
	null as isinternational,
	'PT' as country
	from missing_rivers as rivers
	left join missing_rivers r2 on rivers.target=r2.source
	left join portugal.downstream_points on rivers.target=downstream_points.target; --20 rows

COMMIT;



BEGIN;
with missing_rna as (select * from portugal.rn where idsegment not in (select idsegment from portugal.rna))

insert into portugal.rna
(idsegment, 
  altitudem, 
  distanceseam, 
  distancesourcem, 
  cumnbdam, 
  medianflowm3ps, 
  surfaceunitbvm2, 
  surfacebvm2, 
  strahler, 
  riverwidthm, 
  temperature, 
  temperaturejan, 
  temperaturejul, 
  wettedsurfacem2, 
  delta, 
  gamma, 
  density,
  nyellow,
  nsilver, 
  nsilver300450,
  nsilver450600,
  nsilver600750,
  nsilver750,
  turbinemortalitynsilver, 
  turbinemortalityrate,
  codesea,
  "name",
  pfafriver,
  pfafsegment,
  lengthriverm,
  basin)

  SELECT 
  rn.idsegment, 
  NULL as altitudem, 
  r.dmer as distanceseam, 
  NULL distancesourcem, 
  NULL as cumnbdam, 
  NULL as medianflowm3ps, 
  b.area_*10000 as surfaceunitbvm2, -- this is the surface of the whole basin
  NULL as surfacebvm2, -- todo calculate this
  r.streamorde::numeric AS strahler, 
  NULL as riverwidthm, -- nothing
  NULL as temperature,   -- TODO update temperatures
  NULL as temperaturejan, 
  NULL as temperaturejul, 
  NULL as wettedsurfacem2, 
  NULL AS delta, 
  NULL AS gamma, 
  NULL as density,
  NULL as nyellow,
  NULL as nsilver, 
  NULL as nsilver300450,
  NULL as nsilver450600,
  NULL as nsilver600750,
  NULL as nsilver750,
  NULL as turbinemortalitynumber  , 
  NULL  as  turbinemortalityrate,
  'A' AS codesea,
  r.nome AS name,
  NULL AS pfafriver,
  NULL AS pfafsegment,
  NULL AS lengthriverm,
  'Minho' AS basin
  from missing_rna rn
  left join
  portugal.rivers r on 'PT'||r.gid::text =rn.idsegment 
  left join
  portugal.vw_baccod_25k_ptcont b on rn.idsegment=b.idsegment;
  COMMIT; --3


DROP TABLE IF EXISTS portugal.temp_minho;
create table portugal.temp_minho AS 
select * from portugal.rn_rna where altitudem is null and seaidsegment is null and subpath(path,0,1)='PT32156' --3

begin;
update portugal.rn set seaidsegment = subpath(path,0,1) where idsegment in (select idsegment from portugal.temp_minho); --51
update portugal.rn set nextdownidsegment = subpath(path,nlevel(path)-2,1) where idsegment in (select idsegment from portugal.temp_minho);
update portugal.rna set basin='Minho' where idsegment in (select idsegment from portugal.temp_minho);
update portugal.rna set emu='PT_Port' where idsegment in (select idsegment from portugal.temp_minho); 
COMMit; --7


-- CUENCAS mediterraneas


update spain.rna set basin='CUENCAS MEDITERRANEAS DE ANDALUCIA' where idsegment in (
select idsegment  from spain.rn_rna where seaidsegment = 'SP118910');


update spain.rn set issea=TRUE where idsegment= 'SP112393';
update spain.rn set issea=TRUE where idsegment= 'SP112411';

update spain.rna set basin='TAJO' where idsegment in 
(SELECT idsegment  from spain.rn_rna where seaidsegment='PT80631'); --36635

update spain.rn set issea=TRUE where idsegment='SP1961';


update spain.rna  set basin='MIAO-LIMIA' where idsegment in 
(SELECT idsegment  from spain.rn_rna where seaidsegment in ('SP173326','PT35710'));--12393

-- MARIA start here !

update spain.rn set (nextdownidsegment,isfrontier)=('FR120520',TRUE) where idsegment in ('SP234305','SP234303');


select * from portugal.rn_rna where basin='Guadiana' and isfrontier=TRUE;
BEGIN;
update portugal.rn set isfrontier =FALSE where idsegment in (select idsegment from portugal.rn_rna 
 where basin='Guadiana' and nextdownidsegment like '%PT%' and isfrontier=TRUE);--45
COMMIT;

BEGIN;
update spain.rn  set (nextdownidsegment, isfrontier) = ('SP322812',FALSE) where idsegment ='SP322651';--1
COMMIT;


BEGIN;
update spain.rn  set (nextdownidsegment, isfrontier) = ('SP322651',FALSE) where idsegment ='SP322597';--1
COMMIT;

/*
change 11/10/2019
*/
begin;
UPDATE spain.rn set nextdownidsegment='FR120033' where idsegment in ('SP234477','SP4737');
commit;


begin;
UPDATE spain.rn set isfrontier=TRUE where nextdownidsegment in 
('PT71436','PT71011','PT71391','PT19226','PT71467','PT19464','PT72019','PT72395','PT86155','PT23230','PT23445','PT23445','PT23427','PT24453','PT86537','PT25959','PT25947','PT26148','PT25947','PT25932','PT26286','PT26148','PT32040',
'FR120033','FR121888','FR122067','FR120520','FR120033','PT31832','PT1932','PT31328','PT1439','PT1671','PT1440','PT31342','PT31327','PT1963','PT1981','PT2132','PT2100','PT2757','PT31862',
'PT2937','PT2936','PT31845','PT3064','PT2924','PT3102','PT32497','PT32326','PT3112','PT35541','PT36946','FR120033','PT3024');--64
COMMIT;


/*
Updating the basin surface with the right layer
*/
BEGIN;
UPDATE spain.rna set surfaceunitbvm2 = areactrkm2*10^6 from spain.basin_uni where
 pfafcuen=pfafsegment;--325606
COMMIT;	


SELECT * from spain.basin_uni limit 10;
SELECT * FROM spain.rn_rna limit 10
SELECT * FROM spain.rn_rna 
where surfaceunitbvm2!=surfacebvm2; 


-- the path needs to be calculated there
begin;
UPDATE spain.rn set issea=TRUE where idsegment in 
('SP225992');--64
COMMIT;

-- select * from spain.rna where idsegment = 'SP232405' => basin NORTE


-- SELECT nlevel(path) from portugal.rn where nextdownidsegment  IS null limit 10;
/* Mise à jour des nextdownidsegment (pas fait)*/
BEGIN;
WITH joining as(
select rn2.idsegment, rn.idsegment as nextdownidsegment from portugal.rn join portugal.rn rn2 on rn2.target=rn.source)
UPDATE portugal.rn set nextdownidsegment=joining.nextdownidsegment from joining where joining.idsegment=rn.idsegment;--75236
COMMIT;

CREATE INDEX indexnextdownidsegmentrrn
  ON portugal.rn
  USING btree
  (nextdownidsegment COLLATE pg_catalog."default");
  
BEGIN;
UPDATE portugal.rn seT issource=FALSE;--75830

with tablesource as (
SELECT idsegment from portugal.rn 
EXCEPT
select rn.idsegment from portugal.rn join portugal.rn rn2 on rn2.nextdownidsegment=rn.idsegment)
update portugal.rn set issource=TRUE from tablesource where tablesource.idsegment=rn.idsegment; --38120
COMMIT;

-- pass the strahler to frontier segment

--select * from portugal.rn where isfrontier is TRUE;

-- GROUP BY.... (change rien) mais bon

with spainfrontiersegments as (SELECT nextdownidsegment as nextdownidsegmentsp, shreeve,strahler, surfacebvm2, distancesourcem from spain.rn_rna where isfrontier IS TRUE),
portugalfrontiersegments as (
SELECT * FROM portugal.rn JOIN spainfrontiersegments on idsegment=nextdownidsegmentsp )
update portugal.rn set isfrontier=TRUE FROM portugalfrontiersegments where portugalfrontiersegments.idsegment=rn.idsegment;

with spainfrontiersegments as (SELECT nextdownidsegment as nextdownidsegmentsp, shreeve,strahler, surfacebvm2,distancesourcem from spain.rn_rna where isfrontier IS TRUE),
ptf as (
SELECT * FROM portugal.rn JOIN spainfrontiersegments on idsegment=nextdownidsegmentsp ),
ptfsum as (
SELECT idsegment, sum(shreeve) as shreeve,sum(surfacebvm2) as surfacebvm2,max(strahler) as strahler, max(distancesourcem)+lengthm as distancesourcem from ptf group by idsegment)
update portugal.rna set (shreeve,strahler,surfacebvm2,distancesourcem)=(ptfsum.shreeve,ptfsum.strahler,ptfsum.surfacebvm2,ptfsum.distancesourcem) FROM ptfsum where ptfsum.idsegment=rna.idsegment;--95


-- function idsource
-- created by Laurent
CREATE OR REPLACE FUNCTION spain.idsource(in text, out text)
AS $$ 
    SELECT idsegment 
    FROM (SELECT seaidsegment AS seaidsegment_ref FROM spain.rn WHERE idsegment = $1) AS rn_ref, spain.rn
    JOIN spain.rna USING(idsegment)
    WHERE 
        "path" ~ concat('*.', $1, '.*')::lquery
        AND issource
        AND seaidsegment = seaidsegment_ref
    ORDER BY distanceseam DESC
    LIMIT 1 
$$
LANGUAGE SQL;

-- France bassins

-- UPDATE SURFACE IN PORTUGAL
update portugal.rna set (surfaceunitbvm2, surfacebvm2)=(surfaceunitbvm2*100, surfacebvm2*100);


select * from france.soussecteurhydro limit 10



ALTER TABLE france."SousSecteurHydro" rename to soussecteurhydro;


CREATE INDEX soussecteurhydro_geom_gist
  ON france.soussecteurhydro
  USING gist
  (geom);

DROP TABLE france.join_cdsoussect;
CREATE TABLE france.join_cdsoussect (idsegment text, "name" TEXT,basin TEXT);

  WITH
    lines_in_polygons AS(
      SELECT idsegment,
      cdsoussect,
      lbsoussect,
      cdsecteurh,
      lbsecteurh 
      st_length(ST_INTERSECTION(l.geom,st_transform(p.geom,3035))) as length
      FROM
        france.rn AS l JOIN
        france.soussecteurhydro AS p
        ON ST_INTERSECTS(l.geom,st_transform(p.geom,3035)) 
    ),
      line_in_polygons_selected as (

      select idsegment, lbsoussect||' ['||cdsoussect||']' as "name",lbsecteurh||' ['||cdsectuerh||']' as basin  from lines_in_polygons order by idsegment, length)

      INSERT INTO france.join_cdsoussect SELECT distinct on (idsegment) idsegment, "name", basin FROM line_in_polygons_selected; --114423


 select count(*) from france.rn -- 114564
 SELECT * from france.join_cdsoussect limit 10

-- perform anti join query

with missing as (select * from france.rn r LEFT join france.join_cdsoussect j using (idsegment) where j.idsegment is NULL),
--SELECT * from missing; --141
projected as (select idsegment, 
       cdsoussect,
      lbsoussect,
      cdsecteurh,
      lbsecteurh 
	st_distance(missing.geom,st_transform(p.geom,3035)) as distance
       from missing join france.soussecteurhydro p ON st_dwithin(missing.geom,st_transform(p.geom,3035),500) order by idsegment, distance)
INSERT INTO france.join_csoussect SELECT distinct on (idsegment) idsegment, "name", basin FROM projected 
       
select count(*) from france.join_cdsoussect;





 begin;
 update france.rna r set (basin,"name") = (j.basin, j."name") from france.join_cdsoussect j where r.idsegment=j.idsegment; --114423
 COMMIT;


select * from france.rna  limit 10;
SELECT distinct on (cdregionhy) lbregionhy, cdregionhy from france.soussecteurhydro order by cdregionhy;


-- collect code of sea from the names of the layer
-- also provides a convenient code to extract the code of secteurhydro and soussecteurhydro
with rr as (
	select 
	idsegment,
	split_part(split_part("name",'[',2),']',1) as cdsoussect,
	 split_part(split_part(basin,'[',2),']',1) AS cdsecteurh,
	 substring( split_part(split_part(basin,'[',2),']',1),1,1) as cdregionh
	 FROM france.rna),
  rrr AS (
	 SELECT *,
	 CASE WHEN cdregionh in ('U','V','W','X','Y') then 'M' else 'A' end as codesea
	 from rr)
 update france.rna set codesea=rrr.codesea from rrr where rrr.idsegment=rna.idsegment;--114564

/*
* Correction des basins manquants
*/

-- On va chercher le bassin sur les segments amont (4)
BEGIN;
with nullbasin as(
 select * from spain.rn_rna where basin is null), --14
     additional AS (
 SELECT nullbasin.idsegment, rn_rna.basin from nullbasin join spain.rn_rna on rn_rna.nextdownidsegment=nullbasin.idsegment where rn_rna.basin is not NULL)
 UPDATE spain.rna set basin=additional.basin from additional where additional.idsegment=rna.idsegment; --4
COMMIT;

-- On règle le problème de l'idsegment NULL
SELECT idsegment FROM spain.rn_rna where path='SP234058'; -- one line with missing idsegment but it's not null ?
begin;
ALTER TABLE spain.rna drop CONSTRAINT c_fk_rnaidsegment;
ALTER TABLE spain.rna ADD CONSTRAINT c_fk_rnaidsegment FOREIGN KEY (idsegment)
      REFERENCES spain.rn (idsegment) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
UPDATE spain.rn set idsegment = 'SP234058' where idsegment=(SELECT idsegment FROM spain.rn_rna where path='SP234058');--1
COMMIT;




-- On va chercher le bassin sur les segments aval (6)
 With nullbasin as(
 select * from spain.rn_rna where basin is null) ,--10
      additional AS (
 SELECT nullbasin.idsegment, rn_rna.basin from nullbasin join spain.rn_rna on nullbasin.nextdownidsegment=rn_rna.idsegment where rn_rna.basin is not NULL) 
UPDATE spain.rna set basin=additional.basin from additional where additional.idsegment=rna.idsegment; --6
COMMIT;

-- pareil avec France
BEGIN;
 With nullbasin as(
 select * from spain.rn_rna where basin is null) ,--4
      additional AS (
 SELECT nullbasin.idsegment, rn_rna.basin from nullbasin join france.rn_rna on nullbasin.nextdownidsegment=rn_rna.idsegment where rn_rna.basin is not NULL) 
 --select * from additional
UPDATE spain.rna set basin=additional.basin from additional where additional.idsegment=rna.idsegment; --2
COMMIT;


--select basin from france.rn_rna where idsegment='FR118671'
BEGIN;
update spain.rna set basin='L''Adour du confluent de la Nive (incluse) à l''océan [Q9]' WHERE idsegment='SP225201';
COMMIT;


BEGIN;
update spain.rna set basin='TAJO' WHERE idsegment='SP437';
COMMIT;

-- pareil avec Portugal
/*
BEGIN;
 With nullbasin as(
 select * from spain.rn_rna where basin is null) ,--4
      additional AS (
 SELECT nullbasin.idsegment, rn_rna.basin from nullbasin join portugal.rn_rna on nullbasin.nextdownidsegment=rn_rna.idsegment where rn_rna.basin is not NULL) 
 select * from additional
UPDATE spain.rna set basin=additional.basin from additional where additional.idsegment=rna.idsegment; --2
COMMIT;
*/
SELECT * FROM spain.rn_rna where basin='TEST';
update spain.rna set basin='ISLAS BALEARES' where basin='TEST';


SELECT riverwidthm, riverwidthmsource FROM spain.rn_rna WHERE riverwidthm IS NOT NULL;

SELECT * FROM riverwidth_spain_portugal

BEGIN;
UPDATE spain.rna SET (riverwidthm,riverwidthmsource) = (rsp.pred_river_width::NUMERIC,rsp.riverwidthmsource) 
FROM riverwidth_spain_portugal rsp WHERE rsp.idsegment= rna.idsegment;--308975
UPDATE portugal.rna SET (riverwidthm,riverwidthmsource) = (rsp.pred_river_width::NUMERIC,rsp.riverwidthmsource) 
FROM riverwidth_spain_portugal rsp WHERE rsp.idsegment= rna.idsegment;--68738
COMMIT;

/*

Corrections of minor problems in France

*/
begin;
-- segments not projected in the Mont Saint Michel Bay
update france.rna set (emu,basin)= 
('FR_Sein','La Sélune du confluent de l''Airon (exclu) à l''embouchure [I92]') 
where idsegment in ('FR311476','FR311471');--2
update france.rna set (emu,basin)= 
('FR_Sein','Les bassins côtiers compris entre l''embouchure du Thar (exclu) et l''embouchure de la Sée (exclu) [I78]')
 where idsegment in ('FR311340','FR311335'); --2
update france.rna set emu='FR_Sein' where basin like '%[I9]%' and emu is null;--6
COMMIT;

-- upper Rhone (artificial connexion in the Leman)
SELECT * from france.rn_rna where basin is null and seaidsegment='FR22333' --21

begin;
UPDATE france.rna set (emu,basin)=('FR_Rhon','Le Rhône du lac Léman inclus à l''Annaz [V0]')
FROM france.rn_rna
WHERE
 rn_rna.basin is null and 
 rn_rna.seaidsegment='FR22333'
 and rn_rna.idsegment=rna.idsegment;--21
 COMMIT;

 SELECT * FROM france.rna where basin is NULL; --14


-- in Brittany or Garonne get basin from upstream segment
BEGIN;
WITH missingbasin as (
 SELECT * from france.rn_rna WHERE basin is null ),
correctme as(
 SELECT missingbasin.idsegment, rn_rna.basin from missingbasin JOIN france.rn_rna on rn_rna.nextdownidsegment=missingbasin.idsegment
 where rn_rna.basin is not NULL)
 UPDATE france.rna set basin=correctme.basin FROM correctme where correctme.idsegment=rna.idsegment and rna.basin is NULL;--6
 COMMIT;
-- only works onces
 BEGIN;
WITH missingbasin as (
 SELECT * from france.rn_rna WHERE basin is null ),
correctme as(
 SELECT missingbasin.idsegment, rn_rna.basin from missingbasin JOIN france.rn_rna on rn_rna.nextdownidsegment=missingbasin.idsegment
 where rn_rna.basin is not NULL)
 UPDATE france.rna set basin=correctme.basin FROM correctme where correctme.idsegment=rna.idsegment and rna.basin is NULL;--0
 COMMIT;

-- Using emu to set basin in Britany
BEGIN;
UPDATE france.rna set basin='côtiers du couesnon (c) à la rance (c) [J0]' WHERE basin is null and emu='FR_Bret';--4
COMMIT;

-- Using emu to set basin in Charente
BEGIN;
UPDATE france.rna set basin=
'Les côtiers de l''embouchure de la Charente au confluent de la Garonne et de la Dordogne [S0]'
 WHERE basin is null and emu='FR_Garo';--4
 COMMIT;


  SELECT * FROM france.rna where emu is NULL; --77

  BEGIN;
 UPDATE france.rna set emu='FR_Cors' where codesea='M' and emu IS NULL and idsegment='FR26772'; --1
UPDATE france.rna set emu='FR_Rhon' where codesea='M' and emu IS NULL; --42
COMMIT;


-- Seine
  BEGIN;
 UPDATE france.rna set emu='FR_Sein' where basin like '%H7%' and emu IS NULL ; --7
 COMMIT;

--Seine
  BEGIN;
 UPDATE france.rna set emu='FR_Sein' where basin like '%I8%' and emu IS NULL ; --3
 COMMIT;

BEGIN;
 UPDATE france.rna set emu='FR_Sein' where basin like '%[I%' and emu IS NULL ; --10
 COMMIT;


BEGIN;
 UPDATE france.rna set emu='FR_Adou' where basin like '%[S%' and emu IS NULL ; --10
COMMIT;


  SELECT * FROM france.rna where emu is NULL; --0
  
  
  -- In hilaire_rht table export with all attributes -- Maria this is not for you I will do a dump
  
  CREATE TABLE rht.rnasuppl AS (
  SELECT 
  'FR'||att2.id_drain AS idsegment,
	tjan_moy ,
	tjuil_moy ,
	d_source,
	altitude ,
	sfbvu ,
	long_,
	strahler,
	surf_bv ,
	pente ,
	"module" ,
	l ,
	h ,
	q01_rht ,
	q02_rht ,
	q05_rht ,
	q10_rht ,
	q20_rht ,
	q30_rht ,
	q40_rht ,
	q50_rht ,
	q60_rht ,
	q70_rht ,
	q80_rht ,
	q90_rht ,
	q95_rht ,
	q98_rht ,
	q99_rht ,
	nom_rht,
	toponyme_r,
	id_trhyd
	FROM rht.att2 LEFT JOIN
	rht.rhtvs2 ON rhtvs2.id_drain = att2.id_drain)
	
	
	/*
	 * F:
	 * cd eda/base/eda2.3
	 * C:\"Program Files"\PostgreSQL\10\bin\pg_dump -U postgres -f "rht.rnasuppl.sql" -p 5436 --table rht.rnasuppl --verbose hilaire_rht
	 * --rename rht to france
	 * psql -U postgres -f "rht.rnasuppl.sql" eda2.3
	 * 
	 */
SELECT * FROM france.rnasuppl	 
		





/*
WRONG SEAIDSEGMENTS IN FRANCE FIRST I NEED TO UPDATE SOME SEGMENTS WHICH ARE NOT IDENTIFIED AS frontier (they didn't join the CCM)
*/

UPDATE france.rn set isfrontier = TRUE where idsegment ='FR1775';
UPDATE france.rn set isfrontier = TRUE where idsegment ='FR3977';
UPDATE france.rn set isfrontier = TRUE where idsegment ='FR4467';
UPDATE france.rn set isfrontier = TRUE where idsegment ='FR500037';
UPDATE france.rn set isfrontier = TRUE where idsegment ='FR500039';
UPDATE france.rn set isfrontier = TRUE where idsegment ='FR500043';
UPDATE france.rn set isfrontier = TRUE where idsegment ='FR500044';
UPDATE france.rn set isfrontier = TRUE where idsegment in ('FR401073','FR401022','FR400800','FR400694','FR400638','FR400491',
'FR400313','FR400129','FR400110','FR400035','FR400030','FR400025','FR400001');

-- correct error in france for issea

UPDATE france.rn set issea=FALSE where isfrontier;-- 135 rows affected, 268 msec execution time.

begin;
UPDATE france.rn set seaidsegment=idsegment where issea;-- 946 rows affected, 1.0 secs execution time.
COMMIT;

-- FIND THE FRONTIER NODES FLOWING FROM FRANCE TO SPAIN AND UPDATE THEM
BEGIN;
with pyrenees as (
SELECT distinct on (f.idsegment) f.idsegment as fidsegment, s.* FROM france.rn  f
join spain.rn s on st_dwithin(s.geom, f.geom,50)
where f.isfrontier
order by f.idsegment, f.geom <-> s.geom)

update france.rn set (nextdownidsegment, path, seaidsegment,isinternational) =
( 
pyrenees.idsegment,
text2ltree(ltree2text(pyrenees.path)||'.'||fidsegment),
pyrenees.seaidsegment,
TRUE)
 FROM pyrenees
 where fidsegment=rn.idsegment; --8
COMMIT;



-- UPDATE BASINS UPSTREAM FROM FRONTIER SEGMENTS FLOWING FROM FRANCE TO SPAIN
BEGIN;
-- segments at the frontier, flowing to spain corrected previouly
with pyrenees as (
SELECT distinct on (f.idsegment) f.idsegment as fidsegment, f.path as fpath, f.seaidsegment as fseaidsegment FROM france.rn  f
join spain.rn s on st_dwithin(s.geom, f.geom,50)
where f.isfrontier
order by f.idsegment, f.geom <-> s.geom),
-- basins upstream from those segments, currently flowing to france with seaidsegment in France (! wrong)
upstreampyrenees as (
select idsegment as idsegmentupstream, path as pathupstream, pyrenees.* from france.rn 
JOIN pyrenees on seaidsegment=fidsegment)
-- there is a path, we need to remove the most dowstream segment as it is already in the path of the segment downstream
-- we paste first the donwstream part path, and then the clipped part upstream. The function ltree||ltree adds the '.'
--select * from upstreampyrenees
UPDATE france.rn set (path, seaidsegment,isinternational)=
(fpath||subltree(pathupstream, 1, nlevel(pathupstream)),-- subpath(fpath||subltree(path, 1, nlevel(path)),400) to be able to read
fseaidsegment,
TRUE) FROM upstreampyrenees
where rn.idsegment=upstreampyrenees.idsegmentupstream;--Query returned successfully: 84 rows affected, 500 msec execution time.
COMMIT;



UPDATE spain.rn set isendoreic=TRUE, isfrontier=FALSE where idsegment='SP226616';
begin;
UPDATE spain.rn set isinternational=FALSE where isinternational is NULL;--211026 
COMMIT;


begin;
with frontier_segments as (select * from france.rn where isfrontier),
--SELECT rn_rna.* from france.rn_rna JOIN frontier_segments ON  frontier_segments.path @> rn_rna.path --is left argument an ancestor of right (or equal)?
joined as (
SELECT rn.idsegment from france.rn JOIN frontier_segments ON  frontier_segments.path @> rn.path)
UPDATE france.rn set isinternational=TRUE FROM joined where joined.idsegment=rn.idsegment;--8357 
COMMIT;



SELECT distinct(rna.riverwidthmsource) from dbeel_rivers.rna;


UPDATE spain.rna SET codesea='A' WHERE codesea IS NULL;--1


-- Change to table structures after predictions

ALTER TABLE dbeel_rivers.rna ADD COLUMN psilver NUMERIC;
ALTER TABLE dbeel_rivers.rna RENAME COLUMN nsilver300450 TO psilver300450;
ALTER TABLE dbeel_rivers.rna RENAME COLUMN nsilver450600 TO psilver450600;
ALTER TABLE dbeel_rivers.rna RENAME COLUMN nsilver600750 TO psilver600750;
ALTER TABLE dbeel_rivers.rna RENAME COLUMN nsilver750 TO psilver750;
ALTER TABLE dbeel_rivers.rna ADD COLUMN psilver150300 NUMERIC;
ALTER TABLE dbeel_rivers.rna ADD COLUMN pmale150300 NUMERIC;
ALTER TABLE dbeel_rivers.rna ADD COLUMN pmale300450 NUMERIC;
ALTER TABLE dbeel_rivers.rna ADD COLUMN pmale450600 NUMERIC;
ALTER TABLE dbeel_rivers.rna ADD COLUMN pfemale300450 NUMERIC;
ALTER TABLE dbeel_rivers.rna ADD COLUMN pfemale450600 NUMERIC;
ALTER TABLE dbeel_rivers.rna ADD COLUMN pfemale600750 NUMERIC;
ALTER TABLE dbeel_rivers.rna ADD COLUMN pfemale750 NUMERIC;
ALTER TABLE dbeel_rivers.rna ADD COLUMN pmale NUMERIC;
ALTER TABLE dbeel_rivers.rna ADD COLUMN pfemale NUMERIC;

----------------------------------------
-- script TO UPDATE dry status FROM rivers
-------------------------------------------


--USING Qgis export TABLE rios_temporales_20191129 TO SCHEMA spain
/*
 * code tempor 
 * 1 Permanente
 * 2 Temporal
 * 3 Intermitente
 * 4 Efimero
 * 5 Sin datos
 */


ALTER TABLE spain."Rios temporales_20191129" RENAME TO  rios_temporales_2019;
SELECT * FROM spain.rios_temporales_2019 LIMIT 10;
-- TODO integrate corrections FROM Maria

ALTER TABLE spain.rios_temporales_2019 
  ALTER COLUMN geom 
  TYPE Geometry(MULTILINESTRING, 3035) 
  USING ST_Transform(geom, 3035);


create index rios_temporales_2019_geom_idx on  spain.rios_temporales_2019
  USING gist  (geom) ;
 
 -- Correction these streams are dry in google so they are at least temporary
 -- these corrections have been sent to Belen
 
 UPDATE spain.rios_temporales_2019 SET cod_tempor=3 WHERE 
cod_masa IN ('ES064MSPF000134890','ES050MSPF011002047','ES063MSPF000119260','ES063MSPF000119280','ES063MSPF000119300','ES060MSPF0613020','ES060MSPF0613030',
'ES060MSPF0613040','ES060MSPF0613050','ES060MSPF0613062','ES060MSPF0613072Z','ES060MSPF0613140','ES060MSPF0613150','ES060MSPF0613160','ES060MSPF0623010','ES060MSPF0623020',
'ES060MSPF0623030','ES060MSPF0631010','ES060MSPF0631020','ES060MSPF0631040','ES060MSPF0634090','ES060MSPF0641020','18065'); --23


DROP TABLE IF EXISTS spain.temp_temporales_rn;
CREATE TABLE spain.temp_temporales_rn AS(
SELECT DISTINCT ON (idsegment) 
idsegment,
rn.geom,
cod_tempor,
'rios_temporales' AS type_calc_dryrivers
FROM spain.rios_temporales_2019 rt 
JOIN spain.rn ON st_dwithin(rt.geom,rn.geom,50)
ORDER BY idsegment, cod_tempor , rt.geom <-> rn.geom
); --35m 63112

--DELETE FROM spain.temp_temporales_rn WHERE type_calc_dryrivers !='rios_temporales'; --82115





/*
 * 
 * SELECT * FROM spain.rn 
* JOIN spain.rn_rna ON (rn.idsegment=rna.idsegment)
*/


CREATE INDEX temp_temporales_rn_idsegment_idx ON spain.temp_temporales_rn
  USING btree(idsegment) ;

/*
 * reduce rn-rna to the temporary dataset
 * find the downstream segments in path that flow through the dry rivers
 * If the donwstream part is dry then we consider that the upstream part has the same status
 * remember here we are interested in eel, there is very little chance they will get upstream 
 * if part of the stream is dry during the year
 */ 

 WITH 
downstream_course AS (
  SELECT unnest(regexp_split_to_array(ltree2text(path),E'\\.+')) AS idsegment,
  rn.idsegment AS idsegmentsource,
  geom
  FROM spain.rn),
  
dryrivers AS (
       SELECT idsegment, cod_tempor FROM
  spain.temp_temporales_rn tmp 
  WHERE cod_tempor IN ('3','4')
     		),
     
to_insert AS (
  SELECT DISTINCT ON(idsegmentsource) 
  		idsegmentsource AS idsegment,
        cod_tempor,
        downstream_course.geom        
  FROM downstream_course
  JOIN dryrivers ON downstream_course.idsegment = dryrivers.idsegment
  			),
  
upstream_to_insert AS (
  SELECT * FROM to_insert 
  EXCEPT
  SELECT to_insert.* FROM to_insert JOIN 
  spain.temp_temporales_rn tmp 
  ON tmp.idsegment = to_insert.idsegment
  ) 
  
   INSERT INTO spain.temp_temporales_rn(idsegment, cod_tempor, geom, type_calc_dryrivers)
   SELECT idsegment, cod_tempor, geom, 'upstream' AS type_calc_dryrivers FROM upstream_to_insert ; --57455 3 min


/*
 * those segments with low shreeve <2 or very low flow are dry in the following regions
 * 'CUENCAS MEDITERRANEAS DE ANDALUCIA', 'JUCAR', 'GUADIANA', 'CUENCAS ATLANTICAS DE ANDALUCIA', 'GUADALQUIVIR'
 */   
   
  
   
WITH missing AS (
SELECT idsegment, dis_m3_pmn_riveratlas, shreeve, basin, geom  FROM spain.rn_rna
EXCEPT 
SELECT rn_rna.idsegment, rn_rna.dis_m3_pmn_riveratlas, rn_rna.shreeve, rn_rna.basin, rn_rna.geom FROM spain.rn_rna JOIN
spain.temp_temporales_rn tmp
ON tmp.idsegment = rn_rna.idsegment
),

null_flow AS (
SELECT * FROM missing
WHERE 
dis_m3_pmn_riveratlas IS NULL 
AND shreeve <6
AND basin IN ('CUENCAS MEDITERRANEAS DE ANDALUCIA', 'JUCAR', 'GUADIANA', 'CUENCAS ATLANTICAS DE ANDALUCIA', 'GUADALQUIVIR', 'SEGURA')
)

INSERT INTO spain.temp_temporales_rn(idsegment, cod_tempor, geom, type_calc_dryrivers)
   SELECT idsegment, 3 AS cod_tempor, geom, 'NULL and shreeve <6' AS type_calc_dryrivers FROM null_flow ; -- 29597 45s

--DELETE FROM spain.temp_temporales_rn WHERE type_calc_dryrivers = 'flow <= 0.01'; 
-- Same with flow <=0.3   
WITH missing AS (
SELECT * FROM spain.rn_rna
EXCEPT 
SELECT rn_rna.* FROM spain.rn_rna JOIN
spain.temp_temporales_rn tmp
ON tmp.idsegment = rn_rna.idsegment
),

low_flow AS (
SELECT * FROM missing
WHERE 
dis_m3_pmn_riveratlas IS NOT NULL AND  dis_m3_pmn_riveratlas <= 0.3
AND basin IN ('CUENCAS MEDITERRANEAS DE ANDALUCIA', 'JUCAR', 'GUADIANA', 'CUENCAS ATLANTICAS DE ANDALUCIA', 'GUADALQUIVIR', 'SEGURA')
)

INSERT INTO spain.temp_temporales_rn(idsegment, cod_tempor, geom, type_calc_dryrivers)
   SELECT idsegment, 3 AS cod_tempor, geom, 'flow <= 0.3' AS type_calc_dryrivers FROM low_flow ; --2787

---------------------------------------------------------
-- Portugal
-- South with flow <0.3   
--------------------------------------------------------
DROP TABLE IF EXISTS portugal.temp_temporales_rn;   
CREATE TABLE portugal.temp_temporales_rn (LIKE spain.temp_temporales_rn);



--NULL
WITH 
downstream_course AS (
  SELECT unnest(regexp_split_to_array(ltree2text(path),E'\\.+')) AS idsegment,
  rn.idsegment AS idsegmentsource,
  geom
  FROM portugal.rn),
  
dry_rivers AS (

SELECT * 
FROM portugal.rn_rna		
WHERE dis_m3_pmn_riveratlas IS NULL
AND basin IN ('Ribeiras do Algarve', 'Mira', 'Guadiana','Arade')
AND shreeve < 6
     		),
     
to_insert AS (
  SELECT DISTINCT ON(idsegmentsource) 
  		idsegmentsource AS idsegment,
        3 AS cod_tempor,
        downstream_course.geom,
        'shreeve <6 and NULL flow' AS type_calc_dryrivers
  FROM downstream_course
  JOIN dry_rivers ON downstream_course.idsegment = dry_rivers.idsegment
  			),
  
upstream_to_insert AS (
  SELECT * FROM to_insert 
  EXCEPT
  SELECT to_insert.* FROM to_insert 
  JOIN   portugal.temp_temporales_rn tmp   ON tmp.idsegment = to_insert.idsegment
  )    

INSERT INTO portugal.temp_temporales_rn(idsegment, cod_tempor, geom, type_calc_dryrivers)
   SELECT idsegment, cod_tempor, geom, type_calc_dryrivers FROM upstream_to_insert ; --9341




WITH 
downstream_course AS (
  SELECT unnest(regexp_split_to_array(ltree2text(path),E'\\.+')) AS idsegment,
  rn.idsegment AS idsegmentsource,
  geom
  FROM portugal.rn),
  
dry_rivers AS (

SELECT * 
FROM portugal.rn_rna		
WHERE dis_m3_pmn_riveratlas IS NOT NULL AND  dis_m3_pmn_riveratlas< 0.3
AND basin IN ('Ribeiras do Algarve', 'Mira', 'Guadiana','Arade')
ORDER BY dis_m3_pmn_riveratlas
     		),
     
to_insert AS (
  SELECT DISTINCT ON(idsegmentsource) 
  		idsegmentsource AS idsegment,
        3 AS cod_tempor,
        downstream_course.geom,
        'flow <0.3' AS type_calc_dryrivers
  FROM downstream_course
  JOIN dry_rivers ON downstream_course.idsegment = dry_rivers.idsegment
  			),
  
upstream_to_insert AS (
  SELECT * FROM to_insert 
  EXCEPT
  SELECT to_insert.* FROM to_insert 
  JOIN   portugal.temp_temporales_rn tmp   ON tmp.idsegment = to_insert.idsegment
  )    

INSERT INTO portugal.temp_temporales_rn(idsegment, cod_tempor, geom, type_calc_dryrivers)
   SELECT idsegment, cod_tempor, geom, type_calc_dryrivers FROM upstream_to_insert ; --3836

   -- Apply everywhere in Spain

WITH missing AS (
SELECT * FROM spain.rn_rna
EXCEPT 
SELECT rn_rna.* FROM spain.rn_rna JOIN
spain.temp_temporales_rn tmp
ON tmp.idsegment = rn_rna.idsegment
),

low_flow AS (
SELECT * FROM missing
WHERE 
dis_m3_pmn_riveratlas IS  NULL AND shreeve<6
)   

INSERT INTO spain.temp_temporales_rn(idsegment, cod_tempor, geom, type_calc_dryrivers)
   SELECT idsegment, 3 AS cod_tempor, geom, 'NULL and shreeve <6' AS type_calc_dryrivers FROM low_flow ;--112984
   
WITH missing AS (
SELECT * FROM spain.rn_rna
EXCEPT 
SELECT rn_rna.* FROM spain.rn_rna JOIN
spain.temp_temporales_rn tmp
ON tmp.idsegment = rn_rna.idsegment
),

low_flow AS (
SELECT * FROM missing
WHERE 
dis_m3_pmn_riveratlas IS NOT NULL AND dis_m3_pmn_riveratlas <0.1
)   

INSERT INTO spain.temp_temporales_rn(idsegment, cod_tempor, geom, type_calc_dryrivers)
   SELECT idsegment, 3 AS cod_tempor, geom, 'flow<0.1' AS type_calc_dryrivers FROM low_flow ;--26119
      

-- 'Ribeiras do Alentejo'   

WITH 
downstream_course AS (
  SELECT unnest(regexp_split_to_array(ltree2text(path),E'\\.+')) AS idsegment,
  rn.idsegment AS idsegmentsource,
  geom
  FROM portugal.rn),
  
dry_rivers AS (

SELECT * 
FROM portugal.rn_rna		
WHERE dis_m3_pmn_riveratlas IS NULL
AND basin IN ('Ribeiras do Alentejo')
AND shreeve < 6
     		),
     
to_insert AS (
  SELECT DISTINCT ON(idsegmentsource) 
  		idsegmentsource AS idsegment,
        3 AS cod_tempor,
        downstream_course.geom,
        'shreeve <6 and NULL flow' AS type_calc_dryrivers
  FROM downstream_course
  JOIN dry_rivers ON downstream_course.idsegment = dry_rivers.idsegment
  			),
  
upstream_to_insert AS (
  SELECT * FROM to_insert 
  EXCEPT
  SELECT to_insert.* FROM to_insert 
  JOIN   portugal.temp_temporales_rn tmp   ON tmp.idsegment = to_insert.idsegment
  )    

INSERT INTO portugal.temp_temporales_rn(idsegment, cod_tempor, geom, type_calc_dryrivers)
   SELECT idsegment, cod_tempor, geom, type_calc_dryrivers FROM upstream_to_insert ; --316




WITH 
downstream_course AS (
  SELECT unnest(regexp_split_to_array(ltree2text(path),E'\\.+')) AS idsegment,
  rn.idsegment AS idsegmentsource,
  geom
  FROM portugal.rn),
  
dry_rivers AS (

SELECT * 
FROM portugal.rn_rna		
WHERE dis_m3_pmn_riveratlas IS NOT NULL AND  dis_m3_pmn_riveratlas< 0.05
AND basin IN ('Ribeiras do Alentejo')
ORDER BY dis_m3_pmn_riveratlas
     		),
     
to_insert AS (
  SELECT DISTINCT ON(idsegmentsource) 
  		idsegmentsource AS idsegment,
        3 AS cod_tempor,
        downstream_course.geom,
        'flow <0.05 Ribeiras do Alentejo' AS type_calc_dryrivers
  FROM downstream_course
  JOIN dry_rivers ON downstream_course.idsegment = dry_rivers.idsegment
  			),
  
upstream_to_insert AS (
  SELECT * FROM to_insert 
  EXCEPT
  SELECT to_insert.* FROM to_insert 
  JOIN   portugal.temp_temporales_rn tmp   ON tmp.idsegment = to_insert.idsegment
  )    

INSERT INTO portugal.temp_temporales_rn(idsegment, cod_tempor, geom, type_calc_dryrivers)
   SELECT idsegment, cod_tempor, geom, type_calc_dryrivers FROM upstream_to_insert ; --85
  


   
-- All other  
   

WITH 
downstream_course AS (
  SELECT unnest(regexp_split_to_array(ltree2text(path),E'\\.+')) AS idsegment,
  rn.idsegment AS idsegmentsource,
  geom
  FROM portugal.rn),
  
dry_rivers AS (

SELECT * 
FROM portugal.rn_rna		
WHERE dis_m3_pmn_riveratlas IS NULL
AND basin IN 
('Sado', 
'Tejo', 
'Ribeiras do Oeste', 
'Ave',
'Vouga e Ribeiras Costeiras',
'Leça e Ribeiras Costeiras',
'Lis e Ribeiras Costeiras',
'Ribeiras do Alentejo',
'Douro',
'Ancora e Ribeiras Costeiras',
'Neiva e Ribeiras Costeiras',
'Lima',
'Mira',
'Minho',
'Cávado e Ribeiras Costeiras',
'Mondego')
AND shreeve < 6
     		),
     
to_insert AS (
  SELECT DISTINCT ON(idsegmentsource) 
  		idsegmentsource AS idsegment,
        3 AS cod_tempor,
        downstream_course.geom,
        'shreeve <6 and NULL flow' AS type_calc_dryrivers
  FROM downstream_course
  JOIN dry_rivers ON downstream_course.idsegment = dry_rivers.idsegment
  			),
  
upstream_to_insert AS (
  SELECT * FROM to_insert 
  EXCEPT
  SELECT to_insert.* FROM to_insert 
  JOIN   portugal.temp_temporales_rn tmp   ON tmp.idsegment = to_insert.idsegment
  )    

INSERT INTO portugal.temp_temporales_rn(idsegment, cod_tempor, geom, type_calc_dryrivers)
   SELECT idsegment, cod_tempor, geom, type_calc_dryrivers FROM upstream_to_insert ; --35944 +429




WITH 
downstream_course AS (
  SELECT unnest(regexp_split_to_array(ltree2text(path),E'\\.+')) AS idsegment,
  rn.idsegment AS idsegmentsource,
  geom
  FROM portugal.rn),
  
dry_rivers AS (

SELECT * 
FROM portugal.rn_rna		
WHERE dis_m3_pmn_riveratlas IS NOT NULL AND  dis_m3_pmn_riveratlas< 0.1
AND basin IN ('Sado', 
'Tejo', 
'Ribeiras do Oeste', 
'Ave',
'Vouga e Ribeiras Costeiras',
'Leça e Ribeiras Costeiras',
'Lis e Ribeiras Costeiras',
'Ribeiras do Alentejo',
'Douro',
'Ancora e Ribeiras Costeiras',
'Neiva e Ribeiras Costeiras',
'Lima',
'Mira',
'Minho',
'Cávado e Ribeiras Costeiras',
'Mondego')
ORDER BY dis_m3_pmn_riveratlas
     		),
     
to_insert AS (
  SELECT DISTINCT ON(idsegmentsource) 
  		idsegmentsource AS idsegment,
        3 AS cod_tempor,
        downstream_course.geom,
        'flow <0.1' AS type_calc_dryrivers
  FROM downstream_course
  JOIN dry_rivers ON downstream_course.idsegment = dry_rivers.idsegment
  			),
  
upstream_to_insert AS (
  SELECT * FROM to_insert 
  EXCEPT
  SELECT to_insert.* FROM to_insert 
  JOIN   portugal.temp_temporales_rn tmp   ON tmp.idsegment = to_insert.idsegment
  )    

INSERT INTO portugal.temp_temporales_rn(idsegment, cod_tempor, geom, type_calc_dryrivers)
   SELECT idsegment, cod_tempor, geom, type_calc_dryrivers FROM upstream_to_insert ; --16620 + 420 +437
  

WITH large_flow AS (
SELECT idsegment 
FROM portugal.rn_rna		
WHERE dis_m3_pmn_riveratlas IS NOT NULL AND  dis_m3_pmn_riveratlas>= 0.1
AND basin IN 
('Sado', 
'Tejo', 
'Ribeiras do Oeste', 
'Ave',
'Vouga e Ribeiras Costeiras',
'Leça e Ribeiras Costeiras',
'Lis e Ribeiras Costeiras',
'Ribeiras do Alentejo',
'Douro',
'Ancora e Ribeiras Costeiras',
'Neiva e Ribeiras Costeiras',
'Lima',
'Mira',
'Minho',
'Cávado e Ribeiras Costeiras',
'Mondego')
)
UPDATE portugal.temp_temporales_rn SET cod_tempor=1 
FROM large_flow WHERE large_flow.idsegment=temp_temporales_rn.idsegment; --8205
   
WITH large_flow AS (
SELECT idsegment 
FROM portugal.rn_rna		
WHERE dis_m3_pmn_riveratlas IS NOT NULL AND  dis_m3_pmn_riveratlas>= 0.3
AND basin IN 
('Ribeiras do Algarve', 'Mira', 'Guadiana','Arade')
)
UPDATE portugal.temp_temporales_rn SET cod_tempor=1 
FROM large_flow WHERE large_flow.idsegment=temp_temporales_rn.idsegment;   

WITH large_flow AS (
SELECT idsegment 
FROM portugal.rn_rna		
WHERE dis_m3_pmn_riveratlas IS NOT NULL AND  dis_m3_pmn_riveratlas>= 0.3
AND basin IN 
('Ribeiras do Algarve', 'Mira', 'Guadiana','Arade')
)
UPDATE portugal.temp_temporales_rn SET cod_tempor=1 
FROM large_flow WHERE large_flow.idsegment=temp_temporales_rn.idsegment;--55


-- missing segments for large flows
WITH large_flow AS (
SELECT idsegment, 1 AS cod_tempor, geom, 'flow >0.1' AS type_calc_dryrivers
FROM portugal.rn_rna		
WHERE dis_m3_pmn_riveratlas IS NOT NULL AND  dis_m3_pmn_riveratlas>= 0.1
AND basin IN 
('Sado', 
'Tejo', 
'Ribeiras do Oeste', 
'Ave',
'Vouga e Ribeiras Costeiras',
'Leça e Ribeiras Costeiras',
'Lis e Ribeiras Costeiras',
'Ribeiras do Alentejo',
'Douro',
'Ancora e Ribeiras Costeiras',
'Neiva e Ribeiras Costeiras',
'Lima',
'Mira',
'Minho',
'Cávado e Ribeiras Costeiras',
'Mondego')
AND idsegment NOT IN (SELECT idsegment FROM portugal.temp_temporales_rn))
INSERT INTO portugal.temp_temporales_rn(idsegment, cod_tempor, geom, type_calc_dryrivers)
   SELECT idsegment, cod_tempor, geom, type_calc_dryrivers FROM large_flow ; --4167

   -- missing segments for large flows south
WITH large_flow AS (
SELECT idsegment, 1 AS cod_tempor, geom, 'flow >0.1' AS type_calc_dryrivers
FROM portugal.rn_rna		
WHERE dis_m3_pmn_riveratlas IS NOT NULL AND  dis_m3_pmn_riveratlas>= 0.3
AND basin IN 
('Ribeiras do Algarve', 'Mira', 'Guadiana','Arade')
AND idsegment NOT IN (SELECT idsegment FROM portugal.temp_temporales_rn))
INSERT INTO portugal.temp_temporales_rn(idsegment, cod_tempor, geom, type_calc_dryrivers)
   SELECT idsegment, cod_tempor, geom, type_calc_dryrivers FROM large_flow ; --855

  

SELECT DISTINCT type_calc_dryrivers FROM spain.temp_temporales_rn    

UPDATE spain.temp_temporales_rn SET type_calc_dryrivers =  'Projected from temporal stream layer' 
WHERE type_calc_dryrivers = 'rios_temporales'; --63112

UPDATE spain.temp_temporales_rn SET (type_calc_dryrivers,cod_tempor)  =  ('Thalweg : shreeve <6 and NULL flow','4') 
WHERE type_calc_dryrivers = 'NULL and shreeve <6'; --112984

UPDATE spain.temp_temporales_rn SET (type_calc_dryrivers, cod_tempor) =  ('Thalweg : shreeve <6 and NULL flow', '4') 
WHERE type_calc_dryrivers = 'NULL and shreeve <3'; --29597

UPDATE spain.temp_temporales_rn SET type_calc_dryrivers =  'Upstream from temporal stream layer' 
WHERE type_calc_dryrivers = 'upstream'; --57455


UPDATE spain.temp_temporales_rn SET type_calc_dryrivers =  'Probably no stream, flow < 0.1' 
WHERE type_calc_dryrivers = 'flow<0.1'; --26119

UPDATE spain.temp_temporales_rn SET type_calc_dryrivers =  'Probably no stream, flow < 0.3, South Spain' 
WHERE type_calc_dryrivers = 'flow <= 0.3'; --2787


SELECT DISTINCT type_calc_dryrivers FROM portugal.temp_temporales_rn    

UPDATE portugal.temp_temporales_rn SET type_calc_dryrivers =  'Probably no stream, flow < 0.1' 
WHERE type_calc_dryrivers = 'flow <0.1'; --17477

UPDATE portugal.temp_temporales_rn SET type_calc_dryrivers =  'Probably no stream, flow < 0.3, South Portugal' 
WHERE type_calc_dryrivers = 'flow <0.3'; --3836

UPDATE portugal.temp_temporales_rn SET type_calc_dryrivers =  'Probably a stream, flow > 0.1' 
WHERE type_calc_dryrivers = 'flow >0.1'; --5022

UPDATE portugal.temp_temporales_rn SET (type_calc_dryrivers, cod_tempor) =  ('Thalweg : shreeve <6 and NULL flow', '4') 
WHERE type_calc_dryrivers = 'shreeve <6 and NULL flow'; --48104

VACUUM ANALYSE portugal.temp_temporales_rn
VACUUM ANALYSE spain.temp_temporales_rn

-- DUMP TO MARIA

-- Change to table structures after predictions

ALTER TABLE dbeel_rivers.rna ADD COLUMN drought TEXT;
ALTER TABLE dbeel_rivers.rna ADD COLUMN drought_type_calc TEXT;

UPDATE spain.rna SET drought='5'; -- default 325399
UPDATE spain.rna SET (drought, drought_type_calc) = (cod_tempor, type_calc_dryrivers)  FROM
		spain.temp_temporales_rn trn WHERE
		trn.idsegment = rna.idsegment;--292054
UPDATE portugal.rna SET drought='5'; --75056
UPDATE portugal.rna SET (drought, drought_type_calc) = (cod_tempor, type_calc_dryrivers) FROM
		portugal.temp_temporales_rn trn WHERE
		trn.idsegment = rna.idsegment; -- 74524
/*
* code tempor 
 * 1 Permanente
 * 2 Temporal
 * 3 Intermitente
 * 4 Efimero
 * 5 Sin datos
-*/





	
		
/*-------------------------------------------------------
* FINAL cleaning OF the rna, remove eel attrib. FROM rna
* CREATE a rne table to store information about eel
*/------------------------------------------------------

ALTER TABLE dbeel_rivers.rn_rna_annual_pred RENAME TO rne_annual;
ALTER TABLE dbeel_rivers.rna DROP COLUMN turbinemortalitynsilver;
ALTER TABLE dbeel_rivers.rna DROP COLUMN turbinemortalityrate;
-- we have saved twice the table rna_model_transport on the same table I need to restore the table from model transport lines 9849

DROP TABLE IF EXISTS dbeel_rivers.rne CASCADE;
CREATE TABLE dbeel_rivers.rne (
idsegment TEXT,
surfaceunitbvm2 NUMERIC,
surfacebvm2 NUMERIC,
delta NUMERIC,
gamma NUMERIC,
density NUMERIC,
nyellow NUMERIC,
byellow NUMERIC, -- rne_annual
pyellow150 NUMERIC,
pyellow150300 NUMERIC,
pyellow300450 NUMERIC,
pyellow450600 NUMERIC,
pyellow600750 NUMERIC,
pyellow750 NUMERIC,
nsilver NUMERIC,
bsilver NUMERIC, -- rne_annual
psilver150300 NUMERIC,
psilver300450 NUMERIC,
psilver450600 NUMERIC,
psilver600750 NUMERIC,
psilver750 NUMERIC,
psilver NUMERIC,
pmale150300 NUMERIC,
pmale300450 NUMERIC,
pmale450600 NUMERIC,
pfemale300450 NUMERIC,
pfemale450600 NUMERIC,
pfemale600750 NUMERIC,
pfemale750 NUMERIC,
pmale NUMERIC,
sex_ratio NUMERIC,  -- rne_annual
cnfemale300450 NUMERIC, -- dbeel_rivers.rn_rna_cumul_silver
cnfemale450600 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnfemale600750 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnfemale750 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnmale150300 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnmale300450 NUMERIC,-- dbeel_rivers.rn_rna_cumul_si
cnmale450600 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnsilver150300 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnsilver300450 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnsilver450600 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnsilver600750 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnsilver750 NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
cnsilver NUMERIC,-- dbeel_rivers.rn_rna_cumul_silver
delta_tr NUMERIC, --dbeel_rivers.rn_rna_model_transport_fit(deltatransport)
gamma_tr NUMERIC, --dbeel_rivers.rn_rna_model_transport_fit(gammatransport)
type_fit_delta_tr TEXT, --dbeel_rivers.rn_rna_model_transport_fit(type_fit_delta)
type_fit_gamma_tr TEXT, --dbeel_rivers.rn_rna_model_transport_fit(type_fit_gamma)
density_tr NUMERIC, --dbeel_rivers.rn_rna_model_transport_fit(densitytransport)
density_pmax_tr NUMERIC, -- dbeel_rivers.rn_rna_model_transport_fit(density2)
nyellow_pmax_tr NUMERIC, -- dbeel_rivers.rn_rna_model_transport(nyellow)
nsilver_pmax_tr NUMERIC, -- dbeel_rivers.rn_rna_model_transport(nsilver)
density_wd NUMERIC,  --TODO
nyellow_wd NUMERIC,  --TODO
byellow_wd NUMERIC,  --TODO
nsilver_wd NUMERIC,  --TODO
bsilver_wd NUMERIC,  --TODO
CONSTRAINT c_pk_rne_idsegment PRIMARY KEY (idsegment)
);


DROP TABLE IF EXISTS spain.rne;
CREATE TABLE spain.rne (
			CONSTRAINT c_pk_rne_idsegment PRIMARY KEY (idsegment),
			CONSTRAINT c_fk_rne_idsegment FOREIGN KEY (idsegment) REFERENCES spain.rn(idsegment))
			INHERITS (dbeel_rivers.rne); 
DROP TABLE IF EXISTS france.rne;		
CREATE TABLE france.rne (
			CONSTRAINT c_pk_rne_idsegment PRIMARY KEY (idsegment),
			CONSTRAINT c_fk_rne_idsegment FOREIGN KEY (idsegment) REFERENCES france.rn(idsegment))
			INHERITS (dbeel_rivers.rne); 
DROP TABLE IF EXISTS portugal.rne;
CREATE TABLE portugal.rne (
			CONSTRAINT c_pk_rne_idsegment PRIMARY KEY (idsegment),
			CONSTRAINT c_fk_rne_idsegment FOREIGN KEY (idsegment) REFERENCES portugal.rn(idsegment))
			INHERITS (dbeel_rivers.rne); 
			
-- Updates from rna

INSERT INTO spain.rne (
	idsegment
,	surfaceunitbvm2
,	surfacebvm2
,	delta
,	gamma
,	density
,	nyellow
,	pyellow150
,	pyellow150300
,	pyellow300450
,	pyellow450600
,	pyellow600750
,	pyellow750
,	nsilver
,	psilver150300
,	psilver300450
,	psilver450600
,	psilver600750
,	psilver750
,	psilver
,	pmale150300
,	pmale300450
,	pmale450600
,	pfemale300450
,	pfemale450600
,	pfemale600750
,	pfemale750
,	pmale
)
SELECT 
	idsegment
,	surfaceunitbvm2
,	surfacebvm2
,	delta
,	gamma
,	density
,	nyellow
,	pyellow150
,	pyellow150300
,	pyellow300450
,	pyellow450600
,	pyellow600750
,	pyellow750
,	nsilver
,	psilver150300
,	psilver300450
,	psilver450600
,	psilver600750
,	psilver750
,	psilver
,	pmale150300
,	pmale300450
,	pmale450600
,	pfemale300450
,	pfemale450600
,	pfemale600750
,	pfemale750
,	pmale
FROM spain.rna
;	-- 325399

INSERT INTO france.rne (
	idsegment
,	surfaceunitbvm2
,	surfacebvm2
,	delta
,	gamma
,	density
,	nyellow
,	pyellow150
,	pyellow150300
,	pyellow300450
,	pyellow450600
,	pyellow600750
,	pyellow750
,	nsilver
,	psilver150300
,	psilver300450
,	psilver450600
,	psilver600750
,	psilver750
,	psilver
,	pmale150300
,	pmale300450
,	pmale450600
,	pfemale300450
,	pfemale450600
,	pfemale600750
,	pfemale750
,	pmale)
SELECT 
	idsegment
,	surfaceunitbvm2
,	surfacebvm2
,	delta
,	gamma
,	density
,	nyellow
,	pyellow150
,	pyellow150300
,	pyellow300450
,	pyellow450600
,	pyellow600750
,	pyellow750
,	nsilver
,	psilver150300
,	psilver300450
,	psilver450600
,	psilver600750
,	psilver750
,	psilver
,	pmale150300
,	pmale300450
,	pmale450600
,	pfemale300450
,	pfemale450600
,	pfemale600750
,	pfemale750
,	pmale
FROM france.rna
; --114556

INSERT INTO portugal.rne (
	idsegment
,	surfaceunitbvm2
,	surfacebvm2
,	delta
,	gamma
,	density
,	nyellow
,	pyellow150
,	pyellow150300
,	pyellow300450
,	pyellow450600
,	pyellow600750
,	pyellow750
,	nsilver
,	psilver150300
,	psilver300450
,	psilver450600
,	psilver600750
,	psilver750
,	psilver
,	pmale150300
,	pmale300450
,	pmale450600
,	pfemale300450
,	pfemale450600
,	pfemale600750
,	pfemale750
,	pmale)
SELECT 
	idsegment
,	surfaceunitbvm2
,	surfacebvm2
,	delta
,	gamma
,	density
,	nyellow
,	pyellow150
,	pyellow150300
,	pyellow300450
,	pyellow450600
,	pyellow600750
,	pyellow750
,	nsilver
,	psilver150300
,	psilver300450
,	psilver450600
,	psilver600750
,	psilver750
,	psilver
,	pmale150300
,	pmale300450
,	pmale450600
,	pfemale300450
,	pfemale450600
,	pfemale600750
,	pfemale750
,	pmale
FROM portugal.rna
;--75056

SELECT * FROM dbeel_rivers.rne_annual LIMIT 10
-- updates from rne_annual

UPDATE spain.rne SET 
  (bsilver, beel, sex_ratio) = (aa.bsilver/1000, aa.byellow/1000, aa.sex_ratio)
FROM  dbeel_rivers.rne_annual aa WHERE year = '2015'
AND aa.idsegment=rne.idsegment; --323494 FINAL

UPDATE portugal.rne SET 
  (bsilver, beel, sex_ratio) = (aa.bsilver/1000, aa.byellow/1000, aa.sex_ratio)
FROM  dbeel_rivers.rne_annual aa WHERE year = '2015'
AND aa.idsegment=rne.idsegment; --74833 FINAL
UPDATE france.rne SET 
  (bsilver, beel, sex_ratio) = (aa.bsilver/1000, aa.byellow/1000, aa.sex_ratio)
FROM  dbeel_rivers.rne_annual aa WHERE year = '2015'
AND aa.idsegment=rne.idsegment;--114384 FINAL

/*
 * SELECT bsilver, byellow FROM dbeel_rivers.rne_annual
SELECT bsilver, byellow FROM portugal.rne
SELECT byellow FROM dbeel_rivers.rne_annual WHERE "year"='2015' AND idsegment LIKE ('%PT%') ;
SELECT bsilver FROM dbeel_rivers.rne_annual WHERE "year"='2015' AND idsegment LIKE ('%SP%');
*/

-- Updates from dbeel_rivers.rn_rna_cumul_silver

UPDATE spain.rne SET 
  (
	cnfemale300450
,	cnfemale450600
,	cnfemale600750
,	cnfemale750
,	cnmale150300
,	cnmale300450
,	cnmale450600
,	cnsilver150300
,	cnsilver300450
,	cnsilver450600
,	cnsilver600750
,	cnsilver750
,	cnsilver) =
  (
	c.cnfemale300450
,	c.cnfemale450600
,	c.cnfemale600750
,	c.cnfemale750
,	c.cnmale150300
,	c.cnmale300450
,	c.cnmale450600
,	c.cnsilver150300
,	c.cnsilver300450
,	c.cnsilver450600
,	c.cnsilver600750
,	c.cnsilver750
,	c.cnsilver) 
FROM  dbeel_rivers.rn_rna_cumul_silver c 
WHERE  c.idsegment=rne.idsegment; --325399

UPDATE portugal.rne SET 
  (
	cnfemale300450
,	cnfemale450600
,	cnfemale600750
,	cnfemale750
,	cnmale150300
,	cnmale300450
,	cnmale450600
,	cnsilver150300
,	cnsilver300450
,	cnsilver450600
,	cnsilver600750
,	cnsilver750
,	cnsilver) =
  (
	c.cnfemale300450
,	c.cnfemale450600
,	c.cnfemale600750
,	c.cnfemale750
,	c.cnmale150300
,	c.cnmale300450
,	c.cnmale450600
,	c.cnsilver150300
,	c.cnsilver300450
,	c.cnsilver450600
,	c.cnsilver600750
,	c.cnsilver750
,	c.cnsilver) 
FROM  dbeel_rivers.rn_rna_cumul_silver c 
WHERE  c.idsegment=rne.idsegment; --75056

UPDATE france.rne SET 
  (
	cnfemale300450
,	cnfemale450600
,	cnfemale600750
,	cnfemale750
,	cnmale150300
,	cnmale300450
,	cnmale450600
,	cnsilver150300
,	cnsilver300450
,	cnsilver450600
,	cnsilver600750
,	cnsilver750
,	cnsilver) =
  (
	c.cnfemale300450
,	c.cnfemale450600
,	c.cnfemale600750
,	c.cnfemale750
,	c.cnmale150300
,	c.cnmale300450
,	c.cnmale450600
,	c.cnsilver150300
,	c.cnsilver300450
,	c.cnsilver450600
,	c.cnsilver600750
,	c.cnsilver750
,	c.cnsilver) 
FROM  dbeel_rivers.rn_rna_cumul_silver c 
WHERE  c.idsegment=rne.idsegment;--114556

-- Updates for TRANSPORT
ALTER TABLE dbeel_rivers.rne ADD COLUMN sector_tr TEXT;
ALTER TABLE dbeel_rivers.rne ADD COLUMN year_tr INTEGER;

--SELECT count(*) FROM  dbeel_rivers.rn_rna_model_transport -- 512711
--SELECT count(*) FROM  dbeel_rivers.rn_rna_model_transport_fit --512711


SELECT sum(nsilver_pmax_tr) FROM dbeel_rivers.rne; -- 24 024 166
SELECT sum(nsilver) FROM dbeel_rivers.rn_rna_model_transport2; 25 024 866

WITH transport AS (
SELECT 
	tf.idsegment
, 	tf.deltatransport AS delta_tr
,	tf.gammatransport AS gamma_tr
, 	tf.type_fit_delta AS type_fit_delta_tr
, 	tf.type_fit_gamma AS type_fit_gamma_tr
, 	tf.densitytransport AS density_tr
, 	t.density2 AS density_pmax_tr
, 	t.nyellow AS nyellow_pmax_tr
, 	t.nsilver AS nsilver_pmax_tr
,    sector  AS sector_tr
,   year      AS year_tr
FROM dbeel_rivers.rn_rna_model_transport_fit tf
JOIN dbeel_rivers.rn_rna_model_transport2 t ON tf.idsegment = t.idsegment
LEFT JOIN dbeel_rivers.transport tt ON t.idsegment = tt.idsegment)

UPDATE spain.rne SET (
	delta_tr
,	gamma_tr
,	type_fit_delta_tr
,	type_fit_gamma_tr
,	density_tr
,	density_pmax_tr
,	neel_pmax_tr
,	nsilver_pmax_tr
,	sector_tr
,	year_tr) =

	(
	t.delta_tr
,	t.gamma_tr
,	t.type_fit_delta_tr
,	t.type_fit_gamma_tr
,	t.density_tr
,	t.density_pmax_tr
,	t.nyellow_pmax_tr
,	t.nsilver_pmax_tr
,	t.sector_tr
,	t.year_tr) FROM transport t
WHERE t.idsegment = rne.idsegment; --323494

WITH transport AS (
SELECT 
	tf.idsegment
, 	tf.deltatransport AS delta_tr
,	tf.gammatransport AS gamma_tr
, 	tf.type_fit_delta AS type_fit_delta_tr
, 	tf.type_fit_gamma AS type_fit_gamma_tr
, 	tf.densitytransport AS density_tr
, 	t.density2 AS density_pmax_tr
, 	t.nyellow AS nyellow_pmax_tr
, 	t.nsilver AS nsilver_pmax_tr
,    sector  AS sector_tr
,   year      AS year_tr
FROM dbeel_rivers.rn_rna_model_transport_fit tf
JOIN dbeel_rivers.rn_rna_model_transport t ON tf.idsegment = t.idsegment
LEFT JOIN dbeel_rivers.transport tt ON t.idsegment = tt.idsegment)

UPDATE portugal.rne SET (
	delta_tr
,	gamma_tr
,	type_fit_delta_tr
,	type_fit_gamma_tr
,	density_tr
,	density_pmax_tr
,	neel_pmax_tr
,	nsilver_pmax_tr
,	sector_tr
,	year_tr) =

	(
	t.delta_tr
,	t.gamma_tr
,	t.type_fit_delta_tr
,	t.type_fit_gamma_tr
,	t.density_tr
,	t.density_pmax_tr
,	t.nyellow_pmax_tr
,	t.nsilver_pmax_tr
,	t.sector_tr
,	t.year_tr) FROM transport t
WHERE t.idsegment = rne.idsegment; --74833

WITH transport AS (
SELECT 
	tf.idsegment
, 	tf.deltatransport AS delta_tr
,	tf.gammatransport AS gamma_tr
, 	tf.type_fit_delta AS type_fit_delta_tr
, 	tf.type_fit_gamma AS type_fit_gamma_tr
, 	tf.densitytransport AS density_tr
, 	t.density2 AS density_pmax_tr
, 	t.nyellow AS nyellow_pmax_tr
, 	t.nsilver AS nsilver_pmax_tr
,    sector  AS sector_tr
,   year      AS year_tr
FROM dbeel_rivers.rn_rna_model_transport_fit tf
JOIN dbeel_rivers.rn_rna_model_transport t ON tf.idsegment = t.idsegment
LEFT JOIN dbeel_rivers.transport tt ON t.idsegment = tt.idsegment)

UPDATE france.rne SET (
	delta_tr
,	gamma_tr
,	type_fit_delta_tr
,	type_fit_gamma_tr
,	density_tr
,	density_pmax_tr
,	neel_pmax_tr
,	nsilver_pmax_tr
,	sector_tr
,	year_tr) =

	(
	t.delta_tr
,	t.gamma_tr
,	t.type_fit_delta_tr
,	t.type_fit_gamma_tr
,	t.density_tr
,	t.density_pmax_tr
,	t.nyellow_pmax_tr
,	t.nsilver_pmax_tr
,	t.sector_tr
,	t.year_tr) FROM transport t
WHERE t.idsegment = rne.idsegment;--114384




ALTER TABLE dbeel_rivers.rne ADD COLUMN cnsilver_wd NUMERIC;
ALTER TABLE dbeel_rivers.rne ADD COLUMN is_current_distribution_area boolean;

ALTER TABLE dbeel_rivers.rne ADD COLUMN is_pristine_distribution_area_1985 boolean;
ALTER TABLE dbeel_rivers.rne ADD COLUMN is_pristine_distribution_area_2015 boolean;

UPDATE dbeel_rivers.rne SET (is_pristine_distribution_area_1985, is_pristine_distribution_area_2015, cnsilver_wd) = 
(nd.is_pristine_distribution_area_1985,  nd.is_pristine_distribution_area_2015, nd.cnsilver)
FROM dbeel_rivers.silver_upstream_nodam nd WHERE
nd.idsegment = rne.idsegment; --512711


UPDATE dbeel_rivers.rne SET (nyellow_wd, byellow_wd, nsilver_wd, bsilver_wd) = 
(nd.nyellow,  nd.byellow, nd.nsilver, nd.bsilver)
FROM dbeel_rivers.rne_annual_nodam nd WHERE
nd.idsegment = rne.idsegment
AND nd.year='2015'; --512711

UPDATE dbeel_rivers.rne SET is_current_distribution_area = NULL;
UPDATE dbeel_rivers.rne SET is_pristine_distribution_area_1985 = NULL;

UPDATE france.rne SET is_current_distribution_area = FALSE ;
UPDATE france.rne SET is_current_distribution_area = TRUE WHERE GREATEST(COALESCE(delta,0),COALESCE(delta_tr,0)) >0.01;
UPDATE portugal.rne SET is_current_distribution_area = FALSE ;
UPDATE portugal.rne SET is_current_distribution_area = TRUE WHERE GREATEST(COALESCE(delta,0),COALESCE(delta_tr,0)) >0.01;
UPDATE spain.rne SET is_current_distribution_area = FALSE ;
UPDATE spain.rne SET is_current_distribution_area = TRUE WHERE GREATEST(COALESCE(delta,0),COALESCE(delta_tr,0)) >0.01;

UPDATE  france.rne SET is_pristine_distribution_area_1985 =FALSE;
UPDATE  spain.rne SET is_pristine_distribution_area_1985 =FALSE;
UPDATE  portugal.rne SET is_pristine_distribution_area_1985 =FALSE;



CREATE UNIQUE INDEX ON dbeel_rivers.silver_upstream_nodam (idsegment) ;
WITH iii AS (
SELECT r.idsegment, n.delta_nodam_1985 FROM dbeel_rivers.rne r JOIN dbeel_rivers.silver_upstream_nodam n ON r.idsegment = n.idsegment
)
UPDATE FRANCE.rne SET is_pristine_distribution_area_1985 = iii.delta_nodam_1985>0.01 FROM iii WHERE rne.idsegment=iii.idsegment; --114384

WITH iii AS (
SELECT r.idsegment, n.delta_nodam_1985 FROM dbeel_rivers.rne r JOIN dbeel_rivers.silver_upstream_nodam n ON r.idsegment = n.idsegment
)
UPDATE  spain.rne SET is_pristine_distribution_area_1985 =iii.delta_nodam_1985 >0.01 FROM iii WHERE rne.idsegment=iii.idsegment;--323494

WITH iii AS (
SELECT r.idsegment, n.delta_nodam_1985 FROM dbeel_rivers.rne r JOIN dbeel_rivers.silver_upstream_nodam n ON r.idsegment = n.idsegment
)
UPDATE  portugal.rne SET is_pristine_distribution_area_1985 = iii.delta_nodam_1985 >0.01 FROM iii WHERE rne.idsegment=iii.idsegment;--74833

ALTER TABLE dbeel_rivers.rne DROP COLUMN is_pristine_distribution_area_2015 cascade;

ALTER TABLE dbeel_rivers.rne DROP COLUMN delta_nodam_1985 cascade;
/*
SELECT count(*), is_pristine_distribution_area_2015 FROM dbeel_rivers.rne group_by GROUP BY is_pristine_distribution_area_2015;
SELECT count(*), is_pristine_distribution_area_1985 FROM dbeel_rivers.rne group_by GROUP BY is_pristine_distribution_area_1985;
SELECT count(*), is_current_distribution_area FROM dbeel_rivers.rne group_by GROUP BY is_current_distribution_area;
SELECT count(*), cnsilver_wd-cnsilver>0 FROM dbeel_rivers.rne GROUP BY cnsilver_wd-cnsilver>0 ;
*/


--ALTER TABLE dbeel_rivers.rne DROP COLUMN pfemale CASCADE;

SELECT
   column_name
FROM
   information_schema.columns
WHERE
  table_name = 'rna'
AND table_schema ='dbeel_rivers';


ALTER TABLE dbeel_rivers.rna DROP COLUMN delta CASCADE;
ALTER TABLE dbeel_rivers.rna DROP COLUMN gamma;
ALTER TABLE dbeel_rivers.rna DROP COLUMN density;
ALTER TABLE dbeel_rivers.rna DROP COLUMN nyellow;
ALTER TABLE dbeel_rivers.rna DROP COLUMN pyellow150;
ALTER TABLE dbeel_rivers.rna DROP COLUMN pyellow150300;
ALTER TABLE dbeel_rivers.rna DROP COLUMN pyellow300450;
ALTER TABLE dbeel_rivers.rna DROP COLUMN pyellow450600;
ALTER TABLE dbeel_rivers.rna DROP COLUMN pyellow600750;
ALTER TABLE dbeel_rivers.rna DROP COLUMN pyellow750;
ALTER TABLE dbeel_rivers.rna DROP COLUMN nsilver;
ALTER TABLE dbeel_rivers.rna DROP COLUMN psilver300450;
ALTER TABLE dbeel_rivers.rna DROP COLUMN psilver450600;
ALTER TABLE dbeel_rivers.rna DROP COLUMN psilver600750;
ALTER TABLE dbeel_rivers.rna DROP COLUMN psilver750;
ALTER TABLE dbeel_rivers.rna DROP COLUMN psilver;
ALTER TABLE dbeel_rivers.rna DROP COLUMN pmale150300;
ALTER TABLE dbeel_rivers.rna DROP COLUMN pmale300450;
ALTER TABLE dbeel_rivers.rna DROP COLUMN pmale450600;
ALTER TABLE dbeel_rivers.rna DROP COLUMN pfemale300450;
ALTER TABLE dbeel_rivers.rna DROP COLUMN pfemale450600;
ALTER TABLE dbeel_rivers.rna DROP COLUMN pfemale600750;
ALTER TABLE dbeel_rivers.rna DROP COLUMN pfemale750;
ALTER TABLE dbeel_rivers.rna DROP COLUMN pmale;
ALTER TABLE dbeel_rivers.rna DROP COLUMN pfemale;
ALTER TABLE dbeel_rivers.rna DROP COLUMN psilver150300;




-- change just in rn rna not to inherited sudoang dbeel_rivers schema
SELECT * FROM france.rht_courseau_bdtopage
ALTER TABLE france.rna ADD COLUMN cdoh TEXT;
ALTER TABLE france.rna ADD COLUMN topooh TEXT;
COMMENT ON COLUMN france.rna.cdoh IS 'Stream code bd_topage';
COMMENT ON COLUMN france.rna.topooh IS 'name bd_topage';
UPDATE france.rna SET (cdoh, topooh) = (a.cdoh, a.topooh) FROM france.rht_courseau_bdtopage a
WHERE a.idsegment= rna.idsegment; --107058



UPDATE sudoang.dbeel_obstruction_place SET 
the_geom= ST_SetSRID(ST_GeomFromText('POINT(3518122 2066791)'),3035) 
WHERE op_id= 'bf802066-d2af-4d62-a656-f9402548f5fb' 
AND op_placename='Ribarroja';

UPDATE spain.rn_rne SET (
density
, nyellow
, byellow
, nsilver
, bsilver
, cnfemale300450
, cnfemale450600 
, cnfemale600750 
, cnfemale750 
, cnmale150300 
, cnmale300450 
, cnmale450600 
, cnsilver 
, cnsilver150300 
, cnsilver300450 
, cnsilver450600 
, cnsilver600750 
, cnsilver750 ) = (
0
, 0
, 0
, 0
, 0
, 0
, 0 
, 0 
, 0 
, 0 
, 0 
, 0 
, 0 
, 0 
, 0 
, 0 
, 0 
, 0 )
WHERE idsegment IN (SELECT spain.upstream_segments_rn('SP305043'));

SELECT * FROM dbeel_rivers.rne LIMIT 1;
ALTER TABLE dbeel_rivers.rne RENAME COLUMN nyellow TO neel;
ALTER TABLE dbeel_rivers.rne RENAME COLUMN byellow TO beel;
ALTER TABLE dbeel_rivers.rne RENAME COLUMN pyellow150 TO p150;
ALTER TABLE dbeel_rivers.rne RENAME COLUMN pyellow150300 TO p150300;
ALTER TABLE dbeel_rivers.rne RENAME COLUMN pyellow300450 TO p300450;
ALTER TABLE dbeel_rivers.rne RENAME COLUMN pyellow450600 TO p450600;
ALTER TABLE dbeel_rivers.rne RENAME COLUMN pyellow600750 TO p600750;
ALTER TABLE dbeel_rivers.rne RENAME COLUMN pyellow750 TO p750;
ALTER TABLE dbeel_rivers.rne RENAME COLUMN nyellow_pmax_tr TO neel_pmax_tr;
ALTER TABLE dbeel_rivers.rne RENAME COLUMN nyellow_wd TO neel_wd;
ALTER TABLE dbeel_rivers.rne RENAME COLUMN byellow_wd TO beel_wd;