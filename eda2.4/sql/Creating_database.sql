

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
CREATE INDEX indexcountry ON worksweden.rn USING btree (country);
CREATE INDEX indexidsegmentrrn ON worksweden.rn USING btree (idsegment);
CREATE INDEX indexnextdownidsegmentrrn ON worksweden.rn USING btree (nextdownidsegment);
CREATE INDEX indexsourcern ON worksweden.rn USING btree (source);
CREATE INDEX indextargetrn ON worksweden.rn USING btree (target);
CREATE INDEX rn_geom_ix ON worksweden.rn USING gist (geom);
alter table worksweden.rn add constraint c_pk_idsegment primary key(idsegment);

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
lengthm
)
select  
w.fictitious,
w.innetwork,
w.relatedhydroobject,
w.endnode_localid,
w.startnode_localid,
w.ogc_fid,
w.idsegment,
s.ogc_fid, 
s2.ogc_fid, 
w."length"
from 
watercourselink w
left join watercourselink w2 on w.endnode_localid = w2.startnode_localid
left JOIN  hydronode s on w.startnode_localid=s.localid 
left JOIN  hydronode s2 on w.endnode_localid=s2.localid;

-- obtain target and source
select
w.centrelinegeometry, 
s.ogc_fid as "source",
s2.ogc_fid as target
FROM watercourselink w 
left JOIN  hydronode s on w.startnode_localid=s.localid 
left JOIN  hydronode s2 on w.endnode_localid=s2.localid
limit 1;


------------------------------
-- obtain nextdownidsegment --
------------------------------

-- create temporary table with rounded coordinates 
create table temp_watercourselink as
select w.*, ST_ReducePrecision(centrelinegeometry, 0.1) round_geom
from watercourselink w;

create table temp_watercourselinksequence as
select w.*, ST_ReducePrecision(wkb_geometry, 0.1) round_geom
from watercourselinksequence  w;

-- Create spatial indexes
CREATE INDEX round_geom_WL_idx ON temp_watercourselink USING gist (round_geom);
CREATE index round_geom_WLS_idx on temp_watercourselinksequence using gist (round_geom);

-- create a table that links watercourse link and watercourse link sequence
drop table if exists join_watercourse_link_sequence; 
Create table join_watercourse_link_sequence AS
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
HAVING count(*) > 1

-- remove one watercourselinksequence contains another watercourselink sequence(idsequence=304949)
delete from
join_watercourse_link_sequence
where idsequence =304949
returning *;

-- investigate segments where idsequences are null
create table tempor as
select centrelinegeometry, w.idsegment 
from 
watercourselink w 
left join
join_watercourse_link_sequence jwls
on w.idsegment = jwls.idsegment
where jwls.idsequence is null;

-- connect segments and sequences where there is a mismatch(there is no watercourselinksequence associated to segment SW1313372)
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

-- obtain nextdownidsegment
select distinct (w.idsegment, w2.idsequence)
/*w.idsegment idsegment, 
w2.idsegment nextdownidsegment,
jwls.idsequence idsequence,
jwls2.idsequence nextidsequence
*/
w.centrelinegeometry, w2.centrelinegeometry  
from
watercourselink w 
left join
watercourselink w2 on w.endnode_localid = w2.startnode_localid
left join
join_watercourse_link_sequence jwls on w.idsegment = jwls.idsegment
left join 
join_watercourse_link_sequence jwls2 on w2.idsegment = jwls2.idsegment

group by  
where jwls.idsequence=jwls2.idsequence or ;


select idsegment, count(*)
from join_watercourse_link_sequence jwls 
group by idsegment
HAVING count(*) > 1

select 
count(*)
from
watercourselink w 
left join 
watercourselink w2 on w.endnode_localid = w2.startnode_localid
group by 

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
create table worksweden.frontier(country text, nextcountry text, isfrontier boolean, centerlinegeometry geometry);
insert into worksweden.frontier(country, nextcountry, isfrontier, centerlinegeometry)
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
w.centrelinegeometry
from 
watercourselink w
left JOIN  watercourselink w2 on w.endnode_localid =w2.startnode_localid)
select 
country, 
nextcountry, 
country <> nextcountry as isfrontier,
centrelinegeometry
from tt
where country<>nextcountry;

-----------------------------
------------------------------


------------
-- obtain --
-------------

