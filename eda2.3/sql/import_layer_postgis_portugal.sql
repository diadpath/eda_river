 -- In Command prompt(cmd) we need to create a new schema and import the shapefiles to Postgres
 -- Create a new schema for Portugal
 psql - U postgres - c "create schema portugal" eda2.0 -- shp2pgsql with create index option
 -- Bacias SNIRH (to import shapefiles you must be in the directory where the files are found)
 shp2pgsql - s 3763 - I AtAgua_Bacias_bacias_snirh_PC.shp portugal.AtAgua_Bacias_bacias_snirh_PC > AtAgua_Bacias_bacias_snirh_PC.sql psql - U postgres - f AtAgua_Bacias_bacias_snirh_PC.sql eda2.0 -- Bacias dos troços de linha de água GeoCodificadas (basinorder corresponds to idlocalid from rede hordrografica)
 shp2pgsql - s 3763 - I vw_baccod_25k_ptcont.shp portugal.vw_baccod_25k_ptcont > vw_baccod_25k_ptcont.sql psql - U postgres - f vw_baccod_25k_ptcont.sql eda2.0 -- Rede hidrografica GeoCodificada
 shp2pgsql - s 3763 - W LATIN1 - I netElementL.shp portugal.netElementL > netElementL.sql psql - U postgres - f netElementL.sql eda2.0 ALTER TABLE
	portugal.netElementL RENAME TO rivers;

-- Trial to join river layer with basin that flows into the sea (this layer "AtAgua_Bacias_bacias_snirh_PC" has the name of basin)
SELECT	* FROM	AtAgua_Bacias_bacias_snirh_PC,	netElementL 
	WHERE ST_Intersects(AtAgua_Bacias_bacias_snirh_PC.geom, netElementL.geom);

-- Creating a table corresponding to MINHO
SET search_path TO portugal, spain, public;

-- Table of basins with an id = pfafratio
DROP TABLE IF EXISTS minho_cuenca;

CREATE TABLE minho_cuenca AS SELECT * FROM vw_baccod_25k_ptcont WHERE basinorder LIKE '181%';

CREATE INDEX minho_cuenca_geom_idx ON minho_cuenca USING gist(geom);

-- Table of rivers
DROP TABLE IF EXISTS minho_rio;

CREATE TABLE minho_rio AS SELECT * FROM netElementL WHERE id_localid LIKE '181%';

CREATE INDEX minho_rio_geom_idx ON minho_rio USING gist(geom);

-- Configure the table of rivers to use pgrouting: creating source and target

ALTER TABLE minho_rio DROP COLUMN SOURCE;

ALTER TABLE minho_rio DROP COLUMN target;

ALTER TABLE minho_rio ADD COLUMN SOURCE INTEGER;

ALTER TABLE minho_rio ADD COLUMN target INTEGER;

CREATE INDEX minho_rio_source_idx ON minho_rio(SOURCE);

CREATE INDEX minho_rio_target_idx ON minho_rio(target);


---------------------------------------------------------------------
 -- Using pgrouting: createTopology also creates vertices_pgr
------------------------------------------------------------------
SET search_path TO portugal, public;

SELECT 	pgr_createTopology('minho_rio', 0.0001, 'geom', 'gid');

SELECT * FROM minho_rio LIMIT 10;


----------------------------------------------------------------
 -- Adding a column identifying basin flowing to the sea to rivers
----------------------------------------------------------------

comment ON TABLE portugal.atagua_bacias_bacias_snirh_pc IS 'River basins flowing to the sea';

 
----------------------------
-- several lines for Mondego
----------------------------

SELECT * FROM(SELECT * FROM portugal.atagua_bacias_bacias_snirh_pc WHERE nome = 'Mondego') mondego

JOIN portugal.rivers ON st_intersects(mondego.geom, rivers.geom);


-------------------------
-- Trying to join rivers and basins (trial)
--------------------------

SELECT rivers.gid, nome FROM portugal.atagua_bacias_bacias_snirh_pc bs -- bassins sea 

