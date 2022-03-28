/*
http://hydro.iis.u-tokyo.ac.jp/~yamadai/MERIT_Hydro/index.html
cd F:\eda\shape\MERIT_hydro\selected
n35e000_wth.tif
n35w005_wth.tif
n35w010_wth.tif
n35w025_wth.tif
n35w030_wth.tif
n40e000_wth.tif
n40w005_wth.tif
n40w010_wth.tif
gdalinfo C:\workspace\EDAdata\dataEDAccm\shape\MERIT\n35e000_wth.tif
gdal_translate -a_nodata 0 -of GTiff F:\eda\shape\MERIT_hydro\selected\n35e000_wth.tif F:\eda\shape\MERIT_hydro\selected\n35e000_wth_a.tif
# -I index 
# -C constraint
# -M vacuum analyse
# - F A column with the raster name will be added
# -l creates table overviews 
# -R the layer is read from the file on disk not in the database itself ???? 




-- attention ci dessous fonctionne dans une console dos pas dans powershell


cd C:\workspace\EDAdata\dataEDAccm\shape\MERIT\
set PGPORT=5432
set PGHOST=localhost
set PGUSER=postgres
set PGPASSWORD=postgres
set PGDATABASE=eda2.3
raster2pgsql -s 4326 -t 6000x6000 -I -C -M *.tif raster_width.merit_width15x15 | psql
*/
SELECT st_NumBands(rast) from raster_width.merit_width15x15
SELECT * from raster_width.merit_width15x15 limit 10
SELECT rast from raster_width.merit_width15x15 rr limit 10


/* 
premier test
*/
WITH selection as (
SELECT * from spain.rn where idsegment='SP227983'),

	segmentized as (
 SELECT idsegment, (ST_DumpPoints(ST_Segmentize(st_transform(geom,4326),10))).geom  FROM selection)

        joined as(
select idsegment, st_value(rast,geom) as val FROM raster_width.merit_width15x15
JOIN segmentized
ON ST_Intersects(rast,geom)
where st_value(rast,geom) >0)

/*
Ci dessous segmentized decoupe le tronçon suivant les points, mais je vois pas trop l'effet de max_segment_length
renvoit toujours 57 lignes
Returns a modified geometry having no segment longer than the given max_segment_length.
Je prends la taille de pixel du raster  ?
*/

WITH selection as (
SELECT * from spain.rn where idsegment='SP227983'),

	segmentized as (
 SELECT idsegment, (ST_DumpPoints(ST_Segmentize(st_transform(geom,4326),10))).geom  FROM selection)
select * from segmentized


/*
en prenant tout
*/

CREATE TABLE raster_width.rnsubset as (

WITH 	segmentized as (
		SELECT idsegment, (ST_DumpPoints(ST_Segmentize(st_transform(geom,4326),50))).geom  FROM spain.rn),

	joined as(
		select idsegment, st_value(rast,geom) as val FROM raster_width.merit_width15x15
		JOIN segmentized
		ON ST_Intersects(rast,geom)
		where st_value(rast,geom) >0)

	select idsegment, avg(val) AS width from joined GROUP BY idsegment
); -- marche pas


DROP TABLE IF EXISTs raster_width.rnsubset;
CREATE TABLE raster_width.rnsubset as (
WITH dumprn as (
SELECT idsegment,ST_GeometryN(geom,1) as geom FROM spain.rn WHERE ST_NumGeometries(geom) = 1
--and seaidsegment='SP322526'
 -- four multi geometries ignored there
),
 point0 AS (
  SELECT idsegment, 
         ST_value(raster.rast, ST_StartPoint(st_transform(geom,4326)), TRUE) AS pointvalue
  FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_StartPoint(st_transform(geom,4326)), raster.rast))
), point1 AS (
  SELECT idsegment, 
         ST_value(raster.rast, ST_EndPoint(st_transform(geom,4326)), TRUE) AS pointvalue
  FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_EndPoint(st_transform(geom,4326)), raster.rast))
), point01 AS (
	SELECT idsegment, 
         ST_value(raster.rast, ST_LineInterpolatePoint(st_transform(geom,4326), 0.1), TRUE) AS pointvalue
	FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_LineInterpolatePoint(st_transform(geom,4326), 0.1), raster.rast))
), point02 AS (
	SELECT idsegment, 
         ST_value(raster.rast, ST_LineInterpolatePoint(st_transform(geom,4326), 0.2), TRUE) AS pointvalue
	FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_LineInterpolatePoint(st_transform(geom,4326), 0.2), raster.rast))
), point03 AS (
	SELECT idsegment, 
         ST_value(raster.rast, ST_LineInterpolatePoint(st_transform(geom,4326), 0.3), TRUE) AS pointvalue
	FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_LineInterpolatePoint(st_transform(geom,4326), 0.3), raster.rast)))
