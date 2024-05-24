UPDATE france.tr_lagunes SET lag_polygone= st_setSRID(lag_polygone, 4326);--44
CREATE INDEX id_lag_nom ON france.tr_lagunes USING btree(lag_nom);
ALTER TABLE france.tr_lagunes ADD CONSTRAINT c_pk_lag_id PRIMARY KEY (lag_id);
CREATE INDEX id_tr_lagunes_geom ON france.tr_lagunes USING gist(lag_polygone);

WITH bages AS (
SELECT 
lag_id,
lag_nom,
st_transform(lag_polygone, 3035) AS geom, 
lag_prudhomie,
lag_complexebio,
lag_complexepeche,
lag_zif_id,
lag_zif_nom
FROM france.tr_lagunes 
WHERE lag_id=6
)
SELECT * FROM bages JOIN france.waterbody_unitbv w ON st_intersects(w.geom, bages.geom)


ALTER TABLE  ADD COLUMN w_lag_id integer;
ALTER TABLE france.waterbody_unitbv ADD CONSTRAINT c_fk_waterbody_lag_id FOREIGN KEY (w_lag_id) REFERENCES france.tr_lagunes(lag_id);

WITH 

WITH lagoons AS (
SELECT 
lag_id,
st_transform(lag_polygone, 3035) AS geom
FROM france.tr_lagunes)
UPDATE france.waterbody_unitbv w SET w_lag_id = lag_id FROM lagoons WHERE 
st_intersects(w.geom, lagoons.geom); --1203


SELECT st_srid(geom) FROM france.waterbody_unitbv 
SELECT st_srid(lag_polygone) FROM france.tr_lagunes 
SELECT st_srid(zif_geom) FROM france.tr_zoneifremer_zif; --4326

/*
 * RECHERCHE DES BOUTS MANQUANTS
 * 
 */
WITH bages AS (
SELECT 
lag_id,
lag_nom,
st_transform(lag_polygone, 3035) AS geom, 
lag_prudhomie,
lag_complexebio,
lag_complexepeche,
lag_zif_id,
lag_zif_nom
FROM france.tr_lagunes 
WHERE lag_id=6
)
SELECT * FROM bages JOIN  w ON st_intersects(w.geom, bages.geom)

CREATE INDEX id_ID ON france.surface_hydrographique_bdtopo USING btree("ID");
CREATE INDEX id_unitbv_id ON france.waterbody_unitbv USING btree(id);

WITH missing_id AS(
SELECT "ID" AS id FROM france.surface_hydrographique_bdtopo
EXCEPT 
SELECT id FROM france.waterbody_unitbv)
SELECT * FROM france.surface_hydrographique_bdtopo bt JOIN missing_id ON missing_id.id=bt."ID" LIMIT 10;


CREATE TABLE france.surface_hydrographique_bdtopo_not_included AS (
WITH missing_id AS(
SELECT "ID" AS id FROM france.surface_hydrographique_bdtopo
EXCEPT 
SELECT id FROM france.waterbody_unitbv)
SELECT bt.* FROM france.surface_hydrographique_bdtopo bt JOIN missing_id ON missing_id.id=bt."ID" ); --292612

CREATE INDEX id_surface_hydrographique_bdtopo_not_included_id ON france.surface_hydrographique_bdtopo_not_included USING btree(id);
CREATE INDEX id_surface_hydrographique_bdtopo_not_included_geom ON france.surface_hydrographique_bdtopo_not_included USING gist(the_geom);


/*
 * -- pour affichage

CREATE TABLE france.tempbagessupl AS(
WITH bages AS (
SELECT 
lag_id,
lag_nom,
st_transform(lag_polygone, 3035) AS geom, 
lag_prudhomie,
lag_complexebio,
lag_complexepeche,
lag_zif_id,
lag_zif_nom
FROM france.tr_lagunes 
WHERE lag_id=6
)
SELECT wni.* FROM bages JOIN france.surface_hydrographique_bdtopo_not_included wni ON st_contains(bages.geom, wni.the_geom)); --9

DROP TABLE france.tempbagessupl ;
 */



