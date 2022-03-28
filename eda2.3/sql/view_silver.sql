/*
SELECT * 
FROm sudoang.view_electrofishing
JOIN sudoang.dbeel_batch_fish ON ba_ob_id = ob_id
JOIN sudoang.dbeel_mensurationindiv_biol_charac ON bc_ba_id=ba_id
-- nomenclature table
JOIN dbeel_nomenclature.biological_characteristic_type ON bc_no_characteristic_type = biological_characteristic_type.no_id
JOIN dbeel_nomenclature.species ON ba_no_species = species.no_id
JOIN dbeel_nomenclature.value_type ON ba_no_value_type = value_type.no_id
WHERE species.no_name = 'Anguilla anguilla'
AND value_type.no_name = 'Raw data or Individual data')
*/

-- Install the additional module tablefunc once per database, which provides the function crosstab()
-- CREATE EXTENSION IF NOT EXISTS tablefunc;

DROP VIEW IF EXISTS sudoang.view_silvering_bc CASCADE;
CREATE VIEW sudoang.view_silvering_bc AS (
select * FROM crosstab('SELECT ba_id, biological_characteristic_type.no_name, bc_numvalue 
FROM sudoang.dbeel_batch_fish 
JOIN sudoang.dbeel_mensurationindiv_biol_charac ON bc_ba_id=ba_id
-- nomenclature table
JOIN dbeel_nomenclature.biological_characteristic_type ON bc_no_characteristic_type = biological_characteristic_type.no_id
JOIN dbeel_nomenclature.species ON ba_no_species = species.no_id
JOIN dbeel_nomenclature.value_type ON ba_no_value_type = value_type.no_id
WHERE species.no_name = ''Anguilla anguilla''
AND value_type.no_name = ''Raw data or Individual data''
ORDER by 1,2',
'SELECT no_name FROM dbeel_nomenclature.biological_characteristic_type 
where no_name IN(''Length'',
		''Weight'',
		''Sex'',
		''Stage'',
		''eye_diam_vert'',
		''eye_diam_horiz'',
		''length_pect'',
		''presence_neuromast'',
		''contrast'')
 ORDER BY CASE WHEN no_name=''Length'' then 1
	       WHEN no_name=''Weight'' THEN 2
	       WHEN no_name=''Sex'' THEN 3
	       WHEN no_name=''Stage'' THEN 4
	       WHEN no_name=''eye_diam_vert'' THEN 5
	       WHEN no_name=''eye_diam_horiz'' THEN 6
	       when no_name=''length_pect'' THEN 7
	       WHEN no_name=''presence_neuromast'' THEN 8
	       WHEN no_name=''contrast'' THEN 9 END') AS ("ba_id" uuid, 
									"length" numeric, 
									"weight" NUMERIC, 
									"sex" NUMERIC, 
									"stage" NUMERIC, 
									"eye_diam_vert" NUMERIC,
									"eye_diam_horiz" NUMERIC,
									"length_pect" NUMERIC, 
									"presence_neuromast" NUMERIC, 
									"contrast" NUMERIC
									)); --8.6 s

									
DROP VIEW IF EXISTS sudoang.view_silvering;									
CREATE VIEW sudoang.view_silvering AS
SELECT 
  dbeel_station.op_id, 
  dbeel_station.locationid, 
  dbeel_station.country,
  establishment.et_establishment_name,
  dbeel_station.x, 
  dbeel_station.y, 
  dbeel_electrofishing.ob_id, 
  dbeel_electrofishing.ob_starting_date, 
  view_silvering_bc.* 
   FROM sudoang.dbeel_station 
  JOIN sudoang.dbeel_electrofishing ON dbeel_station.op_id = dbeel_electrofishing.ob_op_id 
  JOIN sudoang.dbeel_batch_fish ON dbeel_electrofishing.ob_id = dbeel_batch_fish.ba_ob_id
  JOIN sudoang.view_silvering_bc on view_silvering_bc.ba_id =  dbeel_batch_fish.ba_id
  JOIN dbeel.data_provider on dp_id=ob_dp_id
  JOIN dbeel.establishment ON et_id = dp_et_id;

 
 -- SELECT * FROM sudoang.view_silvering;