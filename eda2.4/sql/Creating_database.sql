

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
 * testing
 */
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
--	CONSTRAINT c_pk_rnidsegment PRIMARY KEY (idsegment)
)
INHERITS (dbeel_rivers.rn);
CREATE INDEX indexcountry ON worksweden.rn USING btree (country);
CREATE INDEX indexidsegmentrrn ON worksweden.rn USING btree (idsegment);
CREATE INDEX indexnextdownidsegmentrrn ON worksweden.rn USING btree (nextdownidsegment);
CREATE INDEX indexsourcern ON worksweden.rn USING btree (source);
CREATE INDEX indextargetrn ON worksweden.rn USING btree (target);
CREATE INDEX rn_geom_ix ON worksweden.rn USING gist (geom);

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

-- obtain fictitious, innetwork, relatedhydroobject, endnode, startnode, gid, 
select 
w.fictitious fictitious,
w.innetwork innetwork,
w.relatedhydroobject relatedhydroobject,
w.endnode endnode,
w.startnode startnode,
w.ogc_fid gid
from 
watercourselink w;

-- obtain idsegment 
with t as(
select localid,
case 
when gml_id like 'SE.LM.HY.NVE%' then 'NO'
when gml_id like 'SE.LM.HY.SYKE%' then 'FI'
else 'SW' 
end 
as country
from watercourselink w)
select t.country || t.localid idsegment
from t;

 
drop table if exists worksweden.nodes;
create table worksweden.nodes(node_id varchar, node_id_int int4);

insert into worksweden.nodes(node_id, node_id_int)
select node_id, row_number () over() as node_id_int 
from
(select endnode as node_id 
from watercourselink
union
select startnode as node_id 
from watercourselink) t;

-- obtain target and source
select
w.centrelinegeometry, 
s.node_id_int  as "source",
e.node_id_int as target
FROM watercourselink w 
left JOIN  worksweden.nodes s on startnode=s.node_id  
left JOIN worksweden.nodes e on endnode=e.node_id
order by "source" asc;

-- obtain lengthm 
select 
"length"
from watercourselink w 

-- obtain nextdownidsegment
WITH rn0 AS (
SELECT  
w.endnode endnode,
w.startnode startnode, 
(case 
when w.gml_id like 'SE.LM.HY.NVE%' then 'NO'
when w.gml_id like 'SE.LM.HY.SYKE%' then 'FI'
else 'SW' 
end) || w.localid idsegment, 
s.node_id_int as "source",
e.node_id_int as target,
w."length" lengthm
FROM watercourselink w 
left JOIN  worksweden.nodes s on startnode=s.node_id  
left JOIN worksweden.nodes e on endnode=e.node_id 
)
select
down."idsegment" as nextdownidsegment
from rn0 up
left join rn0 down on down."source"=up.target;


-- obtain isfrontier
drop table if exists worksweden.frontier;
create table worksweden.frontier(centerlinegeometry geometry, isfrontier boolean, country text);
insert into worksweden.frontier(centerlinegeometry, isfrontier, country)
select 
centrelinegeometry, 
country<>nextcountry as isfrontier, -- the country of the current segment is not the same as the country of the next segment
country
from
(select 
(case 
when w."namespace" = 'SE.LM.HY.NVE' then 'NO'
when w."namespace" = 'SE.LM.HY.SYKE' then 'FI'
else 'SW' 
end) as country,
(case 
when w2."namespace" = 'SE.LM.HY.NVE' then 'NO'
when w2."namespace" = 'SE.LM.HY.SYKE' then 'FI'
else 'SW' 
end) as nextcountry,
w.centrelinegeometry
from 
watercourselink w
left JOIN  watercourselink w2  on w.endnode=w2.startnode) as rn0
where country<>nextcountry
--order by isfrontier desc
;




-- obtain country column
select gml_id, 
case 
when gml_id like 'SE.LM.HY.NVE%' then 'NO'
when gml_id like 'SE.LM.HY.SYKE%' then 'FI'
else 'SW'
end 
as country
from watercourselink w
order by country desc;



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
 