INSERT INTO france.waterbody_unitbv (
id
,code_hydro
,code_pays
,nature
,persistance
,salinite
,commentaire
,id_p_eau
,id_c_eau
,id_ent_tr
,nom_p_eau
,nom_c_eau
,nom_ent_tr
,idsegment
,geom
,w_lag_id
) 
			SELECT 
			  ni."ID" as id, 
			  ni."CODE_HYDRO" as code_hydro, 
			  ni."CODE_PAYS" as code_pays, 
			  ni."NATURE" as nature, 
			  ni."PERSISTANC" as persistance, 
			  ni."SALINITE" as salinite, 
			  ni."COMMENT" as commentaire, 
			  ni."ID_P_EAU" as id_p_eau, 
			  ni."ID_C_EAU" as id_c_eau, 
			  ni."ID_ENT_TR" as id_ent_tr, 
			  ni."NOM_P_EAU" as nom_p_eau, 
			  ni."NOM_C_EAU" as nom_c_eau, 
			  ni."NOM_ENT_TR" as nom_ent_tr,
			bu_idsegment as idsegment,  
			st_intersection(bu.geom, the_geom) geom,
			lag_id AS w_lag_id
			 from france.basinunit_bu bu
			INNER JOIN france.surface_hydrographique_bdtopo_not_included  ni on st_intersects(the_geom,bu.geom) 
			JOIN (SELECT lag_id,st_transform(lag_polygone, 3035) AS geom  FROM france.tr_lagunes WHERE lag_id=6) bages
			ON st_covers(bages.geom, ni.the_geom)
		;--9
		

WITH shouldbeout AS (SELECT * FROM france.surface_hydrographique_bdtopo_not_included WHERE "ID"='SURF_EAU0000000080016663'),
bages AS(SELECT lag_id,st_transform(lag_polygone, 3035) AS geom  FROM france.tr_lagunes WHERE lag_id=6)
SELECT * FROM bages JOIN shouldbeout ON st_contains(bages.geom,shouldbeout.the_geom)

/*
DELETE FROM france.waterbody_unitbv WHERE id in(
'SURF_EAU0000000080016618',
'SURF_EAU0000000290036616',
'SURF_EAU0000000290036617',
'SURF_EAU0000000290036628',
'SURF_EAU0000000348956589',
'SURF_EAU0000000358728435',
'SURF_EAU0000000358728589',
'SURF_EAU0000000358734466',
'SURF_EAU0000000290036626');--9
*/

/*
 * La TERRRIBLE Lagune de Vendres
 * 
 */

DROP TABLE IF EXISTS temp_vendres;
CREATE TABLE temp_vendres AS (
WITH vendres AS(
SELECT lag_id,st_transform(lag_polygone, 3035) AS geom  FROM france.tr_lagunes WHERE lag_id=14),
decoupebv AS (
SELECT 
			  ni."ID" as id, 
			  ni."CODE_HYDRO" as code_hydro, 
			  ni."CODE_PAYS" as code_pays, 
			  ni."NATURE" as nature, 
			  ni."PERSISTANC" as persistance, 
			  ni."SALINITE" as salinite, 
			  ni."COMMENT" as commentaire, 
			  ni."ID_P_EAU" as id_p_eau, 
			  ni."ID_C_EAU" as id_c_eau, 
			  ni."ID_ENT_TR" as id_ent_tr, 
			  ni."NOM_P_EAU" as nom_p_eau, 
			  ni."NOM_C_EAU" as nom_c_eau, 
			  ni."NOM_ENT_TR" as nom_ent_tr,
			bu_idsegment as idsegment,  
			st_intersection(bu.geom, the_geom) geom
			 FROM france.basinunit_bu bu
			JOIN france.surface_hydrographique_bdtopo_not_included  ni on st_intersects(the_geom,bu.geom)
			JOIN vendres ON (the_geom <-> vendres.geom)<10000),
polygones_select AS(
SELECT decoupebv.*, 
			lag_id AS w_lag_id
			FROM decoupebv JOIN vendres ON 	st_intersects(vendres.geom, decoupebv.geom)
			)
SELECT 
				id,
				code_hydro, 
			   code_pays, 
			  nature, 
			  persistance, 
			  salinite, 
			  commentaire, 
			  id_p_eau, 
			  id_c_eau, 
			  id_ent_tr, 
			  nom_p_eau, 
			  nom_c_eau, 
			  nom_ent_tr,
			  idsegment, 
			  st_intersection(polygones_select.geom, vendres.geom) AS geom,
			  lag_id AS w_lag_id
			  FROM polygones_select , vendres
)			; --24 */

