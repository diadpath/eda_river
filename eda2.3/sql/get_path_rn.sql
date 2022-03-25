/*

THis script contains various functions to explore the rn-rna rivers tables.
=> get_path provides the path between two idsegments of the same basin
=> dbeel_rivers.get_distance calculates the distance between two rivers segments (including the distance of the idsegments themselves)
=> dbeel_rivers.dbeel_rivers.upstream_segments_rn(TEXT) takes an upstream segment and returns a vector of idsegments
=> dbeel_rivers.upstream_segments_rn_sti(TEXT) takes an upstream segment and a TABLE with idsegment, target, source, this in more convenient for
later use of routing functions (like get path) which require source and target
=> spain.write_path(INTEGER) writes the path for a set of idsegment, the function first searches for NULL path where isea or isendoreic (
you need to change the code one line inside the function to adapt) the functions uses upstream_segments to search for upstream segments and will calculate
the path from the sea to all idsegments in the basin and write them. The number inside is a limit argument to not to lauch too much. This function is just there to correct things 
in the end but it takes a while to run....


*/

CREATE OR REPLACE FUNCTION dbeel_rivers.get_path(
    _from integer,
    _to integer,
    _country character varying)
  RETURNS SETOF ltree AS
$BODY$
BEGIN
RETURN QUERY 
SELECT text2ltree(string_agg(idsegment::text, '.')) AS gid_list  
FROM (SELECT idsegment FROM pgr_dijkstra(
   'SELECT gid as id, source, target, st_length(geom) as cost FROM dbeel_rivers.rn where country='||quote_literal(_country),
   _from,
   _to,
  FALSE
)  pt
JOIN dbeel_rivers.rn r ON pt.edge = r.gid where r.country = _country order by seq) sub;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION dbeel_rivers.get_path(integer, integer, character varying)
  OWNER TO postgres;


select dbeel_rivers.get_path (113670,114115,'FR')
-- FR113618.FR114065.FR114053.FR114042
--select * from france.rn_rna limit 10




CREATE OR REPLACE FUNCTION dbeel_rivers.get_distance(
    _from integer,
    _to integer,
    _country character varying)
  RETURNS numeric AS
$BODY$
BEGIN
RETURN(SELECT sum(lengthm) AS distance  
FROM (SELECT idsegment,lengthm FROM pgr_dijkstra(
   'SELECT gid as id, source, target, st_length(geom) as cost FROM dbeel_rivers.rn where country='||quote_literal(_country),
   _from,
   _to,
  FALSE
)  pt
JOIN dbeel_rivers.rn r ON pt.edge = r.gid where r.country = _country order by seq) sub);
END
$BODY$
  LANGUAGE plpgsql VOLATILE

ALTER FUNCTION dbeel_rivers.get_distance(integer, integer, character varying)
  OWNER TO postgres;

  
-- EXAMPLES
select  dbeel_rivers.get_distance (113670,114115,'FR'); --12669
 -- THE SAME WITH VECTORS
 with source as (select source from france.rn_rna where basin ='la sarthe de sa source au loir (nc) [M0]' limit 10)
SELECT dbeel_rivers.get_distance(203073, source.source, 'FR') from source

-- ADAPT spain.get_path to rn
-- this is the same function as dbeel_rivers but for spain only
-- as the indexes are built in the daughter table (spain.rn, france.rn...) this functions applied on the daughter table should be much quicker than de dbeel_river one
-- DROP FUNCTION spain.get_path(integer, integer);

CREATE OR REPLACE FUNCTION spain.get_path(
    _from integer,
    _to integer)
  RETURNS SETOF ltree AS
$BODY$
BEGIN
RETURN QUERY 
SELECT text2ltree(string_agg(idsegment::text, '.')) AS idsegment_list  
FROM (SELECT idsegment FROM pgr_dijkstra(
   'SELECT gid as id, source, target, st_length(geom) as cost FROM spain.rn ',
   _from,
   _to,
  FALSE
)  pt
JOIN spain.rn r ON pt.edge = r.gid order by seq) sub;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION spain.get_path(integer, integer)
  OWNER TO postgres;

-- DROP FUNCTION france.get_path(integer, integer);

CREATE OR REPLACE FUNCTION france.get_path(
    _from integer,
    _to integer)
  RETURNS SETOF ltree AS
