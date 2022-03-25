CREATE INDEX "ccm_ukirl_the_geom_gist" ON "uk"."ccm_ukirl" USING GIST (the_geom);
CREATE INDEX uk_raster_rast_gist_idx ON uk.raster_uk USING GIST (ST_ConvexHull(rast));

-- transformation du raster en polygone "pour le fun"
DROP TABLE IF EXISTS  uk.essai_poly;
CREATE TABLE uk.essai_poly AS
SELECT (ST_DumpAsPolygons(rast)).*
FROM  uk.raster_uk;

-- pour visualiser le buffer
CREATE OR REPLACE VIEW buffer AS
SELECT gid, (ST_Buffer(the_geom, 100)) AS the_geom
FROM uk.ccm_ukirl
;


-- calcul de la largeur moyenne à partir du raster
CREATE TABLE uk.ccm_width AS
SELECT ccm_ukirl.*, mean_width
FROM
	(SELECT gid,
		round(avg((gv).val::numeric),1) as mean_width
	 FROM (SELECT rid,gid, 
		      ST_Intersection(rast, geom) AS gv, ST_BandNoDataValue(rast) as nodata
	       FROM  (SELECT gid, (ST_Transform(ST_Buffer(the_geom, 300),27700)) AS geom
	 FROM uk.ccm_ukirl) AS ccm_ukirl_buffer, uk.raster_uk
	       WHERE ST_Intersects(rast, geom)
	      ) foo
	WHERE (gv).val>=0 GROUP BY gid ) foo2,
	uk.ccm_ukirl
WHERE foo2.gid = ccm_ukirl.gid
;

