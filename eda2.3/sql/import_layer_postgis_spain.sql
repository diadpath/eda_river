-- In Command prompt(cmd) we import the shapefiles to Postgres
-- Spain schema is already created

-- shp2pgsql with create index option
-- M_Rios_v2 (to import shapefiles you must be in the directory where the files are found)
shp2pgsql -s 25830 -W LATIN1 -I M_Rios_v2.shp spain.M_Rios_v2 > M_Rios_v2.sql
psql -U postgres -f M_Rios_v2.sql eda2.0

-- From european_wise2008, we use the table "rbd_f1v3" corresponding to the bassins flowing to the sea and
-- the table "coastal_waters" to erase this area from the other table

------------------------------------------------------------------
-- First join atlantic and mediterranean rivers in the same table
------------------------------------------------------------------
SET search_path TO spain, public;

DROP TABLE IF EXISTS rivers;
CREATE TABLE rivers AS
	(SELECT gid, cod_mar, pfafcuen, pfafrio, cod_uni, nom_rio, lngtramo_m, long_rio_m, color, geom FROM m_rios_v2 
	UNION ALL 
	SELECT gid, cod_mar, pfafcuen, pfafrio, cod_uni, nom_rio, lngtramo_m, long_rio_m, color, geom FROM a_rios_v2);

SELECT * FROM rivers limit 10;

--------------------------------------------------------------
-- CREATE THE TOPOLOGY
-------------------------------------------------------------

ALTER TABLE spain.rivers drop column gid;
ALTER TABLE spain.rivers add column gid serial primary key;
ALTER TABLE spain.rivers DROP COLUMN IF EXISTS SOURCE;
ALTER TABLE spain.rivers DROP COLUMN IF EXISTS target;
ALTER TABLE spain.rivers ADD COLUMN SOURCE INTEGER;
ALTER TABLE spain.rivers ADD COLUMN target INTEGER;
CREATE INDEX rivers_source_idx ON spain.rivers(SOURCE);
CREATE INDEX rivers_target_idx ON spain.rivers(target);

SELECT pgr_createTopology('rivers', 0.0001, 'geom', 'gid'); -- 14:49 minutes



---------------------------------------------------------------------
-- CREATING A TABLE OF Downstream points
---------------------------------------------------------------------


DROP TABLE IF EXISTS spain.downstream_points;