$BODY$
BEGIN
RETURN QUERY 
SELECT text2ltree(string_agg(idsegment::text, '.')) AS idsegment_list  
FROM (SELECT idsegment FROM pgr_dijkstra(
   'SELECT gid as id, source, target, st_length(geom) as cost FROM france.rn ',
   _from,
   _to,
  FALSE
)  pt
JOIN france.rn r ON pt.edge = r.gid order by seq) sub;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION france.get_path(integer, integer)
  OWNER TO postgres;

 -- DROP FUNCTION portugal.get_path(integer, integer);

CREATE OR REPLACE FUNCTION portugal.get_path(
    _from integer,
    _to integer)
  RETURNS SETOF ltree AS
$BODY$
BEGIN
RETURN QUERY 
SELECT text2ltree(string_agg(idsegment::text, '.')) AS idsegment_list  
FROM (SELECT idsegment FROM pgr_dijkstra(
   'SELECT gid as id, source, target, st_length(geom) as cost FROM portugal.rn ',
   _from,
   _to,
  FALSE
)  pt
JOIN portugal.rn r ON pt.edge = r.gid order by seq) sub;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION portugal.get_path(integer, integer)
  OWNER TO postgres;



/*
GETS A VECTOR OF UPSTREAM SEGMENTS (idsegment)
*/
		


CREATE OR REPLACE FUNCTION dbeel_rivers.upstream_segments_rn(IN text)
  RETURNS TABLE(_idsegment text) AS
$BODY$
BEGIN
RETURN QUERY
	WITH RECURSIVE parcours AS(
		SELECT
			r0.idsegment,
			r0.nextdownidsegment
		FROM
			dbeel_rivers.rn r0  
		WHERE
			r0.idsegment = $1
	       
	       
	       UNION SELECT
	           r1.idsegment,
	           r1.nextdownidsegment
		       
		FROM
			parcours
		JOIN dbeel_rivers.rn r1 
		ON  parcours.idsegment = r1.nextdownidsegment)
          SELECT idsegment FROM parcours;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION dbeel_rivers.upstream_segments_rn(text)
  OWNER TO postgres;
COMMENT ON FUNCTION dbeel_rivers.upstream_segments_rn(text) IS 'Function to calculate upstream segments idsegment,
attention this function is slower than national counterparts, check in schema spain portugal and france for quicker functions';


SELECT  dbeel_rivers.upstream_segments_rn('FR114042')


/*
This function is adapted to return all elements (source,target, and idsegment)
*/


CREATE OR REPLACE FUNCTION dbeel_rivers.upstream_segments_rn_sti(IN text)
  RETURNS TABLE(_idsegment text, source integer, target INTEGER) AS
$BODY$
BEGIN
RETURN QUERY
	WITH RECURSIVE parcours AS(
		SELECT
			r0.idsegment,
			r0.source,
			r0.target
		FROM
			dbeel_rivers.rn r0  
		WHERE
			r0.idsegment = $1
	       
	       
	       UNION SELECT
	               r1.idsegment,
		       r1.source,
		       r1.target
		FROM
			parcours
		JOIN dbeel_rivers.rn r1 
		ON  parcours.source = r1.target)
          SELECT * FROM parcours;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION dbeel_rivers.upstream_segments_rn_sti(text)
  OWNER TO postgres;
COMMENT ON FUNCTION dbeel_rivers.upstream_segments_rn_sti(text) IS 'Function to calculate upstream segments source, target idsegment, see spain.upstream_segments_rn to return idsegment only';


/*
Specific function for spain
*/


CREATE OR REPLACE FUNCTION spain.upstream_segments_rn(IN text)
  RETURNS TABLE(_idsegment text) AS
$BODY$
BEGIN
RETURN QUERY
	WITH RECURSIVE parcours AS(
		SELECT
			r0.idsegment,
			r0.nextdownidsegment
		FROM
			spain.rn r0  
		WHERE
			r0.idsegment = $1
	       
	       
	       UNION SELECT
	           r1.idsegment,
	           r1.nextdownidsegment
		       
		FROM
			parcours
		JOIN spain.rn r1 
		ON  parcours.idsegment = r1.nextdownidsegment)
          SELECT idsegment FROM parcours;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION spain.upstream_segments_rn(text)
  OWNER TO postgres;
