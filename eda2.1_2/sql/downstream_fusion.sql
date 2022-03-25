-- Function: downstream(integer)

-- DROP FUNCTION downstream(integer);

CREATE OR REPLACE FUNCTION downstream(integer)
 RETURNS geometry AS
$BODY$WITH RECURSIVE walk_network(drain_amont, nextdownid, geom) AS (
   SELECT id_drain, nextdownid, geom FROM ref.rht_lcv WHERE id_drain = $1 -- Selection du drain amont sur la table RHT
 UNION ALL
   SELECT n.id_drain, n.nextdownid, n.geom -- Champs de la table RHT
   FROM ref.rht_lcv n, walk_network w
   WHERE w.nextdownid = n.id_drain -- Selection récursive des drains suivants jusqu'à la fin du reseau (drain à la mer)
 )
SELECT ST_Union(geom) -- Union des géométries sélectionées pour créer une multipolyligne unique
FROM walk_network$BODY$
 LANGUAGE sql IMMUTABLE
 COST 100;
ALTER FUNCTION downstream(integer)
 OWNER TO logrami;
COMMENT ON FUNCTION downstream(integer) IS 'Fonction récursive pour sélectionner les drains en aval d''un drain du réseau RHT identifié par id_drain.
Utilisation : SELECT downstream(id_drain)';
--===========================
-- Version entre deux drains :
-- Function: downstream(integer, integer)

-- DROP FUNCTION downstream(integer, integer);

CREATE OR REPLACE FUNCTION downstream(
   integer,
   integer)
 RETURNS geometry AS
$BODY$
WITH RECURSIVE walk_network(drain_amont, nextdownid, geom) AS (
SELECT id_drain, nextdownid, geom FROM ref.rht_lcv WHERE id_drain = $1  -- Selection du drain amont sur la table RHT
UNION 
SELECT id_drain, NULL, geom FROM ref.rht_lcv WHERE id_drain = $2  -- Selection du drain aval avec nextdownid NULL pour arrêter le chaînage
UNION ALL
  SELECT n.id_drain, n.nextdownid, n.geom
  FROM ref.rht_lcv n, walk_network w
  WHERE w.nextdownid = n.id_drain AND (w.nextdownid != $2 OR w.nextdownid IS NULL) -- Selection récursive des drains suivants, sauf le drain aval
)
SELECT ST_Union(geom) -- Union des géométries sélectionées pour créer une multipolyligne unique
FROM walk_network$BODY$
 LANGUAGE sql IMMUTABLE
 COST 100;
ALTER FUNCTION downstream(integer, integer)
 OWNER TO logrami;
COMMENT ON FUNCTION downstream(integer, integer) IS 'Fonction récursive pour sélectionner les drains entre deux drains du réseau RHT identifiés par id_drain.
Utilisation : SELECT downstream(drain_amont, drain_aval)';
