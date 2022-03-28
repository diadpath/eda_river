set search_path to public, spain ;


drop table if exists spain.oria_cuenca;
create table spain.oria_cuenca as SELECT * FROM a_cuencas_rios_atl_norte WHERE pfafrio like '1003714%';--422

CREATE INDEX oria_cuenca_geom_idx
  ON oria_cuenca
  USING gist
  (geom);

drop table if exists spain.oria_a_rios_v2;
create table spain.oria_a_rios_v2 as SELECT * FROM a_rios_v2 WHERE pfafrio like '1003714%';--422

CREATE INDEX oria_a_rios_v2_geom_idx
  ON oria_a_rios_v2
  USING gist
  (geom);

the bv code
SELECT min(pfafrio) FROM oria_a_rios_v2; -- 103714
SELECT min(pfafcuen) FROM oria_a_rios_v2; -- 103714111



SELECT * FROM oria_a_rios_v2 limit 10

-- setting up a recursive query
SELECT char_length(10037146457::text) --11
SELECT substring(10037146457::text,1,10)
SELECT substring(10037146457::text,1,char_length(10037146457::text)-1)
1003714631


/*
This query collects all id_drain downstream from a segment within a subbasin
*/
WITH rio1 as (SELECT pfafcuen, pfafrio FROM oria_a_rios_v2  WHERE pfafcuen='10037146457'),
     subbasin as (
	SELECT * FROM rio1
	UNION select r.pfafcuen, r.pfafrio from  oria_a_rios_v2 r, rio1 WHERE
	 substring(rio1.pfafcuen::text,1,char_length(rio1.pfafcuen::text)-1)= 
	   substring(r.pfafcuen::text,1,char_length(r.pfafcuen::text)-1) 
	AND
	 rio1.pfafcuen>r.pfafcuen)
select * from subbasin order by subbasin.pfafcuen


	WITH RECURSIVE ds AS (	     
	     SELECT r.pfafcuen,r.lngtramo_m FROM oria_a_rios_v2 r  
		WHERE pfafcuen='10037146457'			-- first select row corresponding to 
	     UNION
	     SELECT r.pfafcuen, r.lngtramo_m from  oria_a_rios_v2 r, ds WHERE
		 substring(ds.pfafcuen::text,1,char_length(ds.pfafcuen::text)-1)= 
		   substring(r.pfafcuen::text,1,char_length(r.pfafcuen::text)-1) 
		AND
		 ds.pfafcuen>r.pfafcuen
                AND
                 (r.pfafcuen::numeric % 2) = 1)   -- even number
	 SELECT * from ds order by pfafcuen;

||pfafcuen||	pfafrio||
||10037146451||100371464||
||10037146453||100371464||
||10037146455||100371464||

10037146451 => 1003714643



	WITH RECURSIVE ds AS (	     
	     SELECT r.pfafcuen,r.lngtramo_m FROM oria_a_rios_v2 r  
		WHERE pfafcuen='10037146457'			-- first select row corresponding to 
	     UNION
	     SELECT r.pfafcuen, r.lngtramo_m from  oria_a_rios_v2 r, ds WHERE
		 substring(ds.pfafcuen::text,1,char_length(ds.pfafcuen::text)-1)= 
		   substring(r.pfafcuen::text,1,char_length(r.pfafcuen::text)-1) 
		AND
		 ds.pfafcuen>r.pfafcuen
                AND
                 (r.pfafcuen::numeric % 2) = 1)   -- even number
	 SELECT pfafcuen, 
                 lngtramo_m, 
                  (substring(pfafcuen::text,1,char_length(pfafcuen::text)-1)::integer-2)::character varying(254) as pfafcuen_downsteam 
         from ds;

-- this query returns nothing
with d1 as (SELECT    pfafcuen, 
                  lngtramo_m, 
                  (substring(pfafcuen::text,1,char_length(pfafcuen::text)-1)::integer-2)::character varying(254) 
                  as pfafcuen_downstream 
  from downstream_segments('10037146457'))
select * from downstream_segments((select min(pfafcuen_downstream) FROM d1 limit 1));
--because this query returns nothing
select downstream_segments('1003714643');


WITH RECURSIVE d2 
  AS (
	-- first subbasin
	SELECT    pfafcuen, 
                  lngtramo_m, 
                  (substring(pfafcuen::text,1,char_length(pfafcuen::text)-1)::integer-2)::character varying(254) 
                  as pfafcuen_downstream 
  from downstream_segments('10037146457')
        -- next downstream subbasin
        -- need to remove 1 from the previous to last number
    UNION
         SELECT pfafcuen, 
                lngtramo_m, 
                (substring(d2.pfafcuen::text,1,char_length(d2.pfafcuen::text)-1)::integer-2)::character varying(254) 
                  as pfafcuen_downstream   
        FROM  downstream_segments(select min(pfafcuen_downstream) from d1) 
    )	