COMMENT ON FUNCTION spain.upstream_segments_rn(text) IS 'Function to calculate upstream segments idsegment only for the spain
schema, use same function in dbeel_rivers schema for international search.';


CREATE OR REPLACE FUNCTION spain.upstream_segments_rn_sti(IN text)
  RETURNS TABLE(_idsegment text, source integer, target INTEGER) AS
$BODY$
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
          SELECT * FROM parcours;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION spain.upstream_segments_rn_sti(text)
  OWNER TO postgres;
COMMENT ON FUNCTION spain.upstream_segments_rn_sti(text) IS 'Function to calculate upstream segments source, target idsegment, see spain.upstream_segments_rn to return idsegment only';

-- France

CREATE OR REPLACE FUNCTION france.upstream_segments_rn(IN text)
  RETURNS TABLE(_idsegment text) AS
$BODY$
BEGIN
RETURN QUERY
	WITH RECURSIVE parcours AS(
		SELECT
			r0.idsegment,
			r0.nextdownidsegment
		FROM
			france.rn r0  
		WHERE
			r0.idsegment = $1
	       
	       
	       UNION SELECT
	           r1.idsegment,
	           r1.nextdownidsegment
		       
		FROM
			parcours
		JOIN france.rn r1 
		ON  parcours.idsegment = r1.nextdownidsegment)
          SELECT idsegment FROM parcours;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION france.upstream_segments_rn(text)
  OWNER TO postgres;
COMMENT ON FUNCTION france.upstream_segments_rn(text) IS 'Function to calculate upstream segments idsegment only for the france
schema, use same function in dbeel_rivers schema for international search.';

-- Portugal

CREATE OR REPLACE FUNCTION portugal.upstream_segments_rn(IN text)
  RETURNS TABLE(_idsegment text) AS
$BODY$
BEGIN
RETURN QUERY
	WITH RECURSIVE parcours AS(
		SELECT
			r0.idsegment,
			r0.nextdownidsegment
		FROM
			portugal.rn r0  
		WHERE
			r0.idsegment = $1
	       
	       
	       UNION SELECT
	           r1.idsegment,
	           r1.nextdownidsegment
		       
		FROM
			parcours
		JOIN portugal.rn r1 
		ON  parcours.idsegment = r1.nextdownidsegment)
          SELECT idsegment FROM parcours;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION portugal.upstream_segments_rn(text)
  OWNER TO postgres;
COMMENT ON FUNCTION portugal.upstream_segments_rn(text) IS 'Function to calculate upstream segments idsegment only for the portugal
schema, use same function in dbeel_rivers schema for international search.';


/*
 * Gets a vector of downstream segments
 * note this function does not return the segment itself
 */
CREATE OR REPLACE FUNCTION dbeel_rivers.downstream_segments_rn(IN text)
  RETURNS TABLE(_idsegment text) AS
$BODY$
BEGIN
RETURN QUERY
	WITH  parcoursdown AS(
		SELECT
			CAST(UNNEST(regexp_split_to_array(ltree2text(path),E'\\.+')) AS TEXT) AS idsegment  from dbeel_rivers.rn 
			WHERE idsegment = $1 
			EXCEPT 
			SELECT $1 )
          SELECT * FROM parcoursdown;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION dbeel_rivers.downstream_segments_rn(text)
  OWNER TO postgres;
COMMENT ON FUNCTION dbeel_rivers.downstream_segments_rn(text) IS 'Function to calculate downstream segments idsegment';

SELECT dbeel_rivers.downstream_segments_rn('SP227795');



/*---------------
*  FRANCE EXTRACT BASINS
*-------------------------*/
-- example how to extract basins

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
14/02/2020 Missing values for path in SPAIN
*/

SELECT *
	 FROM  spain.rn 
	 WHERE issea 
	 AND path is NULL ;--28 + 21

SELECT idsegment, source, target
	 FROM  spain.rn 	 
	 WHERE isendoreic 
	 AND path IS NULL;; --0

SELECT idsegment, source, target
	 FROM  dbeel_rivers.rn 	 
	 WHERE issea 
	 AND path IS NULL
	 and country= 'SP'; --28
select * from dbeel_rivers.rna where idsegment='SP186717'	 

-- UPDATE VALUES WHERE ONLY ONE SEGMENT = EASY