INSERT INTO france.waterbody_unitbv (
id
,code_hydro
,code_pays
,nature
,persistance
,salinite
,commentaire
,id_p_eau
,id_c_eau
,id_ent_tr
,nom_p_eau
,nom_c_eau
,nom_ent_tr
,idsegment
,geom
,w_lag_id) SELECT * FROM temp_vendres 

/*
 * Lagunes de Thau
 */

/*
DROP TABLE IF EXISTS temp_thau;
CREATE TABLE temp_thau AS (
WITH thau AS(
SELECT lag_id,st_transform(lag_polygone, 3035) AS geom  FROM france.tr_lagunes WHERE lag_id=18),
decoupebv AS (
SELECT 
			  ni."ID" as id, 
			  ni."CODE_HYDRO" as code_hydro, 
			  ni."CODE_PAYS" as code_pays, 
			  ni."NATURE" as nature, 
			  ni."PERSISTANC" as persistance, 
			  ni."SALINITE" as salinite, 
			  ni."COMMENT" as commentaire, 
			  ni."ID_P_EAU" as id_p_eau, 
			  ni."ID_C_EAU" as id_c_eau, 
			  ni."ID_ENT_TR" as id_ent_tr, 
			  ni."NOM_P_EAU" as nom_p_eau, 
			  ni."NOM_C_EAU" as nom_c_eau, 
			  ni."NOM_ENT_TR" as nom_ent_tr,
			NULL AS idsegment,
			st_intersection(thau.geom, the_geom) geom
			 FROM thau
			JOIN france.surface_hydrographique_bdtopo  ni on st_intersects(the_geom,thau.geom))
			
			SELECT * FROM decoupebv)

	
DROP TABLE IF EXISTS temp_thau_2;
CREATE TABLE temp_thau_2 AS(			
SELECT 
temp_thau.id
,temp_thau.code_hydro
,temp_thau.code_pays
,temp_thau.nature
,temp_thau.persistance
,temp_thau.salinite
,temp_thau.commentaire
,temp_thau.id_p_eau
,temp_thau.id_c_eau
,temp_thau.id_ent_tr
,temp_thau.nom_p_eau
,temp_thau.nom_c_eau
,temp_thau.nom_ent_tr
,temp_thau.idsegment
--,ST_CollectionExtract(st_split(temp_thau.geom,st_boundary(b.geom)),3) AS geom
, st_buffer(ST_intersection(temp_thau.geom,w.geom),0.0) geom
,18 AS w_lag_id FROM temp_thau 
  JOIN
--france.surface_hydrographique_bdtopo b ON st_intersects(b.the_geom, temp_thau.geom)
 france.waterbody_unitbv w ON 
 ST_intersects(temp_thau.geom, w.geom) 
 WHERE NOT ST_IsEmpty(ST_Buffer(ST_Intersection(temp_thau.geom,w.geom),0.0))
);--74




DROP TABLE IF EXISTS temp_thau_3;
CREATE TABLE temp_thau_3 AS(			
WITH t3 AS (
SELECT st_union(geom) geom FROM temp_thau_2
)
SELECT
t2.id
,t2.code_hydro
,t2.code_pays
,t2.nature
,t2.persistance
,t2.salinite
,t2.commentaire
,t2.id_p_eau
,t2.id_c_eau
,t2.id_ent_tr
,t2.nom_p_eau
,t2.nom_c_eau
,t2.nom_ent_tr
,t2.idsegment
,t2.w_lag_id
, ST_difference(t1.geom,t3.geom)
FROM temp_thau_2 t2,
 temp_thau t1,
 t3
);

*/





