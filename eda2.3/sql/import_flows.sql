
-- sudoang.hydro_stations_gt2
------------------------------------------
-- SCRIPT TO PROJECT hydro_stations_gt2 on rn and
-- get upstream basin table
-- with a unit basin
----------------------------------------------
SELECT * FROM sudoang.hydro_stations_gt2;

CREATE INDEX sudoang_hydro_stations_gt2_idx
  ON sudoang.hydro_stations_gt2
  USING GIST (geom);

ALTER TABLE sudoang.hydro_stations_gt2 add column idsegment text;
ALTER TABLE sudoang.hydro_stations_gt2 ADD COLUMN id TEXT;
UPDATE sudoang.hydro_stations_gt2 SET id = code_hydro_station||COALESCE(cdsoussect,'') ; --59
ALTER TABLE sudoang.hydro_stations_gt2 ADD CONSTRAINT c_pk_sudoang_hydro_station_gt2 PRIMARY KEY (id);

WITH closest_rn_stationhydro AS (
SELECT
  hydro_stations_gt2.code_hydro_station,
  closest_rn.idsegment,
  closest_rn.dist	
 FROM sudoang.hydro_stations_gt2
LEFT JOIN LATERAL 
  (SELECT
      idsegment, 
      ST_Distance(rn.geom, hydro_stations_gt2.geom) as dist
      FROM dbeel_rivers.rn         
      ORDER BY rn.geom <-> hydro_stations_gt2.geom
      LIMIT 1
   ) AS closest_rn
   ON TRUE)
   
UPDATE sudoang.hydro_stations_gt2 set idsegment=closest_rn_stationhydro.idsegment 
FROM closest_rn_stationhydro
WHERE closest_rn_stationhydro.code_hydro_station = hydro_stations_gt2.code_hydro_station;--120

SELECT * FROM sudoang.hydro_stations_gt2 
JOIN dbeel_rivers.rn ON rn.idsegment=sudoang.hydro_stations_gt2.idsegment






DROP TABLE IF EXISTS dbeel_rivers.rn_gt2 CASCADE;
CREATE TABLE dbeel_rivers.rn_gt2 (
idsegment TEXT PRIMARY KEY,
pos TEXT, -- 'upstream' or  'downstream' or here
code_hydro_station TEXT,
id TEXT
);

SELECT addgeometrycolumn('dbeel_rivers','rn_gt2', 'geom',3035, 'MULTILINESTRING', 2);
-- to use foreign keys I need to create inherited tables
CREATE TABLE france.rn_gt2 (
CONSTRAINT c_fk_dbeel_rivers_rn_gt2 FOREIGN KEY (idsegment) REFERENCES france.rn (idsegment) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT c_pk_idsegment_france_rn_gt2 PRIMARY KEY (idsegment)
) INHERITS (dbeel_rivers.rn_gt2);


CREATE TABLE spain.rn_gt2 (
CONSTRAINT c_fk_dbeel_rivers_rn_gt2 FOREIGN KEY (idsegment) REFERENCES spain.rn (idsegment) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT c_pk_idsegment_spain_rn_gt2 PRIMARY KEY (idsegment)
) INHERITS (dbeel_rivers.rn_gt2);

CREATE TABLE portugal.rn_gt2 (
CONSTRAINT c_fk_dbeel_rivers_rn_gt2 FOREIGN KEY (idsegment) REFERENCES portugal.rn (idsegment) ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT c_pk_idsegment_portugal_rn_gt2 PRIMARY KEY (idsegment)
) INHERITS (dbeel_rivers.rn_gt2);


/*
 * This query is a test
 * it will find all segments upstream and downstream from a station.
 * It has been adapted in R see import_flows.Rmd chunk applystationtosegment
 *  ATTENTION A AVOIR DES DONNEES UNIQUE POUR LES TABLES => OK avec distinct ON
 * there has been a change, the primary key constraints have to be set in the daughter table too
 * otherwise won't work
 * A LANCER DE l'AVAL (prioritaire) vers l'amont pour selectionner les bassins.
 */


WITH downstream_segments AS (
SELECT dbeel_rivers.downstream_segments_rn('SP227795') AS idsegment, 'downstream' AS pos
),

