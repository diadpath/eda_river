
 /*
  * Corrections from Carlos : these streams are considered as DRY
  */
		



WITH drysegments AS (
SELECT spain.upstream_segments_rn('SP117885') AS idsegment
UNION
SELECT spain.upstream_segments_rn('SP117336')   AS idsegment
UNION 
SELECT spain.upstream_segments_rn('SP117146')  AS idsegment
UNION 
SELECT spain.upstream_segments_rn('SP116975') AS idsegment)
UPDATE spain.rna SET (drought, drought_type_calc) = (3, 'correction from Carlos Fernandez Delgado, intermitent stream')  FROM
		drysegments WHERE
		drysegments.idsegment = rna.idsegment; --370
		
		
SELECT * FROM spain.temp_temporales_rn WHERE idsegment IN ('SP117885','SP117336','SP117146','SP116975');

ALTER TABLE dbeel_rivers.rne DROP COLUMN surfaceunitbvm2 CASCADE;
ALTER TABLE dbeel_rivers.rne DROP COLUMN surfacebvm2 CASCADE;

-- correction for the Ebro
-- the coordinates of the dam are updated but this is for later, I will not change view obstruction now....
/*
-- get coordinates from the segment
SELECT * FROM spain.rn WHERE idsegment IN (SELECT spain.upstream_segments_rn('SP305043'))
SELECT (ST_DumpPoints(geom)).geom 
    FROM spain.rn WHERE idsegment='SP305043'
-- verify coordinates
SELECT st_x(the_geom), st_y(the_geom) FROM sudoang.dbeel_obstruction_place
WHERE op_id= 'bf802066-d2af-4d62-a656-f9402548f5fb' AND op_placename='Ribarroja'
 -- 3518690.9100110675	2066962.7710338398  

 */

 UPDATE  sudoang.dbeel_obstruction_place set the_geom = ST_PointFromText('POINT(3518108 2066593)', 3035)
  WHERE op_id= 'bf802066-d2af-4d62-a656-f9402548f5fb' AND op_placename='Ribarroja';

WITH surface AS (
SELECT 
rna.idsegment,
CASE WHEN drought IN ('1','2','5') THEN coalesce(rna.wettedsurfacem2,0)+coalesce(rna.wettedsurfaceotherm2,0) ELSE 0 END AS surface
FROM  spain.rna  WHERE idsegment IN (SELECT spain.upstream_segments_rn('SP305043'))),

newdata AS (
SELECT 
rne.idsegment,
0 delta,0 density,
0 neel,0 beel,
0 nsilver,0 bsilver, 
0 cnfemale300450,0 cnfemale450600,0 cnfemale600750,0 cnfemale750,
0 cnmale150300,0 cnmale300450,0 cnmale450600,
0 cnsilver150300, 0 cnsilver300450, 0 cnsilver450600, 0 cnsilver600750, 0 cnsilver750,
0 cnsilver,  
CASE WHEN delta_tr IS NOT NULL THEN delta_tr*gamma_tr ELSE NULL END AS density_pmax_tr, 
CASE WHEN delta_tr IS NOT NULL THEN delta_tr*gamma_tr*surface ELSE NULL END AS neel_pmax_tr,
CASE WHEN neel = 0 AND delta_tr IS NOT NULL THEN 0 
     WHEN neel >0  AND delta_tr IS NOT NULL THEN delta_tr*gamma_tr*surface*nsilver/neel 
     ELSE NULL 
     END AS nsilver_pmax_tr
-- here I assume the rate OF CONVERSION FROM silver TO eel will remain the same
FROM spain.rne JOIN surface ON surface.idsegment= rne.idsegment)

UPDATE spain.rne SET (
delta,density,
neel,beel,
nsilver,bsilver,
cnfemale300450,cnfemale450600,cnfemale600750,cnfemale750,
cnmale150300,cnmale300450,cnmale450600,
cnsilver150300,cnsilver300450,cnsilver450600,cnsilver600750,cnsilver750,
cnsilver,density_pmax_tr,neel_pmax_tr,nsilver_pmax_tr) =
(
newdata.delta,newdata.density,
newdata.neel,newdata.beel,
newdata.nsilver,newdata.bsilver,
newdata.cnfemale300450,newdata.cnfemale450600,newdata.cnfemale600750,newdata.cnfemale750,
newdata.cnmale150300,newdata.cnmale300450,newdata.cnmale450600,
newdata.cnsilver150300,newdata.cnsilver300450,newdata.cnsilver450600,newdata.cnsilver600750,newdata.cnsilver750,
newdata.cnsilver,
newdata.density_pmax_tr,newdata.neel_pmax_tr,newdata.nsilver_pmax_tr)
FROM newdata
WHERE newdata.idsegment=rne.idsegment ;--51478



-- I have copied the file straight from csv using Qgis
ALTER TABLE spain."Mediterranean rivers" RENAME TO temp_dryrivers_carlos;
--ALTER TABLE spain.temp_dryrivers_carlos DROP COLUMN geom;
SELECT addgeometrycolumn('spain', 'temp_dryrivers_carlos','geom', 3035, 'MULTILINESTRING', 2); 
-- add geometry
WITH singlegeom AS (
SELECT idsegment, seaidsegment, (st_dump(geom)).geom FROM spain.rn),
unifiedrivers AS (
SELECT seaidsegment, st_collect(geom) AS uniongeom FROM singlegeom
GROUP BY seaidsegment)
UPDATE spain.temp_dryrivers_carlos SET geom=unifiedrivers.uniongeom
FROM unifiedrivers
WHERE temp_dryrivers_carlos.seaidsegment = unifiedrivers.seaidsegment;--46


