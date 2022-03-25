drop table if exists bd_carthage2011.toponymerht;
---coupe les troncons par bassins, et leur ajoute le toponyme de la région qui intersecte la plus grande part d'un tronçon hydrographique
-- ne garde pour un id_drain que celui qui est le plus long (distinct on et order by)...
-- NOTE: we are only keeping intersections that result in a LINESTRING or MULTILINESTRING because we don't
-- care about trails that just share a point
-- the dump is needed to expand a geometry collection into individual single MULT* parts
-- the below is fairly generic and will work for polys, etc. by just changing the where clause

create table bd_carthage2011.toponymerht as(
SELECT distinct on (id_drain) * FROM(
	SELECT id_drain, 
		c_ss_sect,
		libelle,
		lib_sect,
		lib_region,
		st_length(clipped_geom) as lengthclipped
	FROM (SELECT id_drain, 
		c_ss_sect,
		libelle,
		lib_sect,
		lib_region,
		(ST_Dump(ST_Intersection(ss.the_geom, rhtvs2.the_geom))).geom As clipped_geom
		FROM bd_carthage2011.sous_secteur ss
		INNER JOIN rht.rhtvs2
		ON ST_Intersects(ss.the_geom, rhtvs2.the_geom))  As clipped
	WHERE ST_Dimension(clipped.clipped_geom) = 1 ) AS sub
order by id_drain, lengthclipped DESC); -- la clause distinct on doit etre reprise dans l'expression order by la plus à gauche
alter table bd_carthage2011.toponymerht drop column lengthclipped;
alter table bd_carthage2011.toponymerht add column lb boolean;

update bd_carthage2011.toponymerht set lb=TRUE where id_drain in (
SELECT * FROM dblink('dbname=ouvragelb host=localhost user=postgres password=petromyzon55***',
                'SELECT  id_drain from rht.rhtvs2_loirebretagne_full')
            AS (id_drain integer));
alter table bd_carthage2011.toponymerht set schema rht;
/*            
pg_dump -U postgres -h w3.eptb-vilaine.fr --table rht.toponymerht eda2.1|psql -U postgres -h w3.eptb-vilaine.fr ouvragelb
*/

-- dans la base ouvragelb
--drop table rht.toponymerht;
--alter table toponymerht set schema rht;
delete from rht.toponymerht where lb is NULL; --80266
select count(*) from rht.toponymerht; --34156
select count(*) from rht.rhtvs2_loirebretagne_full; --34198