upstream_segments AS (
SELECT spain.upstream_segments_rn('SP227795') AS idsegment, 'upstream' AS pos
EXCEPT 
SELECT 'SP227795' , 'upstream'
),

all_segments AS (
SELECT 'SP227795' AS idsegment , 'here' AS pos
UNION 
SELECT * FROM downstream_segments 
UNION 
SELECT * FROM upstream_segments),
-- this will add a column with all values filled with the code of the idsegment
all_segments_pluscolumn  AS (
SELECT * FROM all_segments FULL OUTER JOIN
(SELECT 'SP227795' AS idsegmentstation) temp ON TRUE),

final_join_hydrostation_segments AS(

SELECT all_segments_pluscolumn.idsegment, pos, code_hydro_station FROM all_segments_pluscolumn JOIN
(
SELECT DISTINCT ON (code_hydro_station) * FROM sudoang.hydro_stations_gt2) station_without_double
ON station_without_double.idsegment=idsegmentstation)
-- when there are several stations in a basin only apply to upstream and here locations otherwise add downstream.

--SELECT * FROM final_join_hydrostation_segments

--INSERT INTO dbeel_rivers.rn_gt2 
SELECT * FROM final_join_hydrostation_segments WHERE pos !='downstream'
EXCEPT 
SELECT hs.* FROM final_join_hydrostation_segments hs
JOIN dbeel_rivers.rn_gt2 
ON dbeel_rivers.rn_gt2.idsegment = hs.idsegment
WHERE hs.pos !='downstream';

--------------------TEST SQL FROM R--------------------------------------------------------

WITH downstream_segments AS (
SELECT dbeel_rivers.downstream_segments_rn('PT31034') AS idsegment, 'downstream' AS pos
),

upstream_segments AS (
SELECT dbeel_rivers.upstream_segments_rn('PT31034') AS idsegment, 'upstream' AS pos
EXCEPT 
SELECT 'PT31034' , 'upstream'
),

all_segments AS (
SELECT 'PT31034' AS idsegment , 'here' AS pos
UNION 
SELECT * FROM downstream_segments 
UNION 
SELECT * FROM upstream_segments),

-- this will add a column with all values filled with the code of the idsegment

all_segments_pluscolumn  AS (
SELECT * FROM all_segments FULL OUTER JOIN
(SELECT 'PT31034' AS idsegmentstation) temp ON TRUE),

-- joining with hydro station

final_join_hydrostation_segments AS(					
SELECT all_segments_pluscolumn.idsegment, pos, code_hydro_station FROM all_segments_pluscolumn JOIN
(
SELECT DISTINCT ON (code_hydro_station) * FROM sudoang.hydro_stations_gt2) station_without_double
ON station_without_double.idsegment=idsegmentstation
)
INSERT INTO "portugal".rn_gt2 (idsegment, pos, code_hydro_station)
SELECT * FROM final_join_hydrostation_segments
EXCEPT 
SELECT hs.* FROM final_join_hydrostation_segments hs
JOIN "portugal".rn_gt2 
ON hs.idsegment = rn_gt2.idsegment;




--------------------END TEST SQL FROM R--------------------------------------------------------

/*
 * In France first apply to whole basin using cdsoussect
 */

-- SELECT * FROM sudoang.hydro_stations_gt2
-- SELECT * FROM france.rn_gt2 WHERE idsegment= 'FR122911'

with rr as (
	select 
	idsegment,
	split_part(split_part("name",'[',2),']',1) as cdsoussect,
	 split_part(split_part(basin,'[',2),']',1) AS cdsecteurh,
	 substring( split_part(split_part(basin,'[',2),']',1),1,1) as cdregionh
	 FROM france.rna)
INSERT INTO france.rn_gt2
SELECT rr.idsegment, 'soussecteurhydro' AS pos, code_hydro_station FROM rr JOIN
sudoang.hydro_stations_gt2 g
ON g.cdsoussect = rr.cdsoussect; -- 2913

-- TODO apply TO the rest of the basin WHEN missing


UPDATE france.rn_gt2 SET geom=rn.geom FROM france.rn WHERE rn.idsegment=rn_gt2.idsegment; --2913

