

SELECT ST_value(ST_Union(raster))
FROM altitude.eu_dem_v11_e20n10 join spain.rn
ON ST_Intersects(raster,  geom)
WHERE idsegment='SP187714';

with centroid as
(select idsegment,ST_Centroid(geom) as geom from spain.rn),
  altitude as (
SELECT ST_Value(rast,geom) as alt, idsegment
FROM altitude.eu_dem_v11_e20n10 join centroid 
ON ST_Intersects(rast,  geom))
UPDATE spain.rna set altitudem = altitude.alt from altitude where rna.idsegment=altitude.idsegment; --52417 41.3

with centroid as
(select idsegment,ST_Centroid(geom) as geom from portugal.rn),
  altitude as (
SELECT ST_Value(rast,geom) as alt, idsegment
FROM altitude.eu_dem_v11_e20n10 join centroid 
ON ST_Intersects(rast,  geom))
UPDATE portugal.rna set altitudem = altitude.alt from altitude where rna.idsegment=altitude.idsegment; 

with centroid as
(select idsegment,ST_Centroid(geom) as geom from spain.rn),
  altitude as (
SELECT ST_Value(rast,geom) as alt, idsegment
FROM altitude.eu_dem_v11_e20n20 join centroid 
ON ST_Intersects(rast,  geom))
UPDATE spain.rna set altitudem = altitude.alt from altitude where rna.idsegment=altitude.idsegment; 

with centroid as
(select idsegment,ST_Centroid(geom) as geom from portugal.rn),
  altitude as (
SELECT ST_Value(rast,geom) as alt, idsegment
FROM altitude.eu_dem_v11_e20n20 join centroid 
ON ST_Intersects(rast,  geom))
UPDATE portugal.rna set altitudem = altitude.alt from altitude where rna.idsegment=altitude.idsegment; 

with centroid as
(select idsegment,ST_Centroid(geom) as geom from spain.rn),
  altitude as (
SELECT ST_Value(rast,geom) as alt, idsegment
FROM altitude.eu_dem_v11_e30n10 join centroid 
ON ST_Intersects(rast,  geom))
UPDATE spain.rna set altitudem = altitude.alt from altitude where rna.idsegment=altitude.idsegment; --97617 01:38

with centroid as
(select idsegment,ST_Centroid(geom) as geom from portugal.rn),
  altitude as (
SELECT ST_Value(rast,geom) as alt, idsegment
FROM altitude.eu_dem_v11_e30n10 join centroid 
ON ST_Intersects(rast,  geom))
UPDATE portugal.rna set altitudem = altitude.alt from altitude where rna.idsegment=altitude.idsegment; --0


with centroid as
(select idsegment,ST_Centroid(geom) as geom from spain.rn),
  altitude as (
SELECT ST_Value(rast,geom) as alt, idsegment
FROM altitude.eu_dem_v11_e30n20 join centroid 
ON ST_Intersects(rast,  geom))
UPDATE spain.rna set altitudem = altitude.alt from altitude where rna.idsegment=altitude.idsegment; --97617 01:38

with centroid as
(select idsegment,ST_Centroid(geom) as geom from portugal.rn),
  altitude as (
SELECT ST_Value(rast,geom) as alt, idsegment
FROM altitude.eu_dem_v11_e30n20 join centroid 
ON ST_Intersects(rast,  geom))
UPDATE portugal.rna set altitudem = altitude.alt from altitude where rna.idsegment=altitude.idsegment; --0