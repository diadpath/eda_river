
select count(*) from 
lst_obstacles lo 




select count(*)
from
(SELECT array_agg(localid) over (partition by geometry order by geometry) all_localid, dense_rank() over (order by geometry) node
FROM hydronode) a
group by array_length(a.all_localid,1)

/*
|ogc_fid|gml_id|beginlifespanversion|localid|namespace|innetwork|hydronodecategory|geometry|node_id|all_localids|
|-------|------|--------------------|-------|---------|---------|-----------------|--------|-------|------------|
|287336|SE.LM.HY.f85f134f-df36-0032-8569-432f009e2d48|2015-12-04T07:49:15+01:00|f85f134f-df36-0032-8569-432f009e2d48|SE.LM.HY|||POINT (304139.889 6519233.771)|1187838|{f85f134f-df36-0032-8569-432f009e2d48}|
|287331|SE.LM.HY.61237f14-26c5-5e84-3cd5-402fba5f8757|2015-04-27T13:18:56+02:00|61237f14-26c5-5e84-3cd5-402fba5f8757|SE.LM.HY|||POINT (304253.976 6518053.509)|1187841|{61237f14-26c5-5e84-3cd5-402fba5f8757}|
|287301|SE.LM.HY.6b6bd385-2308-6fe9-80e9-01b37f9faca2|2015-04-27T13:18:56+02:00|6b6bd385-2308-6fe9-80e9-01b37f9faca2|SE.LM.HY|||POINT (304203.6 6513345.106)|1187858|{6b6bd385-2308-6fe9-80e9-01b37f9faca2}|
*/
select max(node_id), count(*)
from 
hydronode

select idsegment, nextdownidsegment 
from 
segments_within_linksequence swl 
union
select idsegment, nextdownidsegment 
from 
segments_connecting_linksequences scl
where nextdownidsegment is not null
union
select idsegment, nextdownidsegment 
from 
segments_connected_multiple_hydronode scmh

select count(*)
from 
segments_within_linksequence swl 
union
select count(*) 
from 
segments_connecting_linksequences scl
where nextdownidsegment is not null
union
select count(*) 
from 
segments_connected_multiple_hydronode scmh

select count(*)
from 
segments_connecting_linksequences scl
group by(streaming_rank)

select objekttyp, count(*)
from 
markkantlinje m
group by objekttyp;
/*
|objekttyp|count|
|---------|-----|
|Bebyggelseområdesgräns|143100|
|Begränsningslinje, ej karterat område|2754|
|Glaciärgräns|434|
|Industri- och handelsbebyggelsegräns|29782|
|Odlingsmarksgräns|2483267|
|Skogsmarksgräns|120504|
|Strandlinje, anlagt vatten|1845|
|Strandlinje, hav|186891|
|Strandlinje, sjö|1305815|
|Strandlinje, vattendragsyta|333503|
|Stängning|27828|
|Stängning mot hav|388|
|Öppen markgräns|3815408|
*/




select * from
nextsegment_not_in_seq
left join watercourselink w5 on nextsegment_not_in_seq.idsegment = w5.idsegment
left join watercourselink w6 on w5.endnode_localid = w6.startnode_localid;


select count(*) 
from (
select 
w3.idsegment
from
watercourselink w3
except 
select swl.idsegment
from
segments_within_linksequence swl
except
select scl.idsegment
from
segments_connecting_linksequences scl) a
group by idsegment having(count(*) >=1)

select count(*) -- (1111129)
from segments_within_linksequence swl 

select count(*) -- (360 340)
from segments_connecting_linksequences scl 

select count(*) -- (1471469)
from watercourselink w  

select idsegment
from (select idsegment, nextdownidsegment 
from segments_within_linksequence swl
union all
select idsegment, nextdownidsegment
from segments_connecting_linksequences scl) W
group by idsegment having(count(*) >1)

WITH groups AS (
SELECT rank() over (partition by idsegment order by st_length(nextgeometry)) as rownb,
*
from segments_connected_multiple_hydronode scmh)
select *
from groups
where rownb=1;

select *
from
mark
where objekttyp='Hav'

select count(*), max(node_id)
from hydronode_altered ha 


select count(*)
from
(select source_node
from watercourselink_altered wa 
except
select target_node
from watercourselink_altered wa2) a -- subset of sourcenodes that are not in the targetnode subset.
left join
watercourselink_altered wa3 on a.source_node=wa3.source_node;