DROP TABLE IF EXISTS temp_thau;
CREATE TABLE temp_thau AS(	
-- t0 selects the lagoon from tr_lagoon according to number
WITH t0 AS(
	SELECT lag_id,st_transform(lag_polygone, 3035) AS geom  FROM france.tr_lagunes WHERE lag_id=18),
-- t1 will get all elements from original bd_topo (including all missing parts)
t1 AS (
SELECT 
	  ni."ID" as id, 
	  ni."CODE_HYDRO" as code_hydro, 
	  ni."CODE_PAYS" as code_pays, 
	  ni."NATURE" as nature, 
	  ni."PERSISTANC" as persistance, 
	  ni."SALINITE" as salinite, 
	  ni."COMMENT" as commentaire, 
	  ni."ID_P_EAU" as id_p_eau, 
	  ni."ID_C_EAU" as id_c_eau, 
	  ni."ID_ENT_TR" as id_ent_tr, 
	  ni."NOM_P_EAU" as nom_p_eau, 
	  ni."NOM_C_EAU" as nom_c_eau, 
	  ni."NOM_ENT_TR" as nom_ent_tr,		
	st_intersection(t0.geom, the_geom) geom,
	t0.lag_id AS  w_lag_id
	FROM t0
	JOIN france.surface_hydrographique_bdtopo  ni on st_intersects(the_geom,t0.geom)
),
-- t2 splits the layer according into polygons for the parts that are common to t1 and waterbody_unitbv
-- it removes lines and points with the st_buffer trick (which creates NULL geometries for POINTS and LINES)
-- the layer really looks like waterbody_unitbv but we have added some missing parts on the edge of the lagoon
-- Here I'm keeping the names, from t3 I will later only work on geom and get features back using st_intersect
t2 AS(			
	SELECT 
t1.id
,t1.code_hydro
,t1.code_pays
,t1.nature
,t1.persistance
,t1.salinite
,t1.commentaire
,t1.id_p_eau
,t1.id_c_eau
,t1.id_ent_tr
,t1.nom_p_eau
,t1.nom_c_eau
,t1.nom_ent_tr
,t1.w_lag_id
, st_buffer(ST_intersection(t1.geom,w.geom),0.0) geom
 FROM t1 
 JOIN france.waterbody_unitbv w ON ST_intersects(t1.geom, w.geom) 
 WHERE NOT ST_IsEmpty(ST_Buffer(ST_Intersection(t1.geom,w.geom),0.0))
),

-- t3 and t4 only contains a unioned geom so a single line
t3 AS (
SELECT st_union(geom) geom FROM t1
),
t4 AS (
SELECT  
st_union(geom) geom FROM t2
),
-- This is just one line, the difference
-- st_difference gets the difference, it  necessary to use UNION before !!!!
-- we need to pass it two multipolygons otherwise we multiply the edges
t5 AS(
SELECT
 ST_MULTI(ST_difference(t3.geom,t4.geom)) geom
FROM t4,
 t3
),
-- T6 will be one line per polygon we split the multipolygon created at previous step
t6 AS (
SELECT  
ST_GeometryN(geom, generate_series(1, ST_NumGeometries(geom))) AS geom
FROM t5),
-- we remove small polygons
t7 AS(
SELECT * FROM t6 WHERE st_area(geom)>500
)
-- finally we get back the ids from t2
SELECT id
,code_hydro
,code_pays
,nature
,persistance
,salinite
,commentaire
,id_p_eau
,id_c_eau
,id_ent_tr
,nom_p_eau
,nom_c_eau
,nom_ent_tr
,NULL AS idsegment
,w_lag_id
, t7.geom
FROM t7 
JOIN t2 ON st_intersects(t2.geom,t7.geom)
);



