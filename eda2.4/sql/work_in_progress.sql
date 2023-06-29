
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


select distinct objekttyp
from sankmark;


create schema eda_gerem;
select count(*)
from sweden.rn r
where isfrontier;

select count(*)
from sweden.rn
where path is not null;

select issea, path, seaidsegment 
from sweden.rn 

select count(*)
from sweden.rn
where "path" is null;

vacuum analyse sweden.rn;

select count(*) from sweden.rn
where "path"is not null;

select count(*) from sweden.temp_rna_distance trd where path is not null

select nextdownidsegment, count(*)
from sweden.rn r 
group by nextdownidsegment 

CREATE VIEW sweden.distancesea AS
    SELECT s.geom, trd.distanceseam 
    FROM sweden.rn s
    left join sweden.temp_rna_distance trd
    on s.idsegment =trd.idsegment; 

select *
from worksweden.rn

select kategori, count(*)
from rawdata."LST_AtgarderIVatten_fiskvagar" laif  
group by kategori

drop view if exists sweden.temp_isendoreic;
create view sweden.temp_isendoreic as
(select *
from sweden.rn
where path is null);

select * 
from 
prota_inv_str_punkt pisp
where undid =477;



WITH raw_width as(
SELECT srn.idsegment, srn.geom, srna.shreeve, srna.strahler,
       CASE 
       WHEN rs.Lokalbre <> -9 THEN rs.Lokalbre
       WHEN rs.Lokalbre = -9 AND rs.Bredd <>-9 THEN rs.Bredd
       END width_ef, 
       pisp.breddmedel width_bk 
       FROM sweden.rn srn 
       LEFT JOIN sweden.rna srna 
       ON srn.idsegment=srna.idsegment
       LEFT JOIN rawdata.sers rs
       ON srn.idsegment=rs.idsegment
       LEFT JOIN rawdata.prota_inv_str_punkt pisp
       ON srn.idsegment=pisp.idsegment)
select   width_bk is not null, width_ef is not null, count(*) 
from raw_width rw
group by(width_bk is not null, width_ef is not null)
;
      
-- Full join query
WITH raw_width as(
SELECT srn.idsegment, srn.geom, srna.shreeve, srna.strahler,
       CASE 
       WHEN rs.Lokalbre <> -9 THEN rs.Lokalbre
       WHEN rs.Lokalbre = -9 AND rs.Bredd <>-9 THEN rs.Bredd
       END width_ef, 
       pisp.breddmedel width_bk 
       FROM sweden.rn srn 
       LEFT JOIN sweden.rna srna 
       ON srn.idsegment=srna.idsegment
       LEFT JOIN rawdata.sers rs
       ON srn.idsegment=rs.idsegment
       LEFT JOIN rawdata.prota_inv_str_punkt pisp
       ON srn.idsegment=pisp.idsegment),
     avg_width as(
SELECT idsegment, AVG(width_ef) width_ef, AVG(width_bk) width_bk
       FROM raw_width
       GROUP BY idsegment),
     width as (
select distinct on (rw.idsegment) rw.idsegment, rw.geom, rw.shreeve, aw.width_ef, aw. width_bk 
from 
raw_width rw
left join avg_width aw
on rw.idsegment=aw.idsegment)
select *
from width;


WITH raw_width as(
SELECT srn.idsegment, srn.geom, srna.shreeve, srna.strahler,
       CASE 
       WHEN rs.Lokalbre <> -9 THEN rs.Lokalbre
       WHEN rs.Lokalbre = -9 AND rs.Bredd <>-9 THEN rs.Bredd
       END width_ef, 
       pisp.breddmedel width_bk 
       FROM sweden.rn srn 
       LEFT JOIN sweden.rna srna 
       ON srn.idsegment=srna.idsegment
       LEFT JOIN rawdata.sers rs
       ON srn.idsegment=rs.idsegment
       LEFT JOIN rawdata.prota_inv_str_punkt pisp
       ON srn.idsegment=pisp.idsegment),
     avg_width as(
SELECT idsegment, AVG(width_ef) width_ef, AVG(width_bk) width_bk
       FROM raw_width
       GROUP BY idsegment),
     width as (
select distinct on (rw.idsegment) rw.idsegment, rw.geom, rw.shreeve, aw.width_ef, aw. width_bk 
from 
raw_width rw
left join avg_width aw
on rw.idsegment=aw.idsegment)


select count(*)
from sweden.rn r
where nextdownidsegment is not null


select count(*) -- 326430
from
sweden.rn r 
where issource


select count(*) -- 1176
from
sweden.rn r 
group by country; 
where nextdownidsegment is null and issource

select count(*) -- 325148
from 
issourcesegments
where issource

select count(*)
from 
issourcesegments

select count(*)
from
sweden.rna 
where strahler=0;

select count(*)
from 
sweden.rna r 
where shreeve =0;