JOIN portugal.rivers ON
	st_intersects(
		bs.geom,
		rivers.geom
	);



SELECT st_transform(st_union(geom),3035) from portugal.atagua_bacias_bacias_snirh_pc
-------------------------
-- Just a view of the rivers
--------------------------	

SELECT * FROM portugal.rivers LIMIT 10;

ALTER TABLE portugal.rivers ADD COLUMN nome CHARACTER VARYING(50);


-------------------------------------------------------------------------
-- ADDING THE BASIN NAME IN THE RIVER TABLE
-- update the table rivers to fill in the column nome using the subquery
---------------------------------------------------------------------------

UPDATE portugal.rivers SET nome = sub.nome
	FROM(
		SELECT
			rivers.gid,
			bs.nome
		FROM
			portugal.atagua_bacias_bacias_snirh_pc bs -- bassins sea 
		JOIN portugal.rivers ON
			st_intersects(
				bs.geom,
				rivers.geom
			)
	) sub
WHERE
	rivers.gid = sub.gid;-- 75386

SELECT count(*) FROM portugal.rivers WHERE airroute_2 =0;
SELECT * FROM portugal.rivers limit 10;
SELECT * FROM portugal.downstream_points limit 10;
SELECT count(*) FROM portugal.downstream_points;

---------------------------------------------------------------------
-- Using pgrouting: createTopology also creates vertices_pgr
------------------------------------------------------------------

SET search_path TO portugal, public;

ALTER TABLE portugal.rivers DROP COLUMN IF EXISTS SOURCE;

ALTER TABLE portugal.rivers DROP COLUMN IF EXISTS target;

ALTER TABLE portugal.rivers ADD COLUMN SOURCE INTEGER;

ALTER TABLE portugal.rivers ADD COLUMN target INTEGER;

CREATE INDEX rivers_source_idx ON portugal.rivers(SOURCE);

CREATE INDEX rivers_target_idx ON portugal.rivers(target);

SELECT
	pgr_createTopology(
		'rivers',
		0.0001,
		'geom',
		'gid'
	);

-- notes
 -- fails with id_localid if character varying so must be gid


-----------------------------------------------
-- CREATE A VIEW OF COASTAL WATERS
-- TWO THINGS : first it is projected to the portugese projection 3763
--            : second we just need one big water mass for st_distance to the sea hence the UNION
------------------------------------------------
 
DROP VIEW european_wise2008.coastal_waters_3763;

CREATE OR replace VIEW european_wise2008.coastal_waters_3763 AS SELECT
			st_union(
				st_transform(
					the_geom,
					3763
				)
			) AS geom
		FROM
			european_wise2008.costal_waters
		WHERE
			cty_id = 'PT';

SELECT * FROM rivers LIMIT 10;
SELECT count(*) FROM rivers WHERE chemin is NULL;


---------------------------------------------------------------------
-- CREATING A TABLE OF Downstream points
---------------------------------------------------------------------

DROP TABLE IF EXISTS portugal.downstream_points;

CREATE TABLE portugal.downstream_points 
	AS (SELECT target, nome, TRUE AS at_sea, v.the_geom FROM(SELECT * FROM rivers) r
		JOIN portugal.rivers_vertices_pgr v ON v.id = r.target 
		WHERE nextdownid = 0);--466
			
ALTER TABLE portugal.downstream_points ADD CONSTRAINT c_pk_target PRIMARY KEY(target);

ALTER TABLE portugal.downstream_points ADD COLUMN distance NUMERIC;

-- ALTER TABLE portugal.downstream_points ADD INDEX 
-- DROP INDEX portugal.downsteam_points_thegeom_idx;

CREATE INDEX downstream_points_thegeom_idx ON portugal.downstream_points USING gist(the_geom);


---------------------------------------------------------------------
-- Some of the basins are endoreic, not flowing to the sea
-- So WE CALCULATE DISTANCE TO THE SEA AND ONLY CHOOSE DISTANCE <500 m
-- as at_sea=TRUE
---------------------------------------------------------------------

DROP TABLE IF EXISTS portugal.coastalwater_union;