, point04 AS (
	SELECT idsegment, 
         ST_value(raster.rast, ST_LineInterpolatePoint(st_transform(geom,4326), 0.4), TRUE) AS pointvalue
	FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_LineInterpolatePoint(st_transform(geom,4326), 0.4), raster.rast)))
, point05 AS (
	SELECT idsegment, 
         ST_value(raster.rast, ST_LineInterpolatePoint(st_transform(geom,4326), 0.5), TRUE) AS pointvalue
	FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_LineInterpolatePoint(st_transform(geom,4326), 0.5), raster.rast)))
, point06 AS (
	SELECT idsegment, 
         ST_value(raster.rast, ST_LineInterpolatePoint(st_transform(geom,4326), 0.6), TRUE) AS pointvalue
	FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_LineInterpolatePoint(st_transform(geom,4326), 0.6), raster.rast)))
, point07 AS (
	SELECT idsegment, 
         ST_value(raster.rast, ST_LineInterpolatePoint(st_transform(geom,4326), 0.7), TRUE) AS pointvalue
	FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_LineInterpolatePoint(st_transform(geom,4326), 0.7), raster.rast)))
, point08 AS (
	SELECT idsegment, 
         ST_value(raster.rast, ST_LineInterpolatePoint(st_transform(geom,4326), 0.8), TRUE) AS pointvalue
	FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_LineInterpolatePoint(st_transform(geom,4326), 0.8), raster.rast)))
, point09 AS (
	SELECT idsegment, 
         ST_value(raster.rast, ST_LineInterpolatePoint(st_transform(geom,4326), 0.9), TRUE) AS pointvalue
         FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_LineInterpolatePoint(st_transform(geom,4326), 0.9), raster.rast))
       ),
union_tous as(
  SELECT * FROM point0
	UNION
	 SELECT * FROM point01
	UNION
	 SELECT * FROM point02
	 UNION
	 SELECT * FROM point03
	 UNION
	 SELECT * FROM point04
	 UNION
	 SELECT * FROM point05
	 UNION
	 SELECT * FROM point06
	 UNION
	 SELECT * FROM point07
	 UNION
	SELECT * FROM  point08
	 UNION
	 SELECT * FROM point09
	 UNION	
	 SELECT * FROM point1),
 grouped as (
  SELECT idsegment, avg(pointvalue) as width FROM union_tous where pointvalue>0 group by idsegment)
 SELECT * FROM grouped where width>11.25
  
);--NOTICE:  Attempting to get pixel value with out of range raster coordinates: (15, 11)
--CONTEXT:  fonction PL/pgsql st_value(raster,integer,geometry,boolean), ligne 18 à RETURN
-- Query returned successfully: 16632 rows affected, 21:57 minutes execution time.



DROP TABLE IF EXISTs raster_width.rnsubsetpo;
CREATE TABLE raster_width.rnsubsetpo as (
WITH dumprn as (
SELECT idsegment,ST_GeometryN(geom,1) as geom FROM portugal.rn WHERE ST_NumGeometries(geom) = 1
--and seaidsegment='SP322526'
 -- no multi geom there so OK
),
 point0 AS (
  SELECT idsegment, 
         ST_value(raster.rast, ST_StartPoint(st_transform(geom,4326)), TRUE) AS pointvalue
  FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_StartPoint(st_transform(geom,4326)), raster.rast))
), point1 AS (
  SELECT idsegment, 
         ST_value(raster.rast, ST_EndPoint(st_transform(geom,4326)), TRUE) AS pointvalue
  FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_EndPoint(st_transform(geom,4326)), raster.rast))
), point01 AS (
	SELECT idsegment, 
         ST_value(raster.rast, ST_LineInterpolatePoint(st_transform(geom,4326), 0.1), TRUE) AS pointvalue
	FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_LineInterpolatePoint(st_transform(geom,4326), 0.1), raster.rast))
), point02 AS (
	SELECT idsegment, 
         ST_value(raster.rast, ST_LineInterpolatePoint(st_transform(geom,4326), 0.2), TRUE) AS pointvalue
	FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_LineInterpolatePoint(st_transform(geom,4326), 0.2), raster.rast))
), point03 AS (
	SELECT idsegment, 
         ST_value(raster.rast, ST_LineInterpolatePoint(st_transform(geom,4326), 0.3), TRUE) AS pointvalue
	FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_LineInterpolatePoint(st_transform(geom,4326), 0.3), raster.rast)))
