
/*
In this join table, the st_id corresponds to sta_code (RSA) or st_codecsp (bd_agglo)
*/
DROP TABLE IF EXISTS france.join_station_rn;
CREATE TABLE france.join_station_rn AS (
SELECT 
  sta_code as st_id,
  'FR'||id_drain as idsegment,
  distance,
  id,
  geom,
  TRUE AS a_conserver
FROM  france.rsa_rht

UNION

  SELECT
  st_codecsp as st_id,
 'FR'||id_drain as idsegment,
  distance,
  id,
  geom,
   a_conserver
   FROM
 france.bdmap_rht);-- 16502