CREATE TABLE portugal.coastalwater_union AS SELECT st_union(geom) FROM european_wise2008.coastal_waters_3763;

UPDATE portugal.downstream_points
			SET
				distance = st_distance(
					cw.geom,
					the_geom
				)
			FROM
				european_wise2008.coastal_waters_3763 cw;

UPDATE	portugal.downstream_points SET at_sea = FALSE WHERE distance > 500;


----------------------------------------------------
-- there are 68 downstream segments in basin Arade
-- we start with it as an example
-----------------------------------------------------

SELECT * FROM downstream_points WHERE nome = 'Lis e Ribeiras Costeiras'; --26

--DROP TABLE IF EXISTS lis_ribeiras;  -- create tables to plot in QGis the example
--CREATE TABLE lis_ribeiras AS SELECT * FROM downstream_points WHERE nome LIKE 'Lis e Ribeiras Costeiras';
--DROP TABLE IF EXISTS lis_ribeiras_river;
--CREATE TABLE lis_ribeiras_river AS SELECT * FROM rivers WHERE nome LIKE 'Lis e Ribeiras Costeiras';

SELECT * FROM downstream_points WHERE nome = 'Ancora e Ribeiras Costeiras'; --13rows
SELECT * FROM downstream_points WHERE nome = 'Lima'; --0rows 
SELECT * FROM downstream_points WHERE nome = 'Neiva e Ribeiras Costeiras'; --12rows

-------------------------------------------------------------------------------	
-- In "Lis e Ribeiras Costeiras" the largest flow 57647 (75270)
-- select everything in basin 57647 (75270)
-- The following function (recusrsive) selects everyting in the basin by a recursive query
-- this query uses source and target created by the pg_routing algorythm
-- it is much quicker than a spatial recursive
-----------------------------------------------------------------------------

DROP function if exists portugal.upstream_segments(INTEGER);

CREATE FUNCTION portugal.upstream_segments(INTEGER)

RETURNS TABLE(source integer, target integer) AS
$$
BEGIN
RETURN QUERY
	WITH RECURSIVE parcours AS(
		SELECT
			r0.source,
			r0.target
		FROM
			portugal.rivers r0
		WHERE
			r0.target = $1
	       UNION SELECT
		       r1.source,
		       r1.target
		FROM
			parcours
		JOIN portugal.rivers r1 ON  parcours.source = r1.target)
          SELECT * FROM parcours;
END
$$
  LANGUAGE plpgsql VOLATILE;

-- select * from portugal.upstream_segments(57647); --1s
-- select * from portugal.upstream_segments(75270); --1s


----------------------------
-- CREATING INDEXES
-----------------------------

ALTER TABLE portugal.rivers ADD COLUMN chemin ltree;
CREATE INDEX chemin_gist_rivers_idx ON portugal.rivers USING GIST(chemin);
CREATE INDEX chemin_rivers_idx ON portugal.rivers USING btree(chemin);


-- SELECT * from portugal.rivers limit 10;
---------------------------------------------------
-- In this function we do the routing and join the result with the river table to get the id of the river segment
------------------------------------------------------

DROP function if exists portugal.get_path(integer,integer);
CREATE OR REPLACE FUNCTION portugal.get_path(_from integer, _to integer)
RETURNS SETOF ltree AS
$$
BEGIN
RETURN QUERY 
SELECT text2ltree(string_agg(gid::text, '.')) AS gid_list  
FROM (SELECT gid FROM pgr_dijkstra(
   'SELECT gid as id, source, target, st_length(geom) as cost FROM portugal.rivers',
   _from,
   _to,
  FALSE
)  pt
JOIN portugal.rivers r ON pt.edge = r.gid order by seq) sub;

END
$$
LANGUAGE plpgsql VOLATILE;

-- select portugal.get_path(21447,21378);
-- select portugal.get_path(77814,77803);
-- select portugal.get_path(28457,12366);

----------------------------------------------------------------------
-- Two options below, in the first we selected the upstream segments from Tejo with a recursive
-- function and as a second step we calculate routing, routing will be a bit faster but calculating source will take time