INSERT INTO france.waterbody_unitbv (
id
,code_hydro
,code_pays
,nature
,persistance
,salinite
,commentaire
,id_p_eau
,id_c_eau
,id_ent_tr
,nom_p_eau
,nom_c_eau
,nom_ent_tr
,idsegment
,w_lag_id,
geom) SELECT id
,code_hydro
,code_pays
,nature
,persistance
,salinite
,commentaire
,id_p_eau
,id_c_eau
,id_ent_tr
,nom_p_eau
,nom_c_eau
,nom_ent_tr
,idsegment
,w_lag_id,
geom FROM temp_thau;--26



------------------------------------------
-- Vic Moures 21
--------------------------------------------

DROP TABLE IF EXISTS temp_vic;
CREATE TABLE temp_vic AS(	
-- t0 selects the lagoon from tr_lagoon according to number
WITH t0 AS(
	SELECT lag_id,st_transform(lag_polygone, 3035) AS geom  FROM france.tr_lagunes WHERE lag_id=21),
-- t1 will get all elements from original bd_topo (including all missing parts)
t1 AS (
SELECT 
	  ni."ID" as id, 
	  ni."CODE_HYDRO" as code_hydro, 
	  ni."CODE_PAYS" as code_pays, 
	  ni."NATURE" as nature, 
	  ni."PERSISTANC" as persistance, 
	  ni."SALINITE" as salinite, 
	  ni."COMMENT" as commentaire, 
	  ni."ID_P_EAU" as id_p_eau, 
	  ni."ID_C_EAU" as id_c_eau, 
	  ni."ID_ENT_TR" as id_ent_tr, 
	  ni."NOM_P_EAU" as nom_p_eau, 
	  ni."NOM_C_EAU" as nom_c_eau, 
	  ni."NOM_ENT_TR" as nom_ent_tr,		
	st_intersection(t0.geom, the_geom) geom,
	t0.lag_id AS  w_lag_id
	FROM t0
	JOIN france.surface_hydrographique_bdtopo  ni on st_intersects(the_geom,t0.geom)
),
-- t2 splits the layer according into polygons for the parts that are common to t1 and waterbody_unitbv
-- it removes lines and points with the st_buffer trick (which creates NULL geometries for POINTS and LINES)
-- the layer really looks like waterbody_unitbv but we have added some missing parts on the edge of the lagoon
-- Here I'm keeping the names, from t3 I will later only work on geom and get features back using st_intersect
t2 AS(			
	SELECT 
t1.id
,t1.code_hydro
,t1.code_pays
,t1.nature
,t1.persistance
,t1.salinite
,t1.commentaire
,t1.id_p_eau
,t1.id_c_eau
,t1.id_ent_tr
,t1.nom_p_eau
,t1.nom_c_eau
,t1.nom_ent_tr
,t1.w_lag_id
, st_buffer(ST_intersection(t1.geom,w.geom),0.0) geom
 FROM t1 
 JOIN france.waterbody_unitbv w ON ST_intersects(t1.geom, w.geom) 
 WHERE NOT ST_IsEmpty(ST_Buffer(ST_Intersection(t1.geom,w.geom),0.0))
),

-- t3 and t4 only contains a unioned geom so a single line
t3 AS (
SELECT st_union(geom) geom FROM t1
),
t4 AS (
SELECT  
st_union(geom) geom FROM t2
),
-- This is just one line, the difference
-- st_difference gets the difference, it  necessary to use UNION before !!!!
-- we need to pass it two multipolygons otherwise we multiply the edges
t5 AS(
SELECT
 ST_MULTI(ST_difference(t3.geom,t4.geom)) geom
FROM t4,
 t3
),
-- T6 will be one line per polygon we split the multipolygon created at previous step
t6 AS (
SELECT  
ST_GeometryN(geom, generate_series(1, ST_NumGeometries(geom))) AS geom
FROM t5),
-- we remove small polygons
t7 AS(
SELECT * FROM t6 WHERE st_area(geom)>500
)
-- finally we get back the ids from t2
SELECT id
,code_hydro
,code_pays
,nature
,persistance
,salinite
,commentaire
,id_p_eau
,id_c_eau
,id_ent_tr
,nom_p_eau
,nom_c_eau
,nom_ent_tr
,NULL AS idsegment
,w_lag_id
, t7.geom
FROM t7 
JOIN t2 ON st_intersects(t2.geom,t7.geom)
);

