
CREATE TABLE pose_wrbd.western_wso1
(
  id serial NOT NULL,
  wso_id integer,
  wso1_id integer,
  area character varying(25),
  CONSTRAINT wso1_pkey PRIMARY KEY (id)
);

COPY pose_wrbd.western_wso1 FROM 'E:/Mes documents/Mes dossiers/ANGUILLE/EDA/20110622/River width Irland/wso_wrbd.csv' CSV HEADER DELIMITER ';'

CREATE TABLE pose_wrbd.ccm_river_segment_wrbb AS SELECT "RIVERSEGMENTS".* FROM pose_wrbd.western_wso1, "CCM"."RIVERSEGMENTS" WHERE "WSO1_ID"=wso1_id;


CREATE TABLE pose_wrbd.ccm_river_segment_irluk AS SELECT "RIVERSEGMENTS".* FROM "CCM"."RIVERSEGMENTS" WHERE "WINDOW"=2001;

DROP TABLE pose_wrbd.ccm_lakes_wrbb;
CREATE TABLE pose_wrbd.ccm_lakes_wrbb AS SELECT "LAKES".* FROM (SELECT DISTINCT ON(wso_id) wso_id FROM pose_wrbd.western_wso1) as western_wso1, "CCM"."LAKES" WHERE "LAKES"."wso_id"=western_wso1.wso_id;

CREATE TABLE pose_wrbd.western_width
(
  id serial NOT NULL,
  KEY_SEGCD character varying(10),
  measered_wetted_width real,
  catchment_area real,
  shreve integer,
  CONSTRAINT western_width_pkey PRIMARY KEY (id)
);

COPY pose_wrbd.western_width FROM 'E:/Mes documents/Mes dossiers/ANGUILLE/EDA/20110622/River width Irland/Original training dataset.csv' CSV HEADER DELIMITER ';'

DROP TABLE IF EXISTS pose_wrbd.wrbd_width_geom;
CREATE TABLE pose_wrbd.wrbd_width_geom AS 
SELECT * FROM pose_wrbd.discovery_rivers, pose_wrbd.western_width WHERE seg_cd = key_segcd;


--- rapprochement couche IRL / couche CCM
DROP TABLE IF EXISTS pose_wrbd.width_ccm ;
CREATE TABLE pose_wrbd.width_ccm AS
SELECT ccm_river_segment_irluk.*, seg_cd, measered_wetted_width, catchment_area, shreve, ST_Distance(ST_Transform(wrbd_width_geom.the_geom,3035), ccm_river_segment_irluk.the_geom)  AS st_distance, ST_HausdorffDistance(ST_Transform(wrbd_width_geom.the_geom,3035), ccm_river_segment_irluk.the_geom) AS ST_HausdorffDistance FROM pose_wrbd.wrbd_width_geom, pose_wrbd.ccm_river_segment_irluk WHERE ST_Transform(wrbd_width_geom.the_geom,3035) &&ccm_river_segment_irluk.the_geom AND ST_Intersects(ST_Transform(wrbd_width_geom.the_geom,3035), ST_Buffer(ccm_river_segment_irluk.the_geom,100));


SELECT wso_id , count(*) 
FROM 
	(	SELECT * 
		FROM (	SELECT width_ccm."WSO1_ID"as wso_id , count(*), max(measered_wetted_width) as max_width  
				FROM (	SELECT "WSO1_ID" , count(*), min(st_distance) AS min_dist 
						FROM pose_wrbd.width_ccm  group by "WSO1_ID"
					) as min_dist, pose_wrbd.width_ccm 
				WHERE st_distance=min_dist AND width_ccm."WSO1_ID" = min_dist."WSO1_ID" GROUP BY width_ccm."WSO1_ID"
	) as max_width,  pose_wrbd.width_ccm 
WHERE 
	measered_wetted_width=max_width AND width_ccm."WSO1_ID" = max_width.wso_id) as toto group by wso_id
;

CREATE TABLE pose_wrbd.ccm_width_final AS 
SELECT width_ccm.*
FROM
	(SELECT "WSO1_ID" , count(*), min(st_distance) AS min_dist , min(st_hausdorffdistance) AS min_hausdorff, max(measered_wetted_width) as max_width  
		FROM pose_wrbd.width_ccm  group by "WSO1_ID") as r_min_dist, 
	pose_wrbd.width_ccm
WHERE width_ccm."WSO1_ID" = r_min_dist."WSO1_ID" AND st_distance=min_dist AND min_hausdorff = st_hausdorffdistance AND measered_wetted_width = max_width 
;