, point04 AS (
	SELECT idsegment, 
         ST_value(raster.rast, ST_LineInterpolatePoint(st_transform(geom,4326), 0.4), TRUE) AS pointvalue
	FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_LineInterpolatePoint(st_transform(geom,4326), 0.4), raster.rast)))
, point05 AS (
	SELECT idsegment, 
         ST_value(raster.rast, ST_LineInterpolatePoint(st_transform(geom,4326), 0.5), TRUE) AS pointvalue
	FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_LineInterpolatePoint(st_transform(geom,4326), 0.5), raster.rast)))
, point06 AS (
	SELECT idsegment, 
         ST_value(raster.rast, ST_LineInterpolatePoint(st_transform(geom,4326), 0.6), TRUE) AS pointvalue
	FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_LineInterpolatePoint(st_transform(geom,4326), 0.6), raster.rast)))
, point07 AS (
	SELECT idsegment, 
         ST_value(raster.rast, ST_LineInterpolatePoint(st_transform(geom,4326), 0.7), TRUE) AS pointvalue
	FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_LineInterpolatePoint(st_transform(geom,4326), 0.7), raster.rast)))
, point08 AS (
	SELECT idsegment, 
         ST_value(raster.rast, ST_LineInterpolatePoint(st_transform(geom,4326), 0.8), TRUE) AS pointvalue
	FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_LineInterpolatePoint(st_transform(geom,4326), 0.8), raster.rast)))
, point09 AS (
	SELECT idsegment, 
         ST_value(raster.rast, ST_LineInterpolatePoint(st_transform(geom,4326), 0.9), TRUE) AS pointvalue
         FROM dumprn LEFT JOIN 
       raster_width.merit_width15x15 AS raster 
       ON (ST_Intersects(ST_LineInterpolatePoint(st_transform(geom,4326), 0.9), raster.rast))
       ),
union_tous as(
  SELECT * FROM point0
	UNION
	 SELECT * FROM point01
	UNION
	 SELECT * FROM point02
	 UNION
	 SELECT * FROM point03
	 UNION
	 SELECT * FROM point04
	 UNION
	 SELECT * FROM point05
	 UNION
	 SELECT * FROM point06
	 UNION
	 SELECT * FROM point07
	 UNION
	SELECT * FROM  point08
	 UNION
	 SELECT * FROM point09
	 UNION	
	 SELECT * FROM point1),
 grouped as (
  SELECT idsegment, avg(pointvalue) as width FROM union_tous where pointvalue>0 group by idsegment)
 SELECT * FROM grouped where width>11.25
  
); --Query returned successfully: 7092 rows affected, 02:24 minutes execution time.

BEGIN;
ALTER TABLE dbeel_rivers.rna ADD column riverwidthmsource TEXT;
ALTER TABLE dbeel_rivers.rna RENAME COLUMN riverwithm to riverwidthm;
UPDATE portugal.rna set (riverwidthm,riverwidthmsource)=(width,'MERIT hydro raster database licence CC-BY-NC 4.0') FROM raster_width.rnsubsetpo w
WHERE w.idsegment=rna.idsegment;--7092
UPDATE spain.rna SET riverwidthm = NULL;
UPDATE spain.rna set (riverwidthm,riverwidthmsource)=(width,'MERIT hydro raster database licence CC-BY-NC 4.0') FROM raster_width.rnsubset w
WHERE w.idsegment=rna.idsegment;--16632
UPDATE spain.rna SET riverwidthm=NULL where strahler<=3; -- remove tributaries
UPDATE portugal.rna SET riverwidthm=NULL where strahler=1; -- remove tributaries
COMMIT;

/*
SELECT * FROM raster_width.rnsubset where idsegment='SP228314'
select st
SELECT ST_LineInterpolatePoint(NULL::LINESTRING)
SELECT GeometryType(geom) from spain.rn limit 10
SELECT GeometryType(geom) from portugal.rn limit 10
SELECT ST_NPoints(geom), idsegment from spain.rn limit 10
SELECT ST_LineInterpolatePoint(geom,0.2), idsegment from spain.rn 
SELECT PostGIS_Version(); --1.4 le lineInterpolatePoints marche pas */

SELECT COUNT(CASE WHEN ST_NumGeometries(geom) > 1 THEN 1 END) AS multi_geom,
COUNT(geom) AS total_geom
FROM spain.rn;

SELECT COUNT(CASE WHEN ST_NumGeometries(geom) > 1 THEN 1 END) AS multi_geom,
COUNT(geom) AS total_geom
FROM portugal.rn; --zero multi