select portugal.get_path(75270,	source) from portugal.upstream_segments(75270); --5:09

select portugal.get_path(57647, source) from portugal.rivers where nome = 'Lis e Ribeiras Costeiras'; --5:59

UPDATE portugal.rivers set chemin=get_path(75270,u.source) from portugal.upstream_segments(75270) u
where rivers.source = u.source; -- 5:13, Lis e Ribeiras Costeiras



-------------------------------------------------------------------------------	
 -- SECOND STEP PASS A VECTOR AND INSERT THE VALUES
 -- this function writes the path for every basin in an aera (set by the name of the hydrographic region, nome)
 -- for this we need to pass the function  get_path(target, source) where the target is the node at the estuary
 -- and the source is all the nodes from the basin connected to that basin.
 -- To achieve the connection to all elements in the basin we used the recursive function upstream_segments
 -- DETAILS :
 -- this function uses a cursor, we could have used a for loop for the cursor
 -- here following an example http://www.postgresqltutorial.com/plpgsql-cursor/
 -- we open the cursor, and loop throught it, and exist at the end with EXIT WHEN NOT FOUND;
 -- We have struggled because we forget to retreive the columns using the * so no column was returned

-----------------------------------------------------------------------------

DROP function if exists portugal.write_chemin(TEXT);
CREATE OR REPLACE FUNCTION portugal.write_chemin(_nome text)
   RETURNS integer AS 
 $$
DECLARE 
 current_count integer default 0;
 the_downstream_point   RECORD;
 cur_target integer;
 cur_down CURSOR(_text text) 
	 FOR SELECT *
	 FROM  portugal.downstream_points 
	 WHERE nome = _nome;
BEGIN
   -- Open the cursor
   OPEN  cur_down(_nome);
 
   LOOP
    -- fetch row one by one into the_downstream_point
      FETCH cur_down INTO the_downstream_point;
    -- exit when no more row to fetch
      EXIT WHEN NOT FOUND;
      current_count := current_count+1;
     cur_target := the_downstream_point.target;
    -- raise notice for now
      RAISE NOTICE 'target :%',cur_target; 
    -- create the chemin for this target and all upstream segments
    UPDATE portugal.rivers set chemin=get_path(cur_target,u.source) from portugal.upstream_segments(cur_target) u
		where rivers.source = u.source; 
   END LOOP;
  
   -- Close the cursor
   CLOSE cur_down;
 
   RETURN current_count;
END; 
$$ 
LANGUAGE plpgsql;

select portugal.write_chemin('Lis e Ribeiras Costeiras');
select * from portugal.downstream_points where nome = 'Lis e Ribeiras Costeiras';
--SELECT * FROM rivers where nome = 'Lis e Ribeiras Costeiras' and chemin IS NULL;


BEGIN;
select portugal.write_chemin('Minho');
COMMIT;

BEGIN;
select portugal.write_chemin('Ancora e Ribeiras Costeiras');
COMMIT;

BEGIN;
select portugal.write_chemin('Lima');
COMMIT;

BEGIN;
select portugal.write_chemin('Neiva e Ribeiras Costeiras');
COMMIT;

BEGIN;
select portugal.write_chemin('Cávado e Ribeiras Costeiras');
COMMIT;

BEGIN;
select portugal.write_chemin('Ave');
COMMIT;

BEGIN;
select portugal.write_chemin('Leça e Ribeiras Costeiras');
COMMIT;

BEGIN;
select portugal.write_chemin('Douro');
COMMIT;

BEGIN;
select portugal.write_chemin('Vouga e Ribeiras Costeiras');
COMMIT;

BEGIN;
select portugal.write_chemin('Mondego');
COMMIT;

BEGIN;
select portugal.write_chemin('Ribeiras do Oeste');
COMMIT;

BEGIN;
select portugal.write_chemin('Tejo');
COMMIT;

BEGIN;
select portugal.write_chemin('Sado');
COMMIT;

BEGIN;
select portugal.write_chemin('Ribeiras do Alentejo');
COMMIT;

