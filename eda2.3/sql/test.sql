select * from sudoang.view_obstruction limit 10


SELECT * FROM sudoang.view_electrofishing WHERE op_gis_layername='miteco'; --767

SELECT * FROM sudoang.view_electrofishing WHERE op_gis_layername='miteco' AND nbp2 IS NOT NULL

SELECT * FROM sudoang.view_electrofishing WHERE op_gis_layername='miteco' AND ef_nbpas= 2


update sudoang.dbeel_batch_ope set ba_quantity = round(op_dens::NUMERIC/100, 3) from sudoang.bc_ope where dbeel_batch_ope.ba_ob_id = bc_ope.bc_ob_id and ba_no_biological_characteristic_type = 48;



SELECT
   column_name
FROM
   information_schema.COLUMNS
WHERE
   TABLE_NAME = 'rna'
AND TABLE_SCHEMA ='france';

SELECT 
              rn.gid, 
  			  rn.idsegment, 
              rn.source, 
              rn.target, 
              rn.lengthm, 
              rn.nextdownidsegment, 
              rn.path, 
              rn.issea, 
              rn.seaidsegment, 
              rn.isfrontier, 
              rn.issource, 
              rn.isendoreic, 
              rn.isinternational,
              rna.*,
              gerem_zone_4,
              CASE WHEN gerem_zone_4=1 THEN 'ATL_F'
                   WHEN gerem_zone_4=2 THEN 'MED'
                   WHEN gerem_zone_4=3 THEN 'CANT'
                   WHEN gerem_zone_4=4 THEN 'ATL_IB'
                   WHEN gerem_zone_4 IS NULL THEN 'CHAN' END 
              AS area_sudo
              FROM dbeel_rivers.rn 
              JOIN dbeel_rivers.rna  ON rna.idsegment =  rn.idsegment
              JOIN eda_gerem.assoc_dbeel_rivers aa ON rn.seaidsegment = aa.seaidsegment
              
              
SELECT 
		rn.gid, 
		rn.idsegment, 
		rn.source, 
		rn.target, 
		rn.lengthm, 
		rn.nextdownidsegment, 
		rn.path, 
		rn.issea, 
		rn.seaidsegment, 
		rn.isfrontier, 
		rn.issource, 
		rn.isendoreic, 
		rn.isinternational,
		rna.*,
		gerem_zone_4,
		CASE WHEN gerem_zone_4=1 THEN 'ATL_F'
		WHEN gerem_zone_4=2 THEN 'MED'
		WHEN gerem_zone_4=3 THEN 'CANT'
		WHEN gerem_zone_4=4 THEN 'ATL_IB'
		WHEN gerem_zone_4 IS NULL THEN 'CHAN' END 
		AS area_sudo
		FROM dbeel_rivers.rn 
		JOIN dbeel_rivers.rna  ON rna.idsegment =  rn.idsegment
		JOIN eda_gerem.assoc_dbeel_rivers aa ON rn.seaidsegment = aa.seaidsegment WHERE rn.country in ('SP')  ORDER BY rn.idsegment ; 
	

WITH approx_dist AS (
SELECT idsegment, geom <#> ST_transform(ST_GeomFromText('POINT(9.37 41.86)',4326), 3035) AS dist 
FROM dbeel_rivers.rn 
ORDER BY dist )
SELECT * FROM approx_dist LIMIT 1

WITH approx_dist AS (
SELECT idsegment, geom <#> ST_transform(ST_GeomFromText('POINT( 9   40 )', 4326 ), 3035) AS dist 
FROM dbeel_rivers.rn ORDER BY dist ), 
the_closest AS (SELECT * FROM approx_dist LIMIT 1) 
SELECT * from dbeel_rivers.rne 
--JOIN dbeel_rivers.rna ON rna.idsegment=rne.idsegment
JOIN  the_closest ON rne.idsegment=the_closest.idsegment


SELECT sum(nsilver) FROM dbeel_rivers.rne
JOIN dbeel_rivers.rn ON rn.idsegment=rne.idsegment
WHERE seaidsegment = 'FR212340'; --90599

SELECT cnsilver FROM dbeel_rivers.rne
JOIN dbeel_rivers.rn ON rn.idsegment=rne.idsegment
WHERE rn.idsegment ='FR212340';--225022

SELECT cnsilver FROM 
dbeel_rivers.rn_rna_cumul_silver WHERE idsegment ='FR212340' --225022

DROP TABLE IF EXISTS temp_emu;
CREATE TABLE temp_emu AS(
WITH spptfr AS(
select 
		case when emu_nameshort in ('ES_Bale', 'ES_Murc', 'ES_Cast') then 'ES_Vale'
		when emu_nameshort = 'FR_Cors' then 'FR_Rhon'
		when emu_nameshort ='ES_Spai' then 'ES_Inne' 
		ELSE emu_nameshort END AS id, 
		case when emu_nameshort in ('FR_Arto','FR_Sein','FR_Meus','FR_Rhin') THEN FALSE 
		ELSE TRUE end as gt3,
		(st_dump(geom)).geom geom 
		FROM ref.tr_emu_emu
		WHERE emu_cou_code in ('FR','ES','PT')
		),
grouped AS (SELECT 
		id, 
		gt3,
		st_multi(st_union(geom)) geom FROM 
		spptfr 
		WHERE NOT ST_IsEmpty(ST_Buffer(geom,0.0)) -- remove dim NOT polygon
		group by id,gt3)
SELECT id, 
		gt3,
		st_simplifypreservetopology(geom,0.001) geom FROM grouped
); --20
           


SELECT *  FROM sudoang.translate_names

SELECT * FROM sudoang.view_obstruction o

CREATE SCHEMA geo;
DROP VIEW IF EXISTS geo.obtacle;
CREATE VIEW geo.obtacle AS(
SELECT 
ROW_NUMBER() OVER (ORDER BY op_id ASC) AS id,
op_id AS obs_id,
op_gis_layername AS obs_name,
op_gislocation,
st_transform(the_geom,4326) AS geom,
id_original AS source_id,
country,
dp_name,
obstruction_type_code,
obstruction_type_name,
obstruction_impact_code,
obstruction_impact_name,
po_obstruction_height AS obs_height,
po_downs_pb AS obs_downs_pb,
po_downs_water_depth AS obs_downs_water_depth,
po_presence_eel_pass AS obs_presence_eel_pass,
po_method_perm_ev AS obs_method_perm_ev,
fishway_type_name AS fishway_type,
googlemapscoods,
CASE WHEN po_obstruction_height<10 and fishway_type_name is NULL Then 'Dam <10 m' 
WHEN po_obstruction_height <10 and  fishway_type_name is NOT NULL
Then 'Dam <10 m with pass available for eel'
WHEN po_obstruction_height >=10 and  fishway_type_name is NULL then 'dam>=10 m'
WHEN  po_obstruction_height >=10 and  fishway_type_name is NOT NULL
then 'dam>=10 m with pass available for eel' 
END as category
FROM sudoang.view_obstruction o)
