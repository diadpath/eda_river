

-- sweden.rn definition

-- Drop table

-- DROP TABLE sweden.rn;

/*
 Creation of the sweden.rn table 
 */

CREATE TABLE sweden.rn (fictitious boolean,
innetwork int4,
relatedhydroobject varchar NULL,
endnode text,
startnode text,
	CONSTRAINT c_pk_rnidsegment PRIMARY KEY (idsegment)
)
INHERITS (dbeel_rivers.rn);
CREATE INDEX indexcountry ON sweden.rn USING btree (country);
CREATE INDEX indexidsegmentrrn ON sweden.rn USING btree (idsegment);
CREATE INDEX indexnextdownidsegmentrrn ON sweden.rn USING btree (nextdownidsegment);
CREATE INDEX indexsourcern ON sweden.rn USING btree (source);
CREATE INDEX indextargetrn ON sweden.rn USING btree (target);
CREATE INDEX rn_geom_ix ON sweden.rn USING gist (geom);

/*
 Use tables public.hydronode and watercourselink to create start and end node ids  
 */

SELECT  
w.ogc_fid gid,
'SW' || w.localid idsegment, 
s.ogc_fid as source,
e.ogc_fid as target,
'SW' country
FROM watercourselink w 
JOIN  hydronode s on startnode=s.gml_id 
JOIN hydronode e on endnode=e.gml_id 
LIMIT 100;

/*
 * populate worksweden
 */

/*
insert into 
worksweden.rn(
fictitious,
innetwork,
relatedhydroobject,
endnode,
startnode,
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
country)
*/

--------------------------------
-- create worksweden.rn table --
--------------------------------
drop schema 
worksweden
cascade; 

create schema worksweden;

DROP TABLE IF EXISTS worksweden.rn;
CREATE TABLE worksweden.rn (fictitious boolean,
innetwork int4,
relatedhydroobject varchar NULL,
endnode text,
startnode text
)
INHERITS (dbeel_rivers.rn);

----------------------------------
-- populate worksweden.rn table --
----------------------------------


-- populate worksweden.rn 
insert into worksweden.rn (
fictitious,
innetwork,
relatedhydroobject,
endnode,
startnode,
gid,
idsegment,
"source", 
target, 
nextdownidsegment, 
--"path", 
isfrontier 
issource, 
--seaidsegment, 
--issea, 
--geom, 
--isendoreic, 
--isinternational, 
--country
)
select  
w.fictitious,
w.innetwork,
w.relatedhydroobject,
w.endnode_localid,
w.startnode_localid,
w.ogc_fid,
w.idsegment,
hm1.node_id,
hm2.node_id,
tn.nextdownidsegment,
--w."length",
wsf.isfrontier
from 
watercourselink w
left join temp_nextdownidsegment tn on w.idsegment=tn.idsegment
left join worksweden.frontier wsf on w.idsegment=wsf.idsegment
left join hydronode_merged hm1 on w.startnode_localid=any(hm1.all_localid) 
left join hydronode_merged hm2 on w.endnode_localid=any(hm2.all_localid) 
--left JOIN  hydronode s on w.startnode_localid=s.localid 
--left JOIN  hydronode s2 on w.endnode_localid=s2.localid;

-- Add indexes and constraints on worksweden.rn 
CREATE INDEX indexcountry ON worksweden.rn USING btree (country);
CREATE INDEX indexidsegmentrrn ON worksweden.rn USING btree (idsegment);
CREATE INDEX indexnextdownidsegmentrrn ON worksweden.rn USING btree (nextdownidsegment);
CREATE INDEX indexsourcern ON worksweden.rn USING btree (source);
CREATE INDEX indextargetrn ON worksweden.rn USING btree (target);
CREATE INDEX rn_geom_ix ON worksweden.rn USING gist (geom);
alter table worksweden.rn add constraint c_pk_idsegment primary key(idsegment);


