

-- sweden.rn definition

-- Drop table

-- DROP TABLE sweden.rn;

/*
 Creation of the sweden.rn table 
 */

/*
drop table if exists sweden.rn;
CREATE TABLE sweden.rn (fictitious boolean,
innetwork int4,
	CONSTRAINT c_pk_rnidsegment PRIMARY KEY (idsegment)
)
INHERITS (dbeel_rivers.rn);
CREATE INDEX indexcountry ON sweden.rn USING btree (country);
CREATE INDEX indexidsegmentrrn ON sweden.rn USING btree (idsegment);
CREATE INDEX indexnextdownidsegmentrrn ON sweden.rn USING btree (nextdownidsegment);
CREATE INDEX indexsourcern ON sweden.rn USING btree (source);
CREATE INDEX indextargetrn ON sweden.rn USING btree (target);
CREATE INDEX rn_geom_ix ON sweden.rn USING gist (geom);
*/

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
from watercourselink_altered w;

create temporary table temp_watercourselinksequence as
select w.*, ST_ReducePrecision(wkb_geometry, 0.1) round_geom
from watercourselinksequence  w;

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

-- investigate segments where idsequences are null
drop table if exists tempor;
create temporary table tempor as
select centrelinegeometry, w.idsegment 
from 
watercourselink_altered w 
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
watercourselinksequence w on 
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
watercourselink_altered w 
left join
watercourselink_altered w2 on w.target_node = w2.source_node
left join
join_watercourse_link_sequence jwls on w.idsegment = jwls.idsegment
left join 
join_watercourse_link_sequence jwls2 on w2.idsegment = jwls2.idsegment
where jwls.idsequence=jwls2.idsequence;

-- delete single row with 2 nextdownidsegments
DELETE FROM segments_within_linksequence 
where nextdownidsegment ='SW1313717';

select *
from watercourselink_altered wa 
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
watercourselink_altered w3
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
left join watercourselink_altered w5 on nextsegment_not_in_seq.idsegment = w5.idsegment
left join watercourselink_altered w6 on w5.target_node = w6.source_node;

create index idx_idsegment_jd on joined_data(idsegment); -- add index to speed up data base
create index idx_nextdownidsegment on joined_data(nextdownidsegment); -- add index to speed up data base
 
-- Find segments where segments don´t belong to the same sequence (choose the shortest downstream segment)
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

-----------------------
-- obtain isfrontier --
-----------------------
drop table if exists worksweden.frontier;
create table worksweden.frontier as
--insert into worksweden.frontier(idsegment, country, nextcountry, isfrontier, centerlinegeometry)
with tt as (select  
case 
when w."namespace" = 'SE.LM.HY.NVE' then 'NO'
when w."namespace" = 'SE.LM.HY.SYKE' then 'FI'
when w."namespace" = 'SE.LM.HY' then 'SW'
end as country,
case 
when w2."namespace" = 'SE.LM.HY.NVE' then 'NO'
when w2."namespace" = 'SE.LM.HY.SYKE' then 'FI'
when w2."namespace" = 'SE.LM.HY' then 'SW' 
end as nextcountry,
w.centrelinegeometry,
w.idsegment 
from 
watercourselink_altered w
left JOIN  watercourselink_altered w2 on w.target_node = w2.source_node)
select wa.idsegment, B.idsegment is not null isfrontier
from watercourselink_altered wa 
left join
(select distinct
idsegment--,
--country, 
--nextcountry, 
--country <> nextcountry as isfrontier--,
--centrelinegeometry
from tt
where country <> nextcountry) B 
on wa.idsegment = B.idsegment;
-----------------------------
------------------------------

---------------------
-- obtain issource --
---------------------
--
-- Use the difference in subsets of sourcenodes and targetnodes to find issource (the sources of the rivernetwork) 
drop table if exists temp_issource;
create table temp_issource as 
select wa.idsegment, wa.source_node = unique_source_nodes.source_node is not null issource 
from watercourselink_altered wa 
left join 
(select source_node
from watercourselink_altered wa 
except
select target_node
from watercourselink_altered wa2) unique_source_nodes on wa.source_node=unique_source_nodes.source_node;

------------------------------
------------------------------

-------------------------
-- obtain seaidsegment --
-------------------------
--
-- Find segments connected to the sea. 
-- These segments are found by connecting coastlines from Topografi 10(Lantmäteriet) spatially
-- with segments in watercourse link. First create temporary table temp_coastline. Second,
-- make a spatial join between endnodes of segments from watercourselink and linestrings from 
-- temp_coastline.  
drop table if exists temp_coastline; -- temporary coastline table
create table temp_coastline as
select *
from 
markkantlinje m
where objekttyp in ('Strandlinje, hav','Stängning mot hav');
CREATE INDEX geom_coast_idx ON temp_coastline USING gist (geom);


drop table if exists temp_seasegm; -- table with identifier of most downstream segments
create table temp_seasegm as
select
w2.idsegment,
isseasegments.idsegment is not null seasegment
from watercourselink_altered w2
left join
(select distinct
w.idsegment 
from
watercourselink_altered w
inner join temp_coastline tc
on ST_DWithin(ST_EndPoint(w.centrelinegeometry),tc.geom,0.5)) isseasegments 
on w2.idsegment = isseasegments.idsegment;

-- add a couple of segments that are not connected to the coastline (+ three segments with outlet in Norway and one segment in Finland)
UPDATE temp_seasegm 
set seasegment=TRUE
where idsegment in ('NO295503','NO594799','NO303497', 'SW281783', 'SW104625', 'SW55909', 
                    'SW1470756', 'SW1433168', 'SW1327170', 'SW1287247', 'SW1259769', 
                    'SW1261581', 'SW899227', 'SW494318', 'SW493639', 'FI53463')

