-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- 					Alter_raw_hydrographic_data                            --
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- 
-- This script is used to alter raw data (hydronodes and watercourselinks)
-- of the Swedish river network from Lantmäteriet. Coastline and sea       
-- polygon from Topografi 10 Lantmäteriet are used to crop the             
-- hydrographic network in order to only include inland waters.            
--
-- @ Torbjörn Säterberg(torbjorn.saterberg@slu.se) 221118

------------------------------------------
-- Create table watercourselink_altered --
------------------------------------------

-- In order to speed up query create a temporary table with index
CREATE TEMPORARY TABLE temp_startpoint_wcl as 
select w.*, st_startpoint(w.centrelinegeometry) geom_startpoint  
from watercourselink w;
CREATE INDEX geom_startpoint_idx ON temp_startpoint_wcl USING GIST (geom_startpoint);

-- Create table with watercourselinks_altered (i.e. watercourselinks that are inland)
drop table if exists watercourselink_altered;
create table watercourselink_altered as 
select *
from watercourselink w 
except -- remove links that are at sea
select t.ogc_fid, t.gml_id, t.beginlifespanversion, t.localid, t."namespace", t.innetwork, 
t.fictitious, t.endnode, t.startnode, t.relatedhydroobject, t."length", t.length_uom, t.centrelinegeometry,
t.startnode_localid, t.endnode_localid, t.idsegment
from temp_startpoint_wcl t, (select geom from mark where objekttyp='Hav') a 
where ST_DWithin(geom_startpoint, a.geom, 0.5);


--
-- add columns to watercourselink_altered 
--

-- add column startnode_localid
ALTER TABLE watercourselink_altered ADD column startnode_localid varchar(50);
update watercourselink_altered set startnode_localid = 
case  
when starts_with(startnode,'SE.LM.HY.NVE.') then regexp_replace(startnode,'SE.LM.HY.NVE.','')
when starts_with(startnode,'SE.LM.HY.SYKE.') then regexp_replace(startnode,'SE.LM.HY.SYKE.','')
else regexp_replace(startnode,'SE.LM.HY.','')
end;

-- add column end_localid
ALTER TABLE watercourselink_altered  ADD column endnode_localid varchar(50);
update watercourselink_altered set endnode_localid = 
case  
when starts_with(endnode,'SE.LM.HY.NVE.') then regexp_replace(endnode,'SE.LM.HY.NVE.','')
when starts_with(endnode,'SE.LM.HY.SYKE.') then regexp_replace(endnode,'SE.LM.HY.SYKE.','')
else regexp_replace(endnode,'SE.LM.HY.','')
end;

-- add idsegment
ALTER TABLE watercourselink_altered ADD column idsegment varchar(50);
update watercourselink_altered set idsegment = 
case 
when "namespace" = 'SE.LM.HY.NVE' then 'NO' || ogc_fid 
when "namespace" = 'SE.LM.HY.SYKE' then 'FI' || ogc_fid 
else 'SW' || ogc_fid  
end; 

-- add primary key to watercourselink_altered
ALTER TABLE watercourselink_altered add primary key (idsegment);
 
-- create indexs on watercourselink_altered
create index idx_snode_localid on watercourselink_altered(startnode_localid);
create index idx_enode_localid on watercourselink_altered(endnode_localid);
create index idx_snode on watercourselink_altered(startnode);
create index idx_enode on watercourselink_altered(endnode);
create index idx_geom_wcl_altered ON watercourselink_altered USING GIST (centrelinegeometry);

-- Manually remove one row that is at sea (on the norwegian side)
DELETE FROM watercourselink_altered  WHERE idsegment='NO295117';

------------------------------------
-- End of watercourselink_altered --
------------------------------------

-------------------------------
-- Create hydronodes_altered --
-------------------------------

-- first create temporary table with geometric index to speed up calculation
drop table if exists temp_hydronode_altered;
create temporary table temp_hydronode_altered as 
select distinct h.* 
from hydronode h
inner join watercourselink_altered wa on ST_DWithin(h.geometry, wa.centrelinegeometry, 0.1);

-- Update temporary table with indices 
create index idx_localid on temp_hydronode_altered(localid);
create index idx_node_id on temp_hydronode_altered(node_id);
CREATE INDEX geom_idx ON temp_hydronode_altered USING GIST (geometry);

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Create merged table (including an array with all localids of from the original hydronode table based on hydroned as multiple nodes are located on approximately the exact same place. --
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
create temporary table merged_localids as 
(select array(select unnest(a.temp_localid) order by 1) as all_localid, row_number() over() node_id
from
(select
array_agg(h2.localid) temp_localid
FROM temp_hydronode_altered h
join temp_hydronode_altered h2 on ST_Intersects(h.geometry,h2.geometry)
group by h.localid) a
group by all_localid)

-- create hydronode_altered table 
create table hydronode_altered as
select distinct on (merged_localids.node_id) * 
from 
merged_localids
left join temp_hydronode_altered h3 on h3.localid = any(merged_localids.all_localid)
order by merged_localids.node_id;

-- add primary key and indices to each unique node
ALTER TABLE hydronode_altered add primary key (node_id);
create index id_node_id on hydronode_altered(node_id);
CREATE INDEX geom_id ON hydronode_altered USING GIST (geometry);


-------------------------------------------------------------------------------
-- Create a connection between hydronode_altered and watercourselink_altered --
-------------------------------------------------------------------------------

-- first add new columns with node_ids for sourcer and target nodes to watercourselink_altered 
ALTER TABLE watercourselink_altered ADD column source_node integer;
ALTER TABLE watercourselink_altered ADD column target_node integer;

-- update watercourselink_altered with source_node from hydronode_altered(Warning!! this is slow) 
update watercourselink_altered wa
set source_node=t."source"
from (select wa.idsegment, ha.node_id "source"  
from watercourselink_altered wa, hydronode_altered ha 
where wa.startnode_localid=any(ha.all_localid)) t
where wa.idsegment=t.idsegment;  

-- update watercourselink_altered with source_node from hydronode_altered(Warning!! this is slow)
update watercourselink_altered wa
set target_node=t.target
from (select wa.idsegment, ha.node_id target  
from watercourselink_altered wa, hydronode_altered ha 
where wa.endnode_localid=any(ha.all_localid)) t
where wa.idsegment=t.idsegment;  

-- add foreign key(connection between hydronode altered and start and endnodes in watercourselink_altered)
ALTER TABLE watercourselink_altered add CONSTRAINT c_fk_startnode_id FOREIGN KEY (source_node) REFERENCES hydronode_altered(node_id);
ALTER TABLE watercourselink_altered add CONSTRAINT c_fk_endnode_id FOREIGN KEY (target_node) REFERENCES hydronode_altered(node_id);