select wa.idsegment, wa.source_node = unique_source_nodes.source_node is not null issource 
from watercourselink_altered wa 
left join 
(select source_node
from watercourselink_altered wa 
except
select target_node
from watercourselink_altered wa2) unique_source_nodes on wa.source_node=unique_source_nodes.source_node;


select
w2.idsegment,
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


select w.innetwork=1 
from watercourselink w
group by innetwo 

CREATE extension IF NOT EXISTS pgrouting
    WITH SCHEMA worksweden;

CREATE OR REPLACE FUNCTION worksweden.get_path(_from integer, _to integer, _country character varying)                           
  RETURNS SETOF ltree                                                                                                               
  LANGUAGE plpgsql                                                                                                                  
 AS $function$                                                                                                                    
 BEGIN                                                                                                                            
 RETURN QUERY                                                                                                                     
 SELECT text2ltree(string_agg(idsegment::text, '.')) AS gid_list                                                                  
 FROM (SELECT idsegment FROM pgr_dijkstra(                                                                                        
    'SELECT gid as id, source, target, st_length(geom) as cost FROM worksweden.rn where country='||quote_literal(_country),     
    _from,                                                                                                                        
    _to,                                                                                                                          
   FALSE                                                                                                                          
 )  pt                                                                                                                            
 JOIN worksweden.rn r ON pt.edge = r.gid where r.country = _country order by seq) sub;                                          
                                                                                                                                  
 END                                                                                                                              
 $function$;      


CREATE OR REPLACE FUNCTION worksweden.get_path(_from integer, _to integer)                           
  RETURNS SETOF ltree                                                                                                               
  LANGUAGE plpgsql                                                                                                                  
 AS $function$                                                                                                                    
 BEGIN                                                                                                                            
 RETURN QUERY                                                                                                                     
 SELECT text2ltree(string_agg(idsegment::text, '.')) AS gid_list                                                                  
 FROM (SELECT idsegment FROM pgr_dijkstra(                                                                                        
    'SELECT gid as id, source, target, lengthm as cost FROM worksweden.rn ',     
    _from,                                                                                                                        
    _to,                                                                                                                          
   TRUE                                                                                                                          
 )  pt                                                                                                                            
 JOIN worksweden.rn r ON pt.edge = r.gid order by seq) sub;                                          
                                                                                                                                  
 END                                                                                                                              
 $function$;      



/*
SELECT * FROM pgr_dijkstra(
  'select gid as id, source, target, lengthm as cost from worksweden.rn',
  702734, 1143560, true)
*/

 -- EXAMPLE OF USE
-- select worksweden.get_path (702734, 1143560),'SW')
-- SW1282915.SW1286283.SW1285130.SW1287839

CREATE OR REPLACE FUNCTION worksweden.upstream_segments_rn(text)
 RETURNS TABLE(_idsegment text)
 LANGUAGE plpgsql
AS $function$
BEGIN
RETURN QUERY
	WITH RECURSIVE parcours AS(
		SELECT
			r0.idsegment,
			r0.nextdownidsegment
		FROM
			worksweden.rn r0  
		WHERE
			r0.idsegment = $1
	       
	       
	       UNION SELECT
	           r1.idsegment,
	           r1.nextdownidsegment
		       
		FROM
			parcours
		JOIN worksweden.rn r1 
		ON  parcours.idsegment = r1.nextdownidsegment)
          SELECT idsegment FROM parcours;
END
$function$
;

drop table if exists temp_table;
create table temp_table as
--with temp_seaidsegment as (
select worksweden.upstream_segments_rn(isseaidsegment.idsegment) idsegment, isseaidsegment.idsegment isseaidsegment
from (select idsegment  
from worksweden.rn rn0
where issea) isseaidsegment;
--select wa.*
--from watercourselink_altered wa
--left join temp_seaidsegment ts on wa.idsegment = ts.idsegment 
--where ts.idsegment is null

select count(*)
from worksweden.rn;
select *
from temp_table;

select *
from watercourselink w
where st_length(centrelinegeometry)< 0.5; 

select *
from
worksweden.rn;

select st_startpoint(geom)
from worksweden.rn r
where idsegment ='SW1427968'