INSERT INTO france.waterbody_unitbv (
id
,code_hydro
,code_pays
,nature
,persistance
,salinite
,commentaire
,id_p_eau
,id_c_eau
,id_ent_tr
,nom_p_eau
,nom_c_eau
,nom_ent_tr
,idsegment
,w_lag_id,
geom) SELECT id
,code_hydro
,code_pays
,nature
,persistance
,salinite
,commentaire
,id_p_eau
,id_c_eau
,id_ent_tr
,nom_p_eau
,nom_c_eau
,nom_ent_tr
,idsegment
,w_lag_id,
geom FROM temp_vic;--1


------------------------------------------
-- Ingril 19
--------------------------------------------

DROP TABLE IF EXISTS temp_ingril;
CREATE TABLE temp_ingril AS(	
-- t0 selects the lagoon from tr_lagoon according to number
WITH t0 AS(
	SELECT lag_id,st_transform(lag_polygone, 3035) AS geom  FROM france.tr_lagunes WHERE lag_id=19),
-- t1 will get all elements from original bd_topo (including all missing parts)
t1 AS (
SELECT 
	  ni."ID" as id, 
	  ni."CODE_HYDRO" as code_hydro, 
	  ni."CODE_PAYS" as code_pays, 
	  ni."NATURE" as nature, 
	  ni."PERSISTANC" as persistance, 
	  ni."SALINITE" as salinite, 
	  ni."COMMENT" as commentaire, 
	  ni."ID_P_EAU" as id_p_eau, 
	  ni."ID_C_EAU" as id_c_eau, 
	  ni."ID_ENT_TR" as id_ent_tr, 
	  ni."NOM_P_EAU" as nom_p_eau, 
	  ni."NOM_C_EAU" as nom_c_eau, 
	  ni."NOM_ENT_TR" as nom_ent_tr,		
	st_intersection(t0.geom, the_geom) geom,
	t0.lag_id AS  w_lag_id
	FROM t0
	JOIN france.surface_hydrographique_bdtopo  ni on st_intersects(the_geom,t0.geom)
),
-- t2 splits the layer according into polygons for the parts that are common to t1 and waterbody_unitbv
-- it removes lines and points with the st_buffer trick (which creates NULL geometries for POINTS and LINES)
-- the layer really looks like waterbody_unitbv but we have added some missing parts on the edge of the lagoon
-- Here I'm keeping the names, from t3 I will later only work on geom and get features back using st_intersect
t2 AS(			
	SELECT 
t1.id
,t1.code_hydro
,t1.code_pays
,t1.nature
,t1.persistance
,t1.salinite
,t1.commentaire
,t1.id_p_eau
,t1.id_c_eau
,t1.id_ent_tr
,t1.nom_p_eau
,t1.nom_c_eau
,t1.nom_ent_tr
,t1.w_lag_id
, st_buffer(ST_intersection(t1.geom,w.geom),0.0) geom
 FROM t1 
 JOIN france.waterbody_unitbv w ON ST_intersects(t1.geom, w.geom) 
 WHERE NOT ST_IsEmpty(ST_Buffer(ST_Intersection(t1.geom,w.geom),0.0))
),

-- t3 and t4 only contains a unioned geom so a single line
t3 AS (
SELECT st_union(geom) geom FROM t1
),
t4 AS (
SELECT  
st_union(geom) geom FROM t2
),
-- This is just one line, the difference
-- st_difference gets the difference, it  necessary to use UNION before !!!!
-- we need to pass it two multipolygons otherwise we multiply the edges
t5 AS(
SELECT
 ST_MULTI(ST_difference(t3.geom,t4.geom)) geom
FROM t4,
 t3
),
-- T6 will be one line per polygon we split the multipolygon created at previous step
t6 AS (
SELECT  
ST_GeometryN(geom, generate_series(1, ST_NumGeometries(geom))) AS geom
FROM t5),
-- we remove small polygons
t7 AS(
SELECT * FROM t6 WHERE st_area(geom)>500
)
-- finally we get back the ids from t2
SELECT id
,code_hydro
,code_pays
,nature
,persistance
,salinite
,commentaire
,id_p_eau
,id_c_eau
,id_ent_tr
,nom_p_eau
,nom_c_eau
,nom_ent_tr
,NULL AS idsegment
,w_lag_id
, t7.geom
FROM t7 
JOIN t2 ON st_intersects(t2.geom,t7.geom)
);--10

