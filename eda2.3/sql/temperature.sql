
/*
 * 
 * SCRIPT TO UPDATE TEMPERATURES FROM THE CCM
 * 
 */



BEGIN;
UPDATE france.rna SET temperature=NULL;
-- extract catchments from ccm
WITH c AS (
  SELECT gid AS catchmentgid, temp_mean, the_geom FROM ccm21.catchments
                where "window" in (2001, 2002, 2003,2004)
                --JOIN europe.wso1 ON wso1.wso1_id=catchments.wso1_id
                --WHERE wso1.area = 'Bretagne'
                ),
                
-- using inner join lateral does not work at all, check if necessary
ii AS (
     SELECT idsegment, geom, c.* 
     FROM france.rn 
     INNER JOIN c
     ON ST_Intersects (rn.geom,c.the_geom)
  ),
-- cut with st_intersection
 clipped AS (
	SELECT catchmentgid, 
	idsegment,
	geom,
	temp_mean,
	(st_dump(ST_Intersection(the_geom, geom))).geom  clipped_geom
	FROM ii 
),

-- the following st_dimension will drop the geom that are not linestrings e.g. points
perclen AS (
	SELECT 
	idsegment,
	temp_mean,
	round((st_length(clipped_geom)/st_length(geom))::numeric,3) AS perclength
	FROM clipped
	where ST_Dimension(clipped.clipped_geom) = 1  
),
weighted_temp AS (
	SELECT 
	idsegment, 
	temp_mean*perclength AS wt,
	perclength
	FROM perclen 
),
 tempe AS (
SELECT idsegment, 
sum(wt)/sum(perclength) AS temperature
FROM weighted_temp
GROUP BY idsegment
)
UPDATE france.rna SET temperature=tempe.temperature FROM tempe WHERE rna.idsegment=tempe.idsegment; --228915 9m59

COMMIT;

/*
 * 
 * SCRIPT TO UPDATE TEMPERATURES FROM THE CCM SPAIN
 * 
 */

BEGIN;
-- extract catchments from ccm
WITH c AS (
  SELECT gid AS catchmentgid, temp_mean, the_geom FROM ccm21.catchments
                where "window" in (2002, 2003,2004)
                --JOIN europe.wso1 ON wso1.wso1_id=catchments.wso1_id
                --WHERE wso1.area = 'Bretagne'
                ),
                
-- using inner join lateral does not work at all, check if necessary
ii AS (
     SELECT idsegment, geom, c.* 
     FROM spain.rn 
     INNER JOIN c
     ON ST_Intersects (rn.geom,c.the_geom)
  ),
-- cut with st_intersection
 clipped AS (
	SELECT catchmentgid, 
	idsegment,
	geom,
	temp_mean,
	(st_dump(ST_Intersection(the_geom, geom))).geom  clipped_geom
	FROM ii 
),

-- the following st_dimension will drop the geom that are not linestrings e.g. points
perclen AS (
	SELECT 
	idsegment,
	temp_mean,
	round((st_length(clipped_geom)/st_length(geom))::numeric,3) AS perclength
	FROM clipped
	where ST_Dimension(clipped.clipped_geom) = 1  
	AND st_length(geom)>0
),
weighted_temp AS (
	SELECT 
	idsegment, 
	temp_mean*perclength AS wt,
	perclength
	FROM perclen 
),
 tempe AS (
SELECT idsegment, 
sum(wt)/sum(perclength) AS temperature
FROM weighted_temp
GROUP BY idsegment
HAVING sum(perclength)>0
)
UPDATE spain.rna SET temperature=tempe.temperature FROM tempe WHERE rna.idsegment=tempe.idsegment;--113217

COMMIT; --1 030 118
-- 17 minutes

/*
 * 
 * SCRIPT TO UPDATE TEMPERATURES FROM THE CCM PORTUGAL
 * 
 */

BEGIN;
-- extract catchments from ccm
WITH c AS (
  SELECT gid AS catchmentgid, temp_mean, the_geom FROM ccm21.catchments
                where "window" in (2002, 2003,2004)
                --JOIN europe.wso1 ON wso1.wso1_id=catchments.wso1_id
                --WHERE wso1.area = 'Bretagne'
                ),
                