SELECT * from d2;	


/*
same using recursive structure
This query collects all id_drain downstream from a segment within a subbasin
*/
/*
DROP TABLE IF EXISTS simple_rios CASCADE;
CREATE TABLE simple_rios (pfacuen character varying(254), lngtramo_m numeric);
--DROP FUNCTION downstream_segments(text);
*/
/*-----------------------------------------
Function to get all segments downstream from one one in the same subbasin
Problem when the subbasin changes it is difficult to go downstream
-----------------------------------------*/
CREATE OR REPLACE FUNCTION downstream_segments(_id text) 
RETURNS TABLE(pfafcuen character varying(254), lngtramo_m numeric) AS
$$
BEGIN
	RAISE NOTICE 'downstream segment for %', _id;    -- prints the selected segment
	RETURN QUERY   
	     SELECT r.pfafcuen, r.lngtramo_m from  oria_a_rios_v2 r 
		WHERE
		 substring(_id::text,1,char_length(_id::text)-1)= 
		   substring(r.pfafcuen::text,1,char_length(r.pfafcuen::text)-1) 
		AND
		 _id>r.pfafcuen
		AND
                 (r.pfafcuen::numeric % 2) = 1 
               order by r.pfafcuen::numeric DESC;  -- even number		
END
$$
  LANGUAGE plpgsql VOLATILE;
select * from downstream_segments('10037146457'); 


/*
create function ds_sub (downstream_segment in subbasin)
*/

CREATE OR REPLACE FUNCTION f_foo(open_id numeric)
  RETURNS TABLE (a int, b int, c int) AS
$func$
BEGIN
   -- do something with open_id?
   RETURN QUERY VALUES
     (1,2,3)
   , (3,4,5)
   , (3,4,5);
END
$func$  LANGUAGE plpgsql IMMUTABLE ROWS 3;


SELECT * FROM f_foo(1);

-- TODO upstream segments

https://docs.pgrouting.org/2.5/en/pgRouting-concepts.html#description-of-the-edges-sql-query-for-dijkstra-like-functions
{{{#!slq
-------------------------------------
-- pgrouting installation and configuration on table
CREATE EXTENSION pgrouting;
ALTER TABLE spain.oria_a_rios_v2 DROP COLUMN source;
ALTER TABLE spain.oria_a_rios_v2 DROP COLUMN target;
ALTER TABLE spain.oria_a_rios_v2 ADD COLUMN source integer;
ALTER TABLE spain.oria_a_rios_v2 ADD COLUMN target integer;
CREATE INDEX oria_a_rios_v2_source_idx ON spain.oria_a_rios_v2 (source);
CREATE INDEX oria_a_rios_v2_target_idx ON spain.oria_a_rios_v2 (target);

---------------------------------------------------------------------
-- createTopology also creates spain.oria_a_rios_v2_vertices_pgr
------------------------------------------------------------------
set search_path to spain,public;
SELECT pgr_createTopology('oria_a_rios_v2', 0.0001, 'geom', 'gid');--1.4s
---------------------------------------------------------------------
-- routing this is done using nodes, FALSE is necessery otherwise fails (using a directed path=
------------------------------------------------------------------
SELECT seq, node, edge, agg_cost, gid, pfafcuen
FROM pgr_dijkstra(
   'SELECT gid as id, source, target, st_length(geom) as cost FROM oria_a_rios_v2',
   5,
   540,
  FALSE
)  pt
JOIN oria_a_rios_v2 r ON pt.edge = r.gid order by seq;
}}}
||"seq"||"node"||"edge"||"agg_cost"||"gid"||"pfafcuen"||
||1||5||774||0||774||"1003714113"||
||2||28||783||340.239109235141||783||"1003714115"||
||3||33||916||434.71909815275||916||"1003714117"||
||4||61||920||1381.42299559645||920||"100371413"||
||5||62||956||1931.41349601216||956||"10037141511"||
||6||54||992||2751.07786782504||992||"10037141513"||
||7||53||1023||3006.69704002442||1023||"10037141515"||
||8||16||1028||3923.51604452287||1028||"10037141517"||
||9||15||962||4550.98432547035||962||"10037141531"||
||10||47||879||5241.61915518433||879||"10037141533"||
||11||39||880||5777.24646955956||880||"10037141535"||