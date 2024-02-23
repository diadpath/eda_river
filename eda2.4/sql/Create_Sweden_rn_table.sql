-- sweden.rn definition

-- Drop table
DROP TABLE IF EXISTS worksweden.rn;

-- Create schema worksweden
create schema worksweden;

-- Create table rn   
CREATE TABLE worksweden.rn (gml_id VARCHAR,
fictitious BOOLEAN,
divergence INT,
isinlandoutlet BOOLEAN,
CONSTRAINT c_pk_rnidsegment PRIMARY KEY (idsegment),
UNIQUE(gid)
)
INHERITS (dbeel_rivers.rn);


------------------------------------------------
-- Columns to populate in worksweden.rn table --
------------------------------------------------
/*
gml_id, -- This script
gid, -- This script
idsegment, -- This script
"source", -- This script
target, -- This script
lengthm, -- This script
nextdownidsegment -- Routing algorithm in R finds most of these (Update non existing rows here)
"path" --  Routing algorithm R
isfrontier, -- This script
issource, -- This script
seaidsegment, -- Routing algorithm R
issea, -- This script
geom, -- This script
isendoreic, -- This script
isinternational, -- This script
country, -- This script
fictitious, -- This script
isinlandoutlet, -- Routing algorithm in R (these are outlets from one basin to another etc. Keeping if there are issues in path algorithm
divergence -- Routing algorithm R (Bifurcations; 1 - main path, 2 - subpath, 0 non-branching segment)  
*/

----------------------------------------
-- insert simple data into worksweden --
----------------------------------------
WITH 
tt AS 
(SELECT 
gml_id,
ogc_fid as gid,
CASE 
WHEN w."namespace" = 'SE.LM.HY.NVE' THEN 'NO'
WHEN w."namespace" = 'SE.LM.HY.SYKE' THEN 'FI'
WHEN w."namespace" = 'SE.LM.HY' THEN 'SW'
END || ogc_fid 
AS idsegment,
"length" AS lengthm,
issea,
ST_multi(ST_transform(wkb_geometry,3035)) AS geom,
CASE 
WHEN w."namespace" = 'SE.LM.HY.NVE' THEN 'NO'
WHEN w."namespace" = 'SE.LM.HY.SYKE' THEN 'FI'
WHEN w."namespace" = 'SE.LM.HY' THEN 'SW'
END AS country,
fictitious
FROM 
alt_insp.watercourselink w 
WHERE NOT w.isinsea)
INSERT INTO worksweden.rn(
gml_id, 
gid, 
idsegment,
lengthm,
issea,
geom,
country,
fictitious
)
SELECT 
gml_id, 
gid, 
idsegment,
lengthm,
issea,
geom,
country,
fictitious 
FROM 
tt
;

-------------------
-- obtain source --
-------------------
UPDATE worksweden.rn wrn
SET
"source" = skey.ogc_fid
FROM
(SELECT w.gml_id, h.ogc_fid  
FROM 
alt_insp.watercourselink w 
LEFT JOIN
alt_insp.hydronode h
ON
w.startnode = h.gml_id) skey
WHERE 
wrn.gml_id=skey.gml_id; 

-------------------
-- obtain target --
-------------------
UPDATE worksweden.rn wrn
SET
target = tkey.ogc_fid
FROM
(SELECT w.gml_id, h.ogc_fid  
FROM 
alt_insp.watercourselink w 
LEFT JOIN
alt_insp.hydronode h
ON
w.endnode = h.gml_id) tkey
WHERE 
wrn.gml_id=tkey.gml_id; 


-----------------------
-- obtain isfrontier --
-----------------------

-- create temporary table
DROP TABLE IF EXISTS frontier CASCADE;
CREATE TEMPORARY TABLE frontier AS