BEGIN;
UPDATE spain.rn set (path,seaidsegment)=(idsegment::ltree,seaidsegment) WHERE issea AND issource and path IS NULL; --21
COMMIT;


--select * FROM dbeel_rivers.upstream_segments_rn_sti('SP188069');

/*
Function to write missing path (some basins have not been updated probably because of wrong basin assignation)
The function loads all downstream points where path is null into a cursor (curdown) and will move into this cursor
to apply get_path(cur_target,u.source, _country) where cur_target will be target point of the most downstream segment
source is the vector of sources of the whole basin collected by upstream_segments.

Function for spain (no country argument)
change isendoreic or idsea to adapt path calculation
*/


DROP function if exists spain.write_path(INTEGER);
CREATE OR REPLACE FUNCTION spain.write_path(_limit INTEGER)
   RETURNS integer AS 
 $$
DECLARE 
 current_count integer default 0;
 the_downstream_point   RECORD;
 cur_target integer;
 cur_idsegment TEXT; 
 cur_down CURSOR 
	 FOR SELECT idsegment, source, target
	 FROM  spain.rn 	 
	 --WHERE issea
	 WHERE isendoreic 
	 AND path IS NULL 
	 limit _limit;
         
BEGIN
   -- Open the cursor
   OPEN  cur_down;
   
   LOOP
    -- fetch row one by one into the_downstream_point
      FETCH cur_down INTO the_downstream_point;
    -- exit when no more row to fetch
      EXIT WHEN NOT FOUND;
      current_count := current_count+1;
     cur_target := the_downstream_point.target;
     cur_idsegment := the_downstream_point.idsegment;
     
    -- raise notice for now
      RAISE NOTICE 'target :%',cur_target; 
      
    -- create the path for this target and all upstream segments, the correction is done in each country
     WITH uu AS (SELECT source from spain.upstream_segments_rn_sti(cur_idsegment))
     UPDATE spain.rn set path=spain.get_path(cur_target,uu.source) 
     from uu
     where rn.source = uu.source; 
  END LOOP;
  
   -- Close the cursor
   CLOSE cur_down;
 
   RETURN current_count;
END; 
$$ 
LANGUAGE plpgsql;

SELECT spain.write_path(150);  -- first version with issea 36 lines 4:00
-- Also launched for all endoreic streams 1:00

select * from spain.rn where seaidsegment is NULL --7197
select * from spain.rn where seaidsegment is NULL and path is not NULL; --7006



/*
setting seaidsegment when missing
*/
BEGIN;
with lastdownsegment as (
select subltree(path,0,1) as lastidsegment, idsegment  from spain.rn where seaidsegment is NULL and path is not NULL),
getsisseavalue as (
select lastdownsegment.*, rn.issea from spain.rn join lastdownsegment on ltree2text(lastidsegment)=rn.idsegment)
UPDATE spain.rn set seaidsegment=lastidsegment from getsisseavalue where getsisseavalue.idsegment=rn.idsegment and getsisseavalue.issea; --21
COMMIT;




/*
Set to endoreic all stream which finish by an endoreic stream
*/
BEGIN;
with endoreic as (
SELECT * from spain.rn WHERE isendoreic),
joined AS (
SELECT rn.idsegment FROM spain.rn join  endoreic on ltree2text(subltree(rn.path,0,1))=ltree2text(endoreic.path)
WHERE NOT rn.isendoreic)
UPDATE spain.rn set isendoreic = TRUE where idsegment in (SELECT idsegment from joined); --2030
COMMIT;


/*
Problem with path (the function last run has returned gid not idsegment) 
this code selects all lines without SP, or FR, or PT at the beginning of string (those with error) 
unfolds the path, corrects by adding SP, folds the path again, and update the path....
*/