CREATE TABLE spain.downstream_points AS (
     SELECT 
     distinct on (target) target, 
     TRUE AS at_sea, -- endoreic basins will be FALSE later
     v.the_geom, -- this geom comes from vertice (it's a point)
     NULL::character varying(100) AS name, -- name of the wise layer
     NULL::text AS hyd_syst_o -- the sea
     FROM spain.rivers r
     JOIN spain.rivers_vertices_pgr v ON v.id = r.target 
     --JOIN european_wise2008.rbd_f1v3 w ON st_intersects(st_transform(w.the_geom,25830),v.the_geom)
     -- WHERE cty_id='ES' 	
     WHERE target in (
-- this returns all segments without a source downstream from the target
		select target from rivers except
		
		(
			select b1.target from rivers as b1
			join
			rivers as b2
			on b2.source=b1.target
		)
		)
); --2095 13 s


ALTER TABLE spain.downstream_points ADD CONSTRAINT c_pk_target PRIMARY KEY(target);
----------------------
-- extract small table of wise layer corresponding to spain and create index with gist
-----------------------

DROP TABLE IF EXISTS spain.wise_rbd_f1v3;
CREATE TABLE spain.wise_rbd_f1v3 as select name, hyd_syst_o, st_transform(the_geom,25830) as the_geom from european_wise2008.rbd_f1v3 w where cty_id='ES';
CREATE INDEX wise_rbd_f1v3_thegeom_idx ON spain.wise_rbd_f1v3 USING gist(the_geom);


-------------------
-- find frontier nodes
-------------------
ALTER TABLE spain.downstream_points add column frontier boolean default FALSE;

-- we have created a polygon of the frontier area
/*
shp2pgsql -s 25830 -I frontiere spain.frontiere > frontiere.sql
psql -U postgres -f frontiere.sql eda2.0
*/

update spain.downstream_points set frontier=TRUE where target IN (
select downstream_points.target from frontiere join spain.downstream_points on st_intersects(the_geom,geom)); --115



------------------------
-- get sea and wise basin in downstream point
------------------------


UPDATE spain.downstream_points set (name,hyd_syst_o) = (sub.name, sub.hyd_syst_o) FROM
(SELECT w.name,w.hyd_syst_o, target from spain.wise_rbd_f1v3 w
JOIN spain.downstream_points d ON st_intersects(w.the_geom,d.the_geom)) sub
WHERE sub.target=downstream_points.target; --2012 3.2s

ALTER TABLE spain.downstream_points ADD COLUMN distance NUMERIC;
CREATE INDEX downstream_points_thegeom_idx ON spain.downstream_points USING gist(the_geom);

ALTER TABLE spain.downstream_points ADD COLUMN cod_mar character varying(1);
UPDATE spain.downstream_points set cod_mar='M' where hyd_syst_o = 'Mediterranean Sea';
UPDATE spain.downstream_points set cod_mar='A' where hyd_syst_o = 'North Eastern Atlantic Ocean';


-----------------------------------------------
-- CREATE A VIEW OF COASTAL WATERS
-- TWO THINGS : first it is projected to the spanish projection 25830
--            : second we just need one big water mass for st_distance to the sea hence the UNION
------------------------------------------------
 
DROP VIEW european_wise2008.coastal_waters_25830;

CREATE OR replace VIEW european_wise2008.coastal_waters_25830 AS SELECT
			st_union(
				st_transform(
					the_geom,
					25830
				)
			) AS geom
		FROM
			european_wise2008.costal_waters
		WHERE
			cty_id = 'ES'; -- 23 s

-----------------------------------------------
-- CALCULATE DISTANCE OF DOWNSTREAM POINTS TO THE SEA
------------------------------------------------
UPDATE spain.downstream_points set at_sea = TRUE;
UPDATE spain.downstream_points
			SET
				distance = st_distance(
					cw.geom,
					the_geom
				)
			FROM
				european_wise2008.coastal_waters_25830 cw;

UPDATE	spain.downstream_points SET at_sea = FALSE WHERE distance > 5000; --350 rows affected, 01:12 minutes execution time.


-----------------------------------------------------
-- using the cuencas layer
------------------------------------------------------

-- select cuen_tipo from spain.a_cuencas_rios_atl_norte where cuen_tipo is not null;

select pfafrio from spain.a_cuencas_rios_atl_norte where cuen_tipo ='Cuenca Endorreica Sin Rio'; --139



------------------------------------------------------------------
-- Join name of basin in the rivers table
------------------------------------------------------------------

ALTER TABLE spain.rivers DROP COLUMN IF EXISTS basin;
ALTER TABLE spain.rivers ADD basin character varying(100);


UPDATE spain.rivers set basin = sub.name FROM
(SELECT w.name, target from spain.wise_rbd_f1v3 w
JOIN spain.rivers r ON st_intersects(w.the_geom,r.geom)) sub
WHERE sub.target=rivers.target; --325518 02:47 min

SELECT * FROM spain.rivers limit 10;


-------------------------------------------------------------------------------	
-- RECURSIVE FUNCTION TO FIND SEGMENTS UPSTREAM
-- The following function (recusrsive) selects everyting in the basin by a recursive query
-- this query uses source and target created by the pg_routing algorythm
-- it is much quicker than a spatial recursive
-----------------------------------------------------------------------------

DROP function if exists spain.upstream_segments(INTEGER);
CREATE FUNCTION spain.upstream_segments(INTEGER)

RETURNS TABLE(source integer, target integer) AS
$$
BEGIN
RETURN QUERY
	WITH RECURSIVE parcours AS(
		SELECT
			r0.source,
			r0.target
		FROM
			spain.rivers r0  
		WHERE
			r0.target = $1
	      
	       
	       UNION SELECT
		       r1.source,
		       r1.target
		FROM
			parcours
		JOIN spain.rivers r1 
		ON  parcours.source = r1.target
		)
          SELECT * FROM parcours;
END
$$
  LANGUAGE plpgsql VOLATILE;

-- same function but selecting basins  

DROP function if exists spain.upstream_segments(INTEGER, character varying(100));
CREATE FUNCTION spain.upstream_segments(INTEGER,character varying(100))

RETURNS TABLE(source integer, target integer) AS
$$
BEGIN
RETURN QUERY
	WITH RECURSIVE parcours AS(
		SELECT
			r0.source,
			r0.target
		FROM
			spain.rivers r0  
		WHERE
			r0.target = $1
	       AND      
	                basin = $2
	       
	       UNION SELECT
		       r1.source,
		       r1.target
		FROM
			parcours
		JOIN spain.rivers r1 
		ON  parcours.source = r1.target
		where basin = $2)
          SELECT * FROM parcours;
END
$$
  LANGUAGE plpgsql VOLATILE;

-- SELECT * from spain.rivers where target = 88621;--basin = "SEGURA"
-- SELECT * from spain.upstream_segments(88621, 'SEGURA');--17 13msec

----------------------------
-- CREATING INDEXES
-----------------------------
select * from spain.rivers limit 10;
ALTER TABLE spain.rivers ADD COLUMN chemin ltree;
CREATE INDEX chemin_gist_rivers_idx ON spain.rivers USING GIST(chemin);
CREATE INDEX chemin_rivers_idx ON spain.rivers USING btree(chemin);

----------------------------
-- CREATING two get_path functions
-----------------------------
-- first function does not use basin

DROP function if exists spain.get_path(integer,integer);
CREATE OR REPLACE FUNCTION spain.get_path(_from integer, _to integer)
RETURNS SETOF ltree AS
$$
BEGIN
RETURN QUERY 
SELECT text2ltree(string_agg(gid::text, '.')) AS gid_list  
FROM (SELECT gid FROM pgr_dijkstra(
   'SELECT gid as id, source, target, st_length(geom) as cost FROM spain.rivers ',
   _from,
   _to,
  FALSE
)  pt
JOIN spain.rivers r ON pt.edge = r.gid order by seq) sub;

END
$$
LANGUAGE plpgsql VOLATILE;


DROP function if exists spain.get_path(integer,integer,character varying(1));

DROP function if exists spain.get_path(integer,integer,character varying(100));
CREATE OR REPLACE FUNCTION spain.get_path(_from integer, _to integer, _basin character varying(100))
RETURNS SETOF ltree AS
$$
BEGIN
RETURN QUERY 
SELECT text2ltree(string_agg(gid::text, '.')) AS gid_list  
FROM (SELECT gid FROM pgr_dijkstra(
   'SELECT gid as id, source, target, st_length(geom) as cost FROM spain.rivers where basin='||quote_literal(_basin),
   _from,
   _to,
  FALSE
)  pt
JOIN spain.rivers r ON pt.edge = r.gid where r.basin = _basin order by seq) sub;

END
$$
LANGUAGE plpgsql VOLATILE;


select spain.get_path(88621, source, 'SEGURA') from spain.upstream_segments(88621, 'SEGURA'); --58s

UPDATE spain.rivers set chemin=spain.get_path(88621, u.source, 'SEGURA') from spain.upstream_segments(88621, 'SEGURA') u
		where rivers.source = u.source; 

select * from spain.upstream_segments(88621, 'SEGURA');


-------------------------------------------------------------------------------	
 -- Write chemins to work within a subbasin
-- will not run on endoreic or frontier nodes
-----------------------------------------------------------------------------
--ROLLBACK;

SELECT *
	 FROM  spain.downstream_points 
	 WHERE name = 'TEST'
	 AND at_sea= TRUE 
	 AND frontier = FALSE;



DROP function if exists spain.write_chemin(TEXT);
CREATE OR REPLACE FUNCTION spain.write_chemin(_basin text)
   RETURNS integer AS 
 $$
DECLARE 
 current_count integer default 0;
 the_downstream_point   RECORD;
 cur_target integer;
 cur_down CURSOR(_text text) 
	 FOR SELECT *
	 FROM  spain.downstream_points 
	 WHERE name = _text
	 AND at_sea= TRUE 
	 AND frontier = FALSE;
         
BEGIN
   -- Open the cursor
   OPEN  cur_down(_basin);
   
   RAISE NOTICE 'bassin :%',_basin;       
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
    UPDATE spain.rivers set chemin=spain.get_path(cur_target,u.source, _basin) 
    from spain.upstream_segments(cur_target, _basin) u
		where rivers.source = u.source; 
   END LOOP;
  
   -- Close the cursor
   CLOSE cur_down;
 
   RETURN current_count;
END; 
$$ 
LANGUAGE plpgsql;

---------------------
-- TODO ADD COMMENT
---------------------

DROP function if exists spain.write_chemin(TEXT,integer,integer);
CREATE OR REPLACE FUNCTION spain.write_chemin(_basin text,_init integer,_end integer)
   RETURNS integer AS 
 $$
DECLARE 
 current_count integer default 0;
 the_downstream_point   RECORD;
 cur_target integer;
 cur_down CURSOR(_text text) 
	 FOR SELECT *
	 FROM  spain.downstream_points 
	 WHERE name = _text
	 AND at_sea= TRUE 
	 AND frontier = FALSE;
         
BEGIN
   -- Open the cursor
   OPEN  cur_down(_basin);
   MOVE FORWARD _init-1 from cur_down;
   -- this will move forward by one, so if init=15 current_count will be 15
   current_count :=_init;
   RAISE NOTICE 'bassin :%',_basin;       
   LOOP
    -- fetch row one by one into the_downstream_point
      FETCH cur_down INTO the_downstream_point;
    -- exit when no more row to fetch
      EXIT WHEN NOT FOUND;    
      EXIT WHEN current_count>_end;
      RAISE NOTICE 'current count :%',current_count;        
      cur_target := the_downstream_point.target;
    -- raise notice for now
      RAISE NOTICE 'target :%',cur_target; 

      
    -- create the chemin for this target and all upstream segments
    UPDATE spain.rivers set chemin=spain.get_path(cur_target,u.source, _basin) 
    from spain.upstream_segments(cur_target, _basin) u
		where rivers.source = u.source; 
     current_count := current_count+1;	
   END LOOP;
  
   -- Close the cursor
   CLOSE cur_down;
 
   RETURN current_count-_init;
END; 
$$ 
LANGUAGE plpgsql;

SELECT * FROM spain.write_chemin('ISLAS BALEARES',2,4);
SELECT target
	 FROM  spain.downstream_points 
	 WHERE name = 'ISLAS BALEARES'
	 AND at_sea= TRUE 
	 AND frontier = FALSE;


UPDATE spain.rivers set chemin=spain.get_path(124923,u.source, 'ISLAS BALEARES') 
    from spain.upstream_segments(124923, 'ISLAS BALEARES') u
		where rivers.source = u.source; 
SELECT * FROM spain.upstream_segments(124923,'ISLAS BALEARES');

SELECT * from spain.rivers limit 10;
UPDATE spain.rivers set chemin=NULL WHERE target IN (125291,125290);
UPDATE spain.rivers set basin='TEST' WHERE target IN (125291,125290);
update spain.downstream_points set name = 'TEST' where target IN (125291,125290);
SELECT chemin FROM spain.rivers WHERE basin = 'TEST';



-- I notice the query SELECT chemin FROM spain.rivers WHERE basin = 'TEST'; was quite slow... 
-- So I've added two index now it's much much faster 12.4 s for BALEARES !
drop index  if exists spain.river_basin_idx;
create index river_basin_idx on spain.rivers(basin);
create index downstream_points_name_idx on spain.downstream_points(name);


BEGIN;
SELECT * FROM spain.write_chemin('ISLAS BALEARES');
COMMIT; --12.4s
SELECT * FROM spain.rivers WHERE basin = 'ISLAS BALEARES' AND chemin IS NULL; --0 rows (total: 1452)
     
BEGIN;
select spain.write_chemin('TEST');
COMMIT;
SELECT * FROM spain.rivers WHERE basin = 'TEST' AND chemin IS NULL; --0 rows (total: 3) from ISLAS BALEARES

BEGIN;
select spain.write_chemin('CUENCAS INTERNAS PAIS VASCO');
COMMIT;
SELECT * FROM spain.rivers WHERE basin = 'CUENCAS INTERNAS PAIS VASCO' AND chemin IS NULL; --222 rows (total: 2132)

CREATE TABLE rivers_PAIS_VASCO_sans_chemin AS --Create a table without the path to plot in QGis
	SELECT * FROM spain.rivers WHERE basin = 'CUENCAS INTERNAS PAIS VASCO' AND chemin IS NULL;
-- target 276585 is far to the sea
-- target 280936, 277885 small segments that are endorheic 
-- target 279998, 280050, ... because previous target 279920 is in NORTE basin. The river is in the limit between two basins
-- target 699, 1882 comes from EBRO basin

BEGIN;
select spain.write_chemin('NORTE');
COMMIT;
SELECT * FROM spain.rivers WHERE basin = 'NORTE' AND chemin IS NULL; --2869 rows (total: 14802)
CREATE TABLE rivers_NORTE_sans_chemin AS --Create a table without the path to plot in QGis
	SELECT * FROM spain.rivers WHERE basin = 'NORTE' AND chemin IS NULL;

BEGIN;
select spain.write_chemin('GALICIA-COSTA');
COMMIT;
SELECT * FROM spain.rivers WHERE basin = 'GALICIA-COSTA' AND chemin IS NULL; --3394 rows (total: 8166)
CREATE TABLE rivers_GALICIA-COSTA_sans_chemin AS --Create a table without the path to plot in QGis
	SELECT * FROM spain.rivers WHERE basin = 'GALICIA-COSTA' AND chemin IS NULL;

BEGIN;
select spain.write_chemin('CUENCAS ATLANTICAS DE ANDALUCIA');--08:20 minutes
COMMIT;
SELECT * FROM spain.rivers WHERE basin = 'CUENCAS ATLANTICAS DE ANDALUCIA' AND chemin IS NULL; -- 49rows (total: 8906)

BEGIN;
select spain.write_chemin('CUENCAS MEDITERRANEAS DE ANDALUCIA');
COMMIT;
SELECT * FROM spain.rivers WHERE basin = 'CUENCAS MEDITERRANEAS DE ANDALUCIA' AND chemin IS NULL; -- 2476rows (total: 16285)

BEGIN;
select spain.write_chemin('SEGURA');
COMMIT;
SELECT count(*) FROM spain.rivers WHERE basin = 'SEGURA' AND chemin IS NULL; -- 1100rows (total: 11696)

BEGIN;
select spain.write_chemin('GUADIANA');
COMMIT;
SELECT count(*) FROM spain.rivers WHERE basin = 'GUADIANA' AND chemin IS NOT NULL; -- 32095rows (total: 32186)
-- downstream point 209521 is not working because its first segment hasn't the name of basin

UPDATE spain.rivers set chemin=spain.get_path(209521,u.source) 
    from spain.upstream_segments(209521) u
    where rivers.source = u.source; --failed to add item to index page in "chemin_gist_rivers_idx (and also 209594)

BEGIN;
select spain.write_chemin('JUCAR');
COMMIT;
SELECT * FROM spain.rivers WHERE basin = 'JUCAR' AND chemin IS NOT NULL; -- rows (total: 25080)

-- These ones do not work
SELECT spain.upstream_segments(65897)
SELECT spain.get_path(65897,u.source) 
    from spain.upstream_segments(65897) u
    
UPDATE spain.rivers set chemin=spain.get_path(65897,u.source) 
    from spain.upstream_segments(65897) u
    where rivers.source = u.source; 

SELECT spain.upstream_segments(69295);
SELECT spain.get_path(69295,u.source) 
    from spain.upstream_segments(69295) u;
UPDATE spain.rivers set chemin=spain.get_path(69295,u.source) 
    from spain.upstream_segments(69295) u
    where rivers.source = u.source; 

-- this one works
UPDATE spain.rivers set chemin=spain.get_path(66810,u.source) 
    from spain.upstream_segments(66810) u
    where rivers.source = u.source; --1min05

SELECT * FROM spain.write_chemin('JUCAR',1,1000);

--BEGIN;
--select spain.write_chemin('GUADALQUIVIR'); -- It does not work because of lack in max_stack_depth
--COMMIT;
-- Another option to resolve this problem:
SELECT count(*) FROM spain.rivers WHERE basin = 'GUADALQUIVIR' AND chemin IS NULL; -- rows (total: 41697)

select target from spain.downstream_points where name = 'GUADALQUIVIR'  AND at_sea= TRUE 
	 AND frontier = FALSE; -- This is the only donwstrem point of the basin, 
			       -- so we can't use the function that cuts back the basin on some dowstream points
			       -- The next idea is to create index for the upstream segments and using that to cut back the basin 
CREATE TABLE spain.temp_guad_upstreamseg as select * from spain.upstream_segments(176817) ; -- 41478
ALTER TABLE spain.temp_guad_upstreamseg add column id serial;

CREATE index idx_id_temp_guad_upstreamseg on  spain.temp_guad_upstreamseg(id);
CREATE index idx_source_temp_guad_upstreamseg on  spain.temp_guad_upstreamseg(source);
-- running the 1000 first ids....
UPDATE spain.rivers set chemin=spain.get_path(176817,u.source) 
    from  (select source from spain.temp_guad_upstreamseg where id<1000) u
    where rivers.source = u.source; --57 min
BEGIN;
UPDATE spain.rivers set chemin=spain.get_path(176817,u.source) 
    from  (select source from spain.temp_guad_upstreamseg where id>=1000 and id < 5000) u
    where rivers.source = u.source; 
COMMIT;
BEGIN;
UPDATE spain.rivers set chemin=spain.get_path(176817,u.source) 
    from  (select source from spain.temp_guad_upstreamseg where id>=5000 and id < 10000) u
    where rivers.source = u.source; 
COMMIT;

-- DO NOT CALCULATE BECAUSE OF LACK IN MAX_STACK_DEPTH
BEGIN;
select spain.write_chemin('EBRO');
COMMIT;
SELECT * FROM  spain.downstream_points WHERE name = 'EBRO' AND at_sea= TRUE AND frontier = FALSE;
SELECT * FROM spain.rivers WHERE basin = 'EBRO' AND chemin IS NULL; -- rows (total: 54596)

-- PROBLEM WITH NAME OF BASIN
SHOW client_encoding;
set client_encoding to 'UNICODE';
select distinct basin from spain.rivers where basin like('%LIMIA%');

select distinct name from spain.downstream_points where basin like('%LIMIA%');

UPDATE spain.rivers set basin='MIAO-LIMIA' where basin like('%LIMIA%'); -- 12406rows , 01:39 min
UPDATE spain.downstream_points set name = 'MIAO-LIMIA' where target = 221780; --1row, 12 msec

BEGIN;
select spain.write_chemin(basin) from (select distinct basin from spain.rivers where basin like('%LIMIA%')) sub;
COMMIT;
SELECT count(*) FROM spain.rivers WHERE basin = (select distinct basin from spain.rivers where basin like('%LIMIA%'));
--select spain.write_chemin('MIAO-LIMIA');
-- failed to add item to index page in "chemin_gist_rivers_idx": target 221780

UPDATE spain.rivers set basin='CUENCAS INTERNAS DE CATALUNA' where basin like('CUENCAS INTERNAS DE CAT%'); --15424 rows affected, 01:37 min
UPDATE spain.downstream_points set name = 'CUENCAS INTERNAS DE CATALUNA' where name like('CUENCAS INTERNAS DE CAT%'); -- 247rows, 32msec

BEGIN;
select spain.write_chemin('CUENCAS INTERNAS DE CATALUNA');
COMMIT;
-- failed to add item to index page in "chemin_gist_rivers_idx": target 123240
SELECT count(*) FROM spain.rivers WHERE basin = 'CUENCAS INTERNAS DE CATALUNA' AND chemin IS NULL; -- rows (total: 15424)

-- DO NOT CALCULATE BECAUSE at_sea=f
BEGIN;
select spain.write_chemin('DUERO');
COMMIT;
SELECT * FROM spain.rivers WHERE basin = 'DUERO' AND chemin IS NULL; -- rows (total: 43970)

BEGIN;
select spain.write_chemin('TAJO');
COMMIT;
SELECT * FROM spain.rivers WHERE basin = 'TAJO' AND chemin IS NULL; -- rows (total: 36669)

-- Total counts
SELECT count(*) from spain.rivers; --325607rows
SELECT count(*) FROM spain.rivers WHERE basin IS NULL; -- 89rows


------------------------------------------
------- R upstream segments calculation
-------------------------------------------

ALTER TABLE spain.rivers ADD COLUMN nextdownid integer;
UPDATE spain.rivers SET nextdownid = sub.nextdownid FROM
(SELECT r2.gid AS nextdownid, r1.gid FROM spain.rivers r1 JOIN spain.rivers r2 ON r2.source = r1.target 
--WHERE r1.basin = 'CUENCAS INTERNAS PAIS VASCO' ANd r2.basin = 'CUENCAS INTERNAS PAIS VASCO'
) sub
WHERE sub.gid = rivers.gid; 

CREATE index idx_rivers_nextdownid ON spain.rivers(nextdownid);  -- 323456 03:52

select count(*) from spain.rivers where nextdownid is not null;
(SELECT r2.gid AS nextdownid, r1.gid FROM spain.rivers r1 JOIN spain.rivers r2 ON r2.source = r1.target 
--WHERE r1.basin = 'CUENCAS INTERNAS PAIS VASCO' ANd r2.basin = 'CUENCAS INTERNAS PAIS VASCO' --2027 rows, 706 msec 
) sub
WHERE sub.gid = rivers.gid; -- 323456 rows, 03:16 min

--DROP index chemin_gist_rivers_idx;
CREATE index idx_rivers_nextdownid ON spain.rivers(nextdownid); --no result in 10.4 secs

select count(*) from spain.rivers where nextdownid is not null;

-- In Guadiana basin, there is a downstream point non connected to the river
-- That has done with QGis, trial to create the nextdownid for this gid
SELECT * FROM spain.rivers_sans_chemin WHERE gid = '160565';

UPDATE spain.rivers SET nextdownid = sub.nextdownid FROM
(SELECT r2.gid AS nextdownid, r1.gid FROM spain.rivers r1 JOIN spain.rivers r2 ON r2.source = r1.target 
WHERE r1.gid = '160565' ANd r2.gid = '160565'
) sub
WHERE sub.gid = rivers.gid; 


-- Add dmer column to calculate distance to the sea
ALTER TABLE spain.rivers ADD COLUMN dmer numeric;
UPDATE spain.rivers SET dmer = 0 WHERE target IN (SELECT target FROM spain.downstream_points); --2151 rows affected, 2.8 secs


-- Trial to create "noeuds_bordure" (from BaseEdaRiosRiversegments, row 47). The idea is to create a column with the downstream points.
-- It do not work. Two options:
-- First one using CASE:
--ALTER TABLE spain.rivers DROP COLUMN downs_point integer;
--UPDATE spain.rivers SET downs_point = sub.case FROM
--(SELECT dmer,
--       CASE WHEN dmer = 0 THEN target
--            ELSE '0'
--       END AS case
--    FROM spain.rivers) sub
--WHERE sub.gid = rivers.gid;
-- Second one using IF:
--ALTER TABLE spain.rivers ADD COLUMN downs_point integer;
--UPDATE spain.rivers SET downs_point = sub.case FROM
--(SELECT dmer,
--	DO
--	$do$
--	BEGIN
--	IF (SELECT 0 FROM dmer) THEN
--		downs_point = target FROM spain.rivers;
--	ELSE downs_point = 0;	
--	END IF;	
--	END
--	$do$) sub
--WHERE sub.gid = rivers.gid;

-- it works but modified in R
--UPDATE spain.rivers SET downs_point = TRUE where target in (
--(SELECT d.target FROM spain.downstream_points as d JOIN spain.rivers as r ON r.downs_point = d.target));



-------------------------------
-- Suite R Analyse rios, path are calculated we try to put them in postgres
-------------------------------
DROP INDEX chemin_gist_rivers_idx;

-- temp_rios is the table created in R to calculate distance to the sea and the path
select ltree_from_sea::ltree from spain.temp_rios limit 10;
select ltree_from_sea::ltree from spain.temp_rios where gid= 46022
alter table spain.rivers drop column chemin; -- Problem with index
alter table spain.rivers add column chemin ltree;




-- Add the path from temp_rios to rivers table
update spain.rivers set chemin=tr.ltree_from_sea::ltree from spain.temp_rios tr where tr.gid=rivers.gid and rivers.chemin is NULL; -- 325607 rows, 03:31 min  (211935

-- Add the distance to the sea from temp_rios to rivers table
update spain.rivers set dmer=tr.dmer::numeric from spain.temp_rios tr where tr.gid=rivers.gid and dmer is null; -- 325607 rows, 02:06 min

select count(*) from spain.rivers where chemin is null; -- 113950 rows
CREATE TABLE rivers_sans_chemin AS --Create a table without the path to plot in QGis
SELECT count(*) FROM spain.rivers WHERE chemin IS NULL; -- 113950 rows, 15.3 secs  --8126

select * from spain.rivers limit 10;
select * from spain.downstream_points limit 10;



-----------------------------
-- Analysis of basin surface
------------------------------


select * from spain.oria_cuenca where cod_uni=172988


select * from spain.oria_cuenca where cod_uni=172535

select max(gid) from spain.rivers


