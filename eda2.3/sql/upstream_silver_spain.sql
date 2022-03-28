/*

Adaptation of script upstream_segment to spain
Cédric Briand Maria Matteo 20/11/2018

Note will probably be changed as we change the table structure
Note done to do a quick calculation of upstream eel densities in eelConsensus

*/

alter table spain.rivers add column dens_silver_pred numeric;
update spain.rivers set dens_silver_pred=exp(-3.09-0.004*dmer/1000)/100; --see sudoang. Density_dist_sea.R one error here we are in m2 and density is predicted for 100 m2. 325607 rows affected, 04:13 minutes


--see sudoang. Density_dist_sea.R one error here we are in m2 and density is predicted for 100 m2

select * from spain.rivers limit 10;

select count(*) from spain.rivers where chemin is null --211935 too much for endoreic basins
-- Ensuite la fonction qui ne marchait pas le E'\\.+' devient un E''\\\\.+''
DROP TYPE IF EXISTS gid;
CREATE TYPE gid as (gid int);

DROP TABLE IF EXISTS spain.upstream_riversegments;
CREATE TABLE spain.upstream_riversegments(gid integer);

CREATE INDEX rivers_gid_idx
  ON spain.rivers
  USING btree
  (gid);
/* 
this function uses path (btree) and it's sooo slow
It's kept there in case
*/

DROP  FUNCTION IF EXISTS spain.upstream_path(id_ numeric);
CREATE OR REPLACE FUNCTION spain.upstream_path(id_ numeric) RETURNS setof int AS $$
        DECLARE
        gid gid%ROWTYPE;
        BEGIN
        -- filling a new table with the results from a catchment
        delete from spain.upstream_riversegments;
        EXECUTE 'insert into spain.upstream_riversegments (select cast(unnest(vecteurchemin) as integer) as gid 
        from (SELECT regexp_split_to_array(ltree2text(chemin),E''\\.+'') as vecteurchemin from spain.rivers where chemin ~ ''*.'||id_||'.*'') as sub 
        EXCEPT  select cast(unnest(vecteurchemin) as integer) as gid 
        from ( select regexp_split_to_array(ltree2text(chemin),E''\\.+'') as vecteurchemin from spain.rivers where gid='||id_||') as sub
        EXCEPT select '||id_||' order by gid)';
        
        for gid in select * from spain.upstream_riversegments loop
                gid.gid=CAST(gid.gid AS int8);
                return next gid.gid;
                end loop;
                return; 
        END;
$$
LANGUAGE 'plpgsql' ;
COMMENT ON FUNCTION spain.upstream_path(id_ numeric) IS 'function using btree to calculate upstream riversegments';


-- This is to try the function
select * from spain.rivers where gid= 46022
select  spain.upstream_path(46022); -- 25s 
select * from spain.upstream_segments(69578)  ; -- upstream_segments uses target

select * from spain.temp_rios where gid=46022

/*
to understand the topology, first function was based on target not gid and it didn't work, hence these trials"

SELECT * from spain.rivers where target = 69578; -- several lines
SELECT * from spain.rivers where gid=  46022; -- several lines
SELECT * from spain.rivers where gid=  46022; -- several lines
*/

/*
ADDING RIVERWIDTH FROM MEDIAN WITH FROM RHT see sudoang. Density_dist_sea.R
*/
ALTER TABLE spain.rivers add column riverwidth numeric;

UPDATE spain.rivers SET riverwidth = -0.2+ 0.0007914*sqrt(shape_area) 
FROM spain.basins
WHERE basins.cod_uni=rivers.cod_uni;

/*
Number of eel is density * surface
*/

ALTER TABLE spain.rivers ADD COLUMN n_silver_pred numeric;
UPDATE spain.rivers set n_silver_pred = riverwidth*lngtramo_m*dens_silver_pred;