BEGIN;
	WITH fff AS (
		SELECT  idsegment, ltree2text(subltree(rn.path,0,1))  as the_first, path
		FROM spain.rn  
		order by the_first),
	withpb AS (
		SELECT * from fff where the_first not like '%PT%'
		AND the_first NOT LIKE '%SP%'
		AND the_first NOT LIKE '%FR%'),
		/*
		SELECT * FROM withpb limit 1  idsegment;the_first;path
		SP98084;100148;100148.100151.88592.100123.100498.98084
		*/

	unfolded as (
		SELECT 'SP'||unnest(regexp_split_to_array(ltree2text(path),E'\\.+')) as elements_path, idsegment FROM withpb
		),

		/*
		SELECT text2ltree(string_agg(elements_path, '.')) AS idsegment_list , idsegment from unfolded  where idsegment='SP98084' GROUP BY idsegment
		idsegment_list;idsegment
		SP100148.SP100151.SP88592.SP100123.SP100498.SP98084;SP98084
		*/
	corrected as (
		SELECT text2ltree(string_agg(elements_path, '.')) AS idsegment_list , idsegment 
		from unfolded 
		GROUP BY idsegment)

		--SELECT *, path FROM corrected JOIN spain.rn on corrected.idsegment= rn.idsegment OK !!

	UPDATE spain.rn set path= idsegment_list FROM corrected 
		where corrected.idsegment= rn.idsegment; --6985
COMMIT;
/*
One problem in Galicia, this one is not endoreic
*/

SELECT * FROM spain.rn where idsegment = 'SP1961'
BEGIN;
UPDATE spain.rn SET (issea, isendoreic)= (TRUE,FALSE) where idsegment = 'SP1961'; --1
COMMIT;

/*
CORRECTING ENDOREIC and seaidsegment
*/

BEGIN;
WITH mendo_mandeo_basin as (
SELECT * FROM spain.rn where ltree2text(subltree(rn.path,0,1))='SP1961')

UPDATE spain.rn set (seaidsegment, isendoreic) = ('SP1961',FALSE) 
FROM mendo_mandeo_basin 
WHERE rn.idsegment=mendo_mandeo_basin.idsegment; --265
COMMIT;

/*
CEUTA AND MELILLA ARE NOT ENDOREIC
*/

BEGIN;
with ceuta_melilla_basins AS (
SELECT * FROM spain.rn_rna where basin in ('CEUTA','MELILLA')
)
UPDATE spain.rn set isendoreic= FALSE FROM ceuta_melilla_basins WHERE ceuta_melilla_basins.idsegment=rn.idsegment; --48
COMMIT;

BEGIN;
with ceuta_melilla_basins_sea AS (
SELECT * FROM spain.rn_rna where basin in ('CEUTA','MELILLA') and nextdownidsegment is NULL
)
UPDATE spain.rn set (issea,seaidsegment)=(TRUE,rn.idsegment) FROM ceuta_melilla_basins_sea WHERE ceuta_melilla_basins_sea.idsegment=rn.idsegment; --17
COMMIT;


BEGIN;
with ceuta_melilla_basins_upstream AS (
SELECT * FROM spain.rn_rna where basin in ('CEUTA','MELILLA') AND NOT issea
)
UPDATE spain.rn set seaidsegment=ltree2text(subltree(rn.path,0,1)) FROM ceuta_melilla_basins_upstream WHERE ceuta_melilla_basins_upstream.idsegment=rn.idsegment; --31
COMMIT;

/*-------------------------------------------
* Working on drainage and cumulated downstream 
*
--------------------------------------------*/


DROP TABLE IF EXISTS dbeel_rivers.habitat_downstream;
CREATE TABLE dbeel_rivers.habitat_downstream AS(
WITH downstreamsegments AS (  
  SELECT unnest(regexp_split_to_array(ltree2text(path),E'\\.+')) as vecteurchemin,
  rn.idsegment,
  rna.distanceseam
  FROM dbeel_rivers.rn 
  JOIN dbeel_rivers.rna ON rna.idsegment=rn.idsegment
  WHERE NOT isendoreic
),
 cumdownstream AS(
 SELECT 
  downstreamsegments.idsegment,
  downstreamsegments.distanceseam,
 SUM(wettedsurfacem2) AS cumwettedsurfacem2,
 SUM(wettedsurfaceotherm2) AS cumwettedsurfaceotherm2,
 COUNT(vecteurchemin) -1 AS nbtributarydownstream,
 SUM(surfaceunitbvm2) AS cumsurfaceunitbvm2
 FROM downstreamsegments 
 JOIN dbeel_rivers.rn  ON rn.idsegment=downstreamsegments.vecteurchemin
 JOIN dbeel_rivers.rna ON rn.idsegment=rna.idsegment
 GROUP BY (downstreamsegments.idsegment, downstreamsegments.distanceseam))
SELECT 
 idsegment,
 COALESCE(cumwettedsurfacem2,0) AS cumwettedsurfacem2,
 COALESCE(cumwettedsurfaceotherm2,0) AS cumwettedsurfaceotherm2,
 COALESCE(cumwettedsurfacem2,0) + COALESCE(cumwettedsurfaceotherm2,0) AS cumwettedsurfacebothm2,
 cumsurfaceunitbvm2,
 (cumwettedsurfaceotherm2 + cumwettedsurfacem2)/distanceseam AS avgwidthdownstreamm,
 nbtributarydownstream,
 1000*(nbtributarydownstream)/distanceseam AS nbforkperkm,
 CASE WHEN cumsurfaceunitbvm2=0 THEN 0 ELSE
 (cumwettedsurfaceotherm2 + cumwettedsurfacem2)/cumsurfaceunitbvm2 END AS downstreamwettedsurface 
 FROM cumdownstream 
 ); --19m 512873 rows
 
 
 

 SELECT AddGeometryColumn ('dbeel_rivers','habitat_downstream','geom',3035,'MULTILINESTRING',2, false);

 UPDATE dbeel_rivers.habitat_downstream SET 
