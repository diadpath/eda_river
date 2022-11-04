
-- segments that belong to watecourselinksequences 
drop table if exists temp_downsegment;
create table temp_downsegment as
select w.centrelinegeometry , w.idsegment 
from
watercourselink w 
left join
watercourselink w2 on w.endnode_localid = w2.startnode_localid
left join
join_watercourse_link_sequence jwls on w.idsegment = jwls.idsegment
left join 
join_watercourse_link_sequence jwls2 on w2.idsegment = jwls2.idsegment
where jwls.idsequence=jwls2.idsequence

-- attached those segements that do not have a nextidsegment in the same sequence
drop table if exists missing_downsegment;
create table missing_downsegment as
with segments as (
select a.idsegment  
from (
select 
w3.idsegment
from
watercourselink w3
except 
select w.idsegment
from
watercourselink w 
left join
watercourselink w2 on w.endnode_localid = w2.startnode_localid
left join
join_watercourse_link_sequence jwls on w.idsegment = jwls.idsegment
left join 
join_watercourse_link_sequence jwls2 on w2.idsegment = jwls2.idsegment
where jwls.idsequence=jwls2.idsequence) a 
)
select distinct on (s.idsegment) *
from
(select 
w5.centrelinegeometry, w5.idsegment idsegment, w6.idsegment nextdownidsegment
from
segments
left join watercourselink w5 on segments.idsegment = w5.idsegment
left join watercourselink w6 on w5.endnode_localid = w6.startnode_localid) s 
order by s.idsegment; 

-- check how many of the missing_downsegment are null (676)
select count(*)
from missing_downsegment md 
where nextdownidsegment is null

-- attach nextdownidsegments where startnode and endnode can be part of multiple hydronodes
with S as
(select *
from
(select idsegment 
from missing_downsegment md 
where nextdownidsegment is null) f
left join watercourselink w on f.idsegment=w.idsegment 
left join (select * from hydronode h where array_length(all_localids,1)>1) b on w.endnode_localid = any(b.all_localids))
select count(*)--w2.idsegment 
from
S
left join watercourselink w2 on w2.startnode_localid =any(S.all_localids)
where w2.idsegment is not null
;

drop table if exists duplicate_nodes;
create table duplicate_nodes as
select w.centrelinegeometry geom_upstream, h.geometry geom_node, w2.centrelinegeometry geom_downstream, w.idsegment id_upstream, w2.idsegment id_downstream 
from
(select idsegment 
from missing_downsegment md 
where nextdownidsegment is null) f
left join watercourselink w on f.idsegment=w.idsegment 
left join hydronode h on w.endnode_localid = h.localid 
left join watercourselink w2 on w2.startnode_localid=any(h.all_localids)
where array_length(h.all_localids,1)>1; 

drop table if exists duplicate_nodes2;
create table duplicate_nodes2 as
select count(*)
from
(select h.geometry, array_agg(h.localid) 
  from hydronode h 
  left join hydronode h2 on ST_DWithin(h.geometry , h2.geometry, 1)
group by h.geometry) a

-- Selection of groups of localids
select array(select unnest(a.temp_localid) order by 1) as all_localid, row_number() over() node_id
from
(select
array_agg(h2.localid) temp_localid
FROM hydronode h
join hydronode h2 on ST_DWithin(h.geometry,h2.geometry,10)
group by h.localid) a
group by all_localid;

select max(node_id), count(*)
from hydronode h 