-- Populate temporary table frontier
WITH tt AS (SELECT  
CASE
WHEN w."namespace" = 'SE.LM.HY.NVE' THEN 'NO'
WHEN w."namespace" = 'SE.LM.HY.SYKE' THEN 'FI'
WHEN w."namespace" = 'SE.LM.HY' THEN 'SW'
END AS country,
CASE 
WHEN w2."namespace" = 'SE.LM.HY.NVE' THEN 'NO'
WHEN w2."namespace" = 'SE.LM.HY.SYKE' THEN 'FI'
WHEN w2."namespace" = 'SE.LM.HY' THEN 'SW' 
END AS nextcountry,
w.wkb_geometry,
w.gml_id 
FROM
alt_insp.watercourselink w
LEFT JOIN  alt_insp.watercourselink w2 ON w.endnode = w2.startnode)
SELECT wa.gml_id, B.gml_id IS NOT NULL isfrontier
FROM alt_insp.watercourselink wa 
LEFT JOIN
(SELECT DISTINCT
gml_id
FROM tt
WHERE country <> nextcountry) B 
ON wa.gml_id = B.gml_id;

/* -- USE THIS TO VISUALIZE FRONTIER SEGMENTS
CREATE VIEW worksweden.frontier_geom AS
SELECT w.*
FROM alt_insp.watercourselink w 
JOIN
frontier f 
ON w.gml_id=f.gml_id
where f.isfrontier;
*/

UPDATE worksweden.rn wrn
SET isfrontier=f.isfrontier
FROM frontier f
WHERE wrn.gml_id = f.gml_id; 
-----------------------------
------------------------------

---------------------
-- obtain issource --
---------------------

-- Utility function for finding sources within basins
CREATE OR REPLACE FUNCTION worksweden.find_source_in_basin(b_id integer)
 RETURNS TABLE(gml_id character varying, issource boolean)
 LANGUAGE plpgsql
AS $function$ 
BEGIN 
	RETURN QUERY
	WITH b_rn AS (
	SELECT *
	FROM alt_insp.watercourselink w
	WHERE w.maincatchment=b_id
	AND NOT w.isinsea
	),
	snode_not_in_endnode AS (
	SELECT 
	rn1.startnode
	FROM b_rn rn1
	EXCEPT
	SELECT
	rn2.endnode
	FROM b_rn rn2)
	SELECT b.gml_id, b.startnode IN (SELECT * FROM snode_not_in_endnode)
	FROM b_rn b;
END;
$function$
;

DROP TEMPORARY TABLE IF EXISTS source;
CREATE TEMPORARY TABLE source AS
WITH A AS
(SELECT DISTINCT maincatchment FROM alt_insp.watercourselink w)
SELECT * FROM A,
LATERAL (select * FROM alt_insp.find_source_in_basin(A.maincatchment)) AS foo;

UPDATE worksweden.rn wrn
SET issource=s.issource
FROM source s
WHERE wrn.gml_id = s.gml_id; 

/*
CREATE MATERIALIZED VIEW alt_insp.source_in_basin AS
SELECT w.*
FROM alt_insp.watercourselink w 
JOIN alt_insp."source" s 
ON w.gml_id=s.gml_id
WHERE s.issource;
*/

-- USE THIS CODE IS TO FIND ISSOURCE WHEN BASIN GROUPING IS NOT CONSIDERED
/* 
WITH swe AS 
(SELECT * -- network excluding segments in the sea
FROM 
alt_insp.watercourselink w
WHERE NOT isinsea),
snode_not_in_endnode AS
(SELECT s1.startnode
FROM swe s1
EXCEPT 
SELECT s2.endnode
FROM swe s2),
issource_ids AS(
SELECT gml_id
FROM
alt_insp.watercourselink w2 
WHERE w2.startnode IN (SELECT * FROM snode_not_in_endnode))
UPDATE worksweden.rn wrn
SET issource=TRUE
FROM issource_ids i
WHERE wrn.gml_id = i.gml_id; 

-- update segments with nulls(These should be boolean false)
UPDATE worksweden.rn
SET issource=FALSE
WHERE issource IS NULL;
*/

-----------------------
-- obtain isendoreic --
-----------------------
-- insert isendoreic in worksweden.rn
UPDATE worksweden.rn 
SET isendoreic = FALSE; -- the inspire network should not include isolated river networks(i.e. subsystems that are not connected to the sea)