INSERT INTO france.waterbody_unitbv (
id
,code_hydro
,code_pays
,nature
,persistance
,salinite
,commentaire
,id_p_eau
,id_c_eau
,id_ent_tr
,nom_p_eau
,nom_c_eau
,nom_ent_tr
,idsegment
,w_lag_id,
geom) SELECT id
,code_hydro
,code_pays
,nature
,persistance
,salinite
,commentaire
,id_p_eau
,id_c_eau
,id_ent_tr
,nom_p_eau
,nom_c_eau
,nom_ent_tr
,idsegment
,w_lag_id,
geom FROM temp_ingril;--10


/*
 * Bages-Sigean : 3800 ha , 97% de males, stock argentées: 1 120 112 - 1 259 509 argentées (30-34 kg/ha ou 294-331 anguilles/ha) : 80% s'échapperaient en mer
 * FR23750
 * * Or , 3170 ha, 67% de males, stock argentées: 180 290 (156 298 - 204 281) argentées (13.19 kg/ha ou 56 anguilles/ha): 77% s’échappent en mer

 */

/*
 *  Production des lagunes méditerranéenes
 */

SELECT * FROM france.waterbody_unitbv wu 
JOIN france.tr_lagunes l ON l.lag_id=wu.lag_id
JOIN france.rne ON wu.ubv_idsegment = rne.idsegment




WITH jj AS (
SELECT DISTINCT ON (ubv_idsegment) neel, beel, nsilver,bsilver,lag_complexepeche  FROM france.waterbody_unitbv wu 
JOIN france.tr_lagunes l ON l.lag_id=wu.lag_id
JOIN france.rne ON wu.ubv_idsegment = rne.idsegment)
SELECT  lag_complexepeche, round(sum(neel)) neel, round(sum(beel)) beel, round(sum(nsilver)) nsilver, round(sum(bsilver)) bsilver 
FROM jj
GROUP BY lag_complexepeche;


-- Elsa me demande le périmètres des lagunes 
SELECT lag_nom,lag_prudhomie,st_perimeter(lag_polygone), lag_zif_nom FROM france.tr_lagunes AS tl 
SELECT lag_nom,lag_prudhomie,st_perimeter(st_transform(lag_polygone, 3035)), lag_zif_nom FROM france.tr_lagunes AS tl ORDER BY lag_nom

SELECT lag_nom,lag_prudhomie, lag_zif_nom,  st_perimeter(st_union(lag_polygone)) FROM france.tr_lagunes AS tl GROUP BY lag_nom,lag_prudhomie, lag_zif_nom;
SELECT lag_nom,lag_prudhomie, lag_zif_nom,  st_perimeter(st_dump(lag_polygone).geom) FROM france.tr_lagunes AS tl GROUP BY lag_nom,lag_prudhomie, lag_zif_nom;

-- surface des zones qui ne sont pas dans les lagunes (qui vont être rattachées de manière fausse aux lagunes)
-- calculer le pourcentage de surface par type
-- convertir canal ecoulement naturel dans les types eda 
-- surface lagune actuelle,
-- surface rajoutée

WITH idsegmentlagune AS (
SELECT DISTINCT ubv_idsegment, lag_id AS lag_id_o FROM 
france.waterbody_unitbv
WHERE lag_id IS NOT null)

SELECT sum(st_area(geom))/10^6, lag_id_o, nature, wu.ubv_idsegment FROM france.waterbody_unitbv AS wu 
JOIN idsegmentlagune ON (wu.ubv_idsegment = idsegmentlagune.ubv_idsegment)
WHERE lag_id IS null
GROUP BY lag_id_o, nature, wu.ubv_idsegment