-- Défine source sectors (on these the cumulated upstream number = the number of eels of the segment
-- No need to calculate there


ALTER TABLE spain.rivers ADD COLUMN sourcenode boolean default FALSE;
UPDATE spain.rivers set sourcenode= TRUE where rivers.source  in (
select source from spain.rivers except
select rd.source from spain.rivers rd join spain.rivers ru on ru.target=rd.source); --1:05

/*
Recusive function for upstream segments modified to use gid instead of targer
*/


DROP function if exists spain.upstream_segments_gid(INTEGER);
CREATE FUNCTION spain.upstream_segments_gid(INTEGER)
RETURNS TABLE(gid integer,source integer, target integer) AS
$$
BEGIN
RETURN QUERY
	WITH RECURSIVE parcours AS(
		SELECT
			r0.gid,
			r0.source,
			r0.target
		FROM
			spain.rivers r0  
		WHERE
			r0.gid = $1
	       
	       
	       UNION SELECT
	               r1.gid,
		       r1.source,
		       r1.target
		FROM
			parcours
		JOIN spain.rivers r1 
		ON  parcours.source = r1.target)
          SELECT * FROM parcours;
END
$$
  LANGUAGE plpgsql VOLATILE;
  

Comment on function spain.upstream_segments_gid(INTEGER) IS 'Function to calculate upstream segments gid, source, target';


/*
tests 
select * from spain.upstream_segments_gid(46022); --23ms
select * from spain.upstream_segments(69578); --20 ms
*/


/*
We write this in silver_production, same as EDA2.2
*/

DROP TABLE spain.silver_production;
CREATE TABLE spain.silver_production (
gid integer,
n_silver_pred_upstream numeric);


/*
This functions writes one line in silver_production with the cumulated number upstream
*/
DROP FUNCTION  if exists spain.upstream_silver(integer);
CREATE OR REPLACE FUNCTION spain.upstream_silver(_gid integer) RETURNS void AS 
$$
        BEGIN
	        INSERT INTO spain.silver_production("gid","n_silver_pred_upstream")
			SELECT _gid as gid,
			round(sum(n_silver_pred),2) as n_silver_pred_upstream	               
			FROM spain.rivers r
	        WHERE r.gid in (select gid from spain.upstream_segments_gid(_gid));
	    RETURN;        
        END       
$$
LANGUAGE 'plpgsql' ;

/*
If you test it, remember to remove the data from the table using delete

select * from spain.upstream_silver(46022);
select * from spain.silver_production
delete from spain.silver_production;
*/

/*
Calculation of the number of silver eels, loop betwenn gid start and gid end
*/
DROP FUNCTION spain.upstream_silver_vector(integer, integer);
CREATE OR REPLACE FUNCTION spain.upstream_silver_vector(
    gid_init integer,
    gid_end integer)
  RETURNS text AS
$BODY$
	DECLARE
	current_gid int;
	exists_gid boolean;
	is_not_source boolean;	
	BEGIN	  	
		RAISE NOTICE 'calculating  % à %',gid_init,gid_end;
		current_gid=gid_init;
		while (current_gid<=gid_end) LOOP 
			select exists (SELECT 1 FROM spain.rivers WHERE gid = current_gid LIMIT 1) into exists_gid ;
			select NOT sourcenode from spain.rivers where gid=current_gid into is_not_source;
			RAISE NOTICE 'gid =%',current_gid;
			IF (exists_gid AND is_not_source) THEN
			RAISE NOTICE 'insert';	
			EXECUTE 'select spain.upstream_silver('||current_gid||')';			
			END IF;	
			current_gid=current_gid+1;						
		END LOOP;
	RETURN('transaction done');
	END
$BODY$
LANGUAGE plpgsql VOLATILE;

--327694
/*
RUN everywhere
*/
SELECT  spain.upstream_silver_vector(1,100000);--04:47
SELECT  spain.upstream_silver_vector(100001,200000);
SELECT  spain.upstream_silver_vector(200001,300000);
SELECT  spain.upstream_silver_vector(300001,327694);

/*
ADD THOSE NOT CALCULATED ON SOURCE SEGMENTS
*/

insert into spain.silver_production  (gid,n_silver_pred_upstream) 
select gid, n_silver_pred
from spain.rivers  where sourcenode; --164240
SELECT count(*) from spain.silver_production; --325607

/*
ADD GEOM
*/

select addgeometrycolumn('spain','silver_production','geom', 25830, 'MultiLineString',2);
update spain.silver_production set geom=rivers.geom from spain.rivers where rivers.gid=silver_production.gid;


/*
If the following does not work, you have launched several times the same loop
use the next script to remove duplicates and try again.
*/

alter table spain.silver_production 
add constraint c_pk_silver_production_gid primary key (gid);
select * from spain.silver_production limit 10

/*
Save my ass from duplicates
*/
delete from spain.silver_production where gid in (
select sub.gid from (
select gid,count(*) as count from spain.silver_production group by gid)sub
where count>1); --27553 








/* Projection on the dam layer
The pg_dump and the psql of this table and the sudoang schema in eda2.0 had done in dbeel_sudoang_obstruction (line 70)
*/


alter table sudoang.spain_obstruction add column n_silver_pred_upstream numeric;
update  sudoang.spain_obstruction  set n_silver_pred_upstream= sub2.n_silver_pred_upstream from (
select distinct on("PRESA") "PRESA", n_silver_pred_upstream from (
SELECT  
"PRESA",
silver_production.n_silver_pred_upstream,
 st_distance(silver_production.geom,so.geom) as distance
 from  sudoang.spain_obstruction so join
	spain.silver_production  on st_dwithin(silver_production.geom,so.geom,500)
 order by "PRESA", distance asc) sub) sub2
 where sub2."PRESA"=spain_obstruction."PRESA"