BEGIN;
select portugal.write_chemin('Mira');
COMMIT;

BEGIN;
select portugal.write_chemin('Ribeiras do Algarve');
COMMIT;

BEGIN;
select portugal.write_chemin('Arade');
COMMIT;

BEGIN;
select portugal.write_chemin('Guadiana');
COMMIT;


--SELECT * FROM rivers where nome = 'Neiva e Ribeiras Costeiras' and chemin IS NULL; --110 rows (3rows without ltree, why?)
--SELECT * FROM rivers where nome = 'Ancora e Ribeiras Costeiras' and chemin IS NULL; --247 rows (19rows without ltree, why?)
--SELECT * FROM rivers where nome = 'Cávado e Ribeiras Costeiras' and chemin IS NULL; --247 rows (19rows without ltree, why?)
--SELECT * FROM rivers where nome = 'Ave' and chemin IS NULL; --247 rows (19rows without ltree, why?)
--SELECT * FROM rivers where nome = 'Leça e Ribeiras Costeiras' and chemin IS NULL; --247 rows (19rows without ltree, why?)
--SELECT * FROM rivers where nome = 'Douro' and chemin IS NULL; --247 rows (19rows without ltree, why?)
--SELECT * FROM rivers where nome = 'Vouga e Ribeiras Costeiras' and chemin IS NULL; --247 rows (19rows without ltree, why?)
--SELECT * FROM rivers where nome = 'Mondego' and chemin IS NULL; --247 rows (19rows without ltree, why?)
--SELECT * FROM rivers where nome = 'Ribeiras do Oeste' and chemin IS NULL; --247 rows (19rows without ltree, why?)
--SELECT * FROM rivers where nome = 'Tejo' and chemin IS NULL; --247 rows (19rows without ltree, why?)
--SELECT * FROM rivers where nome = 'Sado' and chemin IS NULL; --247 rows (19rows without ltree, why?)
--SELECT * FROM rivers where nome = 'Ribeiras do Alentejo' and chemin IS NULL; --247 rows (19rows without ltree, why?)
--SELECT * FROM rivers where nome = 'Mira' and chemin IS NULL; --247 rows (19rows without ltree, why?)
--SELECT * FROM rivers where nome = 'Ribeiras do Algarve' and chemin IS NULL; --247 rows (19rows without ltree, why?)
--SELECT * FROM rivers where nome = 'Arade' and chemin IS NULL; --247 rows (19rows without ltree, why?)

-- When the name of the basin is missing, we need to calculate with the target code (14 points)

UPDATE downstream_points set nome='Outside basin' where nome is null;

BEGIN;
select portugal.write_chemin('Outside basin');
COMMIT;



SELECT * FROM portugal.downstream_points where nome IS NULL;
select portugal.get_path(12819,	source) from portugal.upstream_segments(12819); --5:09
select portugal.get_path(12064,	source) from portugal.upstream_segments(12064); --5:09
select portugal.get_path(12379,	source) from portugal.upstream_segments(12379); --
select portugal.get_path(12477,	source) from portugal.upstream_segments(12477); --
select portugal.get_path(12678,	source) from portugal.upstream_segments(12678); --

select portugal.get_path(12819,	source) from portugal.upstream_segments(12819); --5:09
select portugal.get_path(12819,	source) from portugal.upstream_segments(12819); --5:09
select portugal.get_path(12819,	source) from portugal.upstream_segments(12819); --5:09
select portugal.get_path(12819,	source) from portugal.upstream_segments(12819); --5:09
select portugal.get_path(12819,	source) from portugal.upstream_segments(12819); --5:09
select portugal.get_path(12819,	source) from portugal.upstream_segments(12819); --5:09
select portugal.get_path(12819,	source) from portugal.upstream_segments(12819); --5:09
select portugal.get_path(12819,	source) from portugal.upstream_segments(12819); --5:09
select portugal.get_path(12819,	source) from portugal.upstream_segments(12819); --5:09
select portugal.get_path(12819,	source) from portugal.upstream_segments(12819); --5:09
select portugal.get_path(12819,	source) from portugal.upstream_segments(12819); --5:09



