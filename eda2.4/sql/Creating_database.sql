

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
startnode text,
	CONSTRAINT c_pk_rnidsegment PRIMARY KEY (idsegment)
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
"path", 
isfrontier, 
issource, 
seaidsegment, 
issea, 
geom, 
isendoreic, 
isinternational, 
country)


WITH rn0 AS (
SELECT  
w.fictitious fictitious,
w.innetwork innetwork,
w.relatedhydroobject relatedhydroobject,
w.endnode endnode,
w.startnode startnode,
w.ogc_fid gid,
'SW' || w.localid idsegment, 
s.ogc_fid as source,
e.ogc_fid as target,
w."length" lengthm
FROM watercourselink w 
JOIN  hydronode s on startnode=s.gml_id 
JOIN hydronode e on endnode=e.gml_id
)
--SELECT * FROM rn0

SELECT
down."idsegment" as nextdownidsegment 
from rn0 up
left join rn0 down on down."source"=up.target;



,
null nextdownidsegment, 
null "path", 
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
 