geom = rn.geom
FROM dbeel_rivers.rn
WHERE rn.idsegment= habitat_downstream.idsegment; --57 s 512873

CREATE INDEX indexhabitatdownstreamidsegment
  ON dbeel_rivers.habitat_downstream 
  USING btree
  (idsegment); 
 
CREATE INDEX habitat_downstreamgeom
  ON dbeel_rivers.habitat_downstream
  USING gist
  (geom);




 
/*
 *  Calculates downstream variable
 */

drop table if exists drainage_downstream;
create table drainage_downstream (idsegment text,
hydraulicdensityperm2 numeric, 
drainage_density_perm numeric, 
downstdrainagewettedsurface numeric, 
downstdrainagewettedsurfaceother NUMERIC,
downstdrainagewettedsurfaceboth NUMERIC);
alter table drainage_downstream add primary key (idsegment);
DROP TABLE IF EXISTS eda_gerem.drainage_downstream; 
ALTER TABLE drainage_downstream SET SCHEMA eda_gerem;




  DO $$
    DECLARE
      rec RECORD;
      seaid varchar;
      nbseg integer;
      avail_wetted numeric;
      avail_wetted_other numeric;
      avail_wetted_both NUMERIC;
      surface numeric;
      length numeric;
      
    BEGIN
      FOR seaid in SELECT distinct seaidsegment from dbeel_rivers.rn
      LOOP
        BEGIN
	  surface:=0.001;
	  avail_wetted:=0;
	  avail_wetted_other:=0;
	  nbseg:=0;
	  length:=0;
	  avail_wetted_both:=0;
	  for rec in select distanceseam,
	  idsegment,seaidsegment,
	  coalesce(surfaceunitbvm2,0) surfaceunitbvm2,
	  coalesce(lengthm,0) lengthm,
	  coalesce(wettedsurfacem2,0) wettedsurfacem2,
	  coalesce(wettedsurfaceotherm2,0) wettedsurfaceotherm2,
	  coalesce(wettedsurfacem2)+COALESCE(wettedsurfaceotherm2,0) AS wettedsurfacebothm2,
	  distanceseam from dbeel_rivers.rn 
	  join dbeel_rivers.rna using(idsegment) 
	  where seaidsegment=seaid 
	  order by distanceseam
	  LOOP
	    BEGIN
		length:=length+rec.lengthm;
		surface:=surface+rec.surfaceunitbvm2;
		nbseg:=nbseg+1;
		avail_wetted:=avail_wetted+rec.wettedsurfacem2;
		avail_wetted_other:=rec.wettedsurfaceotherm2+avail_wetted_other;
		avail_wetted_both:=avail_wetted+avail_wetted_other;
		insert into eda_gerem.drainage_downstream 
		values(rec.idsegment,nbseg/surface,
		length/surface,
		avail_wetted/surface,
		avail_wetted_other/surface,
		avail_wetted_both/surface);
            end;
          END LOOP;
	END;
      end loop;
     end;
  $$ LANGUAGE 'plpgsql'; --57 min

  
  
  


SELECT * FROM eda_gerem.drainage_downstream LIMIT 10