----------------------------
-- obtain isinternational --
----------------------------
WITH 
int_basin AS
(SELECT maincatchment
FROM alt_insp.watercourselink w
WHERE NOT isinsea
GROUP BY maincatchment
HAVING COUNT(DISTINCT("namespace")) >1),
int_basin_segm AS
(SELECT gml_id
FROM alt_insp.watercourselink w 
WHERE w.maincatchment 
IN (SELECT maincatchment FROM int_basin)
)
UPDATE worksweden.rn wrn
SET isinternational=TRUE 
WHERE wrn.gml_id IN (SELECT * FROM int_basin_segm); 

-- This parameter is boolean. Hence change from NULL to FALSE for segments that are not part of international basins
UPDATE worksweden.rn wrn
SET isinternational =FALSE 
WHERE isinternational IS NULL;

------------------------
-- obtain divergence  --
------------------------

-- First run Find_bifurcations_and_nextdownidsegment script, then populate rn table using this script

/*
 This column is filled in R using the hydroloom package to find primary and substreams
 0 - a segment which is not part of a bifurcation
 1 - primary riversegment from a bifurcation(these are found using information from watercourselinksequence)
 2 - secondary riversegment from a bifurcation
 */

/* CHECK IF THERE ARE ANY EMPTY ROWS IN DIVERGENCE COLUMN
SELECT COUNT(*) -- 0
FROM div d 
WHERE divergence IS NULL;
*/ 

-- insert data from table div (produced in R) to rn table
UPDATE worksweden.rn wrn
SET divergence = d.divergence
FROM div d
WHERE wrn.gml_id = d.gml_id; 

------------------------------
-- obtain nextdownidsegment --
------------------------------

-- update table div with some nextdowngml_ids for null values
WITH tt AS 
(SELECT w.gml_id, w2.gml_id nextdowngml_id 
FROM alt_insp.watercourselink w 
JOIN alt_insp.watercourselink w2 
ON w.endnode=w2.startnode 
JOIN div d 
on w.gml_id = d.gml_id 
WHERE d.isinlandoutlet)
UPDATE div d
SET nextdowngml_id = tt.nextdowngml_id
FROM tt
WHERE d.gml_id = tt.gml_id;
 
/* -- CHECK SEGMENTS THAT DON´T HAVE A NEXTDOWNIDSEGMENT
CREATE MATERIALIZED VIEW worksweden.non_nextdownid AS
SELECT *
FROM alt_insp.watercourselink w 
WHERE gml_id IN
(SELECT gml_id
FROM
div d
WHERE d.isinlandoutlet
EXCEPT
SELECT gml_id --218
FROM
(SELECT w.gml_id, w2.gml_id nextdowngml_id
FROM alt_insp.watercourselink w 
JOIN alt_insp.watercourselink w2 
ON w.endnode=w2.startnode 
JOIN div d 
on w.gml_id = d.gml_id 
WHERE d.isinlandoutlet) A)

 CREATE MATERIALIZED VIEW alt_insp.inland_outlet AS
 SELECT w.*
 FROM alt_insp.watercourselink w 
 JOIN div d 
 ON w.gml_id=d.gml_id
 WHERE d.isinlandoutlet;
 
 CREATE MATERIALIZED VIEW worksweden.divergence AS
SELECT w.*, d.divergence
FROM
alt_insp.watercourselink w 
JOIN 
div d 
ON w.gml_id=d.gml_id
WHERE d.divergence IN (1,2);

SELECT COUNT(*)
FROM 
worksweden.rn

CREATE MATERIALIZED VIEW alt_insp.non_nextdowngml_id AS 
SELECT w.*
FROM
alt_insp.watercourselink w
JOIN div d
ON w.gml_id = d.gml_id
WHERE d.nextdowngml_id='';

SELECT COUNT(*) --5258
FROM div 
WHERE nextdowngml_id=''

SELECT COUNT(*) --5029
FROM 
alt_insp.watercourselink w 
WHERE issea 

SELECT COUNT(*) --229
FROM div
WHERE isinlandoutlet; 

SELECT 5258-5029 --229(number of segments with no nextdownidsegments but are not sea outlets)
*/