select count(*) --18010
from 
(select * 
from 
rawdata.watercourse w 
where geometrytype(w.geometry)='POLYGON') as wc, rawdata.sers rs
where ST_Intersects(st_transform(rs.snapped_geom,3006),wc.geometry);

select count(*) --37096
from 
(select * 
from 
rawdata.watercourse w 
where geometrytype(w.geometry)='POLYGON') as wc, rawdata.prota_inv_str_punkt rs
where ST_Intersects(st_transform(rs.merged_geom,3006),wc.geometry);

select count(*) -- 52199
from
rawdata.sers;

select count(*) -- 101764
from rawdata.prota_inv_str_punkt pisp 

create table temp_table as 
WITH 
raw_width as(
SELECT srn.idsegment, srn.geom, srna.shreeve, srna.strahler, srna.basin,
       CASE 
       WHEN rs1.Lokalbre <> -9 THEN rs1.Lokalbre
       WHEN rs1.Lokalbre = -9 AND rs1.Bredd <>-9 THEN rs1.Bredd
       END width_ef, 
       rs2.breddmedel width_bk 
       FROM sweden.rn srn
       LEFT JOIN sweden.rna srna 
       ON srn.idsegment=srna.idsegment
       LEFT JOIN 
       (select *
       from 
       rawdata.sers
       except
       select rs.* 
		from 
		(select *
		from
		rawdata.watercourse w 
		where geometrytype(w.geometry)='POLYGON') as wc, rawdata.sers rs
		where ST_Intersects(st_transform(rs.snapped_geom,3006),wc.geometry)) as rs1
       on srn.idsegment=rs1.idsegment  
       left join
       (select *
       from 
       rawdata.prota_inv_str_punkt
       except
       select rs.* 
		from 
		(select *
		from
		rawdata.watercourse w 
		where geometrytype(w.geometry)='POLYGON') as wc, rawdata.prota_inv_str_punkt rs
		where ST_Intersects(st_transform(rs.merged_geom,3006),wc.geometry)) as rs2 
       ON srn.idsegment=rs2.idsegment), 
avg_width as(
SELECT idsegment, AVG(width_ef) width_ef, AVG(width_bk) width_bk
       FROM raw_width
       GROUP BY idsegment),
"width" as(
SELECT DISTINCT ON (rw.idsegment) rw.idsegment, rw.geom, rw.shreeve, rw.strahler, rw.basin, aw.width_ef, aw. width_bk 
FROM 
raw_width rw
LEFT JOIN avg_width aw
ON rw.idsegment=aw.idsegment)
SELECT *
FROM 
width;

drop table if exists rawdata.temp_width;
create table rawdata.temp_width as
WITH 
raw_width as(
SELECT srn.idsegment, srn.geom, srna.shreeve, srna.strahler, srna.basin,
       CASE 
       WHEN rs1.Lokalbre <> -9 THEN rs1.Lokalbre
       WHEN rs1.Lokalbre = -9 AND rs1.Bredd <>-9 THEN rs1.Bredd
       END width_ef, 
       rs2.breddmedel width_bk 
       FROM sweden.rn srn
       LEFT JOIN sweden.rna srna 
       ON srn.idsegment=srna.idsegment
       LEFT JOIN 
       (select *
       from 
       rawdata.sers
       except -- exclude Electrofishing points where we already have polygons
       select rs.* 
		from 
		(select *
		from
		rawdata.watercourse w 
		where geometrytype(w.geometry)='POLYGON') as wc, rawdata.sers rs
		where ST_Intersects(st_transform(rs.snapped_geom,3006),wc.geometry)) as rs1 -- points from electrofishing data were we do not have polygon data
       on srn.idsegment=rs1.idsegment -- OK  
       left join
       (select *
       from 
       rawdata.prota_inv_str_punkt
       except -- exclude river inventory points where we already have polygons
       select rs.* 
		from 
		(select *
		from
		rawdata.watercourse w 
		where geometrytype(w.geometry)='POLYGON') as wc, rawdata.prota_inv_str_punkt rs
		where ST_Intersects(st_transform(rs.merged_geom,3006),wc.geometry)) as rs2 
       ON srn.idsegment=rs2.idsegment), --OK
avg_width as(
SELECT idsegment, AVG(width_ef) width_ef, AVG(width_bk) width_bk
       FROM raw_width
       GROUP BY idsegment), -- NOT OK
"width" as(
SELECT DISTINCT ON (rw.idsegment) rw.idsegment, rw.geom, ST_X(ST_centroid(rw.geom)) X,
ST_Y(ST_centroid(rw.geom)) Y, rw.shreeve, rw.strahler, rw.basin, aw.width_ef, aw. width_bk 
FROM 
raw_width rw
LEFT JOIN avg_width aw
ON rw.idsegment=aw.idsegment)
SELECT w.*
FROM 
width w
left join sweden.rn srn
on w.idsegment=srn.idsegment 
where w.width_ef is not null or w.width_bk is not null and srn.fictitious is not true; -- filter data where we have width data

select * from AquaDW_prod.mart.SERS_ELFANGST

       