---------------------------------------------
---------------------------------------------

------------------------------
-- create schema worksweden --
------------------------------                   
create schema worksweden;
DROP TABLE IF EXISTS worksweden.rn;
CREATE TABLE worksweden.rn (fictitious boolean,
innetwork int4,
CONSTRAINT c_pk_rnidsegment PRIMARY KEY (idsegment),
UNIQUE (gid)
)
INHERITS (dbeel_rivers.rn);

-------------------------------
-------------------------------

----------------------------------
-- populate worksweden.rn table --
----------------------------------

insert into worksweden.rn (
fictitious,
innetwork,
gid,
idsegment,
"source", 
target, 
lengthm,
nextdownidsegment, 
--"path", 
isfrontier, 
issource, 
seaidsegment, 
issea, 
geom, 
isendoreic, 
isinternational, 
country
)
select  
w.fictitious,
w.innetwork,
w.ogc_fid,
w.idsegment,
w.source_node,
w.target_node,
w."length",
tn.nextdownidsegment,
--w."path",
wsf.isfrontier,
ti.issource,
ts.seasegment, -- this is the id of the segment that is closest to sea
ts.seasegment,
st_multi(st_transform(w.centrelinegeometry,3035)), 
w.innetwork=1,
null as isinternational,
case 
when w."namespace" = 'SE.LM.HY.NVE' then 'NO'
when w."namespace" = 'SE.LM.HY.SYKE' then 'FI'
when w."namespace" = 'SE.LM.HY' then 'SW'
end 
as country
from 
watercourselink_altered w
left join temp_nextdownidsegment tn on w.idsegment=tn.idsegment
left join worksweden.frontier wsf on w.idsegment=wsf.idsegment
left join temp_issource ti on w.idsegment =ti.idsegment 
left join temp_seasegm ts on w.idsegment = ts.idsegment;

-- Add indexes and constraints on worksweden.rn 
CREATE INDEX indexcountry ON worksweden.rn USING btree (country);
CREATE INDEX indexidsegmentrrn ON worksweden.rn USING btree (idsegment);
CREATE INDEX indexnextdownidsegmentrrn ON worksweden.rn USING btree (nextdownidsegment);
CREATE INDEX indexsourcern ON worksweden.rn USING btree (source);
CREATE INDEX indextargetrn ON worksweden.rn USING btree (target);
CREATE INDEX rn_geom_ix ON worksweden.rn USING gist (geom);
--alter table worksweden.rn add constraint c_pk_idsegment primary key(idsegment);

                    
---------------------------------------------
-- Make corrections to worksweden.rn table --                    
---------------------------------------------
UPDATE worksweden.rn 
set nextdownidsegment='SW1427948', target=109925, "source"=738556
where idsegment='SW1427968';

UPDATE worksweden.rn 
set nextdownidsegment='SW1428344'
where idsegment ='SW1428627';

update worksweden.rn
set nextdownidsegment='SW1428344', issource =FALSE
where idsegment='SW1428628';

update worksweden.rn 
set nextdownidsegment ='SW1428752', target= 1388762,"source"= 383636
where idsegment='SW1428344';

update worksweden.rn 
set nextdownidsegment ='SW1428752', target= 1388762,"source"= 383636
where idsegment='SW1428344';

update worksweden.rn 
set issource =false 
where idsegment ='SW1430784';

update worksweden.rn
set nextdownidsegment ='SW1430784', target=749043, "source"=1315449
where idsegment = 'SW1365662';

update worksweden.rn
set nextdownidsegment ='SW73173', target= 174562
where idsegment = 'SW73215';

update worksweden.rn
set issource = FALSE
where idsegment = 'SW73173';

delete from worksweden.rn 
where idsegment in ('SW59162', 'SW70394');

update worksweden.rn 
set nextdownidsegment ='SW58220';

update worksweden.rn 
set nextdownidsegment = 'SW1286686', target=1252912
where idsegment ='SW1319904';

update worksweden.rn 
set nextdownidsegment ='SW1292319', target = 717053
where idsegment='SW1290543';

update worksweden.rn
set nextdownidsegment='SW1287157', "source"=813749, target = 473488
where idsegment='SW1280991';

update worksweden.rn
set target=404171, nextdownidsegment='SW1268433'
where idsegment='SW1268611';

update worksweden.rn 
set issource=FALSE
where idsegment ='SW1268433';

update worksweden.rn 
set nextdownidsegment = 'SW1222197', target = 683859, "source"=716701
where idsegment='SW1221484';

update worksweden.rn 
set nextdownidsegment ='SW1221484', issource=FALSE
where idsegment='SW1219998';


--------------------------
-- obtain seaidsegment  --
--------------------------
-- warning!! this is superslow 7-8 hours
-- This code-snippet also needs worksweden.rn
--

drop table if exists temp_seaidsegment;
create table temp_seaidsegment as
select worksweden.upstream_segments_rn(isseaidsegment.idsegment) idsegment, isseaidsegment.idsegment isseaidsegment
from (select idsegment  
from worksweden.rn rn0
where issea) isseaidsegment;

-- insert seaidsegment in worksweden.rn 
UPDATE worksweden.rn wsrn
SET seaidsegment  = ts.isseaidsegment
FROM temp_seaidsegment ts 
WHERE wsrn.idsegment = ts.idsegment;

-----------------
-- obtain path --
-----------------