---------------------------
---------------------------
-- obtain nextdownidsegment 
--
-- The hydrographic network forks both upstream and downstream. The dbeel.rivernetwork branches only from the sea to the source.
-- Therefore, we create a network which branches upstreams only. To this end, we create three subtables and merge them:
-- 1. segments_within_linksequence - segments where both upstream and downstream segments belong to the same sequence. 
-- 2. segments_connecting_linksequences - selects shortest downstream segment of all possible downstream segments from a given segment that is not part of segments_within_linksequence
-- 3. segments_connected_multiple_hydronode - some downstreamsegments in segments_connecting_linksequences do not have matching startnode and endnodes. 
---   									      For some of these multiple hydronodes are located on the same geographical position. Such occations are here connected through the hydronode_merged table.
											  					  

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
watercourselink_altered w2 on w.endnode_localid = w2.startnode_localid
left join
join_watercourse_link_sequence jwls on w.idsegment = jwls.idsegment
left join 
join_watercourse_link_sequence jwls2 on w2.idsegment = jwls2.idsegment
where jwls.idsequence=jwls2.idsequence;

-- delete single row with 2 nextdownidsegments
DELETE FROM segments_within_linksequence 
where nextdownidsegment ='SW1313717';

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

-----------------------------------------------------------
-- Create subtable segments_connected_multiple_hydronode --
-----------------------------------------------------------

-- This subtable includes all cases where nextdownidsegment in subtable segments_connecting_linksequences is null. 
-- For some of these cases startnode_localid and endnode_localid belongs to multiple hydronodes that are located 
-- in the same geographical position. Those cases are included in this table.   

/*
drop table if exists segments_connected_multiple_hydronode;
create temporary table segments_connected_multiple_hydronode as
with segm_nodes as -- connect multiple hydronodes to nextdown idsegments from segments_connecting_linksequences that are null
(select w.idsegment, w.centrelinegeometry,  multiple_nodes.all_localid
from
(select idsegment 
from segments_connecting_linksequences 
where nextdownidsegment is null) f -- idsegments where nextdownidsegment is null
left join watercourselink_altered w on f.idsegment=w.idsegment 
left join (select * from hydronode_altered h where array_length(all_localid,1)>1) multiple_nodes 
on w.endnode_localid = any(multiple_nodes.all_localid)
), 
segm_nodes_nextsegment as ( -- attach nextdownidsegments from watercourse link
select
rank() over (partition by segm_nodes.idsegment order by st_length(w2.centrelinegeometry)) as rownb,
segm_nodes.centrelinegeometry, 
w2.centrelinegeometry nextgeometry, 
segm_nodes.idsegment, 
w2.idsegment nextdownidsegment
from
segm_nodes
left join watercourselink_altered w2 on w2.startnode_localid =any(segm_nodes.all_localid)
)
select * -- select the shortest nextdownidsegments
from segm_nodes_nextsegment
where rownb=1;
*/

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


-- update country column
select 
case 
when w."namespace" = 'SE.LM.HY.NVE' then 'NO'
when w."namespace" = 'SE.LM.HY.SYKE' then 'FI'
when w."namespace" = 'SE.LM.HY' then 'SW'
end 
as country
from watercourselink w;

-----------------------
-- obtain isfrontier --
-----------------------
drop table if exists worksweden.frontier;
create table worksweden.frontier(idsegment text, country text, nextcountry text, isfrontier boolean, centerlinegeometry geometry);
insert into worksweden.frontier(idsegment, country, nextcountry, isfrontier, centerlinegeometry)
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
left JOIN  watercourselink_altered w2 on w.endnode_localid =w2.startnode_localid)
select 
idsegment,
country, 
nextcountry, 
country <> nextcountry as isfrontier,
centrelinegeometry
from tt
where country <> nextcountry;
-----------------------------
------------------------------


---------------------
-- obtain issource --
---------------------
--
-- Use the difference in subsets of sourcenodes and targetnodes to find issource (the sources of the rivernetwork) 
drop table if exists temp_issource;
create table temp_issource as 
select wa3.*
from
(select source_node
from watercourselink_altered wa 
except
select target_node
from watercourselink_altered wa2) a -- subset of sourcenodes that are not in the targetnode subset.
left join
watercourselink_altered wa3 on a.source_node=wa3.source_node;

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


drop table if exists temp_isseasegm; -- table including most downstream segments
create table temp_isseasegm as
select
w2.idsegment,
w2.centrelinegeometry, 
isseasegments.idsegment is not null
from watercourselink_altered w2
left join
(select distinct
w.idsegment 
from
watercourselink_altered w
inner join temp_coastline tc
on ST_DWithin(ST_EndPoint(w.centrelinegeometry),tc.geom,0.5)) isseasegments 
on w2.idsegment = isseasegments.idsegment
where isseasegments.idsegment is not null;