SELECT DISTINCT "Habitat" FROM spain.temp_dryrivers_carlos;
UPDATE spain.temp_dryrivers_carlos SET "Habitat"='R' WHERE "Habitat"='R ';

-- sauvegarde pour Maria
--pg_dump -U postgres -Fc -f "spain.temp_dryrivers_carlos" --table spain.temp_dryrivers_carlos eda2.3


-- Carlos says this one is dry
WITH dryriver AS (
SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
JOIN spain.rna ON rn.idsegment = rna.idsegment
WHERE seaidsegment = 'SP116806')
UPDATE spain.rna SET 
(drought,drought_type_calc) = (3,'River considered as dry after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado, this river was previously 
considered as permanent (1) using temportal stream layer') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --63

 UPDATE spain.rna SET 
(drought,drought_type_calc) = (3,'River considered as dry after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado, this river was previously 
considered as permanent (1) by lack of information') 
WHERE idsegment in ('SP117620', 'SP114195'); --2

 UPDATE spain.rna SET 
(drought,drought_type_calc) = (3,'River considered as dry after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado, this river was previously 
considered as permanent (1) by lack of information') 
WHERE idsegment in ('SP10947', 'SP10946','SP10945'); --2

 UPDATE spain.rna SET 
(drought,drought_type_calc) = (3,'River considered as dry after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado, this river was previously 
considered as permanent (1) by lack of information') 
WHERE idsegment in ('SP182033','SP1869'); --2

-- this one IS classified AS flowing BY Carlos but I have doubts concerning the head, so I DO manually
-- ARROYO DE CAGANCHA
UPDATE spain.rna SET 
(drought,drought_type_calc) = (2,'River considered as temporal (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado, this river was previously 
considered dry ') 
WHERE idsegment in ('SP118692','SP118664','SP118661','SP118606'); --4

-- RIO VERDE
-- Carlos said this was dry, and the surface should be limited to the estuary below reservoir
SP116600 SP116804 SP116975 SP116497 SP116316 SP116288 SP116176 SP324942 SP116434 SP116380 SP115041 SP116261 SP116269 SP116130
SP116213 SP116140 SP116111 SP116070 SP116006 SP116106 SP116019

UPDATE spain.rna SET 
(drought,drought_type_calc) = (1,'River considered as permanent (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado, the river is considered as eel
habitat below and in the reservoir') 
WHERE idsegment IN (
SELECT idsegment FROM spain.waterbody_unitbv WHERE cod_masa= 'ES060MSPF0613130')
OR idsegment IN ('SP116600','SP116804','SP116975');--35


WITH dryriver AS (
SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
JOIN spain.rna ON rn.idsegment = rna.idsegment
WHERE seaidsegment IN ('SP113722','SP113102')
AND drought='5')
UPDATE spain.rna SET 
(drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --8

UPDATE spain.rna SET 
(drought,drought_type_calc) = (3,'River segment isolated among dry rivers')    
WHERE idsegment = 'SP110719';

WITH dryriver AS (
SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
JOIN spain.rna ON rn.idsegment = rna.idsegment
WHERE seaidsegment IN ('SP113212','SP112952')
AND drought='5')
UPDATE spain.rna SET 
(drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --3
 
 
 WITH dryriver AS (
SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
JOIN spain.rna ON rn.idsegment = rna.idsegment
WHERE seaidsegment IN ('SP113212','SP112952')
AND drought='1')
UPDATE spain.rna SET 
(drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --39
 
 
  WITH dryriver AS (
SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
JOIN spain.rna ON rn.idsegment = rna.idsegment
WHERE seaidsegment IN ('SP113482')
AND drought IN ('1','5'))
UPDATE spain.rna SET 
(drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --4

   WITH dryriver AS (
SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
JOIN spain.rna ON rn.idsegment = rna.idsegment
WHERE seaidsegment IN ('SP112875','SP112875')
AND drought IN ('1','5'))
UPDATE spain.rna SET 
(drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --2
 
 
 UPDATE spain.rna SET 
(drought,drought_type_calc) = (1,'River considered as permanent (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado, the river is considered as eel
habitat below and in the reservoir') 
WHERE idsegment IN (
SELECT idsegment FROM spain.waterbody_unitbv WHERE id= 104)
OR idsegment IN (SELECT spain.downstream_segments_rn('SP110967')) ;--29


   WITH dryriver AS (
SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
JOIN spain.rna ON rn.idsegment = rna.idsegment
WHERE seaidsegment IN ('SP112744')
AND drought IN ('1','5'))
UPDATE spain.rna SET 
(drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --2
 
 
 
   WITH dryriver AS (
SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
JOIN spain.rna ON rn.idsegment = rna.idsegment
WHERE seaidsegment IN ('SP109550','SP108960')
AND drought IN ('1','5'))
UPDATE spain.rna SET 
(drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --4
 
 
    WITH dryriver AS (
SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
JOIN spain.rna ON rn.idsegment = rna.idsegment
WHERE seaidsegment IN ('SP105415','SP102445','SP109671')
AND drought IN ('1','5'))
UPDATE spain.rna SET 
(drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --4
 
 
     WITH dryriver AS (
SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
JOIN spain.rna ON rn.idsegment = rna.idsegment
WHERE seaidsegment IN ('SP101496','SP98388')
AND drought IN ('1','5'))
UPDATE spain.rna SET 
(drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --2
 
 
      WITH dryriver AS (
SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
JOIN spain.rna ON rn.idsegment = rna.idsegment
WHERE seaidsegment IN ('SP87021','SP86822','SP86296','SP85307', 'SP85841' )
AND drought IN ('1','5'))
UPDATE spain.rna SET 
(drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --6
 
 
  UPDATE spain.rna SET 
(drought,drought_type_calc) = (1,'River considered as permanent (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado, the river is considered as eel
habitat below and in the reservoir') 
WHERE idsegment IN (SELECT spain.downstream_segments_rn('SP64101')); --2


  UPDATE spain.rna SET 
(drought,drought_type_calc) = (1,'River considered as permanent (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado, the river is considered as eel
habitat below and in the reservoir') 
WHERE idsegment IN (
SELECT idsegment FROM spain.waterbody_unitbv WHERE id= 861); --9



      WITH dryriver AS (
SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
JOIN spain.rna ON rn.idsegment = rna.idsegment
WHERE seaidsegment IN ('SP64573')
AND drought IN ('1','5'))
UPDATE spain.rna SET 
(drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --1
 
 
   UPDATE spain.rna SET 
(drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
WHERE idsegment IN (
SELECT spain.upstream_segments_rn('SP59505'));--203



WITH dryriver AS (
 SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
 JOIN spain.rna ON rn.idsegment = rna.idsegment
 WHERE seaidsegment IN ('SP324525')
 AND drought IN ('1','5'))
UPDATE spain.rna SET 
 (drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
 orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --1
 
 
 WITH dryriver AS (
 SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
 JOIN spain.rna ON rn.idsegment = rna.idsegment
 WHERE seaidsegment IN ('SP38551')
 AND drought IN ('1','5'))
UPDATE spain.rna SET 
 (drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
 orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --1
 
 
 UPDATE spain.rna SET 
(drought,drought_type_calc) = (3,'River segment isolated among dry rivers')    
WHERE idsegment = 'SP36607';


 WITH dryriver AS (
 SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
 JOIN spain.rna ON rn.idsegment = rna.idsegment
 WHERE seaidsegment IN ('SP25575','SP23248','SP19372')
 AND drought IN ('1','5','2'))
UPDATE spain.rna SET 
 (drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
 orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --36
 
 
 
  WITH dryriver AS (
 SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
 JOIN spain.rna ON rn.idsegment = rna.idsegment
 WHERE seaidsegment IN ('SP148014', 'SP147779','SP147957','SP148094','SP147433')
 AND drought IN ('1','5'))
UPDATE spain.rna SET 
 (drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
 orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --8
 
 
 
  
WITH dryriver AS (
 SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
 JOIN spain.rna ON rn.idsegment = rna.idsegment
 WHERE seaidsegment IN ('SP147321', 'SP147294','SP147003','SP146557','SP146269')
 AND drought IN ('1','5','2'))
UPDATE spain.rna SET 
 (drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
 orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --213
 
 
 WITH dryriver AS (
 SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
 JOIN spain.rna ON rn.idsegment = rna.idsegment
 WHERE seaidsegment IN ('SP145511', 'SP142797','SP141577','SP134268','SP139325','SP138816','SP138443','SP137046','SP138681','SP139608')
 AND drought IN ('1','5','2'))
UPDATE spain.rna SET 
 (drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
 orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --105
 
 
  WITH dryriver AS (
 SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
 JOIN spain.rna ON rn.idsegment = rna.idsegment
 WHERE seaidsegment IN ('SP118715','SP118291','SP133042','SP11454')
 AND drought IN ('1','5','2'))
UPDATE spain.rna SET 
 (drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
 orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --93
 
 
   WITH dryriver AS (
 SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
 JOIN spain.rna ON rn.idsegment = rna.idsegment
 WHERE seaidsegment IN ('SP125041','SP124581')
 AND drought IN ('1','5','2'))
UPDATE spain.rna SET 
 (drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
 orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --2
 
 
    WITH dryriver AS (
 SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
 JOIN spain.rna ON rn.idsegment = rna.idsegment
 WHERE seaidsegment IN ('SP150536')
 AND drought IN ('1','5','2'))
UPDATE spain.rna SET 
 (drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
 orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --1
 
 
   UPDATE spain.rna SET 
(drought,drought_type_calc) = (1,'River considered as permanent (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado, the river is considered as eel
habitat below and in the reservoir') 
WHERE idsegment IN (SELECT spain.downstream_segments_rn('SP41214')); --2

   UPDATE spain.rna SET 
(drought,drought_type_calc) = (1,'River considered as permanent (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado, the river is considered as eel
habitat below and in the reservoir') 
WHERE idsegment IN (SELECT spain.downstream_segments_rn('SP39968')); --2


   UPDATE spain.rna SET 
(drought,drought_type_calc) = (1,'River considered as permanent (habitat for eel) after verification using hydrographic districts map,
orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado, the river is considered as eel
habitat below and in the reservoir') 
WHERE idsegment IN (SELECT spain.downstream_segments_rn('SP64855')); --2


    WITH dryriver AS (
 SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
 JOIN spain.rna ON rn.idsegment = rna.idsegment
 WHERE seaidsegment IN ('SP87432')
 AND drought IN ('1','5','2'))
UPDATE spain.rna SET 
 (drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
 orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --2

    WITH dryriver AS (
 SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
 JOIN spain.rna ON rn.idsegment = rna.idsegment
 WHERE seaidsegment IN ('SP324892')
 AND drought IN ('1','5','2'))
UPDATE spain.rna SET 
 (drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
 orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --64
 
 
   WITH dryriver AS (
 SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
 JOIN spain.rna ON rn.idsegment = rna.idsegment
 WHERE seaidsegment IN ('SP149051','SP12124','SP150202','SP150351')
 AND drought IN ('1','5','2'))
UPDATE spain.rna SET 
 (drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
 orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --25

 
 
  WITH dryriver AS (
 SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
 JOIN spain.rna ON rn.idsegment = rna.idsegment
 WHERE seaidsegment IN ('SP149432','SP149453')
 AND drought IN ('1','5','2'))
UPDATE spain.rna SET 
 (drought,drought_type_calc) = (3,'River considered as ephemrous (habitat for eel) after verification using hydrographic districts map,
 orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --18
 
  WITH dryriver AS (
 SELECT rn.idsegment, drought, drought_type_calc FROM  
 spain.rn
 JOIN spain.rna ON rn.idsegment = rna.idsegment
 WHERE rn.idsegment IN ('SP149432','SP149453')
 AND drought IN ('3'))
UPDATE spain.rna SET 
 (drought,drought_type_calc) = (2,'Estuarine habitat for eel  after verification using hydrographic districts map,
 orthophotos and personal knowledge, source University of Cordoba, Mercedes Herrera, Carlos Fernandez Delgado') 
 FROM dryriver WHERE rna.idsegment = dryriver.idsegment; --2
 
 ----------------
 -- Ticket 176
-------------------

 -- couche des estuaires
 
 
 WITH estuaries AS ( SELECT wu.* FROM portugal.waterbody_unitbv wu  
 WHERE categoria = 'TW' )
 UPDATE portugal.rna SET (drought, drought_type_calc ) = (1, 'Set to 1 because connected to estuary')
 FROM estuaries WHERE estuaries.idsegment=rna.idsegment; --1586

 
  WITH estuaries AS ( SELECT rn.* FROM portugal.waterbody_unitbv wu  
 JOIN spain.rn ON st_intersects(rn.geom, wu.geom)
  WHERE categoria = 'TW') 
 UPDATE spain.rna SET (drought, drought_type_calc ) = (1, 'Set to 1 because connected to estuary treatment similar to Portugal on the other side')
 FROM estuaries WHERE estuaries.idsegment=rna.idsegment; --149
 
  ----------------
 -- Ticket 183 duplicated waterbodies
-------------------

CREATE TEMPORARY SEQUENCE seq;
DROP TABLE temp_portugal ;
CREATE TABLE temp_portugal AS(
WITH commonw AS ( 
SELECT st_union(s.geom) geom FROM portugal.waterbody_unitbv p
JOIN spain.waterbody_unitbv s ON ST_intersects(s.geom, p.geom))
SELECT nextval('seq') AS id, idsegment, (st_dump(st_difference(p.geom, c.geom ))).geom geom FROM 
portugal.waterbody_unitbv p JOIN commonw c ON ST_intersects(c.geom, p.geom)) --4594

DROP TABLE temp_portugal_crap;
CREATE TABLE temp_portugal_crap AS(
SELECT t.* FROM temp_portugal t JOIN 
spain.basinunit_bu bu ON st_covers(bu.geom, t.geom));--3396

-- still some here

DROP TABLE IF EXISTS temp_portugal_crap2;
CREATE TABLE temp_portugal_crap2 AS(
SELECT t.* FROM temp_portugal t JOIN 
spain.wise_rbd_f1v3 bu ON st_covers(bu.the_geom, st_transform(t.geom,25830)));--559


DELETE FROM temp_portugal WHERE id IN (SELECT id FROM temp_portugal_crap); --3396
DELETE FROM temp_portugal WHERE id IN (SELECT id FROM temp_portugal_crap2); --3396
-- try to identify long and narrow polygons created by the buffer
DROP TABLE temp_portugalb;
CREATE TABLE temp_portugalb AS(
WITH commonw AS ( 
SELECT st_buffer(st_union(s.geom) , 10) geom FROM portugal.waterbody_unitbv p
JOIN spain.waterbody_unitbv s ON ST_intersects(s.geom, p.geom))
SELECT idsegment, st_difference(p.geom, c.geom ) FROM 
portugal.waterbody_unitbv p JOIN commonw c ON ST_intersects(c.geom, p.geom));


-- split multi into parts



ALTER TABLE portugal.waterbody_unitbv ADD COLUMN id_ SERIAL PRIMARY KEY;
SELECT * FROM temp_portugal



WITH to_update AS (
SELECT id_, t.geom FROM temp_portugal t JOIN portugal.waterbody_unitbv u
ON st_intersects (st_buffer(t.geom,-10), u.geom))
UPDATE portugal.waterbody_unitbv SET geom = t.geom FROM to_update t WHERE t.id_= waterbody_unitbv.id_; --432





CREATE TABLE temp_portugal3 AS(
SELECT DISTINCT ON(id_) id_, p.geom  FROM portugal.waterbody_unitbv p JOIN spain.waterbody_unitbv s
ON st_intersects (st_buffer(p.geom,-10), s.geom))

SELECT * FROM temp_portugal3

----------------
-- Ticket 177 duplicated waterbodies
-------------------


-- adding Mar menor
INSERT INTO spain.waterbody_unitbv 
SELECT
NULL AS idsegment,
id,
cod_masa,
nom_masa,
categoria,
naturalida,
tipona_cod,
dh_cod,
dh_nom,
tipona_nom,
tipocalib,
num_tipoca,
internac,
embalse,
geom,
1 AS perc_rn_notcovered FROM spain.masas_agua WHERE id=1046;


----------------------------
-- PRODUCTION IN ESTUARIES WATERBODIES SHOULD NOT BE 0 BECAUSE ATTACHED RIVERSEGMENT IS DRY
---------------------------

 WITH estuaries AS ( SELECT wu.* FROM spain.waterbody_unitbv wu  
 WHERE categoria = 'TW' )
 UPDATE spain.rna SET (drought, drought_type_calc ) = (1, 'Set to 1 because connected to estuary')
 FROM estuaries WHERE estuaries.idsegment=rna.idsegment; --1526



----------
-- CREATING CATEGORIES FOR WATERBODIES SPAIN
-------------

ALTER TABLE spain.waterbody_unitbv ADD COLUMN id_ serial PRIMARY KEY;

DROP TABLE IF exists spain.temp_type_habitat_spain;
CREATE TABLE spain.temp_type_habitat_spain (tipona_nom TEXT,	categoria TEXT,	embalse TEXT,	sudoang_category TEXT);
COPY spain.temp_type_habitat_spain FROM 'F:/eda/data/eda2.3/type_habitat_spain.csv' WITH CSV HEADER DELIMITER AS ';' ENCODING 'WIN1252'; --99

ALTER TABLE spain.waterbody_unitbv ADD COLUMN sudoang_category TEXT;

WITH jjj AS (
	SELECT id_,tth.sudoang_category  FROM spain.waterbody_unitbv ma JOIN spain.temp_type_habitat_spain tth 
	ON (ma.tipona_nom,ma.categoria,ma.embalse) = (tth.tipona_nom,tth.categoria,tth.embalse) 
) UPDATE spain.waterbody_unitbv SET sudoang_category = jjj.sudoang_category
FROM jjj WHERE jjj.id_=waterbody_unitbv.id_; 18732

SELECT * FROM  spain.waterbody_unitbv WHERE sudoang_category IS NULL;
SELECT distinct(sudoang_category) FROM  spain.waterbody_unitbv ;


-- simplifying categories
UPDATE spain.waterbody_unitbv SET sudoang_category='estuary' WHERE sudoang_category LIKE '%estuary%';
UPDATE spain.waterbody_unitbv SET sudoang_category='lagoon' WHERE sudoang_category LIKE '%lagune%';--1611 (les deux)
UPDATE spain.waterbody_unitbv SET sudoang_category='estuary' WHERE sudoang_category LIKE '%TW_atl%'; --64
UPDATE spain.waterbody_unitbv SET sudoang_category='coastal_waters' WHERE sudoang_category LIKE '%coastal_waters%'; --905

ALTER TABLE portugal.waterbody_unitbv ADD COLUMN sudoang_category TEXT;
UPDATE portugal.waterbody_unitbv SET sudoang_category='reservoir' WHERE  nome LIKE '%Albufeira%'; --4719
UPDATE portugal.waterbody_unitbv SET sudoang_category='estuary' WHERE  categoria LIKE 'TW'; --1807
SELECT distinct(sudoang_category) FROM  portugal.waterbody_unitbv ;
SELECT * FROM portugal.waterbody_unitbv WHERE sudoang_category IS NULL;


UPDATE  portugal.rna SET drought_type_calc = 'Stream flow >0.1'
WHERE drought='1' AND drought_type_calc ILIKE '%probably no stream%' AND dis_m3_pyr_riveratlas >0.1; --8144

/* 
 * WE checked with Maria some of those are large streams....
 * We need to change them
 * 
 */

WITH downstream_duero AS (
SELECT dbeel_rivers.downstream_segments_rn('SP309409') idsegment),
duero AS (
SELECT * FROM portugal.waterbody_unitbv u JOIN
dbeel_rivers.rn ON st_intersects(st_buffer(rn.geom, 100), u.geom)
JOIN downstream_duero ON downstream_duero.idsegment= rn.idsegment
WHERE categoria='RW'
)
UPDATE portugal.waterbody_unitbv SET sudoang_category ='river' FROM duero WHERE 
duero.id_=waterbody_unitbv.id_;--718 

UPDATE portugal.waterbody_unitbv SET sudoang_category ='river' WHERE codigo IN ('PT03DOU0415','PT03DOU0328','PT03DOU0295',
'PT03DOU0275','PT03DOU0245'); --223


-- same for spain
WITH downstream_duero AS (
SELECT dbeel_rivers.downstream_segments_rn('SP309409') idsegment),
duero AS (
SELECT * FROM spain.waterbody_unitbv u JOIN
dbeel_rivers.rn ON st_intersects(st_buffer(rn.geom, 100), u.geom)
JOIN downstream_duero ON downstream_duero.idsegment= rn.idsegment
)
UPDATE spain.waterbody_unitbv SET sudoang_category ='river' FROM duero WHERE 
duero.id_=waterbody_unitbv.id_;--246 


WITH downstream_tagus AS (
SELECT dbeel_rivers.downstream_segments_rn('SP210221') idsegment),
tagus AS (
SELECT * FROM portugal.waterbody_unitbv u JOIN
dbeel_rivers.rn ON st_intersects(st_buffer(rn.geom, 100), u.geom)
JOIN downstream_tagus ON downstream_tagus.idsegment= rn.idsegment
WHERE categoria='RW'
)
UPDATE portugal.waterbody_unitbv SET sudoang_category ='river' FROM tagus WHERE 
tagus.id_=waterbody_unitbv.id_;--228 7m

WITH downstream_tagus AS (
SELECT dbeel_rivers.downstream_segments_rn('SP210221') idsegment),
tagus AS (
SELECT * FROM spain.waterbody_unitbv u JOIN
dbeel_rivers.rn ON st_intersects(st_buffer(rn.geom, 100), u.geom)
JOIN downstream_tagus ON downstream_tagus.idsegment= rn.idsegment
WHERE categoria='RW'
)
UPDATE spain.waterbody_unitbv SET sudoang_category ='river' FROM tagus WHERE 
tagus.id_=waterbody_unitbv.id_;--165


UPDATE portugal.waterbody_unitbv SET sudoang_category ='river' WHERE codigo IN ('PT01LIM0036');--21


UPDATE spain.waterbody_unitbv SET sudoang_category ='lagoon' WHERE cod_masa IN ('ES080MSPFL06');--3
-- en Espagne, il y a des marais (358 lignes) qui sont indiqu�s comme "lagune", "lake" ou "estuaire" (la plupart), devons-nous ajouter une nouvelle cat�gorie pour "marais" ?

update spain.waterbody_unitbv set sudoang_category = 'marsh' where nom_masa like 'Marisma%';--358

update portugal.waterbody_unitbv set sudoang_category = 'lake' where nome = 'Lagoa da Ervedeira';
update portugal.waterbody_unitbv set sudoang_category = 'lake' where nome = 'Lagoa dos Patos';
update portugal.waterbody_unitbv set sudoang_category = 'lake' where nome = 'Pateira de Fermentelos';



----------
-- ADDING MARSHES IN SPAIN
-------------

-- In Spain there are marshes that are indicated as 'lagoon' or 'estuary', must we add new category for 'marsh'?
select count(*) from spain.waterbody_unitbv where nom_masa like 'Marisma%'; -- 358 rows
update spain.waterbody_unitbv set sudoang_category = 'marsh' where nom_masa like 'Marisma%';


----------
-- ADDING LAGOONS IN PORTUGAL
-------------

--		1. Import lagoon table in Portugal (QGis)
ALTER table lagoons SET SCHEMA portugal;

--		2. Searching the idsegment associated for each lagoon
SELECT Find_SRID('portugal', 'lagoons', 'geom'); -- 3763

-- SELECT UpdateGeometrySRID('portugal', 'lagoons', 'geom', 3035);
ALTER TABLE  portugal.lagoons
  ALTER COLUMN geom
    TYPE geometry(MULTIPOLYGON, 3035)
    USING ST_Transform(geom, 3035);

alter table portugal.lagoons add column idsegment text;

BEGIN;
with jsub as (
	SELECT rn.idsegment, id, st_length(st_intersection(rn.geom,b.geom)) len
	FROM portugal.rn join portugal.lagoons b on st_intersects(rn.geom, b.geom
), -- getting the longest segment for the join
jsub1 as (
	SELECT distinct on (id) * FROM jsub order by id, len desc
)
UPDATE portugal.lagoons set idsegment = jsub1.idsegment FROM jsub1 where jsub1.id = lagoons.id; -- 16 rows
COMMIT; 

--		3. Importing into the waterbody_unitbv table with 'lagoon' category
begin;
INSERT INTO portugal.waterbody_unitbv (
		idsegment,
		nome,
		geom,
		id_,
		sudoang_category)		
	SELECT		
		idsegment as idsegment,
		nome as nome,
		geom as geom,
		idhidro as id_,
		'lagoon' as sudoang_category 
	from portugal.lagoons; -- 16 rows
COMMIT;

--		4. Correcting some points
delete from portugal.waterbody_unitbv where nome = 'Lagoa do Peneireiro'; -- dry in Google maps

update portugal.waterbody_unitbv set sudoang_category = 'lake' where nome = 'Lagoa da Ervedeira';
update portugal.waterbody_unitbv set sudoang_category = 'lake' where nome = 'Lagoa dos Patos';
update portugal.waterbody_unitbv set sudoang_category = 'lake' where nome = 'Pateira de Fermentelos';



----------
-- CORRECTING NULL CATEGORIES in PORTUGAL
-------------

SELECT * FROM portugal.waterbody_unitbv WHERE ubv_sudoang_category IS NULL;

update portugal.waterbody_unitbv set ubv_sudoang_category = 'reservoir' where ubv_name = 'Acude Ponte Coimbra' and ubv_sudoang_category IS null; 		-- 13 rows
update portugal.waterbody_unitbv set ubv_sudoang_category = 'temporary_lake' where ubv_name = 'Acude Vale Coelheiros' and ubv_sudoang_category IS null; -- 9 rows
update portugal.waterbody_unitbv set ubv_sudoang_category = 'reservoir' where ubv_name = 'Acude Vale das Bicas' and ubv_sudoang_category IS null; 		-- 2 rows
update portugal.waterbody_unitbv set ubv_sudoang_category = 'temporary_lake' where ubv_name = 'Acude Vale de Pocos' and ubv_sudoang_category IS null; 	-- 7 rows



----------
-- INTEGRATE CHANGES BACK IN RNA
-------------

SELECT DISTINCT ubv_sudoang_category FROM dbeel_rivers.waterbody_unitbv ORDER BY 1;

/*
canal
coastal_waters
estuary
lagoon
lake
marsh
reservoir
river
temporary_lake
*/

-- Create columns in dbeel_rivers.rna

alter table dbeel_rivers.rna add column wettedasurface_riverm2 numeric;
alter table dbeel_rivers.rna add column wettedasurface_estuarym2 numeric;
alter table dbeel_rivers.rna add column wettedasurface_lagoonm2 numeric;
alter table dbeel_rivers.rna add column wettedasurface_reservoirm2 numeric;
alter table dbeel_rivers.rna add column wettedasurface_lakem2 numeric;
alter table dbeel_rivers.rna add column wettedasurface_temp_lakem2 numeric;


-- PORTUGAL
/* Regarding the wetted area in portugal.waterbody_unitbv and wettedsurfaceotherm2 from portugal.rna

select count(distinct ubv_idsegment) from portugal.waterbody_unitbv; -- 5845

with ggg as(
select ubv_idsegment, sum(st_area(geom)) as wettedarea FROM portugal.waterbody_unitbv group by ubv_idsegment
)
--select count(idsegment) from ggg JOIN portugal.rna on (rna.idsegment = ggg.ubv_idsegment)  -- 5845
select ggg.*, idsegment, wettedsurfaceotherm2 from ggg JOIN portugal.rna on (rna.idsegment = ggg.ubv_idsegment)

-- The portuguese total surface is the same in both tables, except the portuguese lagoons that there aren't in wettedsurfaceotherm2
***/ 


update portugal.rna set wettedsurfaceotherm2=NULL; --75056
WITH wettedarea AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea 
	FROM portugal.waterbody_unitbv 
	group by ubv_idsegment),
river AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea_river 
	FROM portugal.waterbody_unitbv 
	WHERE ubv_sudoang_category = 'canal' OR ubv_sudoang_category ='river'
	group by ubv_idsegment),
estuary AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea_estuary 
	FROM portugal.waterbody_unitbv 
	WHERE ubv_sudoang_category = 'estuary'
	group by ubv_idsegment),
lagoon AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea_lagoon 
	FROM portugal.waterbody_unitbv 
	WHERE ubv_sudoang_category = 'lagoon' OR ubv_sudoang_category = 'marsh' OR ubv_sudoang_category = 'coastal_waters'
	group by ubv_idsegment),
reservoir AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea_reservoir 
	FROM portugal.waterbody_unitbv 
	WHERE ubv_sudoang_category = 'reservoir'
	group by ubv_idsegment),
lake AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea_lake
	FROM portugal.waterbody_unitbv 
	WHERE ubv_sudoang_category = 'lake'
	group by ubv_idsegment),
temp_lake AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea_temp_lake 
	FROM portugal.waterbody_unitbv 
	WHERE ubv_sudoang_category = 'temporary_lake'
	group by ubv_idsegment),
joined AS (
	SELECT wettedarea.ubv_idsegment,
	wettedarea,
	wettedarea_river,
	wettedarea_estuary,
	wettedarea_lagoon,
	wettedarea_reservoir,
	wettedarea_lake,
	wettedarea_temp_lake
	FROM wettedarea 
	LEFT JOIN
	river ON wettedarea.ubv_idsegment=river.ubv_idsegment
	LEFT JOIN
	estuary ON wettedarea.ubv_idsegment=estuary.ubv_idsegment
	LEFT JOIN
	lagoon ON wettedarea.ubv_idsegment=lagoon.ubv_idsegment
	LEFT JOIN
	reservoir ON wettedarea.ubv_idsegment=reservoir.ubv_idsegment
	LEFT JOIN
	lake ON wettedarea.ubv_idsegment=lake.ubv_idsegment
	LEFT JOIN
	temp_lake ON wettedarea.ubv_idsegment=temp_lake.ubv_idsegment)
--SELECT joined.*, idsegment, wettedsurfaceotherm2 FROM joined join portugal.rna on rna.idsegment = ubv_idsegment -- where wettedsurfaceotherm2 is null;
update portugal.rna set 
	(wettedsurfaceotherm2,wettedasurface_riverm2, wettedasurface_estuarym2, wettedasurface_lagoonm2, wettedasurface_reservoirm2, wettedasurface_lakem2, wettedasurface_temp_lakem2)  = 
	(wettedarea,wettedarea_river, wettedarea_estuary, wettedarea_lagoon, wettedarea_reservoir, wettedarea_lake, wettedarea_temp_lake)
from joined where joined.ubv_idsegment = rna.idsegment; -- 5845 rows 



-- TODO: update wettedsurfaceotherm2 with the surface of lagoons/lakes


-- SPAIN
/* Regarding the wetted area in spain.waterbody_unitbv and wettedsurfaceotherm2 from spain.rna

select count(distinct ubv_idsegment) from spain.waterbody_unitbv; -- 18281

with ggg as(
select ubv_idsegment, sum(st_area(geom)) as wettedarea FROM spain.waterbody_unitbv group by ubv_idsegment
)
--select count(idsegment) from ggg JOIN spain.rna on (rna.idsegment = ggg.ubv_idsegment)  -- 18281
select ggg.*, idsegment, wettedsurfaceotherm2 from ggg JOIN spain.rna on (rna.idsegment = ggg.ubv_idsegment)

-- The Spanish total surface is the same in both tables
***/ 

update spain.rna set wettedsurfaceotherm2=NULL;--325399
WITH wettedarea AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea 
	FROM spain.waterbody_unitbv 
	group by ubv_idsegment),
river AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea_river 
	FROM spain.waterbody_unitbv 
	WHERE ubv_sudoang_category = 'canal' OR ubv_sudoang_category ='river'
	group by ubv_idsegment),
estuary AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea_estuary 
	FROM spain.waterbody_unitbv 
	WHERE ubv_sudoang_category = 'estuary'
	group by ubv_idsegment),
lagoon AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea_lagoon 
	FROM spain.waterbody_unitbv 
	WHERE ubv_sudoang_category = 'lagoon' OR ubv_sudoang_category = 'marsh' OR ubv_sudoang_category = 'coastal_waters'
	group by ubv_idsegment),
reservoir AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea_reservoir 
	FROM spain.waterbody_unitbv 
	WHERE ubv_sudoang_category = 'reservoir'
	group by ubv_idsegment),
lake AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea_lake
	FROM spain.waterbody_unitbv 
	WHERE ubv_sudoang_category = 'lake'
	group by ubv_idsegment),
temp_lake AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea_temp_lake 
	FROM spain.waterbody_unitbv 
	WHERE ubv_sudoang_category = 'temporary_lake'
	group by ubv_idsegment),
joined AS (
	SELECT wettedarea.ubv_idsegment,
	wettedarea,
	wettedarea_river,
	wettedarea_estuary,
	wettedarea_lagoon,
	wettedarea_reservoir,
	wettedarea_lake,
	wettedarea_temp_lake
	FROM wettedarea 
	LEFT JOIN
	river ON wettedarea.ubv_idsegment=river.ubv_idsegment
	LEFT JOIN
	estuary ON wettedarea.ubv_idsegment=estuary.ubv_idsegment
	LEFT JOIN
	lagoon ON wettedarea.ubv_idsegment=lagoon.ubv_idsegment
	LEFT JOIN
	reservoir ON wettedarea.ubv_idsegment=reservoir.ubv_idsegment
	LEFT JOIN
	lake ON wettedarea.ubv_idsegment=lake.ubv_idsegment
	LEFT JOIN
	temp_lake ON wettedarea.ubv_idsegment=temp_lake.ubv_idsegment)
--SELECT joined.*, idsegment, wettedsurfaceotherm2 FROM joined join spain.rna on rna.idsegment = ubv_idsegment -- where wettedsurfaceotherm2 is null; -- 0
update spain.rna set 
	(wettedsurfaceotherm2,wettedasurface_riverm2, wettedasurface_estuarym2, wettedasurface_lagoonm2, wettedasurface_reservoirm2, wettedasurface_lakem2, wettedasurface_temp_lakem2)  = 
	(wettedarea,wettedarea_river, wettedarea_estuary, wettedarea_lagoon, wettedarea_reservoir, wettedarea_lake, wettedarea_temp_lake)
from joined where joined.ubv_idsegment = rna.idsegment; -- 18281 rows 



-- FRANCE
/* Regarding the wetted area in france.waterbody_unitbv and wettedsurfaceotherm2 from france.rna

select count(distinct ubv_idsegment) from france.waterbody_unitbv; -- 89787

with ggg as(
select ubv_idsegment, sum(st_area(geom)) as wettedarea FROM france.waterbody_unitbv group by ubv_idsegment
)
--select count(idsegment) from ggg JOIN france.rna on (rna.idsegment = ggg.ubv_idsegment)  -- 89787
select ggg.*, idsegment, wettedsurfaceotherm2 from ggg JOIN france.rna on (rna.idsegment = ggg.ubv_idsegment)

-- The French total surface is the same in both tables
***/ 

update france.rna set wettedsurfaceotherm2=NULL;--114556
WITH wettedarea AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea 
	FROM france.waterbody_unitbv 
	group by ubv_idsegment),
river AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea_river 
	FROM france.waterbody_unitbv 
	WHERE ubv_sudoang_category = 'canal' OR ubv_sudoang_category ='river'
	group by ubv_idsegment),
estuary AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea_estuary 
	FROM france.waterbody_unitbv 
	WHERE ubv_sudoang_category = 'estuary'
	group by ubv_idsegment),
lagoon AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea_lagoon 
	FROM france.waterbody_unitbv 
	WHERE ubv_sudoang_category = 'lagoon' OR ubv_sudoang_category = 'marsh' OR ubv_sudoang_category = 'coastal_waters'
	group by ubv_idsegment),
reservoir AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea_reservoir 
	FROM france.waterbody_unitbv 
	WHERE ubv_sudoang_category = 'reservoir'
	group by ubv_idsegment),
lake AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea_lake
	FROM france.waterbody_unitbv 
	WHERE ubv_sudoang_category = 'lake'
	group by ubv_idsegment),
temp_lake AS (
	select ubv_idsegment, round(sum(st_area(geom))::numeric,2) as wettedarea_temp_lake 
	FROM france.waterbody_unitbv 
	WHERE ubv_sudoang_category = 'temporary_lake'
	group by ubv_idsegment),
joined AS (
	SELECT wettedarea.ubv_idsegment,
	wettedarea,
	wettedarea_river,
	wettedarea_estuary,
	wettedarea_lagoon,
	wettedarea_reservoir,
	wettedarea_lake,
	wettedarea_temp_lake
	FROM wettedarea 
	LEFT JOIN
	river ON wettedarea.ubv_idsegment=river.ubv_idsegment
	LEFT JOIN
	estuary ON wettedarea.ubv_idsegment=estuary.ubv_idsegment
	LEFT JOIN
	lagoon ON wettedarea.ubv_idsegment=lagoon.ubv_idsegment
	LEFT JOIN
	reservoir ON wettedarea.ubv_idsegment=reservoir.ubv_idsegment
	LEFT JOIN
	lake ON wettedarea.ubv_idsegment=lake.ubv_idsegment
	LEFT JOIN
	temp_lake ON wettedarea.ubv_idsegment=temp_lake.ubv_idsegment)
--SELECT joined.*, idsegment, wettedsurfaceotherm2 FROM joined join france.rna on rna.idsegment = ubv_idsegment -- where wettedsurfaceotherm2 is null; -- FR501254
update france.rna set 
	(wettedsurfaceotherm2, wettedasurface_riverm2, wettedasurface_estuarym2, wettedasurface_lagoonm2, wettedasurface_reservoirm2, wettedasurface_lakem2, wettedasurface_temp_lakem2)  = 
	(wettedarea,wettedarea_river, wettedarea_estuary, wettedarea_lagoon, wettedarea_reservoir, wettedarea_lake, wettedarea_temp_lake)
from joined where joined.ubv_idsegment = rna.idsegment; -- 89787 rows 


SELECT * FROM sudoang.view_obstruction WHERE op_id = '2919fe0b-0e03-4e65-b0e6-05f46456b75d' -- ==> two ob_id
SELECT * FROM sudoang.view_obstruction WHERE op_id = '623d218a-b295-49f7-af38-919019f0d58d' -- ==> two ob_id
SELECT * FROM sudoang.view_obstruction WHERE op_id ='94602adf-c264-4dec-9cfa-ce9c043570f5' -- => this one is a duplicate because loaded both in France and spain at the frontier


ASP_57747 (op_id =  -> France not Spain


SELECT * FROM dbeel_rivers.rna WHERE wettedarea !=