SELECT * FROM dbeel_rivers.rn_gt2

--- st_union des bassins unitaires en espagne

DROP TABLE IF EXISTS dbeel_rivers.basins_gt2;
CREATE TABLE dbeel_rivers.basins_gt2 AS (
SELECT  rn_gt2.code_hydro_station, hydro_stations_gt2.idsegment, st_union(bu.geom) AS geom FROM
dbeel_rivers.rn_gt2  JOIN
sudoang.hydro_stations_gt2 ON hydro_stations_gt2.code_hydro_station = rn_gt2.code_hydro_station JOIN
dbeel_rivers.basinunit_bu bu ON bu.bu_idsegment = rn_gt2.idsegment
GROUP by rn_gt2.code_hydro_station, hydro_stations_gt2.idsegment); --14 min 44 lines

-- below test for the code that will be used in R Import_flows.Rmd


					
SELECT * FROM sudoang.hydro_station_gt2_quantile



-- Test for getting the right flow (interpolated at every river segment


Voir => Methode_de_transfert_de_bassin_G_Piton.pdf

WITH flowatstation AS (
SELECT 
	code_hydro_station,
	q_1004_10 AS station_q_1004_10, 
	q_1004_20 AS station_q_1004_20, 
	q_1004_30 AS station_q_1004_30,
	q_1004_40 AS station_q_1004_40,
	q_1004_50 AS station_q_1004_50, 
	q_1004_60 AS station_q_1004_60, 
	q_1004_70 AS station_q_1004_70, 
	q_1004_80 AS station_q_1004_80, 
	q_1004_90 AS station_q_1004_90,
	q_1004_95 AS station_q_1004_95,
	q_1004_99 AS station_q_1004_99,
	qq.idsegment AS station_idsegment,
	COALESCE(rna.medianflowm3ps, rna.dis_m3_pyr_riveratlas) AS station_flow,
	CASE WHEN rna.medianflowm3ps IS NULL AND rna.dis_m3_pyr_riveratlas IS NULL THEN 'no flow'
	     WHEN  rna.medianflowm3ps IS NULL AND rna.dis_m3_pyr_riveratlas IS NOT NULL THEN 'Q50 river Atlas'
	     WHEN rna.medianflowm3ps IS NOT NULL THEN 'Q50 RHT'
	     END AS source_flow_station,
	surfacebvm2 AS station_surfacebvm2
	FROM
	sudoang.hydro_station_gt2_quantile qq JOIN
	dbeel_rivers.rna ON rna.idsegment = qq.idsegment)

		SELECT 
		flowatstation.*, 
		gg.idsegment, 
		COALESCE(rna.medianflowm3ps,	rna.dis_m3_pyr_riveratlas) AS idsegmentflow,
		CASE WHEN rna.medianflowm3ps IS NULL AND rna.dis_m3_pyr_riveratlas IS NULL THEN 'no flow'
				WHEN rna.medianflowm3ps IS NULL AND rna.dis_m3_pyr_riveratlas IS NOT NULL THEN 'Q50 river Atlas'
				WHEN rna.medianflowm3ps IS NOT NULL THEN 'Q50 RHT'
				END AS source_flow_idsegment,
		surfacebvm2 AS idsegmentsurfacebvm2
		FROM 
		flowatstation JOIN 
		dbeel_rivers.rn_gt2 gg ON flowatstation.code_hydro_station= gg.code_hydro_station JOIN 
		dbeel_rivers.rna ON rna.idsegment = gg.idsegment




  CREATE TABLE sudoang.hydro_station_gt2_quantile 
				   AS (SELECT hydro_stations_gt2.*, 
					q_1004_10,
					q_1004_20,
					q_1004_30,
					q_1004_40,
					q_1004_50,
					q_1004_60,
					q_1004_70,
					q_1004_80,
					q_1004_90,
					q_1004_95,
					q_1004_99,
					year_min,
					year_max
					FROM
					sudoang.quantile_flow_temp FULL OUTER JOIN sudoang.hydro_stations_gt2
					ON quantile_flow_temp.id = hydro_stations_gt2.id
  
  
  