-- using inner join lateral does not work at all, check if necessary
ii AS (
     SELECT idsegment, geom, c.* 
     FROM portugal.rn 
     INNER JOIN c
     ON ST_Intersects (rn.geom,c.the_geom)
  ),
-- cut with st_intersection
 clipped AS (
	SELECT catchmentgid, 
	idsegment,
	geom,
	temp_mean,
	(st_dump(ST_Intersection(the_geom, geom))).geom  clipped_geom
	FROM ii 
),

-- the following st_dimension will drop the geom that are not linestrings e.g. points
perclen AS (
	SELECT 
	idsegment,
	temp_mean,
	round((st_length(clipped_geom)/st_length(geom))::numeric,3) AS perclength
	FROM clipped
	WHERE ST_Dimension(clipped.clipped_geom) = 1  
	AND st_length(geom)>0
),
weighted_temp AS (
	SELECT 
	idsegment, 
	temp_mean*perclength AS wt,
	perclength
	FROM perclen 
),
 tempe AS (
SELECT idsegment, 
sum(wt)/sum(perclength) AS temperature
FROM weighted_temp
GROUP BY idsegment
HAVING sum(perclength)>0
)

UPDATE portugal.rna SET temperature=tempe.temperature FROM tempe WHERE rna.idsegment=tempe.idsegment; --75406


COMMIT;

SELECT * FROM france.rna WHERE temperature IS NULL; --213
SELECT * FROM france.rna WHERE temperature IS NULL; -- 0
SELECT * FROM france.rn_rna WHERE temperature=0; 

/*
 * For missing segments at the coast we fetch missing parts from nearby ccm basins
 * 
 */
BEGIN;
WITH getsomemore AS (
SELECT rn.idsegment, st_distance(rn.geom, catchments.the_geom) AS distance, temp_mean FROM FRANCE.rn
JOIN france.rna ON rn.idsegment=rna.idsegment
JOIN  ccm21.catchments ON st_dwithin(rn.geom, catchments.the_geom, 3000)
WHERE temperature IS NULL
AND "window" in (2001, 2002, 2003,2004)),
joined as(
SELECT DISTINCT ON (idsegment) * FROM getsomemore WHERE temp_mean >0 ORDER BY idsegment,distance)
UPDATE france.rna SET temperature=temp_mean FROM joined WHERE joined.idsegment=rna.idsegment; --208
COMMIT;

-- manque encore Sélune et Seine



-- some temperatures are zero, I don't know why but something went wrong in the calculation.
-- correcting this by using upstream segment

WITH problems AS (
SELECT idsegment FROM france.rn_rna WHERE temperature=0),
upstream_solution AS (
SELECT problems.idsegment AS idsegment0, temperature FROM france.rn_rna 
JOIN problems ON rn_rna.nextdownidsegment=problems.idsegment)
UPDATE france.rna SET temperature=upstream_solution.temperature 
FROM upstream_solution WHERE rna.idsegment=upstream_solution.idsegment0
AND upstream_solution.temperature>0

WITH problems AS (
	SELECT idsegment, nextdownidsegment FROM france.rn_rna WHERE temperature=0),
downstream_solution AS (
	SELECT problems.idsegment AS idsegment0, temperature FROM france.rn_rna 
JOIN problems ON problems.nextdownidsegment=rn_rna.idsegment)
UPDATE france.rna SET temperature=downstream_solution.temperature 
FROM downstream_solution WHERE rna.idsegment=downstream_solution.idsegment0
AND downstream_solution.temperature>0; --3

UPDATE france.rna set temperature=NULL WHERE temperature=0;  --4


-- missing temperatures from Spain

SELECT * FROM spain.rna WHERE temperature IS NULL; --48 CEUTA MELILLA 
SELECT * FROM spain.rn_rna WHERE temperature =0; --0