-- populate rn table
WITH tt AS
(SELECT wrn1.idsegment, wrn2.idsegment nextdownidsegment 
FROM worksweden.rn wrn1
JOIN div d
ON wrn1.gml_id = d.gml_id
JOIN worksweden.rn wrn2
ON d.nextdowngml_id=wrn2.gml_id)
UPDATE worksweden.rn wrn 
SET nextdownidsegment = tt.nextdownidsegment
FROM tt
WHERE wrn.idsegment = tt.idsegment; 

------------------------
-- Add isinlandoutlet --
------------------------
UPDATE worksweden.rn wrn 
SET isinlandoutlet = d.isinlandoutlet
FROM div d
WHERE wrn.gml_id = d.gml_id; 

-----------------------------
-- manually update one row --
-----------------------------

UPDATE worksweden.rn wrn
SET issea=TRUE 
WHERE gml_id='SE.LM.HY.fb6661ad-3ec8-479c-a779-ffbdbb6e098d'

-----------------
-- Obtain path --
-----------------

-- This column is found using routing algorithm in R

------------------------
-- Vacuum clean table --
------------------------
VACUUM FULL worksweden.rn;
--------------------------------------------------
-- Add indexes and constraints on worksweden.rn --
--------------------------------------------------
CREATE INDEX indexcountry ON worksweden.rn USING btree (country);
CREATE INDEX indexidsegmentrrn ON worksweden.rn USING btree (idsegment);
CREATE INDEX indexnextdownidsegmentrrn ON worksweden.rn USING btree (nextdownidsegment);
CREATE INDEX indexsourcern ON worksweden.rn USING btree (source);
CREATE INDEX indextargetrn ON worksweden.rn USING btree (target);
CREATE INDEX rn_geom_ix ON worksweden.rn USING gist (geom);
--alter table worksweden.rn add constraint c_pk_idsegment primary key(idsegment);


-----------------------
-- change schema name -
-----------------------

ALTER SCHEMA worksweden RENAME TO sweden;

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- 						Commented code not used at the moment							   --
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------


---------------------------------------
-- Work on fork segments
--
/* 
CREATE VIEW rawdata.temp_fork AS (
SELECT 
srn.geom 
FROM
sweden.rn srn
WHERE 
"source" IN
(SELECT "source"
FROM 
sweden.rn
GROUP BY "source" HAVING COUNT(*) > 1)
)
*/

---------------------------------
-- make correction to issource --
---------------------------------
-- 
-- Correcting issource in order to make strahler and shreeve order calculations in R.
-- As the river network has been restructured to not include loops (only one nextdownidsegment)
-- we also need to change the issource column. Segments that are connected to the network and do 
-- not have any nextdownidsegments are considered issource segments.    
/*
with sourcesegment as ( -- new issourcesegments
select idsegment
from 
sweden.rn r1
where nextdownidsegment is not null -- segments that are connected to other segments
except 
select nextdownidsegment 
from 
sweden.rn r2 
where nextdownidsegment is not null)
UPDATE sweden.rn srn
SET issource  = true
FROM sourcesegment ss 
WHERE srn.idsegment = ss.idsegment;
*/



/*
-- Routing algorithm in R uses frontiersegment when calculating path. 
-- Therefore, path is null for non swedish riversegments. Those are however part of the network. Thus, include those as
-- part of network 
update worksweden.rn 
set isendoreic = false
where country in ('NO','FI');
*/

