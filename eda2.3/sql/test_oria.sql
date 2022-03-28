SELECT Find_SRID('oria', 'operation_station', 'the_geom'); -- 3035
SELECT Find_SRID('oria', 'obstacles_ccm_500', 'the_geom'); -- 3035

select * from oria.operation_station limit 10;
select * from oria.obstacles_ccm_500 limit 10;

/*
CREATE TABLE oria_sta_dam AS
SELECT t1.*, t2.ob_id, t2.gid, t2.distance, t2.height, t2.nbdams, t2.id FROM oria.operation_station t1
JOIN oria.obstacles_ccm_500 t2
ON ST_Intersects(t1.the_geom, t2.the_geom);
drop table oria.oria_sta_dam;
*/

SET search_path TO oria, public;
select * from oria.oria_sta_dam limit 10;

CREATE TABLE oria_station_dams AS
SELECT distinct on (operation_id, distance) t1.st_id as station_id, t1.st_name as river_name, t1.op_date, t1.op_id as operation_id, 
	t1.op_surf as surface, t1.op_nbtot as nb_eels,
	t2.ob_id as dam_id, t2.height as height_dam, t2.nbdams as nb_dam,  
	ST_ClosestPoint(t1.the_geom,t2.the_geom) as geom_reproj, ST_distance(t1.the_geom,t2.the_geom) as distance
FROM oria.operation_station t1
JOIN oria.obstacles_ccm_500 t2  
on st_dwithin(t1.the_geom,t2.the_geom, 1000)
order by operation_id, distance;  -- 4046 rows 

select * from oria.operation_station where op_nbtot = 692;