SELECT DISTINCT basin FROM spain.rna WHERE temperature IS NULL --313 -- CEUTA MELILLA 
SELECT avg(temperature) FROM spain.rna WHERE   basin='ISLAS BALEARES'; --16
UPDATE spain.rna SET temperature =16 WHERE temperature IS NULL AND basin ='ISLAS BALEARES';--126
SELECT * FROM spain.rna WHERE temperature=0;

WITH problems AS (
	SELECT idsegment FROM spain.rn_rna WHERE temperature=0),
upstream_solution AS (
	SELECT problems.idsegment AS idsegment0, temperature FROM spain.rn_rna 
JOIN problems ON rn_rna.nextdownidsegment=problems.idsegment)
UPDATE spain.rna SET temperature=upstream_solution.temperature 
FROM upstream_solution WHERE rna.idsegment=upstream_solution.idsegment0; --2

WITH problems AS (
	SELECT idsegment, nextdownidsegment FROM spain.rn_rna WHERE temperature=0),
downstream_solution AS (
	SELECT problems.idsegment AS idsegment0, temperature FROM spain.rn_rna 
JOIN problems ON problems.nextdownidsegment=rn_rna.idsegment)
UPDATE spain.rna SET temperature=downstream_solution.temperature 
FROM downstream_solution WHERE rna.idsegment=downstream_solution.idsegment0
AND downstream_solution.temperature>0; --4


BEGIN;
WITH getsomemore AS (
SELECT rn.idsegment, st_distance(rn.geom, catchments.the_geom) AS distance, temp_mean FROM spain.rn
JOIN spain.rna ON rn.idsegment=rna.idsegment
JOIN  ccm21.catchments ON st_dwithin(rn.geom, catchments.the_geom, 5000)
WHERE temperature IS NULL
AND "window" in (2001, 2002, 2003,2004)),
joined as(
SELECT DISTINCT ON (idsegment) * FROM getsomemore WHERE temp_mean >0 ORDER BY idsegment,distance)
UPDATE spain.rna SET temperature=temp_mean FROM joined WHERE joined.idsegment=rna.idsegment; --5
COMMIT; --424


-- correction for portugal


SELECT * FROM portugal.rna WHERE temperature IS NULL; --0
SELECT * FROM portugal.rn_rna WHERE temperature =0; --45

BEGIN;
WITH getsomemore AS (
SELECT rn.idsegment, st_distance(rn.geom, catchments.the_geom) AS distance, temp_mean FROM portugal.rn
JOIN portugal.rna ON rn.idsegment=rna.idsegment
JOIN  ccm21.catchments ON st_dwithin(rn.geom, catchments.the_geom, 5000)
WHERE temperature IS NULL
AND "window" in (2001, 2002, 2003,2004)),
joined as(
SELECT DISTINCT ON (idsegment) * FROM getsomemore WHERE temp_mean >0 ORDER BY idsegment,distance)
UPDATE portugal.rna SET temperature=temp_mean FROM joined WHERE joined.idsegment=rna.idsegment;
COMMIT; 

WITH problems AS (
	SELECT idsegment FROM portugal.rn_rna WHERE temperature=0),
upstream_solution AS (
	SELECT problems.idsegment AS idsegment0, temperature FROM portugal.rn_rna 
JOIN problems ON rn_rna.nextdownidsegment=problems.idsegment)
UPDATE portugal.rna SET temperature=upstream_solution.temperature 
FROM upstream_solution WHERE rna.idsegment=upstream_solution.idsegment0
AND upstream_solution.temperature>0; --32 --16 --12 --11 

WITH problems AS (
	SELECT idsegment, nextdownidsegment FROM portugal.rn_rna WHERE temperature=0),
downstream_solution AS (
	SELECT problems.idsegment AS idsegment0, temperature FROM portugal.rn_rna 
JOIN problems ON problems.nextdownidsegment=rn_rna.idsegment)
UPDATE portugal.rna SET temperature=downstream_solution.temperature 
FROM downstream_solution WHERE rna.idsegment=downstream_solution.idsegment0
AND downstream_solution.temperature>0; --8 --5 --4 --1 
