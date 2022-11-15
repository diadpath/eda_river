-- add primary key
--ALTER TABLE watercourselink DROP CONSTRAINT watercourselink_pkey;
--ALTER TABLE watercourselink  add primary key (idsegment);

-- create unique constraint
ALTER TABLE hydronode ADD CONSTRAINT c_uk_localid UNIQUE (localid);
ALTER TABLE hydronode ADD CONSTRAINT c_uk_gml_id UNIQUE (gml_id);

-- ALTER hydronode table 
--
-- There are multiple hydronodes on the same spot. Therefore create two extra columns in hydronode: all_localids - an array with all local ids for multiple hydronodes
--                                                                                                  node_id - a new node id for multiple hydronodes         
--ALTER TABLE hydronode drop column node_id;
--ALTER TABLE hydronode drop column all_localids;
ALTER TABLE hydronode ADD column node_id integer;
ALTER TABLE hydronode ADD column all_localids varchar(50)[];

-- Add array with localids, based on geometry, to hydronode as multiple nodes are located on the exact same place.
with B as 
(SELECT *, array_agg(localid) over (partition by geometry order by geometry) all_localid, dense_rank() over (order by geometry) node
FROM hydronode)
update hydronode 
set 
all_localids = B.all_localid,
node_id = B.node
FROM B 
where hydronode.ogc_fid=B.ogc_fid;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Create merged table(including a an array with all localids of from the original hydronode table based on hydroned as multiple nodes are located on approximately the exact same place. --
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
create table hydronode_merged as
with merged_localids as 
(select array(select unnest(a.temp_localid) order by 1) as all_localid, row_number() over() node_id
from
(select
array_agg(h2.localid) temp_localid
FROM hydronode h
join hydronode h2 on ST_Intersects(h.geometry,h2.geometry)
group by h.localid) a
group by all_localid)
select distinct on (merged_localids.node_id) *
from 
merged_localids
left join hydronode h3 on h3.localid = any(merged_localids.all_localid)
order by merged_localids.node_id;

-- Update hydronode_merged  with primary key for each unique node
ALTER TABLE hydronode_merged add primary key (node_id);
create index idx_node_id on hydronode_merged(node_id);
CREATE INDEX geom_idx ON hydronode_merged USING GIST (geometry);

-- create index
create index idx_startnode_localid on watercourselink(startnode_localid);
create index idx_endnode_localid on watercourselink(endnode_localid);



ALTER TABLE watercourselink  ADD column startnode_localid varchar(50);
update watercourselink set startnode_localid = 
case  
when starts_with(startnode,'SE.LM.HY.NVE.') then regexp_replace(startnode,'SE.LM.HY.NVE.','')
when starts_with(startnode,'SE.LM.HY.SYKE.') then regexp_replace(startnode,'SE.LM.HY.SYKE.','')
else regexp_replace(startnode,'SE.LM.HY.','')
end;

-- add foreign key
ALTER TABLE watercourselink add CONSTRAINT c_fk_startnode_localid FOREIGN KEY (startnode_localid) REFERENCES hydronode(localid);


ALTER TABLE watercourselink  ADD column endnode_localid varchar(50);
update watercourselink set endnode_localid = 
case  
when starts_with(endnode,'SE.LM.HY.NVE.') then regexp_replace(endnode,'SE.LM.HY.NVE.','')
when starts_with(endnode,'SE.LM.HY.SYKE.') then regexp_replace(endnode,'SE.LM.HY.SYKE.','')
else regexp_replace(endnode,'SE.LM.HY.','')
end;

-- add idsegment to watercourselink
ALTER TABLE watercourselink  ADD column idsegment varchar(50);
update watercourselink set idsegment = 
case 
when "namespace" = 'SE.LM.HY.NVE' then 'NO' || ogc_fid 
when "namespace" = 'SE.LM.HY.SYKE' then 'FI' || ogc_fid 
else 'SW' || ogc_fid  
end; 