------------------------------------------
------- R upstream segments calculation
-------------------------------------------

-- Summary of tables to see what there are in rivers and downstream_points
SELECT count(*) FROM portugal.rivers;
SELECT * FROM portugal.rivers limit 10;
SELECT count(*) FROM portugal.downstream_points;
SELECT * FROM portugal.downstream_points limit 10;

-- Change the name of "nextdownid" because they use the "hydroid" code and we want to stay with "target"
ALTER TABLE portugal.rivers RENAME COLUMN nextdownid TO nextdownid_hydroid;

-- So, we create a new nextdownid
--ALTER TABLE portugal.rivers DROP COLUMN IF EXISTS nextdownid;
ALTER TABLE portugal.rivers ADD COLUMN nextdownid integer;

UPDATE portugal.rivers SET nextdownid = sub.nextdownid FROM
(SELECT r2.gid AS nextdownid, r1.gid FROM portugal.rivers r1 JOIN portugal.rivers r2 ON r2.source = r1.target 
) sub
WHERE sub.gid = rivers.gid; -- 100765 rows affected, 6.6 secs

CREATE index idx_rivers_nextdownid ON portugal.rivers(nextdownid);


-- Add dmer column to calculate distance to the sea (I do not know if the length_ column from rivers is the same)
ALTER TABLE portugal.rivers ADD COLUMN dmer numeric;
UPDATE portugal.rivers SET dmer = 0 WHERE target IN (SELECT target FROM portugal.downstream_points); --466 rows, 363 msec


-------------------------------
-- Suite R Analyse rios, path are calculated we try to put them in postgres
-------------------------------
DROP INDEX chemin_gist_rivers_idx;

-- temp_rios is the table created in R to calculate distance to the sea and the path
select * from portugal.temp_rios limit 10;

alter table portugal.rivers drop column chemin; -- Problem with index
alter table portugal.rivers add column chemin ltree;

-- Add the path from temp_rios to rivers table
update portugal.rivers set chemin=tr.ltree_from_sea::ltree from portugal.temp_rios tr where tr.gid=rivers.gid; -- 101231 rows, 25.9 secs

-- Add the distance to the sea from temp_rios to rivers table
update portugal.rivers set dmer=tr.dmer::numeric from portugal.temp_rios tr where tr.gid=rivers.gid; -- 101231 rows, 11.5 secs

select count(*) from portugal.rivers where chemin is null; -- 225 rows
CREATE TABLE rivers_sans_chemin AS --Create a table without the path to plot in QGis
	SELECT * FROM portugal.rivers WHERE chemin IS NULL; -- 225 rows, 852 msec

select * from portugal.rivers limit 10;
select * from portugal.downstream_points limit 10;


-------------------------------
-- gid of portugese river corresponding to target spain
-- gid portugal
-- target spain
-------------------------------
drop table spain.join_portugal_spain
create table spain.join_portugal_spain as (
with frontier_segments as (
	select target, the_geom from spain.downstream_points where frontier=TRUE 
),
    projected_point as (
	select gid, st_distance(st_transform(p.geom,25830), f.the_geom) as dist, f.target 
	from portugal.rivers p join frontier_segments f on st_dwithin(st_transform(p.geom,25830), f.the_geom, 500) 
),
    ordered_by_distance_gid as (
select gid, dist, target from projected_point order by target, dist)

select  distinct on (target) gid, target from ordered_by_distance_gid ); -- 110 rows, 05:34 min

select * from spain.join_portugal_spain limit 10;
select * from spain.join_portugal_spain where target = 267937;

comment on column spain.join_portugal_spain.gid is 'gid corresponds to gid of portugese rivers';
comment on column spain.join_portugal_spain.target is 'target corresponds to target of spain rivers';


-- alter table spain.join_portugal_spain add column gid_spain integer unique;
-- update spain.join_portugal_spain set gid_spain = rivers.gid from
-- spain.rivers
-- where rivers.target=join_portugal_spain.target;


