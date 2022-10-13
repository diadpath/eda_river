

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

-- obtain nextdownidsegment
select count(*)
from 
watercourselink w,
 (select * from watercourselinksequence limit 10) w2 where 
ST_intersects(w.centrelinegeometry,w2.wkb_geometry) and w.centrelinegeometry && w2.wkb_geometry; 

select count(*)
from 
watercourselink w
inner join (select * from watercourselinksequence limit 10) w2 on 
ST_intersects(w.centrelinegeometry,w2.wkb_geometry); 

select 
count(*)
from 
watercourselink w ;

select 
count(*)
from 
watercourselink w
left join watercourselink w2 on w.endnode_localid=w2.startnode_localid;


-- update country column
select 
case 
when w."namespace" = 'SE.LM.HY.NVE' then 'NO'
when w."namespace" = 'SE.LM.HY.SYKE' then 'FI'
when w."namespace" = 'SE.LM.HY' then 'SW'
end 
as country
from watercourselink w;


-- obtain isfrontier
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

country<>nextcountry as isfrontier, -- the country of the current segment is not the same as the country of the next segment


where country<>nextcountry
--order by isfrontier desc
;





-- obtain isfrontier


null isfrontier, 
null issource, 
null seaidsegment,
null issea,
st_multi(st_transform(w.centrelinegeometry,3035)) geom,
null isendoreic, 
null isinternational, 
'SW' country
FROM watercourselink w 
JOIN  hydronode s on startnode=s.gml_id 
JOIN hydronode e on endnode=e.gml_id;

/* 
 * find nextdownidsegment ~1700 nulls
 */
select
down."idsegment" as nextdownidsegment 
from worksweden.rn up
left join worksweden.rn down on down."source"=up.target;


/*
 * play around code
 */
 select
 localid  
 from 
 watercourselink w 
 limit 30;