/*
---------------------------
---------------------------
-- obtain nextdownidsegment 
--
-- The hydrographic network forks both upstream and downstream. The dbeel.rivernetwork branches only from the sea to the source.
-- Therefore, we create a network which branches upstreams only. To this end, we create three subtables and merge them:
-- 1. segments_within_linksequence - segments where both upstream and downstream segments belong to the same sequence. 
-- 2. segments_connecting_linksequences - selects shortest downstream segment of all possible downstream segments from a given segment that is not part of segments_within_linksequence
-- 										  					  

--------------------------------------------------
-- Create subtable segments_within_linksequence --
--------------------------------------------------

-- Unfortunately, for some of the raw data (watercourselink and watercourselinksequence) there
-- are rounding differences in those two tables. Therefore, we can not simply join those two tables
-- using a spatial join (ST_Intersection). Geometries are therefore rounded as a first step. 
create temporary table temp_watercourselink as
select w.*, ST_ReducePrecision(centrelinegeometry, 0.1) round_geom
from rawdata.watercourselink_altered w;

create temporary table temp_watercourselinksequence as
select w.*, ST_ReducePrecision(wkb_geometry, 0.1) round_geom
from rawdata.watercourselinksequence  w;

-- Create spatial indexes on temporary tables
CREATE INDEX round_geom_WL_idx ON temp_watercourselink USING gist (round_geom);
CREATE index round_geom_WLS_idx on temp_watercourselinksequence using gist (round_geom);

-- create a table that links watercourse link and watercourse link sequence, i.e. which links are withing sequences.
drop table if exists join_watercourse_link_sequence; 
Create temporary table join_watercourse_link_sequence AS
select w.idsegment idsegment, w2.ogc_fid idsequence --  w2.centrelinegeometry segment, w.wkb_geometry "sequence", 
from 
temp_watercourselink w
left join temp_watercourselinksequence w2 on 
ST_covers(w2.round_geom, w.round_geom); 

CREATE INDEX on join_watercourse_link_sequence(idsegment);
CREATE INDEX on join_watercourse_link_sequence(idsequence);

-- check for duplicates
select idsegment, count(*)
from join_watercourse_link_sequence jwls 
group by idsegment
HAVING count(*) > 1;

-- remove one watercourselinksequence which contains another watercourselinksequence(idsequence=304949)[this is error in the raw data]
delete from
join_watercourse_link_sequence
where idsequence =304949
returning *;

SELECT 
*
FROM 
join_watercourse_link_sequence;

-- investigate segments where idsequences are null
drop table if exists tempor;
create temporary table tempor as
select centrelinegeometry, w.idsegment 
from 
rawdata.watercourselink_altered w 
left join
join_watercourse_link_sequence jwls
on w.idsegment = jwls.idsegment
where jwls.idsequence is null;

-- connect segments and sequences where there is a mismatch (Note! there is no watercourselinksequence associated to segment SW1313372)
drop table if exists updated_watercourselinksequences;
create table updated_watercourselinksequences as
with A as(
select *, st_length(st_intersection(t.centrelinegeometry,w.wkb_geometry)) L
from
tempor t
join
rawdata.watercourselinksequence w on 
ST_DWithin(t.centrelinegeometry,w.wkb_geometry,0.1)
order by t.idsegment, L desc)
select distinct on (idsegment) idsegment, ogc_fid 
from A;

-- add missing sequences to join_watercourse_link_sequence 
update join_watercourse_link_sequence jwls
set idsequence = uw.ogc_fid
from updated_watercourselinksequences uw
where jwls.idsegment = uw.idsegment; 

-- Find segments that belong to watecourselinksequences(1098749 segments) 
drop table if exists segments_within_linksequence;
create table segments_within_linksequence as
select w.centrelinegeometry , w.idsegment, w2.idsegment nextdownidsegment 
from
rawdata.watercourselink_altered w 
left join
rawdata.watercourselink_altered w2 on w.target_node = w2.source_node
left join
join_watercourse_link_sequence jwls on w.idsegment = jwls.idsegment
left join 
join_watercourse_link_sequence jwls2 on w2.idsegment = jwls2.idsegment
where jwls.idsequence=jwls2.idsequence;


-- delete single row with 2 nextdownidsegments
DELETE FROM segments_within_linksequence 
where nextdownidsegment ='SW1313717';

select *
from rawdata.watercourselink_altered wa 
where wa.idsegment in (select nextdownidsegment as idsegment
from segments_within_linksequence
group by nextdownidsegment having (count(*) >1));

-------------------------------------------------------
-- Create subtable segments_connecting_linksequences --
-------------------------------------------------------
-- To speed up calculations two temporary tables with indexes are created (1. nexsegment_not_in_seq; 2. joined_data)
--

-- creat temporary table 1
drop table if exists nextsegment_not_in_seq;
create temporary table nextsegment_not_in_seq as
select a.idsegment  
from (
select 
w3.idsegment
from
rawdata.watercourselink_altered w3
except 
select idsegment
from
segments_within_linksequence) a

create index idx_idsegment on nextsegment_not_in_seq(idsegment); -- add index to speed up data base

-- creat temporary table 2
drop table if exists joined_data;
create temporary table joined_data as
select 
w5.idsegment, 
w6.idsegment nextdownidsegment,
w5.centrelinegeometry,
w6.centrelinegeometry nextdowngeometry,
w6."length" 
from
nextsegment_not_in_seq
left join rawdata.watercourselink_altered w5 on nextsegment_not_in_seq.idsegment = w5.idsegment
left join rawdata.watercourselink_altered w6 on w5.target_node = w6.source_node;

create index idx_idsegment_jd on joined_data(idsegment); -- add index to speed up data base
create index idx_nextdownidsegment on joined_data(nextdownidsegment); -- add index to speed up data base
 
-- Find segments where segments don�t belong to the same sequence (choose the shortest downstream segment)
drop table if exists segments_connecting_linksequences;
create temporary table segments_connecting_linksequences as
WITH groups AS (
SELECT idsegment,
nextdownidsegment,
"length"
      ,ROW_NUMBER() OVER (
                     PARTITION BY idsegment 
                     ORDER BY "length" ASC
         	   ) AS rownb
  FROM joined_data jd 
  )
SELECT * FROM groups
WHERE groups.rownb = 1;

select count(*)
from segments_connecting_linksequences s
where s.nextdownidsegment is null;

select count(*)
from segments_within_linksequence s
where s.nextdownidsegment is not null;

----------------------------------------------------------------------------------------
-- Merge temporary tables and insert nextdownidsegment in worksweden.rn               -- 
-- Warning!! This code is slow                                                        --
----------------------------------------------------------------------------------------
drop table if exists temp_nextdownidsegment;
create table temp_nextdownidsegment as
select idsegments_seq.*, wa.centrelinegeometry idseg_geom, wa2.centrelinegeometry nextidseg_geom 
from
(select idsegment, nextdownidsegment 
from 
segments_within_linksequence swl 
union
select idsegment, nextdownidsegment   
from segments_connecting_linksequences) idsegments_seq
left join watercourselink_altered wa on idsegments_seq.idsegment=wa.idsegment
left join watercourselink_altered wa2 on idsegments_seq.nextdownidsegment=wa2.idsegment;  
create index temp_idsegmentidx on temp_nextdownidsegment(idsegment);
update worksweden.rn ws
set nextdownidsegment = tn.nextdownidsegment 
FROM temp_nextdownidsegment tn 
where  ws.idsegment=tn.idsegment
;
 
select count(*) 
from 
temp_nextdownidsegment tn 
group by idsegment having(count(*) >1)

select count(*)
from
temp_isseasegm ti 
-- delete all temporary tables from database
-- We do not want an overabundance of tables in the database
drop table temp_watercourselink;
drop table temp_watercourselinksequence;
drop table tempor;
drop table nextsegment_not_in_seq;
drop table join_watercourse_link_sequence;
drop table updated_watercourselinksequences;
drop table segments_connecting_linksequences;
drop table segments_connected_multiple_hydronode;
drop table temp_nextdownidsegment;

-------------------------------------------------------
-------------------------------------------------------
-- end of massive code for updating nextdownidsegment--
-------------------------------------------------------
------------------------------------------------------ 
*/