create table spain.join_portugal_spain_segments as 
	select join_portugal_spain.gid, join_portugal_spain.target, rivers.gid as gid_spain
	 from spain.join_portugal_spain join spain.rivers on rivers.target = join_portugal_spain.target; -- 118 rows
	 
-- notes: table join_portugal_spain corresponds only to one row per gid. in some cases there are several segments arriving to the point
--        the second table (join_portugal_spain_segments) corresponds to join and adds 8 rows to the previous table
-- select * from spain.rivers where target=267937;

comment on column spain.join_portugal_spain_segments.gid is 'gid corresponds to gid of portugese rivers';
comment on column spain.join_portugal_spain_segments.target is 'target corresponds to target of spain rivers';

-----------------------------------
-- some portugal rivers are in spain
-----------------------------------

select * from portugal.rivers r join spain.wise_rbd_f1v3 w on st_contains(w.the_geom,st_transform(r.geom, 25830)) limit 10

alter table portugal.rivers add column in_spain boolean default FALSE;

CREATE INDEX rivers_gid_idx
  ON portugal.rivers
  USING btree
  (gid);
  
-- only segments fully contained in spain will be marked as FALSE
create table spain.wise_union as select st_union(w.the_geom) as the_geom from spain.wise_rbd_f1v3 w;

update portugal.rivers set in_spain = TRUE where gid in (
select gid from portugal.rivers r join spain.wise_union w on st_contains(w.the_geom,st_transform(r.geom, 25830))); -- 25554 rows, 1:31 min

select count(*) from portugal.rivers group by in_spain;
select * from spain.temp_rios_frontier where gid = 125384;

----------------------------------
-- Calculation of ltree spain from frontier nodes (IN R, creation of temporary table, see analyserios.R 
-----------------------------------
-- Add the path from temp_rios to rivers table
update spain.rivers set chemin=tr.ltree_from_sea::ltree from spain.temp_rios_frontier tr where tr.gid=rivers.gid and rivers.chemin is NULL; 
-- first round 325607 rows, 03:31 min 
-- second run (some minor basins had been forgotten) 1:53



-- Add the distance to the sea from temp_rios to rivers table
update spain.rivers set dmer=tr.dmer::numeric from spain.temp_rios_frontier tr where tr.gid=rivers.gid and rivers.chemin is NULL; -- 325607 rows, 02:06 min
-- second run (some minor basins had been forgotten) 1:47
SELECT * FROM spain.rivers WHERE dmer IS NULL;

-----------------------------------
-- Calculation of ltree portugal
-----------------------------------



-- upstream segment must provide two columns instead on one
/*
[spain, portugal]
2	458
4	478
*/

alter table spain.rivers add column chemin_portugal ltree;


-----------------------------------
-- JOINING WITH BASINS : there is no common unique column between the two layers, one has to have been updated
-----------------------------------

alter table portugal.rivers add column idsegment text   ;
update portugal.rivers set idsegment = 'PT'||gid::text;
alter table portugal.vw_baccod_25k_ptcont add column idsegment text   ;

update portugal.vw_baccod_25k_ptcont set idsegment=NULL;
-- test with subsambple rivers
-- then run on all rivers
with sr as (
select * from portugal.rivers --where gid in (74100,74058)
),
     j as (
select sr.idsegment ,
ST_LENGTH(ST_Intersection(sr.geom, b.geom))/st_length(sr.geom) as prop,
b.gid
from sr 
join 
portugal.vw_baccod_25k_ptcont b
on st_intersects(b.geom,sr.geom)-- both geometries have srid 3763
),
  jj as (
SELECT * from j order by gid, prop desc),
  kk AS (
SELECT distinct on (gid) gid, idsegment, prop from jj
where prop>0.5
  )
--select * from kk
update portugal.vw_baccod_25k_ptcont set idsegment=kk.idsegment
from kk where kk.gid=vw_baccod_25k_ptcont.gid -- 101340



SELECT * from portugal.vw_baccod_25k_ptcont WHERE NOT ST_isvalid(geom)

update portugal.vw_baccod_25k_ptcont set geom=st_makevalid(geom); --11670
